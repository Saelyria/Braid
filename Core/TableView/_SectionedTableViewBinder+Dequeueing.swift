import UIKit

// Extensions on 'sectioned table view binder' to add dequeue blocks for cells, headers, and footers. These methods
// should be used instead of directly adding to the binder's dictionaries so further checks can be performed.

internal extension SectionedTableViewBinder {
    /**
     Adds a dequeueing block to the binder for a view model-bindable cell for the given sections or 'any section'.
     */
    func addCellDequeueBlock<C>(cellType: C.Type, affectedSections: SectionBindingScope<S>)
        where C: UITableViewCell & ViewModelBindable
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, tableView, indexPath) in
            let reuseIdentifier = (cellType as? ReuseIdentifiable.Type)?.reuseIdentifier
                ?? cellType.classNameReuseIdentifier
            if var cell = binder?.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? C,
            let viewModel = binder?.currentDataModel.item(inSection: section, row: indexPath.row)?.viewModel as? C.ViewModel {
                cell.viewModel = viewModel
                binder?.callonDequeue(cell: cell, section: section, row: indexPath.row)
                binder?.setEventCallback(onCell: cell, section: section, row: indexPath.row)
                
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        
        if self.automaticallyRegister {
            if let nibCellType = cellType as? (UITableViewCell & UINibInitable).Type {
                let reuseIdentifier = (cellType as? ReuseIdentifiable.Type)?.reuseIdentifier
                    ?? cellType.classNameReuseIdentifier
                let nib = UINib(nibName: nibCellType.nibName, bundle: nibCellType.bundle)
                self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
            } else {
                self.tableView.register(cellType)
            }
        }

        self._addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a cell for the given sections or 'any section'.
     */
    func addCellDequeueBlock<C: UITableViewCell>(
        cellType: C.Type, affectedSections: SectionBindingScope<S>)
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, tableView, indexPath) in
            let reuseIdentifier = (cellType as? ReuseIdentifiable.Type)?.reuseIdentifier
                ?? cellType.classNameReuseIdentifier
            if let cell = binder?.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? C {
                binder?.callonDequeue(cell: cell, section: section, row: indexPath.row)
                binder?.setEventCallback(onCell: cell, section: section, row: indexPath.row)
                
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        
        if self.automaticallyRegister {
            if let nibCellType = cellType as? (UITableViewCell & UINibInitable).Type {
                let reuseIdentifier = (cellType as? ReuseIdentifiable.Type)?.reuseIdentifier
                    ?? cellType.classNameReuseIdentifier
                let nib = UINib(nibName: nibCellType.nibName, bundle: nibCellType.bundle)
                self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
            } else {
                self.tableView.register(cellType)
            }
        }
        
        self._addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a cell for the given sections or 'any section'.
     */
    func addCellDequeueBlock(
        cellProvider: @escaping (_ table: UITableView, _ row: Int) -> UITableViewCell,
        affectedSections: SectionBindingScope<S>)
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, _, indexPath) in
            guard let table = binder?.tableView else { return UITableViewCell() }
            let cell = cellProvider(table, indexPath.row)
            binder?.callonDequeue(cell: cell, section: section, row: indexPath.row)
            binder?.setEventCallback(onCell: cell, section: section, row: indexPath.row)
            
            return cell
        }
        self._addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a cell for the given sections or 'any section'.
     */
    func addCellDequeueBlock(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int) -> UITableViewCell,
        affectedSections: SectionBindingScope<S>)
    {
        let cellDequeueBlock: CellDequeueBlock<S> = { [weak binder = self] (section, _, indexPath) in
            guard let table = binder?.tableView else { return UITableViewCell() }
            let cell = cellProvider(table, section, indexPath.row)
            binder?.callonDequeue(cell: cell, section: section, row: indexPath.row)
            binder?.setEventCallback(onCell: cell, section: section, row: indexPath.row)
            
            return cell
        }
        self._addDequeueBlock(cellDequeueBlock, affectedSections: affectedSections)
    }
    
    /// calls the `onDequeue` method appropriate to how the binding chain was setup
    private func callonDequeue(cell: UITableViewCell, section: S, row: Int) {
        if self.currentDataModel.uniquelyBoundCellSections.contains(section) == true {
            self.handlers.sectionDequeuedCallbacks[section]?(section, row, cell)
        } else {
            self.handlers.dynamicSectionsCellDequeuedCallback?(section, row, cell)
        }
        self.handlers.anySectionDequeuedCallback?(section, row, cell)
    }
    
    /// sets a callback handler that the cell will call in its `emit(event:)` method.
    private func setEventCallback(onCell cell: UITableViewCell, section: S, row: Int) {
        if let eventCell = cell as? UITableViewCell & AnyViewEventEmitting {
            if self.currentDataModel.uniquelyBoundCellSections.contains(section) == true {
                eventCell.eventEmitHandler = { [weak self] cell, event in
                    let eventEmitOperation = BlockOperation(block: {
                        guard let cell = cell as? UITableViewCell else { fatalError("Wasn't a cell") }
                        guard self?.tableView.visibleCells.contains(cell) == true else { return }
                        let hashCellName = String(reflecting: type(of: eventCell))
                        self?.handlers.sectionViewEventHandlers[section]?[hashCellName]?(section, row, cell, event)
                    })
                    if let tableUpdateOperation = self?.tableUpdateOperation {
                        eventEmitOperation.addDependency(tableUpdateOperation)
                    }
                    self?.viewEventOperations.append(eventEmitOperation)
                    OperationQueue.main.addOperation(eventEmitOperation)
                }
            } else {
                eventCell.eventEmitHandler = { [weak self] cell, event in
                    let eventEmitOperation = BlockOperation(block: {
                        guard let cell = cell as? UITableViewCell else { fatalError("Wasn't a cell") }
                        guard self?.tableView.visibleCells.contains(cell) == true else { return }
                        let hashCellName = String(reflecting: type(of: eventCell))
                        self?.handlers.sectionViewEventHandlers[section]?[hashCellName]?(section, row, cell, event)
                    })
                    if let tableUpdateOperation = self?.tableUpdateOperation {
                        eventEmitOperation.addDependency(tableUpdateOperation)
                    }
                    self?.viewEventOperations.append(eventEmitOperation)
                    OperationQueue.main.addOperation(eventEmitOperation)
                }
            }
        }
    }
    
    // MARK: -
    
    /// Create and store an 'item equality checker' that the binder can use in its diffing to determine whether two
    /// items in a section are equal according to the `Equatable` conformance
    func addCellEqualityChecker<I: Equatable & CollectionIdentifiable>(
        itemType: I.Type, affectedSections: SectionBindingScope<S>)
    {
        let handler: (Any, Any) -> Bool? = { (lhs, rhs) in
            guard let lhs = lhs as? I, let rhs = rhs as? I else { return nil }
            return lhs.collectionId == rhs.collectionId && lhs == rhs
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
     Store the given callback handler for custom cell events for callback when it emits events
    */
    func addEventEmittingHandler<C: UITableViewCell & ViewEventEmitting>(
        cellType: C.Type,
        handler: @escaping (_ row: Int, _ cell: C, _ event: C.ViewEvent) -> Void,
        affectedSections: SectionBindingScope<S>)
    {
        let unsafeHandler: (S, Int, UITableViewCell, Any) -> Void = { _, row, cell, event in
            guard let cell = cell as? C, let event = event as? C.ViewEvent else {
                assertionFailure("Didn't get the expected cell or event type, something went awry!")
                return
            }
            handler(row, cell, event)
        }
        self._addEventEmittingHandler(cellType: cellType, handler: unsafeHandler, affectedSections: affectedSections)
    }
    
    /**
     Store the given callback handler for custom cell events for callback when it emits events
     */
    func addEventEmittingHandler<C: UITableViewCell & ViewEventEmitting>(
        cellType: C.Type,
        handler: @escaping (_ section: S, _ row: Int, _ cell: C, _ event: C.ViewEvent) -> Void,
        affectedSections: SectionBindingScope<S>)
    {
        let unsafeHandler: (S, Int, UITableViewCell, Any) -> Void = { section, row, cell, event in
            guard let cell = cell as? C, let event = event as? C.ViewEvent else {
                assertionFailure("Didn't get the expected cell or event type, something went awry!")
                return
            }
            handler(section, row, cell, event)
        }
        self._addEventEmittingHandler(cellType: cellType, handler: unsafeHandler, affectedSections: affectedSections)
    }
    
    // MARK: -
    
    /**
     Adds a dequeueing block to the binder for a view model-bindable header for the given sections or 'any section'.
     */
    func addHeaderDequeueBlock<H: UITableViewHeaderFooterView & ViewModelBindable>(
        headerType: H.Type, affectedSections: SectionBindingScope<S>)
    {
        self._addHeaderOrFooterDequeueBlock(type: headerType, isHeader: true, affectedSections: affectedSections)
    }
    
    /**
     Adds a dequeueing block to the binder for a view model-bindable footer for the given sections or 'any section'.
     */
    func addFooterDequeueBlock<F: UITableViewHeaderFooterView & ViewModelBindable>(
        footerType: F.Type, affectedSections: SectionBindingScope<S>)
    {
        self._addHeaderOrFooterDequeueBlock(type: footerType, isHeader: false, affectedSections: affectedSections)
    }
}

private extension SectionedTableViewBinder {
    private func _addEventEmittingHandler<C: UITableViewCell & ViewEventEmitting>(
        cellType: C.Type,
        handler: @escaping (S, Int, UITableViewCell, Any) -> Void,
        affectedSections: SectionBindingScope<S>)
    {
        let hashCellName = String(reflecting: cellType)
        switch affectedSections {
        case .forNamedSections(let sections):
            for section in sections {
                if self.handlers.sectionViewEventHandlers[section] == nil {
                    self.handlers.sectionViewEventHandlers[section] = [:]
                }
                self.handlers.sectionViewEventHandlers[section]?[hashCellName] = handler
            }
        case .forAllUnnamedSections:
            self.handlers.dynamicSectionViewEventHandler[hashCellName] = handler
        case .forAnySection:
            assertionFailure("Can't add event handling blocks for 'any section'")
        }
    }
    
    func _addDequeueBlock(_ cellDequeueBlock: @escaping CellDequeueBlock<S>, affectedSections: SectionBindingScope<S>) {
        // Go over the parameters we were given and put the dequeue block in the right place on the binder
        switch affectedSections {
        case .forNamedSections(let sections):
            for section in sections {
                if self.nextDataModel.uniquelyBoundCellSections.contains(section) {
                    assertionFailure("Section '\(section)' already has a cell type bound to it - re-binding not supported.")
                    return
                }
                self.handlers.sectionDequeueBlocks[section] = cellDequeueBlock
            }
            self.nextDataModel.uniquelyBoundCellSections.append(contentsOf: sections)
        case .forAllUnnamedSections:
            self.handlers.dynamicSectionDequeueBlock = cellDequeueBlock
        case .forAnySection:
            assertionFailure("Can't add cell dequeue blocks for 'any section'")
        }
    }
    
    func _addHeaderOrFooterDequeueBlock<H: UITableViewHeaderFooterView & ViewModelBindable>(
        type: H.Type, isHeader: Bool, affectedSections: SectionBindingScope<S>)
    {
        // Create the dequeue block
        let dequeueBlock: HeaderFooterDequeueBlock<S> = { [weak binder = self] (section, tableView) in
            let reuseIdentifier = (type as? ReuseIdentifiable.Type)?.reuseIdentifier
                ?? type.classNameReuseIdentifier
            guard var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? H else {
                return nil
            }
            
            if isHeader, let viewModel = binder?.currentDataModel.sectionModel(for: section).headerViewModel as? H.ViewModel {
                view.viewModel = viewModel
                return view
            } else if !isHeader, let viewModel = binder?.currentDataModel.sectionModel(for: section).footerViewModel as? H.ViewModel {
                view.viewModel = viewModel
                return view
            }
            
            return nil
        }
        
        // Go over the parameters we were given and put the dequeue block in the right place on the binder
        if isHeader {
            self.nextDataModel.headerViewBound = true
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
            self.nextDataModel.footerViewBound = true
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
        
        if self.automaticallyRegister {
            if let nibType = type as? (UITableViewHeaderFooterView & UINibInitable).Type {
                let reuseIdentifier = (nibType as? ReuseIdentifiable.Type)?.reuseIdentifier
                    ?? nibType.classNameReuseIdentifier
                let nib = UINib(nibName: nibType.nibName, bundle: nibType.bundle)
                self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
            } else {
                self.tableView.register(type)
            }
        }
    }
}
