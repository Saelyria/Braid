import UIKit
import Tableau

class ToggleTableViewCell: UITableViewCell, ViewEventEmitting, UINibInitable {
    enum ViewEvent {
        case switchToggled(state: Bool)
    }

    @IBOutlet private(set) weak var toggle: UISwitch!
    @IBOutlet private(set) weak var titleLabel: UILabel!
    
    @IBAction private func switchToggled() {
        self.emit(event: .switchToggled(state: self.toggle.isOn))
    }
}
