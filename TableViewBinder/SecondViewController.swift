import UIKit
import RxSwift

struct Person {
    let name: String
    let age: Int
}

class SecondViewController: UIViewController {
    enum Section: TableViewSection {
        case friends
        case enemies

        static let allSections: [Section] = [.friends, .enemies]
    }

    @IBOutlet private weak var tableView: UITableView!
    private var tableViewBinder: SectionedTableViewBinder<Section>!
    
    let friends = Variable<[Person]>([
        Person(name: "John", age: 32),
        Person(name: "Mary", age: 50),
        Person(name: "Nabil", age: 18)
    ])
    let enemies = Variable<[Person]>([
        Person(name: "Matt", age: 26)
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(TableViewCell.self)
        
        // here we're going to set the table view binder up with raw `Person` models. To do this, we:
        self.tableViewBinder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.tableViewBinder
            .onSections([.friends, .enemies]) // declare the sections we're binding on
            .bind(
                cellType: TableViewCell.self, // give a cell type
                models: [
                    .friends: self.friends.asObservable(), // give a dictionary to specify the observable models for each section
                    .enemies: self.enemies.asObservable()
                ],
                mapToViewModelsWith: { person in // then give a function to map those models into the cell's view model.
                    return TableViewCell.ViewModel(title: person.name, subtitle: String(person.age))
                }
            )
            // now the tapped handler can be passed in the associated model (i.e. `Person`).
            .onTapped { [weak self] (section: Section, row: Int, cell: TableViewCell, model: Person) in
                print("Cell tapped in section '\(section)' at row \(row). The cell is a '\(String(describing: cell))' and the person's name is \(model.name).")
                self?.dismiss(animated: true, completion: nil)
            }
        
        self.tableViewBinder
            .onSection(.friends)
            .headerTitle(.just("FRIENDS"))
        
        self.tableViewBinder
            .onSection(.enemies)
            .headerTitle(.just("ENEMIES"))
    }

    deinit {
        print("no retain cycles!")
    }
}
