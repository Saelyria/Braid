import Braid

class ImageTitleSubtitleTableViewCell: UITableViewCell, ViewModelBindable, UINibInitable {
    /// The 'view model' for cells of this type. This view model conforms to `CollectionIdentifiable` so table binders
    /// can generate diffs for these cells (i.e. track insertions, deletions, and moves, and animate them on the table).
    struct ViewModel: CollectionIdentifiable, Equatable {
        let collectionId: String
        let title: String
        let subtitle: String?
        let image: UIImage?
    }
    
    var viewModel: ViewModel? {
        didSet {
            self.leftImageView.image = self.viewModel?.image
            self.titleLabel.text = self.viewModel?.title
            self.subtitleLabel.text = self.viewModel?.subtitle
        }
    }
    
    @IBOutlet private var leftImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
}
