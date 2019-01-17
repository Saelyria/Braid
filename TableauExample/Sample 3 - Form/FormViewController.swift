import UIKit
import Tableau

class FormViewController: UIViewController {
    // 2.
    enum Section: Int, TableViewSection, Comparable {
        case titleAndLocation
        case time
        case notes
    }
    
    // 3.
    enum FormItem: String, CollectionIdentifiable {
        case title
        case location
        case isAllDay
        case date
        case datePicker
        case startTime
        case startTimePicker
        case endTime
        case endTimePicker
        case url
        case notes
        
        enum CellModel {
            case titleDetail(title: String, detail: String?)
            case textField(title: String, enteredText: String?)
            case toggle(title: String, isOn: Bool)
            case textView(placeholder: String, numberOfLines: Int)
            case datePicker(includeTime: Bool)
        }
    }
    
    // 4.
    private var displayedFormItems: [Section: [FormItem]] {
        let titleLocationItems: [FormItem] = [.title, .location]
        var timeItems: [FormItem] = (self.formData.isAllDay) ?
            [.isAllDay, .date]
            : [.isAllDay, .date, .startTime, .endTime]
        if let activeFormItem = self.activeFormItem {
            switch activeFormItem {
            case .date:
                timeItems.insert(.datePicker, at: timeItems.index(after: timeItems.firstIndex(of: .date)!))
            case .startTime:
                timeItems.insert(.startTimePicker, at: timeItems.index(after: timeItems.firstIndex(of: .startTime)!))
            case .endTime:
                timeItems.insert(.endTimePicker, at: timeItems.index(after: timeItems.firstIndex(of: .endTime)!))
            default: break
            }
        }
        let notesItems: [FormItem] = [.url, .notes]
        
        return [
            .titleAndLocation: titleLocationItems,
            .time: timeItems,
            .notes: notesItems
        ]
    }
    
    private var binder: SectionedTableViewBinder<Section>!
    // 5.
    private var formData = FormData()
    // 6.
    private var activeFormItem: FormItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Event"
        
        let tableView = UITableView(frame: self.view.frame, style: .grouped)
        tableView.register(TitleDetailTableViewCell.self)
        tableView.register(ToggleTableViewCell.self)
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(TextViewTableViewCell.self)
        tableView.register(DatePickerTableViewCell.self)
        self.view.addSubview(tableView)
        
        self.binder = SectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoData
        
        // 7.
        self.binder.onAllSections()
            .bind(
                cellProvider: { [unowned self] tableView, _, _, formItem in
                    return self.dequeueCell(forFormItem: formItem, tableView: tableView)
                }, models: { [unowned self] in
                    return self.displayedFormItems
                })
        
        // 8.
        self.binder.onSections(.titleAndLocation)
            .assuming(modelType: FormItem.self)
            // 9.
            .onEvent(from: TextFieldTableViewCell.self) { [unowned self] _, _, _, event, formItem in
                switch (event, formItem) {
                case (.textEntered(let text), .title):
                    self.formData.title = text
                case (.textEntered(let text), .location):
                    self.formData.location = text
                default: break
                }
            }
        
        // 10.
        self.binder.onSection(.time)
            .assuming(modelType: FormItem.self)
            .onEvent(from: ToggleTableViewCell.self) { [unowned self] _, _, event in
                switch event {
                case .switchToggled(let state):
                    self.formData.isAllDay = state
                    self.activeFormItem = nil
                    self.binder.refresh()
                }
            }
            // 11.
            .onTapped { _, cell, formItem in
                if cell is TitleDetailTableViewCell {
                    if self.activeFormItem == formItem {
                        self.activeFormItem = nil
                    } else {
                        self.activeFormItem = formItem
                    }
                    self.binder.refresh()
                }
            }
//            .onEvent(from: TextFieldTableViewCell.self) { [unowned self] _, _, event, formItem in
//                switch event {
//                case .textEntryStarted:
//                    self.activeFormItem = formItem
//                case .textEntryEnded:
//                    if self.activeFormItem == formItem {
//                        self.activeFormItem = nil
//                    }
//                default: return
//                }
//                self.binder.refresh()
//            }
            .onEvent(from: DatePickerTableViewCell.self) { [unowned self] _, _, event, formItem in
                switch (event, formItem) {
                case (.dateSelected(let date), .datePicker):
                    self.formData.date = date
                case (.dateSelected(let date), .startTimePicker):
                    self.formData.startTime = date
                case (.dateSelected(let date), .endTimePicker):
                    self.formData.endTime = date
                default: break
                }
                self.binder.refresh()
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
            cellModel = .textField(title: "Event name", enteredText: self.formData.title)
        case .location:
            cellModel = .textField(title: "Location", enteredText: self.formData.location)
        case .isAllDay:
            cellModel = .toggle(title: "All-day", isOn: self.formData.isAllDay)
        case .date:
            let givenDate: String? = (self.formData.date == nil)
                ? nil : DateFormatter.dateFormatter.string(from: self.formData.date!)
            cellModel = .titleDetail(title: "Date", detail: givenDate)
        case .startTime:
            let givenDate: String? = (self.formData.date == nil)
                ? nil : DateFormatter.timeFormatter.string(from: self.formData.date!)
            cellModel = .titleDetail(title: "Start time", detail: givenDate)
        case .endTime:
            let givenDate: String? = (self.formData.date == nil)
                ? nil : DateFormatter.timeFormatter.string(from: self.formData.date!)
            cellModel = .titleDetail(title: "End time", detail: givenDate)
        case .url:
            cellModel = .textView(placeholder: "URL", numberOfLines: 1)
        case .notes:
            cellModel = .textView(placeholder: "Notes", numberOfLines: 5)
        case .datePicker:
            cellModel = .datePicker(includeTime: false)
        case .startTimePicker, .endTimePicker:
            cellModel = .datePicker(includeTime: true)
        }
        
        switch cellModel {
        case .textField(let title, let enteredText):
            let cell = tableView.dequeue(TextFieldTableViewCell.self)
            cell.titleLabel.text = title
            cell.textField.text = enteredText
            cell.selectionStyle = .none
            return cell
        case .textView(let placeholder, _):
            let cell = tableView.dequeue(TextViewTableViewCell.self)
            cell.placeholderLabel.text = placeholder
            cell.selectionStyle = .none
            return cell
        case .toggle(let title, let isOn):
            let cell = tableView.dequeue(ToggleTableViewCell.self)
            cell.toggle.isOn = isOn
            cell.titleLabel.text = title
            cell.selectionStyle = .none
            return cell
        case .datePicker(let includeTime):
            let cell = tableView.dequeue(DatePickerTableViewCell.self)
            cell.datePicker.datePickerMode = includeTime ? .time : .date
            cell.selectionStyle = .none
            return cell
        case .titleDetail(let title, let detail):
            let cell = tableView.dequeue(TitleDetailTableViewCell.self)
            cell.viewModel = TitleDetailTableViewCell.ViewModel(
                collectionId: title, title: title, subtitle: nil, detail: detail, accessoryType: .none)
            return cell
        }
    }
}

private extension DateFormatter {
    static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        return df
    }()
    
    static var timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }()
}
