import Tableau
import RxSwift
import RxCocoa

/**
 This view controller demonstrates how to use a struct instead of an enum as the section model for more dynamic section
 binding. It's a mock 'artists' view controller - basically the same as the one in the default iOS Music app.
 
 While enums provide better code legibility for more static table views, using a struct has many advantages as well.
 In this example, we decide to use a struct instead of an enum with 26 cases (more if you want to organize by symbol)
 for brevity of code. It also allows us to bind other data to the section model - most notably, the 'title' for the
 section.
 */
class ArtistsViewController: UIViewController {
    // The struct section model. To use a struct, it must declare an `id` property (as part of `Identifiable`
    // conformance) so the  binder can track section insertion/deletion/movement.
    struct Section: TableViewSection {
        let id: String
        let title: String?
    }
    
    private let tableView = UITableView()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var binder: SectionedTableViewBinder<Section>!
    
    private let disposeBag = DisposeBag()
    
    // This is effectively the 'data source' for the table view. This property is observed by the binder, which will
    // update its sections and their data based on the dictionary returned from this.
    private let artistsForSections = BehaviorRelay<[Section: [Artist]]>(value: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Artists"
        
        self.setupTableView()
        self.setupOtherViews()
        
        // after we finish binding our table view, fetch the artists 'from a server'
        self.spinner.startAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        MusicLibraryService.shared.getArtists()
            .flatMapToSectionDict()
            .do(onNext: { [unowned self] _ in
                self.spinner.stopAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            })
            .bind(to: self.artistsForSections)
            .disposed(by: self.disposeBag)
    }
    
    private func setupTableView() {
        // The table view and binder are setup in the same way as when using an enum section model.
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        self.tableView.tableFooterView = UIView()
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = SectionedTableViewBinder<Section>(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [])

        // Create an observable for the section titles, mapped from our 'artists for sections' subject
        let headerTitles = self.artistsForSections
            .asObservable()
            .map { (artistsForSections: [Section: [Artist]]) -> [Section: String?] in
                var titles: [Section: String?] = [:]
                artistsForSections.forEach { titles[$0.key] = $0.key.title }
                return titles
        }
        // When we don't know the sections at compile time like this, we use the `onAllSections` method of the binder.
        // This method binds the data in the binding chain to any current or future sections on the table. It's bound
        // in basically the same way - passing in observable models mapped with a given function.
        self.binder.onAllSections()
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.artistsForSections.asObservable(),
                     mapToViewModelsWith: { (artist: Artist) in return artist.asTitleDetailCellViewModel() })
            .rx.headerTitles(headerTitles)
        
        self.binder.finish()
        
        // Map the 'artists for sections' observable into the displayed sections, bound to the 'displayed sections'
        // control property on the binder.
        self.artistsForSections
            .flatMap { (dict: [Section: [Artist]]) -> Observable<[Section]> in
                let sections = Array(dict.keys)
                    .sorted(by: { $0.id < $1.id })
                return Observable.just(sections)
            }
            .bind(to: self.binder.rx.displayedSections)
            .disposed(by: self.disposeBag)
    }
    
    private func setupOtherViews() {
        self.view.addSubview(self.spinner)
        self.spinner.center = self.view.center
        self.spinner.hidesWhenStopped = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.rx.tap
            .do(onNext: { [unowned self] _ in
                self.spinner.startAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            })
            .flatMap { MusicLibraryService.shared.getArtists() }
            .do(onNext: { [unowned self] _ in
                self.spinner.stopAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            })
            .flatMapToSectionDict()
            .bind(to: self.artistsForSections)
            .disposed(by: self.disposeBag)
    }
}

extension Artist: Identifiable {
    var id: String { return self.name }
    
    /// Maps the 'artist' into a view model for a 'title detail cell'
    func asTitleDetailCellViewModel() -> TitleDetailTableViewCell.ViewModel {
        return TitleDetailTableViewCell.ViewModel(
            id: self.name,
            title: self.name,
            subtitle: "",
            detail: "",
            accessoryType: .disclosureIndicator)
    }
    
    /// The first letter of the artist, accounting for articles.
    var firstLetter: String {
        let nameNoArticle: String = (self.name.lowercased().starts(with: "the ")) ? String(self.name.dropFirst(4)) : self.name
        return String(nameNoArticle.first!)
    }
}

private extension Observable where Element == [Artist] {
    typealias Section = ArtistsViewController.Section
    
    /// Flat maps an observable array of artists into a dictionary of the artists sorted into sections, where each
    /// section is artists that start with the same letter
    func flatMapToSectionDict() -> Observable<[Section: [Artist]]> {
        return self.flatMap { (artists: [Artist]) -> Observable<[Section: [Artist]]> in
            var artistsForSections: [Section: [Artist]] = [:]
            for artist in artists {
                let section = Section(id: artist.firstLetter.capitalized, title: artist.firstLetter.capitalized)
                if artistsForSections[section] == nil {
                    artistsForSections[section] = []
                }
                artistsForSections[section]?.append(artist)
            }
            return Observable<[Section: [Artist]]>.just(artistsForSections)
        }
    }
}
