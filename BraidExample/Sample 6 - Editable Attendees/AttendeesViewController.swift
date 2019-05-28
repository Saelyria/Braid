import Braid
import UIKit

struct Person: Equatable, CollectionIdentifiable {
    var collectionId: String {
        return self.name
    }
    var name: String
}

class AttendeesViewController: UIViewController {
    enum Section: Int, TableViewSection, Comparable {
        case description
        case attending
        case invited
    }
    
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!
    private var peopleAttending: [Person] = []
    private var peopleInvited: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Attendees"
        
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.view.addSubview(self.tableView)
        self.tableView.setEditing(true, animated: false)
        
        self.peopleAttending = [Person(name: "Jonathan"), Person(name: "Omar"), Person(name: "Sara")]
        self.peopleInvited = [Person(name: "Yvonne"), Person(name: "Kalinda")]
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoData
        
        self.binder.onSection(.description)
            .bind(cellType: TitleDetailTableViewCell.self, viewModels: {
                [TitleDetailTableViewCell.ViewModel(
                    collectionId: "1",
                    title: "Christa's Party",
                    subtitle: "We'll start the night at Sneaky Dee's, then head over to Christa's around 7.")]
            })
        
        self.binder.onSection(.attending)
            .allowEditing(style: .delete)
        
        self.binder.onSections(.attending, .invited)
            .bind(cellType: TitleDetailTableViewCell.self,
                  models: { [unowned self] in [.attending: self.peopleAttending, .invited: self.peopleInvited] },
                  mapToViewModels: { TitleDetailTableViewCell.ViewModel(collectionId: $0.collectionId, title: $0.name)})
            .bind(headerTitles: [.attending: "ATTENDING", .invited: "INVITED"])
            .allowMoving(.toSectionsIn([.attending, .invited]))
            .onInsert { section, row, reason, person in
                switch section {
                case .attending:
                    self.peopleAttending.insert(person!, at: row)
                case .invited:
                    self.peopleInvited.insert(person!, at: row)
                default: break
                }
            }
            .onDelete { section, row, reason, person in
                switch section {
                case .attending:
                    switch reason {
                    case .editing:
                        self.peopleInvited.insert(person, at: 0)
                    default: break
                    }
                    self.peopleAttending.remove(at: row)
                case .invited:
                    self.peopleInvited.remove(at: row)
                default: break
                }
            }
        
        self.binder.finish()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }
    
    @objc private func addButtonPressed() {
        self.peopleAttending.append(Person(name: "Name"))
    }
}
