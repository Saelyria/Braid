import UIKit

/// An internal class that acts as the de facto data source / delegate to a binder's table view.
class _TableViewDataSourceDelegate<S: TableViewSection>: NSObject, UITableViewDataSource, UITableViewDelegate {

    private weak var binder: SectionedTableViewBinder<S>!
    private var dataModel: _TableViewDataModel<S>! {
        return self.binder.currentDataModel
    }

    init(binder: SectionedTableViewBinder<S>) {
        self.binder = binder
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        switch aSelector {
        case #selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)):
            return self.binder.nextDataModel.headerTitleBound
        case #selector(UITableViewDataSource.tableView(_:titleForFooterInSection:)):
            return self.binder.nextDataModel.footerTitleBound
        case #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)):
            return self.binder.nextDataModel.headerViewBound
        case #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)):
            return self.binder.nextDataModel.footerViewBound
            
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
            
        case #selector(UITableViewDataSource.tableView(_:canEditRowAt:)):
            return self.binder.nextDataModel.hasEditableSections
        case #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)):
            return self.binder.nextDataModel.hasEditableSections
            
        case #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)):
            return !self.binder.handlers.sectionPrefetchBehavior.isEmpty
                || self.binder.handlers.dynamicSectionPrefetchBehavior != nil
            
        default:
            return super.responds(to: aSelector)
        }
    }
    
