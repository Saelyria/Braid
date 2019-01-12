import UIKit
import Tableau

class SamplesViewController: UIViewController {
    private var tableView: UITableView!
    private var binder: TableViewBinder!

    private var rows: [TitleDetailTableViewCell.ViewModel] = [
        TitleDetailTableViewCell.ViewModel(
            collectionId: "1",
            title: "Sample 1 - Accounts",
            subtitle: "A mock 'accounts' view like you might find in a banking app.",
            detail: "",
            accessoryType: .disclosureIndicator),
        TitleDetailTableViewCell.ViewModel(
            collectionId: "2",
            title: "Sample 2 - Artists & Songs",
            subtitle: "A mock 'artists' view like you might find in a music app.",
            detail: "",
            accessoryType: .disclosureIndicator),
        TitleDetailTableViewCell.ViewModel(
            collectionId: "3",
            title: "Sample 3 - Form",
            subtitle: "A form view demonstrating use of custom cell events.",
            detail: "",
            accessoryType: .disclosureIndicator),
        TitleDetailTableViewCell.ViewModel(
            collectionId: "4",
            title: "Sample 4 - News Feed",
            subtitle: "A news feed demonstrating infinite scrolling with data prefetching.",
            detail: "",
            accessoryType: .disclosureIndicator),
        TitleDetailTableViewCell.ViewModel(
            collectionId: "5",
            title: "Sample 5 - Home Page",
            subtitle: "A dynamic home page whose section information is given in a server response.",
            detail: "",
            accessoryType: .disclosureIndicator)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Samples"
        
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.view.addSubview(self.tableView)
        self.tableView.register(TitleDetailTableViewCell.self)
        
        self.binder = TableViewBinder(tableView: self.tableView)
        
        self.binder.onTable()
            .bind(cellType: TitleDetailTableViewCell.self, viewModels: { self.rows })
            .onTapped { [unowned self] (row, cell) in
                cell.setSelected(false, animated: true)
                switch row {
                case 0:
                    self.navigationController?.pushViewController(AccountsViewController(), animated: true)
                case 1:
                    self.navigationController?.pushViewController(ArtistsViewController(), animated: true)
                case 2:
                    self.navigationController?.pushViewController(FormViewController(), animated: true)
                case 3:
                    self.navigationController?.pushViewController(NewsFeedViewController(), animated: true)
                case 4:
                    self.navigationController?.pushViewController(HomeViewController(), animated: true)
                default: break
                }
            }
        
        self.binder.finish()
    }
}
