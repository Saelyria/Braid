import UIKit

/**
 An enum that describes at what point a section binder should call a 'data prefetch' handler.
 */
public enum PrefetchBehavior {
    /// The default UIKit behaviour. If this is used, the binder will use a `UITableViewDataSourcePrefetching`
    /// conformance to determine when to indicate that data should be prefetched.
//    case tableViewDecides
    /// The binder will incidate that data should be prefetched when the table is the given number of cells away
    /// from the end of the section.
    case cellsFromEnd(Int)
    /// The binder will incidate that data should be prefetched when the table is the given distance in points away
    /// from the end of the section.
//    case distanceFromEnd(CGFloat)
}

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
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, viewModels: { viewModels })
    }
    
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
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, viewModels: { viewModels })
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A closure that will return the view models to bind to the the dequeued cells for this
        section. This closure is called whenever the section is refreshed.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: @escaping () -> [NC.ViewModel])
        -> TableViewSingleSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A closure that will return the view models to bind to the the dequeued cells for this
        section. This closure is called whenever the section is refreshed.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: @escaping () -> [NC.ViewModel])
        -> TableViewSingleSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    private func _bind<NC>(
        cellType: NC.Type,
        viewModels: @escaping () -> [NC.ViewModel])
        -> TableViewSingleSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        let section = self.section
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateCellModels(nil, viewModels: [section: viewModels()], affectedSections: scope)
        }
        
        return TableViewSingleSectionBinder<NC, S>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
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
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
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
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
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
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
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
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return the model objects to bind to the dequeued cells for this section.
     - parameter mapToViewModel: A function that, when given a model from the `models` array, will create a view model
        for the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.

     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return the model objects to bind to the dequeued cells for this section.
     - parameter mapToViewModel: A function that, when given a model from the `models` array, will create a view model
        for the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
    */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
 
     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return the model objects to bind to the dequeued cells for this section.
     - parameter mapToViewModel: A function that, when given a model from the `models` array, will create a view model
        for the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return the model objects to bind to the dequeued cells for this section.
     - parameter mapToViewModel: A function that, when given a model from the `models` array, will create a view model
        for the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        let section = self.section
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            let _models = models()
            let viewModels = [section: _models.map(mapToViewModels)]
            binder?.updateCellModels([section: _models], viewModels: viewModels, affectedSections: scope)
        }
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell
    {
        return self._bind(cellType: cellType, models: { models })
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models })
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.

     When using this method, it is expected that you also provide a handler to the `onDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return the models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell
    {
        return self._bind(cellType: cellType, models: models)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return the models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        let section = self.section
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            let _models = models()
            binder?.updateCellModels([section: _models], viewModels: nil, affectedSections: scope)
        }
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: [NM])
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: { models })
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: [NM])
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
        where NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellProvider: cellProvider, models: { models })
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.

     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A closure that will return the models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A closure that will return the models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
        where NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    private func _bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
    {
        let _cellProvider: (UITableView, S, Int) -> UITableViewCell
        _cellProvider = { [weak binder = self.binder] (table, section, row) -> UITableViewCell in
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? NM else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(table, row, model)
        }
        self.binder.addCellDequeueBlock(cellProvider: _cellProvider, affectedSections: self.affectedSectionScope)
        let section = self.section
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            let _models = models()
            binder?.updateCellModels([section: _models], viewModels: nil, affectedSections: scope)
        }

        return TableViewModelSingleSectionBinder<UITableViewCell, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the section, along with the number of cells to create.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for the section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ table: UITableView, _ row: Int) -> UITableViewCell,
        numberOfCells: Int)
        -> TableViewSingleSectionBinder<UITableViewCell, S>
    {
        return self.bind(cellProvider: cellProvider, numberOfCells: { numberOfCells })
    }
    
    /**
     Bind a custom handler that will provide table view cells for the section, along with the number of cells to create.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: A closure that will return the number of cells to create for the section using the
        provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ table: UITableView, _ row: Int) -> UITableViewCell,
        numberOfCells: @escaping () -> Int)
        -> TableViewSingleSectionBinder<UITableViewCell, S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, affectedSections: self.affectedSectionScope)
        let section = self.section
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateNumberOfCells([section: numberOfCells()], affectedSections: scope)
        }
        
        return TableViewSingleSectionBinder<UITableViewCell, S>(binder: self.binder, section: self.section)
    }
    
    /**
     Binds a handler that will be called when new data should be prefetched for the table.
     
     This method is called with a 'prefetch behaviour' - this is an enum case that describes a heuristic the binder
     should use to determine when data should be prefetched, such as 'when we're X number of cells from the end of the
     section'. The binder will call the given 'prefetch handler' (according to the given behaviour) when new data should
     be prefetched.
     
     - parameter prefetchBehaviour: A behavior indicating when a data prefetch should start. Defaults to 'when there are
        two cells left in before the end of the section'.
     - parameter prefetchHandler: A closure called that should prefetch new data for the section.
     - parameter startingIndex: The starting index from which data should be fetched for.
    */
    @discardableResult
    public func prefetch(
        when prefetchBehaviour: PrefetchBehavior = .cellsFromEnd(2),
        with prefetchHandler: @escaping (_ startingIndex: Int) -> Void)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.handlers.sectionPrefetchBehavior[self.section] = prefetchBehaviour
        self.binder.handlers.sectionPrefetchHandlers[self.section] = prefetchHandler
        return self
    }

    // MARK: -
    
    /**
     Binds the given header type to the declared section with the given view model.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModel: The view model to bind to the section's header when it is dequeued.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModel: H.ViewModel?)
        -> TableViewSingleSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable
    {
        return self.bind(headerType: headerType, viewModel: { viewModel })
    }
    
    /**
     Binds the given header type to the declared section with the given view model.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModel: The view model to bind to the section's header when it is dequeued.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModel: @escaping () -> H.ViewModel?)
        -> TableViewSingleSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable
    {
        self.binder.handlers.sectionHeaderViewModelProviders[self.section] = viewModel
        self.binder.addHeaderDequeueBlock(headerType: headerType, affectedSections: self.affectedSectionScope)
        let scope = self.affectedSectionScope
        let section = self.section
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateHeaderViewModels([section: viewModel()], affectedSections: scope)
        }
        return self
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
        return self.bind(headerTitle: { headerTitle })
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
        headerTitle: @escaping () -> String?)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.handlers.sectionHeaderTitleProviders[self.section] = headerTitle
        self.binder.nextDataModel.uniquelyBoundHeaderSections.append(self.section)
        let scope = self.affectedSectionScope
        let section = self.section
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateHeaderTitles([section: headerTitle()], affectedSections: scope)
        }
        return self
    }
    
    /**
     Binds the given footer type to the declared section with the given view model.
     
     - parameter footerType: The class of the footer to bind.
     - parameter viewModel: The view model to bind to the section's footer when it is dequeued.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModel: F.ViewModel?)
        -> TableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable
    {
        return self.bind(footerType: footerType, viewModel: { viewModel })
    }
    
    /**
     Binds the given footer type to the declared section with the given view model.
     
     - parameter footerType: The class of the footer to bind.
     - parameter viewModel: The view model to bind to the section's footer when it is dequeued.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModel: @escaping () -> F.ViewModel?)
        -> TableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable
    {
        self.binder.handlers.sectionFooterViewModelProviders[self.section] = viewModel
        self.binder.addFooterDequeueBlock(footerType: footerType, affectedSections: self.affectedSectionScope)
        let scope = self.affectedSectionScope
        let section = self.section
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateFooterViewModels([section: viewModel()], affectedSections: scope)
        }
        return self
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
        return self.bind(footerTitle: { footerTitle })
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
        footerTitle: @escaping () -> String?)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.handlers.sectionFooterTitleProviders[self.section] = footerTitle
        self.binder.nextDataModel.uniquelyBoundFooterSections.append(self.section)
        let scope = self.affectedSectionScope
        let section = self.section
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateFooterTitles([section: footerTitle()], affectedSections: scope)
        }
        return self
    }
    
    // MARK: -
    
    /**
     Adds a handler to be called whenever a cell is dequeued in the declared section.
     
     The given handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell.
     The cell will be safely cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method. This method can be used to perform any additional configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in the bound section.
     - parameter row: The row of the cell that was dequeued.
     - parameter cell: The cell that was dequeued that can now be configured.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onDequeue(_ handler: @escaping (_ row: Int, _ cell: C) -> Void)
        -> TableViewSingleSectionBinder<C, S>
    {
        let dequeueCallback: CellDequeueCallback<S> = { (_, row, cell) in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.handlers.sectionDequeuedCallbacks[self.section] = dequeueCallback
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell in the declared section is tapped.
     
     The given handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped.
     The cell will be safely cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter row: The row of the cell that was tapped.
     - parameter cell: The cell that was tapped.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ cell: C) -> Void)
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
     Adds a handler to be called when a cell of the given type emits a custom view event.
     
     To use this method, the given cell type must conform to `ViewEventEmitting`. This protocol has the cell declare an
     associated `ViewEvent` enum type whose cases define custom events that can be observed from the binding chain.
     When a cell emits an event via its `emit(event:)` method, the handler given to this method is called with the
     event and various other objects that allows the view controller to respond.
     
     - parameter cellType: The event-emitting cell type to observe events from.
     - parameter handler: The closure to be called whenever a cell of the given cell type emits a custom event.
     - parameter row: The row of the cell that emitted an event.
     - parameter cell: The cell that emitted an event.
     - parameter event: The custom event that the cell emitted.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onEvent<EventCell>(
        from cellType: EventCell.Type,
        _ handler: @escaping (_ row: Int, _ cell: EventCell, _ event: EventCell.ViewEvent) -> Void)
        -> TableViewSingleSectionBinder<C, S>
        where EventCell: UITableViewCell & ViewEventEmitting
    {
        self.binder.addEventEmittingHandler(
            cellType: EventCell.self, handler: handler, affectedSections: self.affectedSectionScope)
        
        return self
    }
    
    
    /**
     Adds model type information to the binding chain.
     
     This method allows model type information to be assumed on any additional binding chains for a section after the
     binding chain that originally declared the cell and model type. This method will cause a crash if the model type
     originally bound to the section is not the same type or if the section was not setup with a model type.
     
     - parameter modelType: The type of the models that were bound to the section on another binding chain.
     
     - returns: A section binder to continue the binding chain with that allows cast model types to be given to items in
     its chain.
     */
    public func assuming<M>(modelType: M.Type) -> TableViewModelSingleSectionBinder<C, S, M> {
        return TableViewModelSingleSectionBinder(binder: self.binder, section: self.section)
    }
    
    // MARK: -

    /**
     Adds a handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter row: The row of the cell to provide the height for.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionCellHeightBlocks[section] = { (_, row: Int) in
            return handler(row)
        }
        return self
    }
    
    /**
     Adds a handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     
     - parameter handler: The closure to be called that will return the estimated height for cells in the section.
     - parameter row: The row of the cell to provide the estimated height for.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.handlers.sectionEstimatedCellHeightBlocks[section] = { (_, row: Int) in
            return handler(row)
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the height for the section header in the declared section.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public func headerHeight(_ handler: @escaping () -> CGFloat) -> TableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionHeaderHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section header in the declared section.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> TableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionHeaderEstimatedHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the height for the section footer in the declared section.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public func footerHeight(_ handler: @escaping () -> CGFloat) -> TableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionFooterHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section footer in the declared section.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> TableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionFooterEstimatedHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
}
