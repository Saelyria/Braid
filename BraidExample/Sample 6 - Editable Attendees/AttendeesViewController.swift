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
            .bind(headerTitle: "ATTENDING")
            .bind(cellType: TitleDetailTableViewCell.self,
                  models: { [unowned self] in self.peopleAttending },
                  mapToViewModels: { TitleDetailTableViewCell.ViewModel(collectionId: $0.collectionId, title: $0.name) })
            .allowMoving(.to(sections: [.invited]))
            .onDelete { row, _ in
                self.peopleAttending.remove(at: row)
            }
            .onInsert { row, _, model in
                self.peopleAttending.insert(model!, at: row)
            }
        
        self.binder.onSection(.invited)
            .bind(headerTitle: "INVITED")
            .bind(cellType: TitleDetailTableViewCell.self,
                  models: { [unowned self] in self.peopleInvited },
                  mapToViewModels: { TitleDetailTableViewCell.ViewModel(collectionId: $0.collectionId, title: $0.name) })
            .allowMoving(.to(sections: [.attending]))
            .onDelete { row, _ in
                self.peopleInvited.remove(at: row)
            }
            .onInsert { row, _, model in
                self.peopleInvited.insert(model!, at: row)
            }
        
        self.binder.finish()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }
    
    @objc private func addButtonPressed() {
        self.peopleAttending.append(Person(name: "Name"))
    }
}
