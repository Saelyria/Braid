import UIKit
import Tableau

/**
 An example of how a custom table header/footer view would be implemented for use with Tableau.
 */
class SectionHeaderView: UITableViewHeaderFooterView, ReuseIdentifiable, ViewModelBindable {
    typealias ViewModel = String
    
    var viewModel: String? {
        didSet {
            self.textLabel?.text = viewModel
        }
    }
}
