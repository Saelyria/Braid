import UIKit
import Tableau

class HomeViewController: UIViewController {
    private var tableView: UITableView!
    private var binder: TableViewBinder!
    
    private var rows: [TitleDetailTableViewCell.ViewModel] = [
        TitleDetailTableViewCell.ViewModel(
            title: "Sample 1 - Accounts",
            subtitle: "",
            detail: ""),
        TitleDetailTableViewCell.ViewModel(
            title: "Sample 2 - Artists & Songs",
            subtitle: "",
            detail: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.view.frame, style: .plain)
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = TableViewBinder(tableView: self.tableView)
        
        self.binder.onTable()
            .bind(cellType: TitleDetailTableViewCell.self, viewModels: self.rows)
            .onTapped { (row, _) in
                switch row {
                case 0:
                    self.navigationController?.pushViewController(AccountsViewController(), animated: true)
                case 1:
                    self.navigationController?.pushViewController(AccountsViewController(), animated: true)
                default:
                    break
                }
            }
    }
}
