import UIKit

/// Protocol that allows us to have Reactive extensions
public protocol TableViewMultiSectionBinderProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
}

/**
 An object used to continue a binding chain.

 This is a throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a
 number of methods that take a binding handler and give it to the original table view binder to store for callback. A
 reference to this object should not be kept and should only be used in a binding chain.
*/
public class TableViewMultiSectionBinder<C: UITableViewCell, S: TableViewSection>
    : TableViewMultiSectionBinderProtocol
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
     created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: [S: [NC.ViewModel]])
        -> TableViewMultiSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, viewModels: { viewModels })
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value are the view models for the cells
     created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: [S: [NC.ViewModel]])
        -> TableViewMultiSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, viewModels: { viewModels })
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A closure that will return a dictionary where the key is a section and the value are the
        view models for the cells created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: @escaping () -> [S: [NC.ViewModel]])
        -> TableViewMultiSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A closure that will return a dictionary where the key is a section and the value are the
        view models for the cells created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: @escaping () -> [S: [NC.ViewModel]])
        -> TableViewMultiSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    private func _bind<NC>(
        cellType: NC.Type,
        viewModels: @escaping () -> [S: [NC.ViewModel]])
        -> TableViewMultiSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateCellModels(nil, viewModels: viewModels(), affectedSections: scope)
        }
        
        return TableViewMultiSectionBinder<NC, S>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: { models }, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.

     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable
    {
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.

     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.

     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     - parameter mapToViewModel: A function that, when given a model from a `models` array, will create a view model for
        the associated cell using the data from the model object.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable, NM: Equatable & CollectionIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NC.ViewModel.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]],
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            var viewModels: [S: [Any]] = [:]
            let _models = models()
            for (s, m) in _models {
                viewModels[s] = m.map(mapToViewModels)
            }
            binder?.updateCellModels(_models, viewModels: viewModels, affectedSections: scope)
        }
        
        return TableViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell
    {
        return self._bind(cellType: cellType, models: { models })
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
     the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
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
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell
    {
        return self._bind(cellType: cellType, models: models)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given array of models.
     
     When using this method, it is expected that you also provide a handler to the `onDequeue` method to bind the
     model to the cell manually.
     
     - parameter cellType: The class of the header to bind.
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell, NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellType: cellType, models: models)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: @escaping () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<NC, S, NM>
        where NC: UITableViewCell
    {
        self.binder.addCellDequeueBlock(cellType: cellType, affectedSections: self.affectedSectionScope)
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateCellModels(models(), viewModels: nil, affectedSections: scope)
        }
        
        return TableViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, created according to the given
     models.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: { models })
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, created according to the given
     models.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
        where NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellProvider: cellProvider, models: { models })
    }

    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, created according to the given
     models.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @escaping () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, created according to the given
     models.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A closure that will return a dictionary where the key is a section and the value are the models
        for the cells created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @escaping () -> [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
        where NM: Equatable & CollectionIdentifiable
    {
        self.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: self.affectedSectionScope)
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    private func _bind<NM>(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: @escaping () -> [S: [NM]])
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
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateCellModels(models(), viewModels: nil, affectedSections: scope)
        }
        
        return TableViewModelMultiSectionBinder<UITableViewCell, S, NM>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, along with the number of cells
     to create.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for each section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int) -> UITableViewCell,
        numberOfCells: [S: Int])
        -> TableViewMultiSectionBinder<UITableViewCell, S>
    {
        return self.bind(cellProvider: cellProvider, numberOfCells: { numberOfCells })
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, along with the number of cells
     to create.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter table: The table view to dequeue the cell on.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: A closure that will return the number of cells to create for each section using the
        provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ table: UITableView, _ section: S, _ row: Int) -> UITableViewCell,
        numberOfCells: @escaping () -> [S: Int])
        -> TableViewMultiSectionBinder<UITableViewCell, S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, affectedSections: self.affectedSectionScope)
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateNumberOfCells(numberOfCells(), affectedSections: scope)
        }
        
        return TableViewMultiSectionBinder<UITableViewCell, S>(binder: self.binder, sections: self.sections)
    }
    
    // MARK: -
    
    /**
     Binds the given header type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section header with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value is the header view model for the
     header created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModels: [S: H.ViewModel?])
        -> TableViewMultiSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable
    {
        return self.bind(headerType: headerType, viewModels: { viewModels })
    }
    
    /**
     Binds the given header type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section header with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModels: A closure that will return a dictionary where the key is a section and the value is the
        header view model for the header created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModels: @escaping () -> [S: H.ViewModel?])
        -> TableViewMultiSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable
    {
        let scope = self.affectedSectionScope
        self.binder.addHeaderDequeueBlock(headerType: headerType, affectedSections: self.affectedSectionScope)
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateHeaderViewModels(viewModels(), affectedSections: scope)
        }
        
        return self
    }
    
    /**
     Binds the given titles to the section's headers.
     
     This method will provide the given titles as the titles for the iOS native section headers. If you have bound a
     custom header type to the table view using the `bind(headerType:viewModels:)` method, this method will do nothing.
     
     - parameter headerTitles: A dictionary where the key is a section and the value is the title for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        headerTitles: [S: String?])
        -> TableViewMultiSectionBinder<C, S>
    {
        return self.bind(headerTitles: { headerTitles })
    }
    
    /**
     Binds the given titles to the section's headers.
     
     This method will provide the given titles as the titles for the iOS native section headers. If you have bound a
     custom header type to the table view using the `bind(headerType:viewModels:)` method, this method will do nothing.
     
     - parameter headerTitles: A closure that will return a dictionary where the key is a section and the value is the
        title for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        headerTitles: @escaping () -> [S: String?])
        -> TableViewMultiSectionBinder<C, S>
    {        
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateHeaderTitles(headerTitles(), affectedSections: scope)
        }
        return self
    }
    
    /**
     Binds the given footer type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section footer with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter footerType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value is the footer view model for the
     footer created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModels: [S: F.ViewModel?])
        -> TableViewMultiSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable
    {
        return self.bind(footerType: footerType, viewModels: { viewModels })
    }
    
    /**
     Binds the given footer type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section footer with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter footerType: The class of the header to bind.
     - parameter viewModels: A closure that will return a dictionary where the key is a section and the value is the
        footer view model for the footer created for the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModels: @escaping () -> [S: F.ViewModel?])
        -> TableViewMultiSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable
    {
        let scope = self.affectedSectionScope
        self.binder.addFooterDequeueBlock(footerType: footerType, affectedSections: self.affectedSectionScope)
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateFooterViewModels(viewModels(), affectedSections: scope)
        }
        
        return self
    }
    
    /**
     Binds the given titles to the section's footers.
     
     This method will provide the given titles as the titles for the iOS native section footers. If you have bound a
     custom footer type to the table view using the `bind(footerType:viewModels:)` method, this method will do nothing.
     
     - parameter footerTitles: A dictionary where the key is a section and the value is the title for the footer section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        footerTitles: [S: String?])
        -> TableViewMultiSectionBinder<C, S>
    {
        return self.bind(footerTitles: { footerTitles })
    }
    
    /**
     Binds the given titles to the section's footers.
     
     This method will provide the given titles as the titles for the iOS native section footers. If you have bound a
     custom footer type to the table view using the `bind(footerType:viewModels:)` method, this method will do nothing.
     
     - parameter footerTitles: A closure that will return a dictionary where the key is a section and the value is the
        title for the footer section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        footerTitles: @escaping () -> [S: String?])
        -> TableViewMultiSectionBinder<C, S>
    {
        switch self.affectedSectionScope {
        case .forNamedSections(let sections):
            self.binder.nextDataModel.uniquelyBoundFooterSections.append(contentsOf: sections)
        default: break
        }
        let scope = self.affectedSectionScope
        self.binder.handlers.modelUpdaters.append { [weak binder = self.binder] in
            binder?.updateFooterTitles(footerTitles(), affectedSections: scope)
        }
        
        return self
    }
    
    // MARK: -
    
    /**
     Adds a handler to be called whenever a cell is dequeued in one of the declared sections.
     
     The given handler is called whenever a cell in one of the sections being bound is dequeued, passing in the row and
     the dequeued cell. The cell will be safely cast to the cell type bound to the section if this method is called in a
     chain after the `bind(cellType:viewModels:)` method. This method can be used to perform any additional
     configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in one of the bound sections.
     - parameter section: The section in which a cell was dequeued.
     - parameter row: The row of the cell that was dequeued.
     - parameter cell: The cell that was dequeued that can now be configured.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ cell: C) -> Void)
        -> TableViewMultiSectionBinder<C, S>
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
                self.binder.handlers.sectionDequeuedCallbacks[section] = callback
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
     - parameter cell: The cell that was tapped.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ cell: C) -> Void)
        -> TableViewMultiSectionBinder<C, S>
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
     Adds a handler to be called when a cell of the given type emits a custom view event.
     
     To use this method, the given cell type must conform to `ViewEventEmitting`. This protocol has the cell declare an
     associated `ViewEvent` enum type whose cases define custom events that can be observed from the binding chain.
     When a cell emits an event via its `emit(event:)` method, the handler given to this method is called with the
     event and various other objects that allows the view controller to respond.
     
     - parameter cellType: The event-emitting cell type to observe events from.
     - parameter handler: The closure to be called whenever a cell of the given cell type emits a custom event.
     - parameter section: The section in which a cell emitted an event.
     - parameter row: The row of the cell that emitted an event.
     - parameter cell: The cell that emitted an event.
     - parameter event: The custom event that the cell emitted.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onEvent<EventCell>(
        from cellType: EventCell.Type,
        _ handler: @escaping (_ section: S, _ row: Int, _ cell: EventCell, _ event: EventCell.ViewEvent) -> Void)
        -> TableViewMultiSectionBinder<C, S>
        where EventCell: UITableViewCell & ViewEventEmitting
    {
        self.binder.addEventEmittingHandler(
            cellType: EventCell.self, handler: handler, affectedSections: self.affectedSectionScope)
        
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
    public func dimensions(_ dimensions: MultiSectionDimension<S>...) -> TableViewMultiSectionBinder<C, S> {
        self._dimensions(dimensions)
        return self
    }
    
    internal func _dimensions(_ dimensions: [MultiSectionDimension<S>]) {
        for dimension in dimensions {
            dimension.bindingFunc(self.binder, self.affectedSectionScope)
        }
    }
    
    /**
     Adds model type information to the binding chain.
     
     This method allows model type information to be assumed on any additional binding chains for a section after the
     binding chain that originally declared the cell and model type. This method will cause a crash if the model type
     originally bound to the section is not the same type or if the section was not setup with a model type.
     
     - parameter modelType: The type of the models that were bound to the sections on another binding chain.
     
     - returns: A section binder to continue the binding chain with that allows cast model types to be given to items in
        its chain.
     */
    public func assuming<M>(modelType: M.Type) -> TableViewModelMultiSectionBinder<C, S, M> {
        return TableViewModelMultiSectionBinder(binder: self.binder, sections: self.sections)
    }
}
