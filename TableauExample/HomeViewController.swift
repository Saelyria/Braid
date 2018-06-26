import UIKit
import Tableau

class HomeViewController: UIViewController {
    private enum Section: TableViewSection {
        case accounts
        case bills
        case info
    }
    
    private let tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
    private var binder: SectionedTableViewBinder<Section>!
    
    private var rows: [Section: [TitleDetailTableViewCell.ViewModel]] = [
        .accounts: [
            TitleDetailTableViewCell.ViewModel(title: "", subtitle: "", detail: ""),
            TitleDetailTableViewCell.ViewModel(title: "", subtitle: "", detail: ""),
            TitleDetailTableViewCell.ViewModel(title: "", subtitle: "", detail: "")
        ],
        .bills: [
            TitleDetailTableViewCell.ViewModel(title: "", subtitle: "", detail: ""),
            TitleDetailTableViewCell.ViewModel(title: "", subtitle: "", detail: "")
        ],
        .info: [
            TitleDetailTableViewCell.ViewModel(title: "", subtitle: "", detail: "")
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [])
//        self.binder.onSections([.accounts, .bills, .info])
//            .bind(cellType: TitleDetailTableViewCell.self, byObserving: \.rows, on: self)
//            .onTapped { (section: Section, row: Int, cell: TitleDetailTableViewCell) in
//
//            }
    }
}
