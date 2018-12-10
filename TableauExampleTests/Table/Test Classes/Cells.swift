import UIKit
import Tableau

class TestCell: UITableViewCell, ReuseIdentifiable {
    
}

class TestViewModelCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel {
        let id: String
    }
    
    var viewModel: TestViewModelCell.ViewModel?
}
