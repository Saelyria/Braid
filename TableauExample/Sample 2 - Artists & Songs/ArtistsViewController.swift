import Tableau

class ArtistsViewController: UIViewController {
    struct Section: TableViewSection {
        let title: String
    }
    
    private let tableView = UITableView()
    private var binder: SectionedTableViewBinder<Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
    }
}
