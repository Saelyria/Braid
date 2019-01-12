import UIKit
import Tableau

class FormViewController: UIViewController {
    enum Section: Int, TableViewSection, Comparable {
        case titleAndLocation
        case time
        case notes
    }
    
    enum FormItem: String, CollectionIdentifiable {
        case title
        case location
        case isAllDay
        case date
        case startTime
        case endTime
        case url
        case notes
    }
    
    private var displayedFormItems: [Section: [FormItem]] = [
        .titleAndLocation: [
            .title,
            .location
        ],
        .time: [
            .isAllDay,
            .date,
            .startTime,
            .endTime
        ],
        .notes: [
            .url,
            .notes
        ]
    ]
    private var binder: SectionedTableViewBinder<Section>!
    private var formData = FormData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Event"
        
        let tableView = UITableView(frame: self.view.frame, style: .grouped)
        tableView.register(ToggleTableViewCell.self)
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(TextViewTableViewCell.self)
        self.view.addSubview(tableView)
        
        self.binder = SectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoData
        
        self.binder.onAllSections()
            .bind(
                models: { [unowned self] in return self.displayedFormItems },
                cellProvider: { [unowned self] tableView, _, _, formItem in
                    return self.dequeueCell(forCellType: formItem.cellType, tableView: tableView)
                })
            
        self.binder.onSection(.titleAndLocation)
            .assuming(modelType: FormItem.self)
            .onEvent(from: TextFieldTableViewCell.self) { [unowned self] _, cell, event, formItem in
                switch (event, formItem) {
                case (.textEntered(let text), .title):
                    self.formData.title = text
                case (.textEntered(let text), .location):
                    self.formData.location = text
                default: break
                }
            }
        
        self.binder.onSection(.time)
            .onEvent(from: ToggleTableViewCell.self) { [unowned self] _, cell, event in
                switch event {
                case .switchToggled(let state):
                    self.formData.isAllDay = state
                    if self.formData.isAllDay {
                        self.displayedFormItems[.time] = [
                            .isAllDay,
                            .date]
                    } else {
                        self.displayedFormItems[.time] = [
                            .isAllDay,
                            .date,
                            .startTime,
                            .endTime]
                    }
                    self.binder.refresh()
                }
            }
        
        self.binder.onSection(.notes)
            .assuming(modelType: FormItem.self)
            .onEvent(from: TextViewTableViewCell.self) { [unowned self] _, _, event, formItem in
                switch (event, formItem) {
                case (.textEntered(let text), .url):
                    self.formData.url = text
                case (.textEntered(let text), .notes):
                    self.formData.notes = text
                default: break
                }
            }
        
        self.binder.onAnySection()
            .onCellDequeue { (_, _, cell) in
                cell.selectionStyle = .none
            }
        
        self.binder.finish()
    }
    
    private func dequeueCell(forCellType cellType: FormItem.CellType, tableView: UITableView) -> UITableViewCell {
        switch cellType {
        case .textField(let title, let entryType):
            let cell = tableView.dequeue(TextFieldTableViewCell.self)
            cell.title = title
            cell.entryType = entryType
            return cell
        case .textView(let placeholder, _):
            let cell = tableView.dequeue(TextViewTableViewCell.self)
            cell.placeholder = placeholder
            return cell
        case .toggle(let title):
            let cell = tableView.dequeue(ToggleTableViewCell.self)
            cell.title = title
            return cell
        }
    }
}

extension FormViewController.FormItem {
    enum CellType {
        case textField(title: String, entry: TextFieldTableViewCell.TextFieldEntryType)
        case toggle(title: String)
        case textView(placeholder: String, numberOfLines: Int)
    }
    
    var cellType: CellType {
        switch self {
        case .title:
            return .textField(title: "Event name", entry: .keyboard)
        case .location:
            return .textField(title: "Location", entry: .keyboard)
        case .isAllDay:
            return .toggle(title: "All-day")
        case .date:
            return .textField(title: "Date", entry: .datePicker)
        case .startTime:
            return .textField(title: "Start time", entry: .timePicker)
        case .endTime:
            return .textField(title: "End time", entry: .timePicker)
        case .url:
            return .textView(placeholder: "URL", numberOfLines: 1)
        case .notes:
            return .textView(placeholder: "Notes", numberOfLines: 5)
        }
    }
    
    var collectionId: String { return self.rawValue }
}
