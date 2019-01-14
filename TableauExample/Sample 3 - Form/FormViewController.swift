import UIKit
import Tableau

class FormViewController: UIViewController {
    // 1.
    enum Section: Int, TableViewSection, Comparable {
        case titleAndLocation
        case time
        case notes
    }
    
    // 2.
    enum FormItem: String, CollectionIdentifiable {
        case title
        case location
        case isAllDay
        case date
        case startTime
        case endTime
        case url
        case notes
        
        enum CellModel {
            case textField(title: String, entry: TextFieldTableViewCell.TextFieldEntryType)
            case toggle(title: String, isOn: Bool)
            case textView(placeholder: String, numberOfLines: Int)
        }
    }
    
    // 3.
    private var displayedFormItems: [Section: [FormItem]] {
        let titleLocationItems: [FormItem] = [.title, .location]
        let timeItems: [FormItem] = (self.formData.isAllDay) ?
            [.isAllDay, .date]
            : [.isAllDay, .date, .startTime, .endTime]
        let notesItems: [FormItem] = [.url, .notes]
        
        return [
            .titleAndLocation: titleLocationItems,
            .time: timeItems,
            .notes: notesItems
        ]
    }
    
    private var binder: SectionedTableViewBinder<Section>!
    // 4.
    private var formData = FormData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Event"
        
        let tableView = UITableView(frame: self.view.frame, style: .grouped)
        tableView.allowsSelection = false
        tableView.register(ToggleTableViewCell.self)
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(TextViewTableViewCell.self)
        self.view.addSubview(tableView)
        
        self.binder = SectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoData
        
        // 4.
        self.binder.onAllSections()
            .bind(
                models: { [unowned self] in return self.displayedFormItems },
                cellProvider: { [unowned self] tableView, _, _, formItem in
                    return self.dequeueCell(forFormItem: formItem, tableView: tableView)
                })
        
        // 5.
        self.binder.onSections(.titleAndLocation)
            .assuming(modelType: FormItem.self)
            .onEvent(from: TextFieldTableViewCell.self) { [unowned self] _, _, _, event, formItem in
                switch (event, formItem) {
                case (.textEntered(let text), .title):
                    self.formData.title = text
                case (.textEntered(let text), .location):
                    self.formData.location = text
                default: break
                }
            }
        
        // 6.
        self.binder.onSection(.time)
            .assuming(modelType: FormItem.self)
            .onEvent(from: ToggleTableViewCell.self) { [unowned self] _, _, event in
                switch event {
                case .switchToggled(let state):
                    self.formData.isAllDay = state
                    self.binder.refresh()
                }
            }
        
        // 7.
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
        
        self.binder.finish()
    }
    
    private func dequeueCell(forFormItem formItem: FormItem, tableView: UITableView) -> UITableViewCell {
        let cellModel: FormItem.CellModel
        switch formItem {
        case .title:
            cellModel = .textField(title: "Event name", entry: .keyboard)
        case .location:
            cellModel = .textField(title: "Location", entry: .keyboard)
        case .isAllDay:
            cellModel = .toggle(title: "All-day", isOn: self.formData.isAllDay)
        case .date:
            cellModel = .textField(title: "Date", entry: .datePicker)
        case .startTime:
            cellModel = .textField(title: "Start time", entry: .timePicker)
        case .endTime:
            cellModel = .textField(title: "End time", entry: .timePicker)
        case .url:
            cellModel = .textView(placeholder: "URL", numberOfLines: 1)
        case .notes:
            cellModel = .textView(placeholder: "Notes", numberOfLines: 5)
        }
        
        switch cellModel {
        case .textField(let title, let entryType):
            let cell = tableView.dequeue(TextFieldTableViewCell.self)
            cell.title = title
            cell.entryType = entryType
            return cell
        case .textView(let placeholder, _):
            let cell = tableView.dequeue(TextViewTableViewCell.self)
            cell.placeholder = placeholder
            return cell
        case .toggle(let title, let isOn):
            let cell = tableView.dequeue(ToggleTableViewCell.self)
            cell.isOn = isOn
            cell.title = title
            return cell
        }
    }
}
