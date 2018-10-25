import Tableau

class HomeViewController: UIViewController {
    struct Section: TableViewSection {
        enum CellType {
            case centeredLabel
            case titleDetail
            case imageDetail
        }
        
        let id: String
        let title: String?
        let cellType: CellType

        var hashValue: Int {
            return self.id.hashValue
        }
        
        static let banner: Section = Section(
            id: "banner", title: nil, cellType: .centeredLabel)
    }
    
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
    }
    
    private func setupTableView() {
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.view.addSubview(self.tableView)
        self.tableView.register(CenterLabelTableViewCell.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [])
        
        self.binder.onSection(.banner)
            .bind(cellType: CenterLabelTableViewCell.self, viewModels: ["<Brand Name>. Shopping made easier."])
        
        self.binder.onAllOtherSections()
            
    }
}
