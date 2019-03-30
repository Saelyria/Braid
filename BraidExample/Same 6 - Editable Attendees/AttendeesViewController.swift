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
    private var firstSectionModels: [Person] = []
    private var secondSectionModels: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Attendees"
        
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.view.addSubview(self.tableView)
        
        self.firstSectionModels = [Person(name: "Jonathan"), Person(name: "Omar"), Person(name: "Sara")]
        self.secondSectionModels = [Person(name: "Yvonne"), Person(name: "Kalinda")]
        
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
                  models: { [unowned self] in self.firstSectionModels },
                  mapToViewModels: { TitleDetailTableViewCell.ViewModel(collectionId: $0.collectionId, title: $0.name) })
            .allowEditing(style: .delete)
            .allowMoving(.to(sections: [.invited]))
            .onDelete { row, source in
                switch source {
                case .editing:
                    let model = self.firstSectionModels[row]
                    self.secondSectionModels.append(model)
                default: break
                }
                self.firstSectionModels.remove(at: row)
                self.binder.refresh()
            }
            .onInsert { row, source in
                switch source {
                case let .moved(_, fromRow):
                    let model = self.secondSectionModels[fromRow]
                    self.firstSectionModels.insert(model, at: row)
                    self.binder.refresh()
                default: break
                }
            }
        
        self.binder.onSection(.invited)
            .bind(headerTitle: "INVITED")
            .bind(cellType: TitleDetailTableViewCell.self,
                  models: { [unowned self] in self.secondSectionModels },
                  mapToViewModels: { TitleDetailTableViewCell.ViewModel(collectionId: $0.collectionId, title: $0.name) })
            .allowEditing(style: .insert)
            .allowMoving(.to(sections: [.attending]))
            .onDelete { row, _ in
                self.secondSectionModels.remove(at: row)
                self.binder.refresh()
            }
            .onInsert { row, source in
                switch source {
                case .editing:
                    let model = self.secondSectionModels[row]
                    self.firstSectionModels.append(model)
                    self.secondSectionModels.remove(at: row)
                case let .moved(_, fromRow):
                    let model = self.firstSectionModels[fromRow]
                    self.secondSectionModels.insert(model, at: row)
                }
                self.binder.refresh()
            }
        
        self.binder.finish()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }
    
    @objc private func addButtonPressed() {
        
    }
    
    @objc private func editButtonTapped() {
        tableView.setEditing(!self.tableView.isEditing, animated: true)
        if self.tableView.isEditing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        }
    }
}
