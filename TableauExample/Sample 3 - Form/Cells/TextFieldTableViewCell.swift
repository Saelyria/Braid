import UIKit
import Tableau

class TextFieldTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable {
    enum ViewEvent {
        case textEntryStarted
        case textEntered(text: String)
        case textEntryEnded
    }
    
    enum TextFieldEntryType {
        case keyboard
        case picker(from: [String])
        case datePicker
        case timePicker
    }
    
    var entryType: TextFieldEntryType = .keyboard {
        didSet {
            guard self.textField != nil else { return }
            switch self.entryType {
            case .datePicker, .timePicker, .picker:
                self.textField.tintColor = .clear
            default:
                self.textField.tintColor = .blue
            }
        }
    }
    var title: String? {
        didSet {
            guard self.titleLabel != nil else { return }
            self.titleLabel.text = title
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = self.title
        switch self.entryType {
        case .datePicker, .timePicker, .picker:
            self.textField.tintColor = .clear
        default:
            self.textField.tintColor = .blue
        }
    }
    
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
