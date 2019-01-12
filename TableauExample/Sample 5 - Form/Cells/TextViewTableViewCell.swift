import UIKit
import Tableau

class TextViewTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable, ReuseIdentifiable {
    enum ViewEvent {
        case textEntryStarted
        case textEntered(String)
        case textEntryEnded
    }
    
    var placeholder: String? {
        didSet {
            guard self.placeholderLabel != nil else { return }
            self.placeholderLabel.text = placeholder
        }
    }
    
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.placeholderLabel.text = self.placeholder
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholderLabel.isHidden = true
        self.emit(event: .textEntryStarted)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.emit(event: .textEntered(textView.text))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            self.placeholderLabel.isHidden = false
        }
        self.emit(event: .textEntryEnded)
    }
}
