import UIKit
import Tableau
import RxSwift

class TitleDetailTableViewCell: UITableViewCell, ReuseIdentifiable, RxViewModelBindable, UINibInitable {
    struct ViewModel {
        let title: String
        let subtitle: String
        let detail: String
    }
    
    let viewModel = Variable<TitleDetailTableViewCell.ViewModel?>(nil)
}
