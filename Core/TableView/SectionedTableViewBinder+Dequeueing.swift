import UIKit

// Extensions on 'sectioned table view binder' to add dequeue blocks for cells, headers, and footers. These methods
// should be used instead of directly adding to the binder's dictionaries so further checks can be performed.

internal extension SectionedTableViewBinder {
    /**
     Adds a dequeueing block to the binder for a view model-bindable cell for the given sections or 'any section'.
     
     - parameter headerType: The type of cell to be bound.
     - parameter affectedSections: The section scope that this dequeueing block is used for.
     */
    func addCellDequeueBlock<C>(cellType: C.Type, affectedSections: SectionBindingScope<S>)
        where C: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, tableView, indexPath) in
            if var cell = binder?.tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath) as? C,
            let viewModel = (binder?.currentDataModel.sectionCellViewModels[section] as? [C.ViewModel])?[indexPath.row] {
                cell.viewModel = viewModel
                binder?.handlers.sectionCellDequeuedCallbacks[section]?(section, indexPath.row, cell)
                binder?.handlers.dynamicSectionsCellDequeuedCallback?(section, indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }

        self.addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a cell for the given sections or 'any section'.
     
     - parameter headerType: The type of cell to be bound.
     - parameter affectedSections: The section scope that this dequeueing block is used for.
     */
    func addCellDequeueBlock<C: UITableViewCell & ReuseIdentifiable>(
        cellType: C.Type, affectedSections: SectionBindingScope<S>)
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, tableView, indexPath) in
            if let cell = binder?.tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath) as? C {
                binder?.handlers.sectionCellDequeuedCallbacks[section]?(section, indexPath.row, cell)
                binder?.handlers.dynamicSectionsCellDequeuedCallback?(section, indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        
        self.addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a cell for the given sections or 'any section'.
     
     - parameter headerType: The type of cell to be bound.
     - parameter affectedSections: The section scope that this dequeueing block is used for.
     */
    func addCellDequeueBlock(
        cellProvider: @escaping (_ row: Int) -> UITableViewCell, affectedSections: SectionBindingScope<S>)
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { (_, _, indexPath) in
            return cellProvider(indexPath.row)
        }
        self.addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a cell for the given sections or 'any section'.
     
     - parameter headerType: The type of cell to be bound.
     - parameter affectedSections: The section scope that this dequeueing block is used for.
     */
    func addCellDequeueBlock(
        cellProvider: @escaping (_ section: S, _ row: Int) -> UITableViewCell, affectedSections: SectionBindingScope<S>)
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { (section, _, indexPath) in
            return cellProvider(section, indexPath.row)
        }
        self.addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    func addCellEqualityChecker<I: Equatable & CollectionIdentifiable>(
        itemType: I.Type, affectedSections: SectionBindingScope<S>)
    {
        let handler: (Any, Any) -> Bool? = { (lhs, rhs) in
            guard let lhs = lhs as? I, let rhs = rhs as? I else { return nil }
            return lhs == rhs
        }
        
        switch affectedSections {
        case .forNamedSections(let sections):
            for section in sections {
                self.handlers.sectionItemEqualityCheckers[section] = handler
            }
        case .forAllUnnamedSections:
            self.handlers.dynamicSectionItemEqualityChecker = handler
        case .forAnySection:
            assertionFailure("Can't add a cell equality checker for 'any section'")
        }
        
    }
    
    /**
     Adds a dequeueing block to the binder for a view model-bindable header for the given sections or 'any section'.
     
     - parameter headerType: The type of header view to be bound.
     - parameter affectedSections: The section scope that this dequeueing block is used for.
     */
    func addHeaderDequeueBlock<H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable>(
        headerType: H.Type, affectedSections: SectionBindingScope<S>)
    {
        self.addHeaderOrFooterDequeueBlock(type: headerType, isHeader: true, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a view model-bindable footer for the given sections or 'any section'.
     
     - parameter footerType: The type of footer view to be bound.
     - parameter affectedSections: The section scope that this dequeueing block is used for.
     */
    func addFooterDequeueBlock<F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable>(
        footerType: F.Type, affectedSections: SectionBindingScope<S>)
    {
        self.addHeaderOrFooterDequeueBlock(type: footerType, isHeader: false, affectedSections: affectedSections)
    }
}

private extension SectionedTableViewBinder {
    func addDequeueBlock(_ cellDequeueBlock: @escaping CellDequeueBlock<S>, affectedSections: SectionBindingScope<S>) {
        // Go over the parameters we were given and put the dequeue block in the right place on the binder
        switch affectedSections {
        case .forNamedSections(let sections):
            for section in sections {
                if self.nextDataModel.uniquelyBoundCellSections.contains(section) {
                    assertionFailure("Section '\(section)' already has a cell type bound to it - re-binding not supported.")
                    return
                }
                self.handlers.sectionCellDequeueBlocks[section] = cellDequeueBlock
            }
            self.nextDataModel.uniquelyBoundCellSections.append(contentsOf: sections)
        case .forAllUnnamedSections:
            self.handlers.dynamicSectionCellDequeueBlock = cellDequeueBlock
        case .forAnySection:
            assertionFailure("Can't add cell dequeue blocks for 'any section'")
        }
    }
    
    func addHeaderOrFooterDequeueBlock<H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable>(
        type: H.Type, isHeader: Bool, affectedSections: SectionBindingScope<S>)
    {
        // Create the dequeue block
        let dequeueBlock: HeaderFooterDequeueBlock<S> = { [weak binder = self] (section, tableView) in
            guard var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H else {
                return nil
            }
            
            if isHeader, let viewModel = binder?.currentDataModel.sectionHeaderViewModels[section] as? H.ViewModel {
                view.viewModel = viewModel
                return view
            } else if !isHeader, let viewModel = binder?.currentDataModel.sectionFooterViewModels[section] as? H.ViewModel {
                view.viewModel = viewModel
                return view
            }
            
            return nil
        }
        
        // Go over the parameters we were given and put the dequeue block in the right place on the binder
        if isHeader {
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    if self.nextDataModel.uniquelyBoundHeaderSections.contains(section) {
                        print("Section '\(section)' already has a header type bound to it - re-binding not supported.")
                        return
                    }
                    self.handlers.sectionHeaderDequeueBlocks[section] = dequeueBlock
                }
                self.nextDataModel.uniquelyBoundHeaderSections.append(contentsOf: sections)
            case .forAllUnnamedSections:
                self.handlers.dynamicSectionsHeaderDequeueBlock = dequeueBlock
            case .forAnySection:
                assertionFailure("Can't add header dequeue blocks for 'any section'")
            }
        } else {
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    if self.nextDataModel.uniquelyBoundFooterSections.contains(section) {
                        print("Section '\(section)' already has a footer type bound to it - re-binding not supported.")
                        return
                    }
                    self.handlers.sectionFooterDequeueBlocks[section] = dequeueBlock
                }
                self.nextDataModel.uniquelyBoundFooterSections.append(contentsOf: sections)
            case .forAllUnnamedSections:
                self.handlers.dynamicSectionsFooterDequeueBlock = dequeueBlock
            case .forAnySection:
                assertionFailure("Can't add footer dequeue blocks for 'any section'")
            }
        }
    }
}
