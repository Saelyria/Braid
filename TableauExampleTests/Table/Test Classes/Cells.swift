import UIKit
import Tableau

class TestCell: UITableViewCell, ReuseIdentifiable {
    
}

class TestViewModelCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel {
        let id: String
    }
    
    var viewModel: ViewModel?
}

class TestHeaderFooter: UITableViewHeaderFooterView, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel {
        let title: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.title
        }
    }
}