    // MARK: -

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataModel.displayedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionInt: Int) -> Int {
        let section = self.dataModel.displayedSections[sectionInt]
        return self.dataModel.sectionModel(for: section).items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        // We can't fall back to the 'all sections' cell dequeue block - might expect a different cell type.
        let _dequeueBlock = (self.dataModel.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.sectionDequeueBlocks[section] != nil) ?
            self.binder.handlers.sectionDequeueBlocks[section] :
            self.binder.handlers.dynamicSectionDequeueBlock
        guard let dequeueBlock = _dequeueBlock else { return UITableViewCell() }
        
        let cell = dequeueBlock(section, tableView, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let prefetchBehavior: PrefetchBehavior? = self.dataModel.uniquelyBoundCellSections.contains(section) ?
            self.binder.handlers.sectionPrefetchBehavior[section] : self.binder.handlers.dynamicSectionPrefetchBehavior
        
        if let prefetchBehavior = prefetchBehavior {
            switch prefetchBehavior {
            case .cellsFromEnd(let num):
                let numItemsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
                if indexPath.row == numItemsInSection - num {
                    self.binder.handlers.sectionPrefetchHandlers[section]?(indexPath.row)
                }
            }
        }
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.dataModel.displayedSections[section]
        
        // don't return a title if the section has a header dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' header dequeue block
        let wasBoundUniquely = self.dataModel.uniquelyBoundHeaderSections.contains(section)
        if self.binder.handlers.sectionHeaderDequeueBlocks[section] != nil
        || (!wasBoundUniquely && self.binder.handlers.dynamicSectionsHeaderDequeueBlock != nil) {
            return nil
        }
        return self.dataModel.sectionModel(for: section).headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.dataModel.displayedSections[section]
        
        // don't return a title if the section has a footer dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' footer dequeue block
        let wasBoundUniquely = self.dataModel.uniquelyBoundFooterSections.contains(section)
        if self.binder.handlers.sectionFooterDequeueBlocks[section] != nil
        || (!wasBoundUniquely && self.binder.handlers.dynamicSectionsFooterDequeueBlock != nil) {
            return nil
        }
        return self.dataModel.sectionModel(for: section).footerTitle
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionInt: Int) -> UIView? {
        let section = self.dataModel.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' header dequeue block - might expect a different header type.
        let dequeueBlock = (self.dataModel.uniquelyBoundHeaderSections.contains(section)) ?
            self.binder.handlers.sectionHeaderDequeueBlocks[section] :
            self.binder.handlers.dynamicSectionsHeaderDequeueBlock
        return dequeueBlock?(section, tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection sectionInt: Int) -> UIView? {
        let section = self.dataModel.displayedSections[sectionInt]
        
        let dequeueBlock = (self.dataModel.uniquelyBoundFooterSections.contains(section)) ?
            self.binder.handlers.sectionFooterDequeueBlocks[section] :
            self.binder.handlers.dynamicSectionsFooterDequeueBlock
        return dequeueBlock?(section, tableView)
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let callback = (self.dataModel.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.sectionCellTappedCallbacks[section] != nil) ?
            self.binder.handlers.sectionCellTappedCallbacks[section] :
            self.binder.handlers.dynamicSectionsCellTappedCallback
        callback?(section, indexPath.row, cell)
        self.binder.handlers.anySectionCellTappedCallback?(section, indexPath.row, cell)
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let canEditBlock = (self.dataModel.uniquelyBoundCellSections.contains(section)
            || self.binder.handlers.sectionCellEditableBlocks[section] != nil) ?
                self.binder.handlers.sectionCellEditableBlocks[section] :
                self.binder.handlers.dynamicSectionCellEditableBlock
        
        if let canEditBlock = canEditBlock {
            return canEditBlock(section, indexPath.row)
        } else {
            return self.dataModel.sectionModel(for: section).cellEditingStyle != .none
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let styleBlock = (self.dataModel.uniquelyBoundCellSections.contains(section)
            || self.binder.handlers.sectionCellEditableStyleBlocks[section] != nil) ?
                self.binder.handlers.sectionCellEditableStyleBlocks[section] :
                self.binder.handlers.dynamicSectionCellEditableStyleBlock
        
        if let styleBlock = styleBlock {
            return styleBlock(section, indexPath.row)
        } else {
            return self.dataModel.sectionModel(for: section).cellEditingStyle
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        if editingStyle == .delete {
            let callback = (self.dataModel.uniquelyBoundCellSections.contains(section)
                || self.binder.handlers.sectionCellDeletedCallbacks[section] != nil) ?
                    self.binder.handlers.sectionCellDeletedCallbacks[section] :
                    self.binder.handlers.dynamicSectionCellDeletedCallback
            callback?(section, indexPath.row, .editing)
        } else if editingStyle == .insert {
            let callback = (self.dataModel.uniquelyBoundCellSections.contains(section)
                || self.binder.handlers.sectionCellInsertedCallbacks[section] != nil) ?
                    self.binder.handlers.sectionCellInsertedCallbacks[section] :
                    self.binder.handlers.dynamicSectionCellInsertedCallback
            callback?(section, indexPath.row, .editing)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let canMoveBlock = (self.dataModel.uniquelyBoundCellSections.contains(section)
            || self.binder.handlers.sectionCellMovableBlocks[section] != nil) ?
                self.binder.handlers.sectionCellMovableBlocks[section] :
            self.binder.handlers.dynamicSectionCellMovableBlock
        
        if let canMoveBlock = canMoveBlock {
            return canMoveBlock(section, indexPath.row)
        } else {
            return self.dataModel.sectionModel(for: section).allowedMovableSections != nil
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let fromSection = self.dataModel.displayedSections[sourceIndexPath.section]
        let toSection = self.dataModel.displayedSections[destinationIndexPath.section]
        
        let deleteCallback = (self.dataModel.uniquelyBoundCellSections.contains(fromSection)
            || self.binder.handlers.sectionCellDeletedCallbacks[fromSection] != nil) ?
                self.binder.handlers.sectionCellDeletedCallbacks[fromSection] :
                self.binder.handlers.dynamicSectionCellDeletedCallback
        deleteCallback?(fromSection, sourceIndexPath.row, .moved(toSection: toSection, row: destinationIndexPath.row))
        
        let insertCallback = (self.dataModel.uniquelyBoundCellSections.contains(toSection)
            || self.binder.handlers.sectionCellInsertedCallbacks[toSection] != nil) ?
                self.binder.handlers.sectionCellInsertedCallbacks[toSection] :
            self.binder.handlers.dynamicSectionCellInsertedCallback
        insertCallback?(fromSection, destinationIndexPath.row, .moved(fromSection: toSection, row: destinationIndexPath.row))
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        var _heightBlock: CellHeightBlock<S>?
        if self.dataModel.uniquelyBoundCellSections.contains(section) {
            _heightBlock = self.binder.handlers.sectionCellHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsCellHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionCellHeightBlock else {
            return tableView.rowHeight
        }
        return heightBlock(section, indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if self.dataModel.uniquelyBoundHeaderSections.contains(section) {
            _heightBlock = self.binder.handlers.sectionHeaderHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsHeaderHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionHeaderHeightBlock else {
            return tableView.sectionHeaderHeight
        }
        
        return heightBlock(section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if self.dataModel.uniquelyBoundFooterSections.contains(section) {
            _heightBlock = self.binder.handlers.sectionFooterHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsFooterHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionFooterHeightBlock else {
            return tableView.sectionFooterHeight
        }
        
        return heightBlock(section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        var _heightBlock: CellHeightBlock<S>?
        if self.dataModel.uniquelyBoundCellSections.contains(section) {
            _heightBlock = self.binder.handlers.sectionEstimatedCellHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsEstimatedCellHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionEstimatedCellHeightBlock else {
            return tableView.estimatedRowHeight
        }
        
        return heightBlock(section, indexPath.row)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if self.dataModel.uniquelyBoundHeaderSections.contains(section) {
            _heightBlock = self.binder.handlers.sectionHeaderEstimatedHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionHeaderEstimatedHeightBlock else {
            return tableView.estimatedSectionHeaderHeight
        }
        
        return heightBlock(section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        var _heightBlock: HeaderFooterHeightBlock<S>?
        if self.dataModel.uniquelyBoundFooterSections.contains(section) {
            _heightBlock = self.binder.handlers.sectionFooterEstimatedHeightBlocks[section]
        } else {
            _heightBlock = self.binder.handlers.dynamicSectionsFooterEstimatedHeightBlock
        }
        guard let heightBlock = _heightBlock ?? self.binder.handlers.anySectionFooterEstimatedHeightBlock else {
            return tableView.estimatedSectionHeaderHeight
        }
        
        return heightBlock(section)
    }
}
