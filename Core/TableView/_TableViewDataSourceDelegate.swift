import UIKit

/// An internal class that acts as the de facto data source / delegate to a binder's table view.
class _TableViewDataSourceDelegate<S: TableViewSection>: NSObject, UITableViewDataSource, UITableViewDelegate {

    private weak var binder: SectionedTableViewBinder<S>!

    init(binder: SectionedTableViewBinder<S>) {
        self.binder = binder
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        switch aSelector {
        case #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)):
            return !self.binder.handlers.sectionEstimatedCellHeightBlocks.isEmpty
                || self.binder.handlers.dynamicSectionsEstimatedCellHeightBlock != nil
                || self.binder.handlers.anySectionEstimatedCellHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)):
            return !self.binder.handlers.sectionHeaderEstimatedHeightBlocks.isEmpty
                || self.binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock != nil
                || self.binder.handlers.anySectionHeaderEstimatedHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)):
            return !self.binder.handlers.sectionFooterEstimatedHeightBlocks.isEmpty
                || self.binder.handlers.dynamicSectionsFooterEstimatedHeightBlock != nil
                || self.binder.handlers.anySectionFooterEstimatedHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:heightForRowAt:)):
            return !self.binder.handlers.sectionCellHeightBlocks.isEmpty
                || self.binder.handlers.dynamicSectionsCellHeightBlock != nil
                || self.binder.handlers.anySectionCellHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)):
            return !self.binder.handlers.sectionHeaderHeightBlocks.isEmpty
                || self.binder.handlers.dynamicSectionsHeaderHeightBlock != nil
                || self.binder.handlers.anySectionHeaderHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)):
            return !self.binder.handlers.sectionFooterHeightBlocks.isEmpty
                || self.binder.handlers.dynamicSectionsFooterHeightBlock != nil
                || self.binder.handlers.anySectionFooterHeightBlock != nil
        default:
            return super.responds(to: aSelector)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.binder.currentDataModel.displayedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.binder.currentDataModel.displayedSections[section]
        if let models = self.binder.currentDataModel.sectionCellModels[section] {
            return models.count
        } else if let viewModels = self.binder.currentDataModel.sectionCellViewModels[section] {
            return viewModels.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.binder.currentDataModel.displayedSections[section]
        
        // don't return a title if the section has a header dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' header dequeue block
        if self.binder.handlers.sectionHeaderDequeueBlocks[section] != nil ||
        (!sectionWasUniquelyBound(section) && self.binder.handlers.dynamicSectionsHeaderDequeueBlock != nil) {
            return nil
        }
        return self.binder.currentDataModel.sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.binder.currentDataModel.displayedSections[section]
        
        // don't return a title if the section has a footer dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' footer dequeue block
        if self.binder.handlers.sectionFooterDequeueBlocks[section] != nil ||
        (!sectionWasUniquelyBound(section) && self.binder.handlers.dynamicSectionsFooterDequeueBlock != nil) {
            return nil
        }
        return self.binder.currentDataModel.sectionFooterTitles[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.binder.currentDataModel.displayedSections[indexPath.section]
        
        // We can't fall back to the 'all sections' cell dequeue block - might expect a different cell type.
        let _dequeueBlock = (sectionWasUniquelyBound(section)) ?
            self.binder.handlers.sectionCellDequeueBlocks[section] :
            self.binder.handlers.dynamicSectionCellDequeueBlock
        guard let dequeueBlock = _dequeueBlock else { return UITableViewCell() }

        let cell = dequeueBlock(section, tableView, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionInt: Int) -> UIView? {
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' header dequeue block - might expect a different header type.
        let dequeueBlock = (sectionWasUniquelyBound(section)) ?
            self.binder.handlers.sectionHeaderDequeueBlocks[section] :
            self.binder.handlers.dynamicSectionsHeaderDequeueBlock
        return dequeueBlock?(section, tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection sectionInt: Int) -> UIView? {
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
        let dequeueBlock = (sectionWasUniquelyBound(section)) ?
            self.binder.handlers.sectionFooterDequeueBlocks[section] :
            self.binder.handlers.dynamicSectionsFooterDequeueBlock
        return dequeueBlock?(section, tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.binder.currentDataModel.displayedSections[indexPath.section]
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let callback = (sectionWasUniquelyBound(section)) ?
            self.binder.handlers.sectionCellTappedCallbacks[section] :
            self.binder.handlers.dynamicSectionsCellTappedCallback
        callback?(section, indexPath.row, cell)
        self.binder.handlers.anySectionCellTappedCallback?(section, indexPath.row, cell)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.binder.currentDataModel.displayedSections[indexPath.section]
        
        var _heightBlock: CellHeightBlock<S>?
        if sectionWasUniquelyBound(section) {
            _heightBlock = self.binder.handlers.sectionCellHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsCellHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionCellHeightBlock else {
            assertionFailure("tableView:heightForRowAt: shouldn't be called if there was no height handler bound; 'responds(to:)' override didn't work")
            return tableView.rowHeight
        }
        return heightBlock(section, indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if sectionWasUniquelyBound(section) {
            _heightBlock = self.binder.handlers.sectionHeaderHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsHeaderHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionHeaderHeightBlock else {
            assertionFailure("tableView:heightForHeaderInSection: shouldn't be called if there was no height handler bound; 'responds(to:)' override didn't work")
            return tableView.sectionHeaderHeight
        }
        
        return heightBlock(section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if sectionWasUniquelyBound(section) {
            _heightBlock = self.binder.handlers.sectionFooterHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsFooterHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionFooterHeightBlock else {
            assertionFailure("tableView:heightForFooterInSection: shouldn't be called if there was no height handler bound; 'responds(to:)' override didn't work")
            return tableView.sectionFooterHeight
        }
        
        return heightBlock(section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.binder.currentDataModel.displayedSections[indexPath.section]
        
        var _heightBlock: CellHeightBlock<S>?
        if sectionWasUniquelyBound(section) {
            _heightBlock = self.binder.handlers.sectionEstimatedCellHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsEstimatedCellHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionEstimatedCellHeightBlock else {
            assertionFailure("tableView:estimatedHeightForRowAt: shouldn't be called if there was no height handler bound; 'responds(to:)' override didn't work")
            return tableView.estimatedRowHeight
        }
        
        return heightBlock(section, indexPath.row)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if sectionWasUniquelyBound(section) {
            _heightBlock = self.binder.handlers.sectionHeaderEstimatedHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionHeaderEstimatedHeightBlock else {
            assertionFailure("tableView:estimatedHeightForHeaderInSection: shouldn't be called if there was no height handler bound; 'responds(to:)' override didn't work")
            return tableView.estimatedSectionHeaderHeight
        }
        
        return heightBlock(section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if sectionWasUniquelyBound(section) {
            _heightBlock = self.binder.handlers.sectionFooterEstimatedHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsFooterEstimatedHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionFooterEstimatedHeightBlock else {
            assertionFailure("tableView:estimatedHeightForHeaderInSection: shouldn't be called if there was no height handler bound; 'responds(to:)' override didn't work")
            return tableView.estimatedSectionHeaderHeight
        }
        
        return heightBlock(section)
    }
    
    private func sectionWasUniquelyBound(_ section: S) -> Bool {
        return self.binder.currentDataModel.uniquelyBoundSections.contains(section)
    }
}
