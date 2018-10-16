import UIKit
import Tableau

class SectionHeaderView: UITableViewHeaderFooterView, ReuseIdentifiable, ViewModelBindable {
    typealias ViewModel = String
    
    var viewModel: String? {
        didSet {
            self.textLabel?.text = viewModel
        }
    }
}
