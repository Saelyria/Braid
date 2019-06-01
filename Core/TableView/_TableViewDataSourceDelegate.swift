import UIKit

/// An internal class that acts as the de facto data source / delegate to a binder's table view.
class _TableViewDataSourceDelegate<S: TableViewSection>: NSObject, UITableViewDataSource, UITableViewDelegate {

    private weak var binder: SectionedTableViewBinder<S>!
    private var dataModel: _TableViewDataModel<S>! {
        return self.binder.currentDataModel
    }
    
    /// While moving a cell, this value is set to remember the last valid index path the cell was dragged over.
    private var lastValidIndexPathWhileMovingCell: IndexPath?

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
            return self.binder.handlers.cellMovementPolicies.hasHandler ||
                self.binder.handlers.cellEditingStyleProviders.hasHandler
        case #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)):
            return self.binder.handlers.cellEditingStyleProviders.hasHandler

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
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return 0 }
        let section = self.dataModel.displayedSections[sectionInt]
        return self.dataModel.sectionModel(for: section).items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return UITableViewCell() }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        // We can't fall back to the 'all sections' cell dequeue block - might expect a different cell type.
        let handlerSet = self.binder.handlers.cellProviders
        let provider: ((S, UITableView, IndexPath) -> UITableViewCell)?
        if self.dataModel.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
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
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let prefetchBehavior: PrefetchBehavior? = self.dataModel.uniquelyBoundCellSections.contains(section) ?
            self.binder.handlers.prefetchBehaviors.namedSection[section] :
            self.binder.handlers.prefetchBehaviors.dynamicSections
        
        if let prefetchBehavior = prefetchBehavior {
            switch prefetchBehavior {
            case .cellsFromEnd(let num):
                let numItemsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
                if indexPath.row == numItemsInSection - num {
                    let prefetchHandler: ((Int) -> Void)?
                    if self.dataModel.uniquelyBoundCellSections.contains(section)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionInt: Int) -> String? {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return nil }
        let section = self.dataModel.displayedSections[sectionInt]
        
        // don't return a title if the section has a header dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' header dequeue block
        let wasBoundUniquely = self.binder.nextDataModel.uniquelyBoundHeaderSections.contains(section)
        if self.binder.handlers.headerViewProviders.namedSection[section] != nil
        || (!wasBoundUniquely && self.binder.handlers.headerViewProviders.dynamicSections != nil) {
            return nil
        }
        return self.dataModel.sectionModel(for: section).headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection sectionInt: Int) -> String? {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return nil }
        let section = self.dataModel.displayedSections[sectionInt]
        
        // don't return a title if the section has a footer dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' footer dequeue block
        let wasBoundUniquely = self.dataModel.uniquelyBoundFooterSections.contains(section)
        if self.binder.handlers.footerViewProviders.namedSection[section] != nil
        || (!wasBoundUniquely && self.binder.handlers.footerViewProviders.dynamicSections != nil) {
            return nil
        }
        return self.dataModel.sectionModel(for: section).footerTitle
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionInt: Int) -> UIView? {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return nil }
        let section = self.dataModel.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' header dequeue block - might expect a different header type.
        let dequeueBlock = (self.dataModel.uniquelyBoundHeaderSections.contains(section)
        || self.binder.handlers.headerViewProviders.namedSection[section] != nil) ?
            self.binder.handlers.headerViewProviders.namedSection[section] :
            self.binder.handlers.headerViewProviders.dynamicSections
        return dequeueBlock?(section, tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection sectionInt: Int) -> UIView? {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return nil }
        let section = self.dataModel.displayedSections[sectionInt]
        
        let footerViewProvider: ((S, UITableView) -> UITableViewHeaderFooterView?)?
        if (self.dataModel.uniquelyBoundFooterSections.contains(section)
        || self.binder.handlers.footerViewProviders.namedSection[section] != nil) {
            footerViewProvider = self.binder.handlers.footerViewProviders.namedSection[section]
        } else {
            footerViewProvider = self.binder.handlers.footerViewProviders.dynamicSections
        }
        return footerViewProvider?(section, tableView)
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let tappedHandler: ((S, Int, UITableViewCell) -> Void)?
        if self.dataModel.uniquelyBoundCellSections.contains(section)
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
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return false }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        var allowsEditing: Bool = false
        let styleProvider: ((S, Int) -> UITableViewCell.EditingStyle)?
        if self.dataModel.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.cellEditingStyleProviders.namedSection[section] != nil {
            styleProvider = self.binder.handlers.cellEditingStyleProviders.namedSection[section]
        } else {
            styleProvider = self.binder.handlers.cellEditingStyleProviders.dynamicSections
        }
        if let styleProvider = styleProvider {
            allowsEditing = !(styleProvider(section, indexPath.row) == .none)
        }
        
        let movementPolicy: CellMovementPolicy<S>?
        if self.dataModel.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.cellEditingStyleProviders.namedSection[section] != nil {
            movementPolicy = self.binder.handlers.cellMovementPolicies.namedSection[section]
        } else {
            movementPolicy = self.binder.handlers.cellMovementPolicies.dynamicSections
        }
        let allowsMovement: Bool = (movementPolicy != nil)
        
        return allowsEditing || allowsMovement
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return .none }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let styleProvider: ((S, Int) -> UITableViewCell.EditingStyle)?
        if self.dataModel.uniquelyBoundCellSections.contains(section)
        || self.binder.handlers.cellEditingStyleProviders.namedSection[section] != nil {
            styleProvider = self.binder.handlers.cellEditingStyleProviders.namedSection[section]
        } else {
            styleProvider = self.binder.handlers.cellEditingStyleProviders.dynamicSections
        }
        
        if let styleProvider = styleProvider {
            return styleProvider(section, indexPath.row)
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        if editingStyle == .delete {
            let deleteHandler: ((S, Int, CellDeletionReason<S>) -> Void)?
            if self.dataModel.uniquelyBoundCellSections.contains(section)
            || self.binder.handlers.cellDeletedHandlers.namedSection[section] != nil {
                deleteHandler = self.binder.handlers.cellDeletedHandlers.namedSection[section]
            } else {
                deleteHandler = self.binder.handlers.cellDeletedHandlers.dynamicSections
            }
            let beforeDeletionCount: Int = self.dataModel.sectionModel(for: section).count
            deleteHandler?(section, indexPath.row, .editing)
            self.binder.refresh()
            assert(beforeDeletionCount == self.binder.nextDataModel.sectionModel(for: section).count + 1, "A model wasn't deleted")
        } else if editingStyle == .insert {
            let handler: ((S, Int, CellInsertionReason<S>) -> Void)?
            if self.dataModel.uniquelyBoundCellSections.contains(section)
                || self.binder.handlers.cellInsertedHandlers.namedSection[section] != nil {
                handler = self.binder.handlers.cellInsertedHandlers.namedSection[section]
            } else {
                handler = self.binder.handlers.cellInsertedHandlers.dynamicSections
            }
            let beforeInsertionCount: Int = self.dataModel.sectionModel(for: section).count
            handler?(section, indexPath.row, .editing)
            self.binder.refresh()
            assert(beforeInsertionCount == self.binder.nextDataModel.sectionModel(for: section).count - 1, "A model wasn't inserted")
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return false }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let handlerSet = self.binder.handlers.cellMovableProviders
        let canMove: ((S, Int) -> Bool)?
        if self.dataModel.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
            canMove = handlerSet.namedSection[section]
        } else {
            canMove = handlerSet.dynamicSections
        }
        
        if let canMove = canMove {
            return canMove(section, indexPath.row)
        } else {
            let movementPolicy: CellMovementPolicy<S>?
            if self.dataModel.uniquelyBoundCellSections.contains(section)
                || self.binder.handlers.cellEditingStyleProviders.namedSection[section] != nil {
                movementPolicy = self.binder.handlers.cellMovementPolicies.namedSection[section]
            } else {
                movementPolicy = self.binder.handlers.cellMovementPolicies.dynamicSections
            }
            return movementPolicy != nil
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        guard !self.dataModel.displayedSections.isEmpty else { return sourceIndexPath }
        let section = self.dataModel.displayedSections[sourceIndexPath.section]
        var targetIndexPath: IndexPath
        
        // check if the section the cell came from had a 'movement policy'. If it did, make sure the proposed index
        // path is allowed according to the policy.
        let _movementPolicy: CellMovementPolicy<S>?
        if self.dataModel.uniquelyBoundCellSections.contains(section)
            || self.binder.handlers.cellEditingStyleProviders.namedSection[section] != nil {
            _movementPolicy = self.binder.handlers.cellMovementPolicies.namedSection[section]
        } else {
            _movementPolicy = self.binder.handlers.cellMovementPolicies.dynamicSections
        }
        guard let movementPolicy = _movementPolicy else {
            fatalError("There was no policy dictating which sections a cell are allowed to move to for section \(section) - this shouldn't be possible.")
        }
        switch movementPolicy {
        case .toSectionsIn(let allowedSections):
            let proposedSection = self.dataModel.displayedSections[proposedDestinationIndexPath.section]
            if allowedSections.contains(proposedSection) {
                targetIndexPath = proposedDestinationIndexPath
            } else {
                // if the proposed section wasn't in the 'allowed sections' array, return the last path in the last
                // allowed section instead
                targetIndexPath = self.lastValidIndexPathWhileMovingCell ?? sourceIndexPath
            }
        case .toSectionsPassing(let predicate):
            let proposedSection = self.dataModel.displayedSections[proposedDestinationIndexPath.section]
            if predicate(proposedSection) {
                targetIndexPath = proposedDestinationIndexPath
            } else {
                // if the proposed section didn't pass the predicate, return the last path in the last allowed section
                targetIndexPath = self.lastValidIndexPathWhileMovingCell ?? sourceIndexPath
            }
        case .toAnySection:
            targetIndexPath = proposedDestinationIndexPath
        }
        
        self.lastValidIndexPathWhileMovingCell = targetIndexPath
        return targetIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard !self.dataModel.displayedSections.isEmpty else { return }
        guard sourceIndexPath != destinationIndexPath else { return }
        
        // Set a flag on the binder so it knows it doesn't need to reload when the data changes
        self.binder.isPerformingCellMoving = true
        // Reset the 'last valid index path while moving cell' since we've finished moving it
        self.lastValidIndexPathWhileMovingCell = nil
        
        let fromSection = self.dataModel.displayedSections[sourceIndexPath.section]
        let toSection = self.dataModel.displayedSections[destinationIndexPath.section]
        
        let deleteHandler: ((S, Int, CellDeletionReason<S>) -> Void)?
        if self.dataModel.uniquelyBoundCellSections.contains(fromSection)
        || self.binder.handlers.cellDeletedHandlers.namedSection[fromSection] != nil {
            deleteHandler = self.binder.handlers.cellDeletedHandlers.namedSection[fromSection]
        } else {
            deleteHandler = self.binder.handlers.cellDeletedHandlers.dynamicSections
        }
        let beforeDeletionCount: Int = self.dataModel.sectionModel(for: fromSection).count
        deleteHandler?(fromSection, sourceIndexPath.row, .moved(toSection: toSection, row: destinationIndexPath.row))
        self.binder.refresh()
        assert(beforeDeletionCount == self.binder.nextDataModel.sectionModel(for: fromSection).count + 1, "A model wasn't deleted")
        
        let insertHandler: ((S, Int, CellInsertionReason<S>) -> Void)?
        if self.dataModel.uniquelyBoundCellSections.contains(toSection)
            || self.binder.handlers.cellInsertedHandlers.namedSection[toSection] != nil {
            insertHandler = self.binder.handlers.cellInsertedHandlers.namedSection[toSection]
        } else {
            insertHandler = self.binder.handlers.cellInsertedHandlers.dynamicSections
        }
        let beforeInsertionCount: Int = self.dataModel.sectionModel(for: toSection).count
        insertHandler?(toSection, destinationIndexPath.row, .moved(fromSection: fromSection, row: sourceIndexPath.row))
        self.binder.refresh()
        if fromSection == toSection {
            assert(beforeInsertionCount == self.binder.nextDataModel.sectionModel(for: toSection).count, "A model wasn't inserted")
        } else {
            assert(beforeInsertionCount == self.binder.nextDataModel.sectionModel(for: toSection).count - 1, "A model wasn't inserted")
        }
        
        // Table view don't call the 'editing style for row' method unless their 'is editing' flag is toggled
        DispatchQueue.main.async {
            tableView.isEditing.toggle()
            tableView.isEditing.toggle()
        }
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return tableView.rowHeight }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let handlerSet = self.binder.handlers.cellHeightProviders
        let heightProvider: ((S, Int) -> CGFloat)?
        if self.dataModel.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }

        return heightProvider?(section, indexPath.row) ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionInt: Int) -> CGFloat {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return tableView.sectionHeaderHeight }
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.headerHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.dataModel.uniquelyBoundHeaderSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }

        return heightProvider?(section) ?? tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection sectionInt: Int) -> CGFloat {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return tableView.sectionFooterHeight }
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.footerHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.dataModel.uniquelyBoundFooterSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section) ?? tableView.sectionFooterHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.dataModel.displayedSections.indices.contains(indexPath.section) else { return tableView.estimatedRowHeight }
        let section = self.dataModel.displayedSections[indexPath.section]
        
        let handlerSet = self.binder.handlers.cellEstimatedHeightProviders
        let heightProvider: ((S, Int) -> CGFloat)?
        if self.dataModel.uniquelyBoundCellSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section, indexPath.row) ?? tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection sectionInt: Int) -> CGFloat {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return tableView.estimatedSectionHeaderHeight }
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.headerEstimatedHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.dataModel.uniquelyBoundHeaderSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section) ?? tableView.estimatedSectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection sectionInt: Int) -> CGFloat {
        guard self.dataModel.displayedSections.indices.contains(sectionInt) else { return tableView.estimatedSectionFooterHeight }
        let section = self.dataModel.displayedSections[sectionInt]
        
        let handlerSet = self.binder.handlers.footerEstimatedHeightProviders
        var heightProvider: ((S) -> CGFloat)?
        if self.dataModel.uniquelyBoundFooterSections.contains(section) || handlerSet.namedSection[section] != nil {
            heightProvider = handlerSet.namedSection[section]
        } else {
            heightProvider = handlerSet.dynamicSections ?? handlerSet.anySection
        }
        
        return heightProvider?(section) ?? tableView.estimatedSectionFooterHeight
    }
}
