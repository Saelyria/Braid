import UIKit
import Tableau
import RxSwift

final class TitleDetailTableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable, UINibInitable {
    struct ViewModel: Identifiable {
        let title: String
        let subtitle: String
        let detail: String
        
        var id: String { return self.title }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    var viewModel: TitleDetailTableViewCell.ViewModel? {
        didSet {
            self.titleLabel.text = self.viewModel?.title
            self.subtitleLabel.text = self.viewModel?.subtitle
            self.detailLabel.text = self.viewModel?.detail
        }
    }
}
