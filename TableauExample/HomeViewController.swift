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
            TitleDetailTableViewCell.ViewModel(title: "3", subtitle: "", detail: ""),
            TitleDetailTableViewCell.ViewModel(title: "1", subtitle: "", detail: "")
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
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TitleDetailTableViewCell")!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "CHECKING"
        case 1: return "SAVINGS"
        default: return "OTHER"
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Footer for checking"
        case 1: return "Footer for savings"
        default: return "Footer for other"
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionInt: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.sectionFooterHeight
    }
}
