import UIKit
import RxSwift

class ViewController: UIViewController {
    enum Section: TableViewSection {
        case section1
        case section2
        case section3
        case section4

        static let allSections: [Section] = [.section1, .section2, .section3, .section4]
    }

    @IBOutlet private weak var tableView: UITableView!
    private var tableViewBinder: SectionedTableViewBinder<Section>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("First VC loaded")
        
        // cell registration is easy - the Nib and reuse identifier are created from the cell's `UINibInitable` and
        // `ReuseIdentifiable` conformance automatically.
        self.tableView.register(TableViewCell.self)
        
        // here we set the binder up using cell view models. To do this, we:
        self.tableViewBinder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.tableViewBinder
            .onSections([.section1, .section2]) // declare the sections we're binding
            .bind(
                cellType: TableViewCell.self, // give a cell type
                viewModels: [
                    .section1: .just([ // then give a dictionary to specify the array of view models for each section.
                        TableViewCell.ViewModel(title: "Title", subtitle: "Subtitle")
                    ]),
                    .section2: .just([
                        TableViewCell.ViewModel(title: "Title", subtitle: "Subtitle"),
                        TableViewCell.ViewModel(title: "Title", subtitle: "Subtitle")
                    ])
                ]
            )
            // Then we can specify a number of handlers, like 'on tapped':
            .onTapped { [weak self] (section: Section, row: Int, cell: TableViewCell) in
                let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
                self?.present(secondVC, animated: true, completion: nil)
            }
            // or 'on dequeue', among others.
            .onCellDequeue { (section: Section, row: Int, cell: TableViewCell) in
                
            }
    }
}
