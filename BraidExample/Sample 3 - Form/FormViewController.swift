import UIKit
import Braid

class FormViewController: UIViewController {
    // 4.
    enum Section: Int, TableViewSection, Comparable {
        case titleAndLocation
        case time
        case notes
    }

    private var binder: SectionedTableViewBinder<Section>!
    private var formData = FormData()
    // 5.
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
        self.binder.rowInsertionAnimation = .middle
        self.binder.rowDeletionAnimation = .middle
        self.binder.rowUpdateAnimation = .none
        self.binder.sectionUpdateAnimation = .none
        
        // 6.
        self.binder.onAllSections()
            .bind(
                cellProvider: { [unowned self] tableView, _, _, formItem in
                    return self.dequeueCell(forFormItem: formItem, tableView: tableView)
                }, models: { [unowned self] in
                    return self.determineFormItems(from: self.formData, activeItem: self.activeFormItem)
                })
        
        // 7.
        self.binder.onSections(.titleAndLocation)
            .assuming(modelType: FormItem.self)
            // 8.
            .onEvent(from: TextFieldTableViewCell.self) { [unowned self] _, _, _, event, formItem in
                switch (event, formItem) {
                case (.textEntered(let text), .title):
                    self.formData.title = text
                case (.textEntered(let text), .location):
                    self.formData.location = text
                default: break
                }
            }
        
        // 9.
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
            // 10.
            .onTapped { _, cell, formItem in
                cell.setSelected(false, animated: true)
                if cell is TitleDetailTableViewCell {
                    if self.activeFormItem?.collectionId == formItem.collectionId {
                        self.activeFormItem = nil
                    } else {
                        self.activeFormItem = formItem
                    }
                    self.binder.refresh()
                }
            }
            // 11.
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
        
        // 12.
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
        switch formItem {
        case .title:
            let cell = tableView.dequeue(TextFieldTableViewCell.self)
            cell.titleLabel.text = "Event name"
            cell.textField.text = self.formData.title
            return cell
        case .location:
            let cell = tableView.dequeue(TextFieldTableViewCell.self)
            cell.titleLabel.text = "Location"
            cell.textField.text = self.formData.location
            return cell
        case .isAllDay:
            let cell = tableView.dequeue(ToggleTableViewCell.self)
            cell.titleLabel.text = "All-day"
            cell.toggle.isOn = self.formData.isAllDay
            return cell
        case .date:
            let givenDate: String? = (self.formData.date == nil)
                ? nil : DateFormatter.dateFormatter.string(from: self.formData.date!)
            let cell = tableView.dequeue(TitleDetailTableViewCell.self)
            cell.viewModel = TitleDetailTableViewCell.ViewModel(
                collectionId: "date", title: "Date", subtitle: nil, detail: givenDate, accessoryType: .none)
            return cell
        case .startTime:
            let givenDate: String? = (self.formData.startTime == nil)
                ? nil : DateFormatter.timeFormatter.string(from: self.formData.startTime!)
            let cell = tableView.dequeue(TitleDetailTableViewCell.self)
            cell.viewModel = TitleDetailTableViewCell.ViewModel(
                collectionId: "start", title: "Start time", subtitle: nil, detail: givenDate, accessoryType: .none)
            return cell
        case .endTime:
            let givenDate: String? = (self.formData.endTime == nil)
                ? nil : DateFormatter.timeFormatter.string(from: self.formData.endTime!)
            let cell = tableView.dequeue(TitleDetailTableViewCell.self)
            cell.viewModel = TitleDetailTableViewCell.ViewModel(
                collectionId: "end", title: "End time", subtitle: nil, detail: givenDate, accessoryType: .none)
            return cell
        case .url:
            let cell = tableView.dequeue(TextViewTableViewCell.self)
            cell.placeholderLabel.text = "URL"
            return cell
        case .notes:
            let cell = tableView.dequeue(TextViewTableViewCell.self)
            cell.placeholderLabel.text = "Notes"
            return cell
        case .datePicker:
            let cell = tableView.dequeue(DatePickerTableViewCell.self)
            cell.datePicker.datePickerMode = .date
            return cell
        case .startTimePicker, .endTimePicker:
            let cell = tableView.dequeue(DatePickerTableViewCell.self)
            cell.datePicker.datePickerMode = .time
            return cell
        }
    }
    
    private func determineFormItems(from formData: FormData, activeItem: FormItem?) -> [Section: [FormItem]] {
        let titleLocationItems: [FormItem] = [
            .title(formData.title),
            .location(formData.location)]
        
        var timeItems: [FormItem] = [
            .isAllDay(formData.isAllDay),
            .date(formData.date)]
        if !formData.isAllDay {
            timeItems.append(contentsOf: [
                .startTime(formData.startTime),
                .endTime(formData.endTime)
            ])
        }
        if let activeItem = activeItem {
            switch activeItem {
            case .date:
                guard let dateIndex = timeItems.firstIndex(of: .date(formData.date)) else { fatalError() }
                timeItems.insert(.datePicker, at: timeItems.index(after: dateIndex))
            case .startTime:
                guard let startTimeIndex = timeItems.firstIndex(of: .startTime(formData.startTime)) else { fatalError() }
                timeItems.insert(.startTimePicker, at: timeItems.index(after: startTimeIndex))
            case .endTime:
                guard let endTimeIndex = timeItems.firstIndex(of: .endTime(formData.endTime)) else { fatalError() }
                timeItems.insert(.endTimePicker, at: timeItems.index(after: endTimeIndex))
            default: break
            }
        }
        
        let notesItems: [FormItem] = [
            .url(formData.url),
            .notes(formData.notes)]
        
        return [
            .titleAndLocation: titleLocationItems,
            .time: timeItems,
            .notes: notesItems
        ]
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
