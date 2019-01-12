import UIKit
import Tableau

class TextFieldTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable, ReuseIdentifiable {
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
        didSet {  }
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
    }
}
