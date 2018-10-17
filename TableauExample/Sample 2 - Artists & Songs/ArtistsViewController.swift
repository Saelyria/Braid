import Tableau

fileprivate struct Section: TableViewSection {
    let title: String
}

class ArtistsViewController: UIViewController {
    private let tableView = UITableView()
    private var binder: SectionedTableViewBinder<Section>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
