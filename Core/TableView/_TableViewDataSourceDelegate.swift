import UIKit
import RxSwift

/// An internally-used base class that the vanilla and Rx table view binders inherit from. You should not use this class in your app.
public class _BaseTableViewBinder<S: TableViewSection> {
    var _displayedSections: [S] = []
    var tableView: UITableView!
    var tableViewDataSourceDelegate: _TableViewDataSourceDelegate<S>!
    
    // Blocks to call to dequeue a cell in a section.
    var sectionCellDequeueBlocks: [S: CellDequeueBlock] = [:]
    // The view models for the cells for a section.
    var sectionCellViewModels: [S: [Any]] = [:]
    // The raw models for the cells for a section.
    var sectionCellModels: [S: [Any]] = [:]
    
    // Blocks to call to dequeue a header in a section.
    var sectionHeaderDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // The view models for the headers for a section.
    var sectionHeaderViewModels: [S: Any] = [:]
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:]
    
    // Blocks to call to dequeue a footer in a section.
    var sectionFooterDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // The view models for the footers for a section.
    var sectionFooterViewModels: [S: Any] = [:]
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:]
    
    // Blocks to call when a cell is tapped in a section.
    var sectionCellTappedCallbacks: [S: CellTapCallback] = [:]
    // Callback blocks to call when a cell is dequeued in a section.
    var sectionCellDequeuedCallbacks: [S: CellDequeueCallback] = [:]
    // Blocks to call to get the height for a cell in a section.
    var sectionCellHeightBlocks: [S: CellHeightBlock] = [:]
    // Blocks to call to get the estimated height for a cell in a section.
    var sectionEstimatedCellHeightBlocks: [S: CellHeightBlock] = [:]
    
    public required init(tableView: UITableView, sectionedBy sectionEnum: S.Type, displayedSections: [S]) {
        self.tableView = tableView
        self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate(binder: self)
        tableView.delegate = self.tableViewDataSourceDelegate
        tableView.dataSource = self.tableViewDataSourceDelegate        
    }
    
    /// Reloads the specified section.
    public func reload(section: S) {
        if let sectionToReloadIndex = self._displayedSections.index(of: section) {
            let startIndex = self._displayedSections.startIndex
            let sectionInt = startIndex.distance(to: sectionToReloadIndex)
            let indexSet: IndexSet = [sectionInt]
            self.tableView.reloadSections(indexSet, with: .none)
        } else {
            self.tableView.reloadData()
        }
    }
}

/// An internal class that acts as the de facto data source / delegate to a binder's table view.
class _TableViewDataSourceDelegate<SectionEnum: TableViewSection>: NSObject, UITableViewDataSource, UITableViewDelegate {
    private weak var binder: _BaseTableViewBinder<SectionEnum>!
    
    init(binder: _BaseTableViewBinder<SectionEnum>) {
        self.binder = binder
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.binder._displayedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.binder._displayedSections[section]
        if let numModels = self.binder.sectionCellViewModels[section]?.count {
            return numModels
        }
//        else if let numCells = self.binder.sectionNumberOfCells[section] {
//            return numCells
//        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.binder._displayedSections[section]
        return self.binder.sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.binder._displayedSections[section]
        return self.binder.sectionFooterTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.binder._displayedSections[indexPath.section]
        guard let dequeueBlock = self.binder.sectionCellDequeueBlocks[section] else { return UITableViewCell() }
        
        let cell = dequeueBlock(tableView, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.binder._displayedSections[indexPath.section]
        if let estimatedHeightBlock = self.binder.sectionEstimatedCellHeightBlocks[section] {
            return estimatedHeightBlock(indexPath.row)
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.binder._displayedSections[indexPath.section]
        if let heightBlock = self.binder.sectionCellHeightBlocks[section] {
            return heightBlock(indexPath.row)
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionInt: Int) -> UIView? {
        let section = self.binder._displayedSections[sectionInt]
        if let dequeueBlock = self.binder.sectionHeaderDequeueBlocks[section] {
            let header: UITableViewHeaderFooterView? = dequeueBlock(tableView, sectionInt)
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.binder._displayedSections[indexPath.section]
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        self.binder.sectionCellTappedCallbacks[section]?(indexPath.row, cell)
    }
}
