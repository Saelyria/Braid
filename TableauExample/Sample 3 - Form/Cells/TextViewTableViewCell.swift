import UIKit
import Tableau

class TextViewTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable {
    enum ViewEvent {
        case textEntryStarted
        case textEntered(text: String)
        case textEntryEnded
    }
    
    @IBOutlet private(set) weak var placeholderLabel: UILabel!
    @IBOutlet private(set) weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholderLabel.isHidden = true
        self.emit(event: .textEntryStarted)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.emit(event: .textEntered(text: textView.text))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            self.placeholderLabel.isHidden = false
        }
        self.emit(event: .textEntryEnded)
    }
}
