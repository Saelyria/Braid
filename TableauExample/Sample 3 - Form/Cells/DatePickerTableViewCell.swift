import UIKit
import Tableau

class DatePickerTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable {
    enum ViewEvent {
        case dateSelected(date: Date)
    }
    
    var datePickerMode: UIDatePicker.Mode = .date {
        didSet {
            guard self.datePicker != nil else { return }
            self.datePicker.datePickerMode = self.datePickerMode
        }
    }
    
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.datePicker.datePickerMode = self.datePickerMode
    }
    
    @IBAction func dateSelected(_ datePicker: UIDatePicker) {
        self.emit(event: .dateSelected(date: datePicker.date))
    }
}
