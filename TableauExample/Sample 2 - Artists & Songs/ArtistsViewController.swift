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
    private var binder: SectionedTableViewBinder<Section>!
    
    private let artists = BehaviorRelay<[Artist]>(value: [])
    private let artistsForSections = BehaviorRelay<[Section: [Artist]]>(value: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        
        self.binder = SectionedTableViewBinder<Section>(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [.message])
        
        self.binder.onSection(.message)
            .bind(cellType: CenterLabelTableViewCell.self, models: [
                "This sample demonstrates a view controller whose sections aren't known at compile time, so can't be expressed by an enum. These sections are instead expressed with a custom struct."])
        
        self.binder.onAllSections()
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.artistsForSections.asObservable(),
                     mapToViewModelsWith: { (artist: Artist) in return artist.asTitleDetailCellViewModel() })
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
}
