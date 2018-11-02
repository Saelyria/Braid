import UIKit
import Tableau

/**
 An example of how a custom table header/footer view would be implemented for use with Tableau.
 */
class SectionHeaderView: UITableViewHeaderFooterView, ReuseIdentifiable, ViewModelBindable {
    /// The 'view model' for views of this type. Note that this view model doesn't need to conform to
    /// `CollectionIdentifiable`, since section headers don't move/aren't diffed.
    struct ViewModel {
        let title: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.title
        }
    }
}
