import UIKit

/// Protocol that allows us to have Reactive extensions
public protocol TableViewSingleSectionBinderProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
}

/**
 An object used to continue a binding chain.
 
 This is a throwaway object created when a table view binder's `onSection(_:)` method is called. This object declares a
 number of methods that take a binding handler and give it to the original table view binder to store for callback. A
 reference to this object should not be kept and should only be used in a binding chain.
 */
public class TableViewSingleSectionBinder<C: UITableViewCell, S: TableViewSection>
    : TableViewSingleSectionBinderProtocol
{
    let binder: SectionedTableViewBinder<S>
    let section: S
    var affectedSectionScope: SectionBindingScope<S> {
        return .forNamedSections([self.section])
    }
    
    init(binder: SectionedTableViewBinder<S>, section: S) {
        self.binder = binder
        self.section = section
    }
    
    // MARK: -
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: The view models to bind to the the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: [NC.ViewModel])
        -> TableViewSingleSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: [self.section])
        self.binder.updateCellModels(
            nil, viewModels: [self.section: viewModels], affectedSections: self.affectedSectionScope)
        
        return TableViewSingleSectionBinder<NC, S>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: The view models to bind to the the dequeued cells for this section.
     - parameter callbackRef: A reference to a closure that is called with an array of new view models. A new 'update
        callback' closure is created and assigned to this reference that can be used to update the view models for the
        bound section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: [NC.ViewModel],
        updatedBy callbackRef: inout (_ newModels: [NC.ViewModel]) -> Void)
        -> TableViewSingleSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: ([NC.ViewModel]) -> Void
        updateCallback = { [weak binder = self.binder] (viewModels) in
            binder?.updateCellModels(nil, viewModels: [section: viewModels], affectedSections: scope)
        }
        callbackRef = updateCallback
        
        return self.bind(cellType: cellType, viewModels: viewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in an array of your raw models and a function that transforms them into the view
     models for the cells. This function is stored so, if you later update the models for the section using the section
     binder's created 'update' callback, the models can be mapped to the cells' view models.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The model objects to bind to the dequeued cells for this section.
     - parameter mapToViewModel: A function that, when given a model from the `models` array, will create a view model
        for the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [NM],
        mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: [self.section])
        let viewModels = [self.section: models.map(mapToViewModel)]
        self.binder.updateCellModels(
            [self.section: models], viewModels: viewModels, affectedSections: self.affectedSectionScope)
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in an array of your raw models and a function that transforms them into the view
     models for the cells. This function is stored so, if you later update the models for the section using the section
     binder's created 'update' callback, the models can be mapped to the cells' view models.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The model objects to bind to the dequeued cells for this section.
     - parameter mapToViewModel: A function that, when given a model from the `models` array, will create a view model
        for the associated cell using the data from the model object.
     - parameter callbackRef: A reference to a closure that is called with an array of new models. A new 'update
        callback' closure is created and assigned to this reference that can be used to update the models for the bound
        section after binding. Models passed to this closure are mapped to view models using the supplied
        `mapToViewModel` function.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [NM],
        mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel,
        updatedBy callbackRef: inout (_ newModels: [NM]) -> Void)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: ([NM]) -> Void
        updateCallback = { [weak binder = self.binder, mapToViewModel] (models) in
            let viewModels = models.map(mapToViewModel)
            binder?.updateCellModels([section: models], viewModels: [section: viewModels], affectedSections: scope)
        }
        callbackRef = updateCallback
        
        return self.bind(cellType: cellType, models: models, mapToViewModelsWith: mapToViewModel)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents and the cells. When binding with this method, various other event binding methods (most notably the
     `onTapped` and `onCellDequeue` event methods) can have their handlers be passed in the associated model (cast to
     the same type as the models observable type) along with the row and cell.
     
     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
     model to the cell manually. This handler will be passed in a model cast to this model type if the `onCellDequeue`
     method is called after this method.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: [self.section])
        self.binder.updateCellModels(
            [self.section: models], viewModels: nil, affectedSections: self.affectedSectionScope)
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents and the cells. When binding with this method, various other event binding methods (most notably the
     `onTapped` and `onCellDequeue` event methods) can have their handlers be passed in the associated model (cast to
     the same type as the models observable type) along with the row and cell.
     
     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
     model to the cell manually. This handler will be passed in a model cast to this model type if the `onCellDequeue`
     method is called after this method.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     - parameter callbackRef: A reference to a closure that is called with an array of new models. A new 'update
        callback' closure is created and assigned to this reference that can be used to update the models for the bound
        section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [NM],
        updatedBy callbackRef: inout (_ newModels: [NM]) -> Void)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: ([NM]) -> Void
        updateCallback = { [weak binder = self.binder] (models) in
            binder?.updateCellModels([section: models], viewModels: nil, affectedSections: scope)
        }
        callbackRef = updateCallback
        
        return self.bind(cellType: cellType, models: models)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     Use this method if you want more manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, or you have some other
     particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ row: Int, _ model: NM) -> UITableViewCell,
        models: [NM])
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
    {
        let _cellProvider = { [weak binder = self.binder] (_ section: S, _ row: Int) -> UITableViewCell in
            guard let models = binder?.currentDataModel.sectionCellModels[section] as? [NM] else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(row, models[row])
        }
        self.binder.addCellDequeueBlock(cellProvider: _cellProvider, sections: [self.section])
        self.binder.updateCellModels(
            [self.section: models], viewModels: nil, affectedSections: self.affectedSectionScope)
        
        return TableViewModelSingleSectionBinder<UITableViewCell, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     Use this method if you want more manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, or you have some other
     particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     - parameter callbackRef: A reference to a closure that is called with an array of new models. A new 'update
        callback' closure is created and assigned to this reference that can be used to update the models for the bound
        section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ row: Int, _ model: NM) -> UITableViewCell,
        models: [NM],
        updatedBy callbackRef: inout (_ newModels: [NM]) -> Void)
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: ([NM]) -> Void
        updateCallback = { [weak binder = self.binder] (models) in
            binder?.updateCellModels([section: models], viewModels: nil, affectedSections: scope)
        }
        callbackRef = updateCallback
        
        return self.bind(cellProvider: cellProvider, models: models)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the section, along with the number of cells to create.
     
     Use this method if you want full manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, cells in the section are not necessarily backed by a data model type,
     or you have particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for the section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ row: Int) -> UITableViewCell,
        numberOfCells: Int)
        -> TableViewSingleSectionBinder<UITableViewCell, S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, sections: [self.section])
        self.binder.updateNumberOfCells([self.section: numberOfCells], affectedSections: self.affectedSectionScope)
        
        return TableViewSingleSectionBinder<UITableViewCell, S>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the section, along with the number of cells to create.
     
     Use this method if you want full manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, cells in the section are not necessarily backed by a data model type,
     or you have particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for the section using the provided closure.
     - parameter callbackRef: A reference to a closure that is called with an integer representing the number of cells
        in the section. A new 'update callback' closure is created and assigned to this reference that can be used to
        update the number of cells for the bound section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ row: Int) -> UITableViewCell,
        numberOfCells: Int,
        updatedBy callbackRef: inout (_ numCells: Int) -> Void)
        -> TableViewSingleSectionBinder<UITableViewCell, S>
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: (Int) -> Void
        updateCallback = { [weak binder = self.binder] (numCells) in
            binder?.updateNumberOfCells([section: numCells], affectedSections: scope)
        }
        callbackRef = updateCallback
        
        return self.bind(cellProvider: cellProvider, numberOfCells: numberOfCells)
    }

    // MARK: -
    
    /**
     Binds the given header type to the declared section with the given view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section header with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModel: The view model to bind to the section's header when it is dequeued.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModel: H.ViewModel?)
        -> TableViewSingleSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addHeaderDequeueBlock(headerType: headerType, sections: [self.section])
        self.binder.updateHeaderViewModels([self.section: viewModel], affectedSections: self.affectedSectionScope)
        
        return self
    }
    
    /**
     Binds the given header type to the declared section with the given view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section header with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModel: The view model to bind to the section's header when it is dequeued.
     - parameter callbackRef: A reference to a closure that is called with a new view model for the header in the
        section. A new 'update callback' closure is created and assigned to this reference that can be used to
        update the header view model for the bound section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModel: H.ViewModel?,
        updatedBy callbackRef: inout (_ newViewModel: H.ViewModel?) -> Void)
        -> TableViewSingleSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: (H.ViewModel?) -> Void
        updateCallback = { [weak binder = self.binder] (viewModel) in
            binder?.updateHeaderViewModels([section: viewModel], affectedSections: scope)
        }
        callbackRef = updateCallback
        
        return self.bind(headerType: headerType, viewModel: viewModel)
    }
    
    /**
     Binds the given title to the section's header.
     
     This method will provide the given title as the title for the iOS native section headers. If you have bound a
     custom header type to the table view using the `bind(headerType:viewModel:)` method, this method will do nothing.
     
     - parameter headerTitle: The title to use for the section's header.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        headerTitle: String?)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.updateHeaderTitles([self.section: headerTitle], affectedSections: self.affectedSectionScope)
        
        return self
    }
    
    /**
     Binds the given title to the section's header.
     
     This method will provide the given title as the title for the iOS native section headers. If you have bound a
     custom header type to the table view using the `bind(headerType:viewModel:)` method, this method will do nothing.
     
     - parameter headerTitle: The title to use for the section's header.
     - parameter callbackRef: A reference to a closure that is called with a new title for the header in the section. A
        new 'update callback' closure is created and assigned to this reference that can be used to update the header
        title for the bound section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        headerTitle: String?,
        updatedBy callbackRef: inout (_ newTitle: String?) -> Void)
        -> TableViewSingleSectionBinder<C, S>
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: (String?) -> Void
        updateCallback = { [weak binder = self.binder] (title) in
            binder?.updateHeaderTitles([section: title], affectedSections: scope)
        }
        callbackRef = updateCallback

        return self.bind(headerTitle: headerTitle)
    }
    
    /**
     Binds the given footer type to the declared section with the given view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section footer with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter footerType: The class of the footer to bind.
     - parameter viewModel: The view model to bind to the section's footer when it is dequeued.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModel: F.ViewModel?)
        -> TableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addFooterDequeueBlock(footerType: footerType, sections: [self.section])
        self.binder.updateFooterViewModels([self.section: viewModel], affectedSections: self.affectedSectionScope)
        
        return self
    }
    
    /**
     Binds the given footer type to the declared section with the given view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section footer with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter footerType: The class of the footer to bind.
     - parameter viewModel: The view model to bind to the section's footer when it is dequeued.
     - parameter callbackRef: A reference to a closure that is called with a new view model for the footer in the
        section. A new 'update callback' closure is created and assigned to this reference that can be used to
        update the footer view model for the bound section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModel: F.ViewModel?,
        updatedBy callbackRef: inout (_ newViewModel: F.ViewModel?) -> Void)
        -> TableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: (F.ViewModel?) -> Void
        updateCallback = { [weak binder = self.binder] (viewModel) in
            binder?.updateFooterViewModels([section: viewModel], affectedSections: scope)
        }
        callbackRef = updateCallback
        
        return self.bind(footerType: footerType, viewModel: viewModel)
    }
    
    /**
     Binds the given title to the section's footer.
     
     This method will provide the given title as the title for the iOS native section footers. If you have bound a
     custom footer type to the table view using the `bind(footerType:viewModel:)` method, this method will do nothing.
     
     - parameter footerTitle: The title to use for the section's footer.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        footerTitle: String?)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.updateFooterTitles([self.section: footerTitle], affectedSections: self.affectedSectionScope)
        
        return self
    }
    
    /**
     Binds the given title to the section's footer.
     
     This method will provide the given title as the title for the iOS native section footers. If you have bound a
     custom footer type to the table view using the `bind(footerType:viewModel:)` method, this method will do nothing.
     
     - parameter footerTitle: The title to use for the section's footer.
     - parameter callbackRef: A reference to a closure that is called with a new title for the footer in the section. A
        new 'update callback' closure is created and assigned to this reference that can be used to update the footer
        title for the bound section after binding.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        footerTitle: String?,
        updatedBy callbackRef: inout (_ newTitle: String?) -> Void)
        -> TableViewSingleSectionBinder<C, S>
    {
        let section = self.section
        let scope = self.affectedSectionScope
        let updateCallback: (String?) -> Void
        updateCallback = { [weak binder = self.binder] (title) in
            binder?.updateFooterTitles([section: title], affectedSections: scope)
        }
        callbackRef = updateCallback
 
        return self.bind(footerTitle: footerTitle)
    }
    
    // MARK: -
    
    /**
     Adds a handler to be called whenever a cell is dequeued in the declared section.
     
     The given handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell.
     The cell will be safely cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method. This method can be used to perform any additional configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in the bound section.
     - parameter row: The row of the cell that was dequeued.
     - parameter dequeuedCell: The cell that was dequeued that can now be configured.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void)
        -> TableViewSingleSectionBinder<C, S>
    {
        let dequeueCallback: CellDequeueCallback<S> = { (_, row, cell) in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.handlers.sectionCellDequeuedCallbacks[self.section] = dequeueCallback
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell in the declared section is tapped.
     
     The given handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped.
     The cell will be safely cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter row: The row of the cell that was tapped.
     - parameter tappedCell: The cell that was tapped.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void)
        -> TableViewSingleSectionBinder<C, S>
    {
        let tappedHandler: CellTapCallback<S> = { (_, row, cell) in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.handlers.sectionCellTappedCallbacks[self.section] = tappedHandler
        return self
    }

    /**
     Add handlers for various dimensions of cells for the section being bound.
     
     This method is called with handlers that provide dimensions like cell or header heights and estimated heights. The
     various handlers are made with the static functions on `MultiSectionDimension`. A typical dimension-binding call
     looks something like this:
     
     ```
     binder.onSection(.first)
        .dimensions(
            .cellHeight { row in UITableViewAutomaticDimension },
            .estimatedCellHeight { row in 100 },
            .headerHeight { 50 })
     ```
     
     - parameter dimensions: A variadic list of dimensions bound for the section being bound. These 'dimension' objects
        are returned from the various dimension-binding static functions on `SingleSectionDimension`.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func dimensions(_ dimensions: SingleSectionDimension<S>...) -> TableViewSingleSectionBinder<C, S> {
        self._dimensions(dimensions)
        return self
    }
    
    internal func _dimensions(_ dimensions: [SingleSectionDimension<S>]) {
        for dimension in dimensions {
            dimension.bindingFunc(self.binder, self.section)
        }
    }
}
