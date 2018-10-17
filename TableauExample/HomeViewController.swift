import UIKit
import Tableau

class HomeViewController: UIViewController {
    private var tableView: UITableView!
    private var binder: TableViewBinder!
    
    private var rows: [TitleDetailTableViewCell.ViewModel] = [
        TitleDetailTableViewCell.ViewModel(
            id: "1",
            title: "Sample 1 - Accounts",
            subtitle: "A mock 'accounts' view like you might find in a banking app. This view controller demonstrates hot reloading of sections and rows using RxSwift.",
            detail: "",
            accessoryType: .disclosureIndicator),
        TitleDetailTableViewCell.ViewModel(
            id: "2",
            title: "Sample 2 - Artists & Songs",
            subtitle: "A mock 'artists' view like you might find in a music app. This view controller demonstrates how to use a struct to represent sections instead of an enum for cases where you don't know the sections at compile-time, like when section data is provided via a network response.",
            detail: "",
            accessoryType: .disclosureIndicator)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Samples"
        
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
        
        self.binder.finish()
    }
}
