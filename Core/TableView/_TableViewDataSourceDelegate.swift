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
            return !self.binder.handlers.sectionEstimatedCellHeightBlocks.isEmpty || self.binder.handlers.dynamicSectionsEstimatedCellHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)):
            return !self.binder.handlers.sectionHeaderEstimatedHeightBlocks.isEmpty || self.binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)):
            return !self.binder.handlers.sectionFooterEstimatedHeightBlocks.isEmpty || self.binder.handlers.dynamicSectionsFooterEstimatedHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:heightForRowAt:)):
            return !self.binder.handlers.sectionCellHeightBlocks.isEmpty || self.binder.handlers.dynamicSectionsCellHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)):
            return !self.binder.handlers.sectionHeaderHeightBlocks.isEmpty || self.binder.handlers.dynamicSectionsHeaderHeightBlock != nil
        case #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)):
            return !self.binder.handlers.sectionFooterHeightBlocks.isEmpty || self.binder.handlers.dynamicSectionsFooterHeightBlock != nil
        default:
            return super.responds(to: aSelector)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.binder.displayedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.binder.displayedSections[section]
        if let models = self.binder.currentDataModel.sectionCellModels[section] {
            return models.count
        } else if let viewModels = self.binder.currentDataModel.sectionCellViewModels[section] {
            return viewModels.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.binder.displayedSections[section]
        
        // don't return a title if the section has a header dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' header dequeue block
        if self.binder.handlers.sectionHeaderDequeueBlocks[section] != nil ||
        (!self.binder.currentDataModel.uniquelyBoundSections.contains(section) && self.binder.handlers.dynamicSectionsHeaderDequeueBlock != nil) {
            return nil
        }
        return self.binder.currentDataModel.sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.binder.displayedSections[section]
        
        // don't return a title if the section has a footer dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' footer dequeue block
        if self.binder.handlers.sectionFooterDequeueBlocks[section] != nil ||
        (!self.binder.currentDataModel.uniquelyBoundSections.contains(section) && self.binder.handlers.dynamicSectionsFooterDequeueBlock != nil) {
            return nil
        }
        return self.binder.currentDataModel.sectionFooterTitles[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.binder.displayedSections[indexPath.section]
        
        // We can't fall back to the 'all sections' cell dequeue block - might expect a different cell type.
        let _dequeueBlock = (self.binder.currentDataModel.uniquelyBoundSections.contains(section)) ?
            self.binder.handlers.sectionCellDequeueBlocks[section] : self.binder.handlers.dynamicSectionCellDequeueBlock
        guard let dequeueBlock = _dequeueBlock else { return UITableViewCell() }

        let cell = dequeueBlock(section, tableView, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionInt: Int) -> UIView? {
        let section = self.binder.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' header dequeue block - might expect a different header type.
        let dequeueBlock = (self.binder.currentDataModel.uniquelyBoundSections.contains(section)) ?
            self.binder.handlers.sectionHeaderDequeueBlocks[section] : self.binder.handlers.dynamicSectionsHeaderDequeueBlock
        return dequeueBlock?(section, tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection sectionInt: Int) -> UIView? {
        let section = self.binder.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' footer dequeue block - might expect a different footer type.
        let dequeueBlock = (self.binder.currentDataModel.uniquelyBoundSections.contains(section)) ?
            self.binder.handlers.sectionFooterDequeueBlocks[section] : self.binder.handlers.dynamicSectionsFooterDequeueBlock
        return dequeueBlock?(section, tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.binder.displayedSections[indexPath.section]
        guard let cell = tableView.cellForRow(at: indexPath),
        let callback = self.binder.handlers.sectionCellTappedCallbacks[section] ?? self.binder.handlers.dynamicSectionsCellTappedCallback else { return }
        callback(section, indexPath.row, cell)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.binder.displayedSections[indexPath.section]
        if let heightBlock = self.binder.handlers.sectionCellHeightBlocks[section] ?? self.binder.handlers.dynamicSectionsCellHeightBlock {
            return heightBlock(section, indexPath.row)
        }
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.displayedSections[sectionInt]
        if let heightBlock = self.binder.handlers.sectionHeaderHeightBlocks[section] ?? self.binder.handlers.dynamicSectionsHeaderHeightBlock {
            return heightBlock(section)
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.displayedSections[sectionInt]
        if let heightBlock = self.binder.handlers.sectionFooterHeightBlocks[section] ?? self.binder.handlers.dynamicSectionsFooterHeightBlock {
            return heightBlock(section)
        }
        return tableView.sectionFooterHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.binder.displayedSections[indexPath.section]
        if let estimatedHeightBlock = self.binder.handlers.sectionEstimatedCellHeightBlocks[section] ?? self.binder.handlers.dynamicSectionsEstimatedCellHeightBlock {
            return estimatedHeightBlock(section, indexPath.row)
        }
        return tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.displayedSections[sectionInt]
        if let heightBlock = self.binder.handlers.sectionHeaderEstimatedHeightBlocks[section] ?? self.binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock {
            return heightBlock(section)
        }
        return tableView.estimatedSectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.binder.displayedSections[sectionInt]
        if let heightBlock = self.binder.handlers.sectionFooterEstimatedHeightBlocks[section] ?? self.binder.handlers.dynamicSectionsFooterEstimatedHeightBlock {
            return heightBlock(section)
        }
        return tableView.estimatedSectionFooterHeight
    }
}
