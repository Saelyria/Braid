import UIKit
import Tableau

class ViewController: UIViewController {
    enum Section: TableViewSection {
        case checking
        case savings
    }

    let tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
    var binder: SectionedTableViewBinder<Section>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [.checking, .savings])
    }
}
