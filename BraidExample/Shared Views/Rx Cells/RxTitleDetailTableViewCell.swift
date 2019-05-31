import UIKit
import Braid
import RxCocoa
import RxSwift

/**
 A simple cell with a stacked 'title' and 'subtitle' label on the left and a yellow 'detail' label on the right. The
 cell's ViewModel type is a struct whose properties are Strings for each of these labels. This cell is laid out in a
 Nib file, so it must conform to UINibInitable. A table view binder uses this conformance to find the cell's Nib file so
 it can register it to the table view.
 */
final class RxTitleDetailTableViewCell: UITableViewCell, ViewModelBindable, UINibInitable {
    /// The 'view model' for cells of this type. This view model conforms to `CollectionIdentifiable` so table binders
    /// can generate diffs for these cells (i.e. track insertions, deletions, and moves, and animate them on the table).
    class ViewModel: CollectionIdentifiable, Equatable {
        // View models for cells must provide an `id` property. Braid uses this property to track movement of a cell
        // in the table when it calculates diffs, so it must be unique to each view model.
        let collectionId: String
        let title: BehaviorRelay<String>
        let subtitle: BehaviorRelay<String?>
        let detail: BehaviorRelay<String?>
        let accessoryType: BehaviorRelay<UITableViewCell.AccessoryType>
        
        init(
            collectionId: String,
            title: String,
            subtitle: String? = nil,
            detail: String? = nil,
            accessoryType: UITableViewCell.AccessoryType = .none)
        {
            self.collectionId = collectionId
            self.title = BehaviorRelay(value: title)
            self.subtitle = BehaviorRelay(value: subtitle)
            self.detail = BehaviorRelay(value: detail)
            self.accessoryType = BehaviorRelay(value: accessoryType)
        }
        
        static func ==(lhs: ViewModel, rhs: ViewModel) -> Bool {
            return lhs.collectionId == rhs.collectionId
        }
    }
    
    private let disposeBag = DisposeBag()
    
    var viewModel: RxTitleDetailTableViewCell.ViewModel? {
        didSet {
            self.viewModel?.title.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
            self.viewModel?.subtitle.bind(to: self.subtitleLabel.rx.text).disposed(by: self.disposeBag)
            self.viewModel?.detail.bind(to: self.detailLabel.rx.text).disposed(by: self.disposeBag)
            self.viewModel?.accessoryType.subscribe(onNext: { [unowned self] in self.accessoryType = $0 }).disposed(by: self.disposeBag)
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
}
