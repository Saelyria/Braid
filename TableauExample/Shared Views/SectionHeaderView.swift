import UIKit
import Tableau

/**
 An example of how a custom table header/footer view would be implemented for use with Tableau.
 */
class SectionHeaderView: UITableViewHeaderFooterView, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel: Identifiable {
        let title: String
        var id: String { return self.title }
    }
    
    var viewModel: ViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.title
        }
    }
}
