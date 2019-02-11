import UIKit
import Braid

class DatePickerTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable {
    enum ViewEvent {
        case dateSelected(date: Date)
    }
    
    @IBOutlet private(set) weak var datePicker: UIDatePicker!
    
    @IBAction func dateSelected(_ datePicker: UIDatePicker) {
        self.emit(event: .dateSelected(date: datePicker.date))
    }
}
