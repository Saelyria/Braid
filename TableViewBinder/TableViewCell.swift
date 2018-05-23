import UIKit
import RxSwift

class TableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable, UINibInitable {
    struct ViewModel {
        let title: String
        let subtitle: String
    }
        
    let viewModel = Variable<ViewModel?>(nil)
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewModel.asObservable().subscribe(onNext: { model in
            self.titleLabel.text = model?.title
            self.subtitleLabel.text = model?.subtitle
        }).disposed(by: self.disposeBag)
    }
}
