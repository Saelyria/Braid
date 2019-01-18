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
            
        case #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)):
            return !self.binder.handlers.sectionPrefetchBehavior.isEmpty
                || self.binder.handlers.dynamicSectionPrefetchBehavior != nil
            
        default:
            return super.responds(to: aSelector)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataModel.displayedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.dataModel.displayedSections[section]
        return self.dataModel.sectionModel(for: section).items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        // We can't fall back to the 'all sections' cell dequeue block - might expect a different cell type.
        let _dequeueBlock = (self.dataModel.uniquelyBoundCellSections.contains(section)) ?
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
            default: break
            }
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let callback = (self.dataModel.uniquelyBoundCellSections.contains(section)) ?
            self.binder.handlers.sectionCellTappedCallbacks[section] :
            self.binder.handlers.dynamicSectionsCellTappedCallback
        callback?(section, indexPath.row, cell)
        self.binder.handlers.anySectionCellTappedCallback?(section, indexPath.row, cell)
    }
    
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
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
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
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
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
        let section = self.binder.currentDataModel.displayedSections[indexPath.section]
        
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
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
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
        let section = self.binder.currentDataModel.displayedSections[sectionInt]
        
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
