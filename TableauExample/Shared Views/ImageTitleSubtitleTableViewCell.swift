import Tableau

class ImageTitleSubtitleTableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    /// The 'view model' for cells of this type. This view model conforms to `CollectionIdentifiable` so table binders
    /// can generate diffs for these cells (i.e. track insertions, deletions, and moves, and animate them on the table).
    struct ViewModel: CollectionIdentifiable, Equatable {
        let collectionId: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            
        }
    }
}
