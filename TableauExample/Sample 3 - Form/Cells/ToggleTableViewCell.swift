import UIKit
import Tableau

class ToggleTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable, ReuseIdentifiable {
    enum ViewEvent {
        case switchToggled(state: Bool)
    }
    
    var isOn: Bool = false {
        didSet {
            guard self.toggle != nil else { return }
            self.toggle.isOn = isOn
        }
    }
    
    var title: String? {
        didSet {
            guard self.titleLabel != nil else { return }
            self.titleLabel.text = title
        }
    }
    
    @IBOutlet private weak var toggle: UISwitch!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = self.title
        self.toggle.isOn = self.isOn
    }
    
    @IBAction private func switchToggled() {
        self.emit(event: .switchToggled(state: self.toggle.isOn))
    }
}
