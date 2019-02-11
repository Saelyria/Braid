import UIKit
import Braid

// 1.
class TextFieldTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable {
    enum ViewEvent {
        case textEntryStarted
        case textEntered(text: String)
        case textEntryEnded
    }
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var textField: UITextField!
    
    @IBAction private func textEntryStarted() {
        self.emit(event: .textEntryStarted)
    }
    
    @IBAction private func textEntered() {
        self.emit(event: .textEntered(text: self.textField.text ?? ""))
    }
    
    @IBAction private func textEntryEnded() {
        self.emit(event: .textEntryEnded)
    }
}
