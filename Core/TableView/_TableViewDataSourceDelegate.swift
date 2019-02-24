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
            return self.binder.handlers.cellEstimatedHeightProviders.hasHandler
        case #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)):
            return self.binder.handlers.headerEstimatedHeightProviders.hasHandler
        case #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)):
            return self.binder.handlers.footerEstimatedHeightProviders.hasHandler
        case #selector(UITableViewDelegate.tableView(_:heightForRowAt:)):
            return self.binder.handlers.cellHeightProviders.hasHandler
        case #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)):
            return self.binder.handlers.headerHeightProviders.hasHandler
        case #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)):
            return self.binder.handlers.footerHeightProviders.hasHandler
            
        case #selector(UITableViewDataSource.tableView(_:canEditRowAt:)):
            return self.binder.nextDataModel.hasEditableSections
        case #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)):
            return self.binder.nextDataModel.hasEditableSections
            
        case #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)):
            return self.binder.handlers.prefetchBehaviors.hasHandler
            
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
        let handlerSet = self.binder.handlers.cellProviders
        let provider: ((S, UITableView, IndexPath) -> UITableViewCell)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
            provider = self.binder.handlers.cellProviders.namedSection[section]
        } else {
            provider = self.binder.handlers.cellProviders.dynamicSections
        }
        guard let _provider = provider else {
            assertionFailure("A 'cell provider' could not be found, something went awry!")
            return UITableViewCell()
        }
        
        let cell = _provider(section, tableView, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let prefetchBehavior: PrefetchBehavior? = self.binder.handlers.uniquelyBoundCellSections.contains(section) ?
            self.binder.handlers.prefetchBehaviors.namedSection[section] :
            self.binder.handlers.prefetchBehaviors.dynamicSections
        
        if let prefetchBehavior = prefetchBehavior {
            switch prefetchBehavior {
            case .cellsFromEnd(let num):
                let numItemsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
                if indexPath.row == numItemsInSection - num {
                    let prefetchHandler: ((Int) -> Void)?
                    if self.binder.handlers.uniquelyBoundCellSections.contains(section)
                    || self.binder.handlers.prefetchHandlers.namedSection[section] != nil {
                        prefetchHandler = self.binder.handlers.prefetchHandlers.namedSection[section]
                    } else {
                        prefetchHandler = self.binder.handlers.prefetchHandlers.dynamicSections
                    }
                    prefetchHandler?(indexPath.row)
                }
            }
        }
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.dataModel.displayedSections[section]
        
        // don't return a title if the section has a header dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' header dequeue block
        let wasBoundUniquely = self.binder.handlers.uniquelyBoundHeaderSections.contains(section)
        if self.binder.handlers.headerViewProviders.namedSection[section] != nil
        || (!wasBoundUniquely && self.binder.handlers.headerViewProviders.dynamicSections != nil) {
            return nil
        }
        return self.dataModel.sectionModel(for: section).headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.dataModel.displayedSections[section]
        
        // don't return a title if the section has a footer dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' footer dequeue block
        let wasBoundUniquely = self.binder.handlers.uniquelyBoundFooterSections.contains(section)
        if self.binder.handlers.footerViewProviders.namedSection[section] != nil
        || (!wasBoundUniquely && self.binder.handlers.footerViewProviders.dynamicSections != nil) {
            return nil
        }
        return self.dataModel.sectionModel(for: section).footerTitle
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionInt: Int) -> UIView? {
        let section = self.dataModel.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' header dequeue block - might expect a different header type.
        let dequeueBlock = (self.binder.handlers.uniquelyBoundHeaderSections.contains(section)
        || self.binder.handlers.headerViewProviders.namedSection[section] != nil) ?
            self.binder.handlers.headerViewProviders.namedSection[section] :
            self.binder.handlers.headerViewProviders.dynamicSections
        return dequeueBlock?(section, tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection sectionInt: Int) -> UIView? {
        let section = self.dataModel.displayedSections[sectionInt]
        
        let footerViewProvider: ((S, UITableView) -> UITableViewHeaderFooterView?)?
        if (self.binder.handlers.uniquelyBoundFooterSections.contains(section)
        || self.binder.handlers.footerViewProviders.namedSection[section] != nil) {
            footerViewProvider = self.binder.handlers.footerViewProviders.namedSection[section]
        } else {
            footerViewProvider = self.binder.handlers.footerViewProviders.dynamicSections
        }
        return footerViewProvider?(section, tableView)
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let tappedHandler: ((S, Int, UITableViewCell) -> Void)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.cellTappedHandlers.namedSection[section] != nil {
            tappedHandler = self.binder.handlers.cellTappedHandlers.namedSection[section]
        } else {
            tappedHandler = self.binder.handlers.cellTappedHandlers.dynamicSections
        }
        tappedHandler?(section, indexPath.row, cell)
        self.binder.handlers.cellTappedHandlers.anySection?(section, indexPath.row, cell)
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let canEdit: ((S, Int) -> Bool)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.cellEditableProviders.namedSection[section] != nil {
            canEdit = self.binder.handlers.cellEditableProviders.namedSection[section]
        } else {
            canEdit = self.binder.handlers.cellEditableProviders.dynamicSections
        }
        
        if let canEdit = canEdit {
            return canEdit(section, indexPath.row)
        } else {
            return self.dataModel.sectionModel(for: section).cellEditingStyle != .none
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let styleProvider: ((S, Int) -> UITableViewCell.EditingStyle)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.cellEditingStyleProviders.namedSection[section] != nil {
            styleProvider = self.binder.handlers.cellEditingStyleProviders.namedSection[section]
        } else {
            styleProvider = self.binder.handlers.cellEditingStyleProviders.dynamicSections
        }
        
        if let styleProvider = styleProvider {
            return styleProvider(section, indexPath.row)
        } else {
            return self.dataModel.sectionModel(for: section).cellEditingStyle
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        if editingStyle == .delete {
            let handler: ((S, Int, CellDeletionSource<S>) -> Void)?
            if self.binder.handlers.uniquelyBoundCellSections.contains(section)
            || self.binder.handlers.cellDeletedHandlers.namedSection[section] != nil {
                handler = self.binder.handlers.cellDeletedHandlers.namedSection[section]
            } else {
                handler = self.binder.handlers.cellDeletedHandlers.dynamicSections
            }
            handler?(section, indexPath.row, .editing)
        } else if editingStyle == .insert {
            let handler: ((S, Int, CellInsertionSource<S>) -> Void)?
            if self.binder.handlers.uniquelyBoundCellSections.contains(section)
                || self.binder.handlers.cellInsertedHandlers.namedSection[section] != nil {
                handler = self.binder.handlers.cellInsertedHandlers.namedSection[section]
            } else {
                handler = self.binder.handlers.cellInsertedHandlers.dynamicSections
            }
            handler?(section, indexPath.row, .editing)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let handlerSet = self.binder.handlers.cellMovableProviders
        let canMove: ((S, Int) -> Bool)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
            canMove = handlerSet.namedSection[section]
        } else {
            canMove = handlerSet.dynamicSections
        }
        
        if let canMove = canMove {
            return canMove(section, indexPath.row)
        } else {
            return self.dataModel.sectionModel(for: section).movementOption != nil
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        
        let fromSection = self.dataModel.displayedSections[sourceIndexPath.section]
        let toSection = self.dataModel.displayedSections[destinationIndexPath.section]
        
        let deleteHandler: ((S, Int, CellDeletionSource<S>) -> Void)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(fromSection)
        || self.binder.handlers.cellDeletedHandlers.namedSection[fromSection] != nil {
            deleteHandler = self.binder.handlers.cellDeletedHandlers.namedSection[fromSection]
        } else {
            deleteHandler = self.binder.handlers.cellDeletedHandlers.dynamicSections
        }
        deleteHandler?(fromSection, sourceIndexPath.row, .moved(toSection: toSection, row: destinationIndexPath.row))
        
        let insertHandler: ((S, Int, CellInsertionSource<S>) -> Void)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(fromSection)
            || self.binder.handlers.cellInsertedHandlers.namedSection[fromSection] != nil {
            insertHandler = self.binder.handlers.cellInsertedHandlers.namedSection[fromSection]
        } else {
            insertHandler = self.binder.handlers.cellInsertedHandlers.dynamicSections
        }
        insertHandler?(fromSection, destinationIndexPath.row, .moved(fromSection: toSection, row: sourceIndexPath.row))
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let handlerSet = self.binder.handlers.cellHeightProviders
        let heightProvider: ((S, Int) -> CGFloat)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }

        return heightProvider?(section, indexPath.row) ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.headerHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.binder.handlers.uniquelyBoundHeaderSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }

        return heightProvider?(section) ?? tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.footerHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.binder.handlers.uniquelyBoundFooterSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section) ?? tableView.sectionFooterHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let handlerSet = self.binder.handlers.cellEstimatedHeightProviders
        let heightProvider: ((S, Int) -> CGFloat)?
        if self.binder.handlers.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section, indexPath.row) ?? tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.headerEstimatedHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.binder.handlers.uniquelyBoundHeaderSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section) ?? tableView.estimatedSectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection sectionInt: Int) -> CGFloat {
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.footerEstimatedHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.binder.handlers.uniquelyBoundFooterSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section) ?? tableView.estimatedSectionFooterHeight
    }
}
