import UIKit
import Braid

/**
 An example of how a custom table header/footer view would be implemented for use with Braid.
 */
class SectionHeaderView: UITableViewHeaderFooterView, ViewModelBindable {
    /// The 'view model' for views of this type. Note that this view model doesn't need to conform to
    /// `CollectionIdentifiable`, since section headers don't move/aren't diffed.
    struct ViewModel: Equatable {
        let title: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.title
        }
    }
}
