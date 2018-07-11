import UIKit
import Tableau

class HomeViewController: UIViewController {
    private enum Section: TableViewSection {
        case accounts
        case bills
        case info
    }
    
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!
    
    private var rows: [Section: [TitleDetailTableViewCell.ViewModel]] = [
        .accounts: [
            TitleDetailTableViewCell.ViewModel(title: "1", subtitle: "", detail: ""),
            TitleDetailTableViewCell.ViewModel(title: "2", subtitle: "", detail: ""),
            TitleDetailTableViewCell.ViewModel(title: "3", subtitle: "", detail: "")
        ],
        .bills: [
            TitleDetailTableViewCell.ViewModel(title: "4", subtitle: "", detail: ""),
            TitleDetailTableViewCell.ViewModel(title: "5", subtitle: "", detail: "")
        ],
        .info: [
            TitleDetailTableViewCell.ViewModel(title: "6", subtitle: "", detail: "")
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.view.addSubview(self.tableView)
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [.accounts, .bills, .info])
        self.binder.onSections([.accounts, .bills, .info])
            .bind(cellType: TitleDetailTableViewCell.self, viewModels: self.rows)
            .onTapped { (section: Section, row: Int, cell: TitleDetailTableViewCell) in

            }
        self.tableView.reloadData()
    }
}
