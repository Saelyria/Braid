import UIKit

/**
 An enum that describes at what point a section binder should call a 'data prefetch' handler.
 */
public enum PrefetchBehavior {
    /// The default UIKit behaviour. If this is used, the binder will use a `UITableViewDataSourcePrefetching`
    /// conformance to determine when to indicate that data should be prefetched.
    case tableViewDecides
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    private func _bind<NC>(
        cellType: NC.Type,
        viewModels: @escaping () -> [NC.ViewModel])
        -> TableViewSingleSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        self.binder.handlers.sectionCellViewModelProviders[self.section] = viewModels
        self.binder.updateCellModels(
            nil, viewModels: [self.section: viewModels()], affectedSections: self.affectedSectionScope)
        
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable,
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
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
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
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
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
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
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
        models: @escaping () -> [NM],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable,
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
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        self.binder.handlers.sectionCellModelProviders[self.section] = models
        let _models = models()
        let viewModels = [self.section: _models.map(mapToViewModels)]
        self.binder.updateCellModels(
            [self.section: _models], viewModels: viewModels, affectedSections: self.affectedSectionScope)
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
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
        where NC: UITableViewCell & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, models: { models })
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
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
        where NC: UITableViewCell & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models })
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.

     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, models: models)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onCellDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [NM])
        -> TableViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        self.binder.handlers.sectionCellModelProviders[self.section] = models
        let _models = models()
        self.binder.updateCellModels(
            [self.section: _models], viewModels: nil, affectedSections: self.affectedSectionScope)
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     - parameter models: The models objects to bind to the dequeued cells for this section.
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        models: [NM],
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell)
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: { models })
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     - parameter models: The models objects to bind to the dequeued cells for this section.
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        models: [NM],
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell)
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
        where NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellProvider: cellProvider, models: { models })
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.

     - parameter models: The models objects to bind to the dequeued cells for this section.
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        models: @escaping () -> [NM],
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell)
        -> TableViewModelSingleSectionBinder<UITableViewCell, S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     - parameter models: The models objects to bind to the dequeued cells for this section.
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        models: @escaping () -> [NM],
        cellProvider: @escaping (_ table: UITableView, _ row: Int, _ model: NM) -> UITableViewCell)
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
            guard let models = binder?.currentDataModel.sectionCellModels[section] as? [NM] else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(table, row, models[row])
        }
        self.binder.addCellDequeueBlock(cellProvider: _cellProvider, affectedSections: self.affectedSectionScope)
        let _models = models()
        self.binder.updateCellModels(
            [self.section: _models], viewModels: nil, affectedSections: self.affectedSectionScope)
        
        return TableViewModelSingleSectionBinder<UITableViewCell, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the section, along with the number of cells to create.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for the section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (UITableView, _ row: Int) -> UITableViewCell,
        numberOfCells: Int)
        -> TableViewSingleSectionBinder<UITableViewCell, S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, affectedSections: self.affectedSectionScope)
        self.binder.updateNumberOfCells([self.section: numberOfCells], affectedSections: self.affectedSectionScope)
        
        return TableViewSingleSectionBinder<UITableViewCell, S>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the section, along with the number of cells to create.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for the section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (UITableView, _ row: Int) -> UITableViewCell,
        numberOfCells: @escaping () -> Int)
        -> TableViewSingleSectionBinder<UITableViewCell, S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, affectedSections: self.affectedSectionScope)
        let numCells = numberOfCells()
        self.binder.updateNumberOfCells([self.section: numCells], affectedSections: self.affectedSectionScope)
        
        return TableViewSingleSectionBinder<UITableViewCell, S>(binder: self.binder, section: self.section)
    }
    
    /**
     Binds a handler that will be called when new data should be prefetched for the table.
     
     This method is called with a 'prefetch behaviour' - this is an enum case that describes a heuristic the binder
     should use to determine when data should be prefetched, such as 'when we're X number of cells from the end of the
     section'. The binder will call the given 'prefetch handler' (according to the given behaviour) when new data should
     be prefetched.
     
     - parameter prefetchBehaviour: A behavior indicating when a data prefetch should start.
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
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addHeaderDequeueBlock(headerType: headerType, affectedSections: self.affectedSectionScope)
        self.binder.updateHeaderViewModels([self.section: viewModel], affectedSections: self.affectedSectionScope)
        
        return self
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
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.handlers.sectionHeaderViewModelProviders[self.section] = viewModel
        self.binder.addHeaderDequeueBlock(headerType: headerType, affectedSections: self.affectedSectionScope)
        self.binder.updateHeaderViewModels([self.section: viewModel()], affectedSections: self.affectedSectionScope)
        
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
        self.binder.nextDataModel.headerTitleBound = true
        self.binder.updateHeaderTitles([self.section: headerTitle], affectedSections: self.affectedSectionScope)
        
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
        headerTitle: @escaping () -> String?)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.handlers.sectionHeaderTitleProviders[self.section] = headerTitle
        self.binder.nextDataModel.headerTitleBound = true
        self.binder.updateHeaderTitles([self.section: headerTitle()], affectedSections: self.affectedSectionScope)
        
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
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addFooterDequeueBlock(footerType: footerType, affectedSections: self.affectedSectionScope)
        self.binder.updateFooterViewModels([self.section: viewModel], affectedSections: self.affectedSectionScope)
        
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
        viewModel: @escaping () -> F.ViewModel?)
        -> TableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.handlers.sectionFooterViewModelProviders[self.section] = viewModel
        self.binder.addFooterDequeueBlock(footerType: footerType, affectedSections: self.affectedSectionScope)
        self.binder.updateFooterViewModels([self.section: viewModel()], affectedSections: self.affectedSectionScope)
        
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
        self.binder.nextDataModel.footerTitleBound = true
        self.binder.updateFooterTitles([self.section: footerTitle], affectedSections: self.affectedSectionScope)
        
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
        footerTitle: @escaping () -> String?)
        -> TableViewSingleSectionBinder<C, S>
    {
        self.binder.handlers.sectionFooterTitleProviders[self.section] = footerTitle
        self.binder.nextDataModel.footerTitleBound = true
        self.binder.updateFooterTitles([self.section: footerTitle()], affectedSections: self.affectedSectionScope)
        
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
