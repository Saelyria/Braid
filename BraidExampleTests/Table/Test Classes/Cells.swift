import UIKit
import Braid

class TestCell: UITableViewCell {
    var model: Any?
}

class TestViewModelCell: TestCell, ViewModelBindable {
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
    
    func cellsInSections<C>(type: C.Type) -> [S: [C]] {
        return self.displayedSections.reduce([:], { (result, section) in
            var result = result
            let cellArray = (0..<self.rows(in: section))
                .map { row in self.cell(for: section, row) as? C }
                .compactMap { $0 }
            result[section] = cellArray
            return result
        })
    }
    
    func cell(for section: S, _ row: Int) -> UITableViewCell? {
        guard let section = self.displayedSections.firstIndex(where: { $0 == section }) else { return nil }
        let path = IndexPath(row: row, section: section)
        return self.tableView.cellForRow(at: path)
    }
    
    func rows(in section: S) -> Int {
        guard let section = self.displayedSections.firstIndex(where: { $0 == section }) else { return 0 }
        return self.tableView.numberOfRows(inSection: section)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
