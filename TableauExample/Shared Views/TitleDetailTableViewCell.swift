import UIKit
import Tableau
import RxSwift

/**
 A simple cell with a stacked 'title' and 'subtitle' label on the left and a yellow 'detail' label on the right. The
 cell's ViewModel type is a struct whose properties are Strings for each of these labels. This cell is laid out in a
 Nib file, so it must conform to UINibInitable. A table view binder uses this conformance to find the cell's Nib file so
 it can register it to the table view.
 */
final class TitleDetailTableViewCell: UITableViewCell, ViewModelBindable, UINibInitable {    
    /// The 'view model' for cells of this type. This view model conforms to `CollectionIdentifiable` so table binders
    /// can generate diffs for these cells (i.e. track insertions, deletions, and moves, and animate them on the table).
    struct ViewModel: CollectionIdentifiable, Equatable {
        // View models for cells must provide an `id` property. Tableau uses this property to track movement of a cell
        // in the table when it calculates diffs, so it must be unique to each view model.
        let collectionId: String
        let title: String
        let subtitle: String?
        let detail: String?
        let accessoryType: UITableViewCell.AccessoryType
    }
    
    var viewModel: TitleDetailTableViewCell.ViewModel? {
        didSet {
            self.titleLabel.text = self.viewModel?.title
            self.subtitleLabel.isHidden = self.viewModel?.subtitle == nil
            self.subtitleLabel.text = self.viewModel?.subtitle
            self.detailLabel.text = self.viewModel?.detail
            self.accessoryType = self.viewModel?.accessoryType ?? .none
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
}
