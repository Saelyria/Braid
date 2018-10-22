import Tableau
import RxSwift
import RxCocoa

struct Artist: Identifiable {
    var id: String { return self.name }
    let name: String
}

class ArtistsViewController: UIViewController {
    struct Section: TableViewSection {
        let id: String
        let title: String?
        
        static let message: Section = Section(id: "Message", title: nil)
    }
    
    private let tableView = UITableView()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var binder: SectionedTableViewBinder<Section>!
    
    private let disposeBag = DisposeBag()
    
    private let artistsForSections = BehaviorRelay<[Section: [Artist]]>(value: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Artists"
        
        self.setupOtherViews()
        self.setupTableView()
        
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
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        self.tableView.register(CenterLabelTableViewCell.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = SectionedTableViewBinder<Section>(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [.message])
        
        self.binder.onSection(.message)
            .bind(cellType: CenterLabelTableViewCell.self, models: [
                "This sample demonstrates a view controller whose sections aren't known at compile time, so can't be expressed by an enum. These sections are instead expressed with a custom struct."])
        
        self.binder.onAllSections()
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.artistsForSections.asObservable(),
                     mapToViewModelsWith: { (artist: Artist) in return artist.asTitleDetailCellViewModel() })
//            .rx.headerTitles()
        
        self.binder.finish()
        
        self.artistsForSections
            .flatMap { (dict: [Section: [Artist]]) -> Observable<[Section]> in
                return Observable.just(Array(dict.keys))
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
            .debug()
            .flatMapToSectionDict()
            .debug()
            .do(onNext: { [unowned self] _ in
                self.spinner.stopAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            })
            .bind(to: self.artistsForSections)
            .disposed(by: self.disposeBag)
    }
}

fileprivate extension Artist {
    func asTitleDetailCellViewModel() -> TitleDetailTableViewCell.ViewModel {
        return TitleDetailTableViewCell.ViewModel(
            id: self.name,
            title: self.name,
            subtitle: "",
            detail: "",
            accessoryType: .disclosureIndicator)
    }
    
    var firstLetter: String {
        let nameNoArticle: String = (self.name.lowercased().starts(with: "the ")) ? String(self.name.dropFirst(4)) : self.name
        return String(nameNoArticle.first!)
    }
}

fileprivate extension Observable where Element == [Artist] {
    typealias Section = ArtistsViewController.Section
    
    func flatMapToSectionDict() -> Observable<[Section: [Artist]]> {
        return self.flatMap { (artists: [Artist]) -> Observable<[Section: [Artist]]> in
            var artistsForSections: [Section: [Artist]] = [:]
            for artist in artists {
                let section = Section(id: artist.firstLetter, title: artist.firstLetter)
                if artistsForSections[section] == nil {
                    artistsForSections[section] = []
                }
                artistsForSections[section]?.append(artist)
            }
            return Observable<[Section: [Artist]]>.just(artistsForSections)
        }
    }
}
