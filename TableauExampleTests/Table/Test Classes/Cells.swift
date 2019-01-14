import UIKit
import Tableau

class TestCell: UITableViewCell {
    
}

class TestViewModelCell: UITableViewCell, ViewModelBindable {
    struct ViewModel {
        let id: String
    }
    
    var viewModel: ViewModel?
}

class TestHeaderFooter: UITableViewHeaderFooterView, ViewModelBindable {
    struct ViewModel {
        let title: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.title
        }
    }
}

extension SectionedTableViewBinder {
    func setupForTesting() {
        self.rowUpdateAnimation = .none
        self.rowDeletionAnimation = .none
        self.rowInsertionAnimation = .none
        self.sectionUpdateAnimation = .none
        self.sectionDeletionAnimation = .none
        self.sectionInsertionAnimation = .none
        self.undiffableSectionUpdateAnimation = .none
        self.sectionHeaderFooterUpdateAnimation = .none
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
