import UIKit

/// Protocol that allows us to have Reactive extensions
public protocol TableViewMutliSectionBinderProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
}

/**
 An object used to continue a binding chain.

 This is a throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a
 number of methods that take a binding handler and give it to the original table view binder to store for callback. A
 reference to this object should not be kept and should only be used in a binding chain.
*/
public class TableViewMutliSectionBinder<C: UITableViewCell, S: TableViewSection>
    : TableViewMutliSectionBinderProtocol
{
    internal let binder: SectionedTableViewBinder<S>
    internal let sections: [S]?
    internal var affectedSectionScope: SectionBindingScope<S> {
        if let sections = self.sections {
            return .forNamedSections(sections)
        } else {
            return .forAllUnnamedSections
        }
    }
    
    internal init(binder: SectionedTableViewBinder<S>, sections: [S]?) {
        self.binder = binder
        self.sections = sections
    }
    
    // MARK: -
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value are the view models for the cells
     created for the section. This dictionary does not need to contain a view models array for each section being
     bound - sections not present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: @autoclosure () -> [S: [NC.ViewModel]])
        -> TableViewMutliSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value are the view models for the cells
        created for the section. This dictionary does not need to contain a view models array for each section being
        bound - sections not present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: @autoclosure () -> [S: [NC.ViewModel]])
        -> TableViewMutliSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    private func _bind<NC>(
        cellType: NC.Type,
        viewModels: @autoclosure () -> [S: [NC.ViewModel]])
        -> TableViewMutliSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        self.binder.updateCellModels(nil, viewModels: viewModels(), affectedSections: self.affectedSectionScope)
        
        return TableViewMutliSectionBinder<NC, S>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in a dictionary of arrays of your raw models and a function that transforms them
     into the view models for the cells. This function is stored so, if you later update the models for the section
     using the section binder's created 'update' callback, the models can be mapped to the cells' view models.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
     the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in a dictionary of arrays of your raw models and a function that transforms them
     into the view models for the cells. This function is stored so, if you later update the models for the section
     using the section binder's created 'update' callback, the models can be mapped to the cells' view models.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
     the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in a dictionary of arrays of your raw models and a function that transforms them
     into the view models for the cells. This function is stored so, if you later update the models for the section
     using the section binder's created 'update' callback, the models can be mapped to the cells' view models.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
     the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in a dictionary of arrays of your raw models and a function that transforms them
     into the view models for the cells. This function is stored so, if you later update the models for the section
     using the section binder's created 'update' callback, the models can be mapped to the cells' view models.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
     the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        var viewModels: [S: [Any]] = [:]
        let _models = models()
        for (s, m) in _models {
            viewModels[s] = m.map(mapToViewModels)
        }
        self.binder.updateCellModels(_models, viewModels: viewModels, affectedSections: self.affectedSectionScope)
        
        return TableViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
     model to the cell manually. This handler will be passed in a model cast to this model type if the `onCellDequeue`
     method is called after this method.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, models: models)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
     model to the cell manually. This handler will be passed in a model cast to this model type if the `onCellDequeue`
     method is called after this method.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: @autoclosure () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        self.binder.updateCellModels(models(), viewModels: nil, affectedSections: self.affectedSectionScope)
        
        return TableViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, created according to the given
     models.
     
     Use this method if you want more manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, or you have some other
     particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @autoclosure () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, created according to the given
     models.
     
     Use this method if you want more manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, or you have some other
     particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section. This dictionary does not need to contain a models array for each section being bound - sections not
     present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @autoclosure () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
        where NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    private func _bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @autoclosure () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
    {
        let _cellProvider: (UITableView, S, Int) -> UITableViewCell
        _cellProvider = { [weak binder = self.binder] (_ table, _ section, _ row) -> UITableViewCell in
            guard let models = binder?.currentDataModel.sectionCellModels[section] as? [NM] else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(table, section, row, models[row])
        }
        self.binder.addCellDequeueBlock(cellProvider: _cellProvider, affectedSections: self.affectedSectionScope)
        self.binder.updateCellModels(models(), viewModels: nil, affectedSections: self.affectedSectionScope)
        
        return TableViewModelMultiSectionBinder<UITableViewCell, S, NM>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, along with the number of cells
     to create.
     
     Use this method if you want full manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, cells in the section are
     not necessarily backed by a data model type, or you have particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for each section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int) -> UITableViewCell,
        numberOfCells: @autoclosure () -> [S: Int])
        -> TableViewMutliSectionBinder<UITableViewCell, S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, affectedSections: self.affectedSectionScope)
        self.binder.updateNumberOfCells(numberOfCells(), affectedSections: self.affectedSectionScope)
        
        return TableViewMutliSectionBinder<UITableViewCell, S>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Binds the given header type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section header with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value is the header view model for the
        header created for the section. This dictionary does not need to contain a view model for each section being
        bound - sections not present in the dictionary have no header view created for them. This view models dictionary
        should not contain entries for sections not declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModels: @autoclosure () -> [S: H.ViewModel])
        -> TableViewMutliSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        let scope = self.affectedSectionScope
        self.binder.addHeaderDequeueBlock(headerType: headerType, affectedSections: self.affectedSectionScope)
        self.binder.updateHeaderViewModels(viewModels(), affectedSections: scope)
        
        return self
    }
    
    /**
     Binds the given titles to the section's headers.
     
     This method will provide the given titles as the titles for the iOS native section headers. If you have bound a
     custom header type to the table view using the `bind(headerType:viewModels:)` method, this method will do nothing.
     
     - parameter titles: A dictionary where the key is a section and the value is the title for the section. This
        dictionary does not need to contain a title for each section being bound - sections not present in the
        dictionary have no title assigned to them. This titles dictionary cannot contain entries for sections not
        declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        headerTitles: @autoclosure () -> [S: String])
        -> TableViewMutliSectionBinder<C, S>
    {
        self.binder.nextDataModel.headerTitleBound = true
        self.binder.updateHeaderTitles(headerTitles(), affectedSections: self.affectedSectionScope)
        return self
    }
    
    /**
     Binds the given footer type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section footer with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter footerType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value is the footer view model for the
        footer created for the section. This dictionary does not need to contain a view model for each section being
        bound - sections not present in the dictionary have no footer view created for them. This view models dictionary
        cannot contain entries for sections not declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModels: @autoclosure () -> [S: F.ViewModel])
        -> TableViewMutliSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        let scope = self.affectedSectionScope
        self.binder.addFooterDequeueBlock(footerType: footerType, affectedSections: self.affectedSectionScope)
        self.binder.updateFooterViewModels(viewModels(), affectedSections: scope)
        
        return self
    }
    
    /**
     Binds the given titles to the section's footers.
     
     This method will provide the given titles as the titles for the iOS native section footers. If you have bound a
     custom footer type to the table view using the `bind(footerType:viewModels:)` method, this method will do nothing.
     
     - parameter titles: A dictionary where the key is a section and the value is the title for the footer section. This
        dictionary does not need to contain a footer title for each section being bound - sections not present in the
        dictionary have no footer title assigned to them. This titles dictionary cannot contain entries for sections not
        declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        footerTitles: @autoclosure () -> [S: String])
        -> TableViewMutliSectionBinder<C, S>
    {
        let scope = self.affectedSectionScope
        self.binder.updateFooterTitles(footerTitles(), affectedSections: scope)
        
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell is dequeued in one of the declared sections.
     
     The given handler is called whenever a cell in one of the sections being bound is dequeued, passing in the row and
     the dequeued cell. The cell will be safely cast to the cell type bound to the section if this method is called in a
     chain after the `bind(cellType:viewModels:)` method. This method can be used to perform any additional
     configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in one of the bound sections.
     - parameter section: The section in which a cell was dequeued.
     - parameter row: The row of the cell that was dequeued.
     - parameter dequeuedCell: The cell that was dequeued that can now be configured.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void)
        -> TableViewMutliSectionBinder<C, S>
    {
        let callback: CellDequeueCallback<S> = { (section: S, row: Int, cell: UITableViewCell) in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell)
        }
        
        switch self.affectedSectionScope {
        case .forNamedSections(let sections):
            for section in sections {
                self.binder.handlers.sectionCellDequeuedCallbacks[section] = callback
            }
        case .forAllUnnamedSections:
            self.binder.handlers.dynamicSectionsCellDequeuedCallback = callback
        default: break
        }
        
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell in one of the declared sections is tapped.
     
     The given handler is called whenever a cell in one of the sections being bound  is tapped, passing in the row and
     cell that was tapped. The cell will be safely cast to the cell type bound to the section if this method is called
     in a chain after the `bind(cellType:viewModels:)` method.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter section: The section in which a cell was tapped.
     - parameter row: The row of the cell that was tapped.
     - parameter tappedCell: The cell that was tapped.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void)
        -> TableViewMutliSectionBinder<C, S>
    {
        let callback: CellTapCallback<S> = { (section: S, row: Int, tappedCell: UITableViewCell) in
            guard let tappedCell = tappedCell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(section, row, tappedCell)
        }
        
        switch self.affectedSectionScope {
        case .forNamedSections(let sections):
            for section in sections {
                self.binder.handlers.sectionCellTappedCallbacks[section] = callback
            }
        case .forAllUnnamedSections:
            self.binder.handlers.dynamicSectionsCellTappedCallback = callback
        default: break
        }
        
        return self
    }
    
    /**
     Add handlers for various dimensions of cells for the sections being bound.
     
     This method is called with handlers that provide dimensions like cell or header heights and estimated heights. The
     various handlers are made with the static functions on `MultiSectionDimension`. A typical dimension-binding call
     looks something like this:
     
     ```
     binder.onSections(.first, .second)
        .dimensions(
            .cellHeight { UITableViewAutomaticDimension },
            .estimatedCellHeight { section, row in
                 switch section {
                 case .first: return 120
                 case .second: return 100
                 }
            },
            .headerHeight { 50 })
     ```
     
     - parameter dimensions: A variadic list of dimensions bound for the sections being bound. These 'dimension' objects
        are returned from the various dimension-binding static functions on `MultiSectionDimension`.
     
     - returns: A section binder to continue the binding chain with.
    */
    @discardableResult
    public func dimensions(_ dimensions: MultiSectionDimension<S>...) -> TableViewMutliSectionBinder<C, S> {
        self._dimensions(dimensions)
        return self
    }
    
    internal func _dimensions(_ dimensions: [MultiSectionDimension<S>]) {
        for dimension in dimensions {
            dimension.bindingFunc(self.binder, self.affectedSectionScope)
        }
    }
}
