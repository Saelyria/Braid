import UIKit
import Braid
import RxCocoa

class SimpleFormViewController: UIViewController {
    // 4.
    enum Section: Int, TableViewSection, Comparable {
        case first
        case second
        case third
    }
    
    private var binder: SectionedTableViewBinder<Section>!
    private let cellViewModels = BehaviorRelay<[RxTitleDetailTableViewCell.ViewModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Event"
        
        // 6.
        let tableView = UITableView(frame: self.view.frame, style: .grouped)
        tableView.register(RxTitleDetailTableViewCell.self)
        tableView.register(ToggleTableViewCell.self)
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(TextViewTableViewCell.self)
        tableView.register(DatePickerTableViewCell.self)
        self.view.addSubview(tableView)
        
        self.binder = SectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoData
        
        self.binder.onSection(.first)
            .rx.bind(cellType: RxTitleDetailTableViewCell.self, viewModels: self.cellViewModels.asObservable())
            .onTapped { (_, cell) in
                let title = Bool.random() ? "\(cell.viewModel!.collectionId) something" : "\(cell.viewModel!.collectionId) something else"
                cell.viewModel?.title.accept(title)
            }
        
        self.binder.finish()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }
    
    @objc private func addButtonPressed() {
        var new = self.cellViewModels.value.map {
            RxTitleDetailTableViewCell.ViewModel(collectionId: $0.collectionId, title: $0.title.value) }
        let id = "\(self.cellViewModels.value.count+1)"
        let indexToInsert: Int = Int.random(in: 0...self.cellViewModels.value.count)
        new.insert(RxTitleDetailTableViewCell.ViewModel(collectionId: id, title: "\(id) something"), at: indexToInsert)
        self.cellViewModels.accept(new)
    }
}
