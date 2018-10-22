import UIKit

// Extensions on 'sectioned table view binder' to add dequeue blocks for cells, headers, and footers. These methods
// should be used instead of directly adding to the binder's dictionaries so further checks can be performed.

internal extension SectionedTableViewBinder {
    /**
     Adds a dequeueing block to the binder for a view model-bindable cell for the given sections or 'any section'.
     
     - parameter headerType: The type of cell to be bound.
     - parameter sections: The sections the dequeue block is for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func addCellDequeueBlock<C>(cellType: C.Type, sections: [S]?)
    where C: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, tableView, indexPath) in
            if var cell = binder?.tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath) as? C,
            let viewModel = (binder?.currentDataModel.sectionCellViewModels[section] as? [C.ViewModel])?[indexPath.row] {
                cell.viewModel = viewModel
                binder?.sectionCellDequeuedCallbacks[section]?(section, indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        
        self.addDequeueBlock(cellDequeueBlock, sections: sections)
    }
    
    /**
     Adds a dequeueing block to the binder for a cell for the given sections or 'any section'.
     
     - parameter headerType: The type of cell to be bound.
     - parameter sections: The sections the dequeue block is for. Single- or multi-section binders should pass in their
     'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
     sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
     `onSections` methods on the binder).
     */
    func addCellDequeueBlock<C: UITableViewCell & ReuseIdentifiable>(cellType: C.Type, sections: [S]?) {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, tableView, indexPath) in
            if let cell = binder?.tableView.dequeueReusableCell(withIdentifier: C.reuseIdentifier, for: indexPath) as? C {
                binder?.sectionCellDequeuedCallbacks[section]?(section, indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        
        self.addDequeueBlock(cellDequeueBlock, sections: sections)
    }
    
    /**
     Adds a dequeueing block to the binder for a view model-bindable header for the given sections or 'any section'.
     
     - parameter headerType: The type of header view to be bound.
     - parameter sections: The sections the dequeue block is for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func addHeaderDequeueBlock<H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable>(
        headerType: H.Type,
        sections: [S]?)
    {
        self.addHeaderOrFooterDequeueBlock(type: headerType, isHeader: true, sections: sections)
    }
    
    /**
     Adds a dequeueing block to the binder for a view model-bindable footer for the given sections or 'any section'.
     
     - parameter footerType: The type of footer view to be bound.
     - parameter sections: The sections the dequeue block is for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func addFooterDequeueBlock<F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable>(
        footerType: F.Type,
        sections: [S]?)
    {
        self.addHeaderOrFooterDequeueBlock(type: footerType, isHeader: false, sections: sections)
    }
}

private extension SectionedTableViewBinder {
    func addDequeueBlock(_ cellDequeueBlock: @escaping CellDequeueBlock<S>, sections: [S]?) {
        // Go over the parameters we were given and put the dequeue block in the right place on the binder
        if let sections = sections {
            for section in sections {
                if self.sectionCellDequeueBlocks[section] != nil {
                    assertionFailure("Section already has a cell type bound to it - re-binding not supported.")
                    return
                }
                self.sectionCellDequeueBlocks[section] = cellDequeueBlock
            }
        } else {
            self.cellDequeueBlock = cellDequeueBlock
        }
    }
    
    func addHeaderOrFooterDequeueBlock<H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable>(
        type: H.Type,
        isHeader: Bool,
        sections: [S]?)
    {
        // Create the dequeue block
        let dequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self] (tableView, sectionInt) in
            guard let section = binder?.displayedSections[sectionInt],
                var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H else {
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
            if let sections = sections {
                for section in sections {
                    if self.sectionHeaderDequeueBlocks[section] != nil {
                        print("WARNING: Section already has a header type bound to it - re-binding not supported.")
                        return
                    }
                    self.sectionHeaderDequeueBlocks[section] = dequeueBlock
                }
            } else {
                self.headerDequeueBlock = dequeueBlock
            }
        } else {
            if let sections = sections {
                for section in sections {
                    if self.sectionFooterDequeueBlocks[section] != nil {
                        print("WARNING: Section already has a footer type bound to it - re-binding not supported.")
                        return
                    }
                    self.sectionFooterDequeueBlocks[section] = dequeueBlock
                }
            } else {
                self.footerDequeueBlock = dequeueBlock
            }
        }
    }

}
