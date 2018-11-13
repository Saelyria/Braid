import Tableau
import RxSwift
import RxCocoa

class ArtistsViewController: UIViewController {
    // 1.
    struct Section: TableViewSection, Comparable {
        let title: String
        
        static func < (lhs: ArtistsViewController.Section, rhs: ArtistsViewController.Section) -> Bool {
            return lhs.title < rhs.title
        }
    }
    
    private let tableView = UITableView()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var binder: SectionedTableViewBinder<Section>!
    
    private let disposeBag = DisposeBag()
    
    // 2.
    private let artistsForSections = BehaviorRelay<[Section: [Artist]]>(value: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Artists"
        
        // 3.
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        self.tableView.tableFooterView = UIView()
        self.tableView.sectionFooterHeight = 0.0
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = SectionedTableViewBinder(
            tableView: self.tableView, sectionedBy: Section.self, sectionDisplayBehavior: .hidesSectionsWithNoCellData)
        
        // 4.
        self.binder.onAllSections()
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.artistsForSections.asObservable(),
                     mapToViewModelsWith: { (artist: Artist) in return artist.asTitleDetailCellViewModel() })
            // 5.
            .rx.bind(headerTitles: self.artistsForSections.asObservable()
                .map { (artistsForSections: [Section: [Artist]]) -> [Section: String?] in
                    var titles: [Section: String?] = [:]
                    artistsForSections.forEach { titles[$0.key] = $0.key.title }
                    return titles
            })
        
        self.binder.finish()
        
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

private extension Artist {
    /// Maps the 'artist' into a view model for a 'title detail cell'
    func asTitleDetailCellViewModel() -> TitleDetailTableViewCell.ViewModel {
        return TitleDetailTableViewCell.ViewModel(
            collectionId: self.name,
            title: self.name,
            subtitle: "",
            detail: "",
            accessoryType: .disclosureIndicator)
    }
}

private extension Observable where Element == [String: [Artist]] {
    typealias Section = ArtistsViewController.Section
    
    /// Flat maps an observable dictionary of artists into a dictionary of the artists sorted into sections, where each
    /// section is artists that start with the same letter
    func flatMapToSectionDict() -> Observable<[Section: [Artist]]> {
        return self.flatMap { (artists: [String: [Artist]]) -> Observable<[Section: [Artist]]> in
            var artistsInSections: [Section: [Artist]] = [:]
            artists.forEach({ (key, value) in
                let section = Section(title: key)
                artistsInSections[section] = value
            })
            return Observable<[Section: [Artist]]>.just(artistsInSections)
        }
    }
}
