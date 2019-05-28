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
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? NM else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(table, section, row, model)
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
        let handler: (S, Int, UITableViewCell) -> Void = { (section, row, cell) in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell)
        }
        self.binder.handlers.add(handler, toHandlerSetAt: \.cellDequeuedHandlers, forScope: self.affectedSectionScope)
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
        let handler: (S, Int, UITableViewCell) -> Void = { (section, row, tappedCell) in
            guard let tappedCell = tappedCell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(section, row, tappedCell)
        }
        self.binder.handlers.add(handler, toHandlerSetAt: \.cellTappedHandlers, forScope: self.affectedSectionScope)
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
    
    // MARK: -
    
    /**
     Enables editing (i.e. insertion or deletion controls) for the section.
     
     This method must be called on the chain to enable insertion or deletion actions on the section, passing in the
     editing style (`delete` or `insert`) for items in the section.
     
     - parameter style: The editing styles to apply for cells in the bound sections.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func allowEditing(
        style: UITableViewCell.EditingStyle)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(
            { section, _ in return style },
            toHandlerSetAt: \.cellEditingStyleProviders,
            forScope: self.affectedSectionScope)
        
        return self
    }
    
    /**
     Enables editing (i.e. insertion or deletion controls) for the section.
     
     This method must be called on the chain to enable insertion or deletion actions on the section, passing in the
     editing style (`delete` or `insert`) for items in the section.
     
     - parameter style: The editing styles to apply for cells in the bound sections.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func allowEditing(
        style: [S: UITableViewCell.EditingStyle])
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(
            { section, _ in return style[section] ?? .none },
            toHandlerSetAt: \.cellEditingStyleProviders,
            forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Enables editing (i.e. insertion or deletion controls) for the section.
     
     This method must be called on the chain to enable insertion or deletion actions on the section, passing in a
     closure that will return the editing style (`delete` or `insert`) for items in the section. This method should
     typically be paired with an `onEdit(_:)` method after it on the chain.
     
     - parameter styleForRow: A closure that returns the editing style to apply a row in the bound section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func allowEditing(
        styleForRow: @escaping (_ section: S, _ row: Int) -> UITableViewCell.EditingStyle)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(
            styleForRow, toHandlerSetAt: \.cellEditingStyleProviders, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Enables moving cells via a move control for the section.
     
     This method enables moving cells within the section according to a given 'movement policy'. This policy dictates
     which sections on the table cells from the section being bound can be moved to. By default, when this method is
     added to a chain, all cells on the section will become movable - to have more fine-grained control over which
     rows are allowed to be moved, a 'row is movable' closure can be provided that is passed in rows.
     
     - parameter movementPolicy: The policy that determines which sections rows from the section being bound can be
     moved to.
     - parameter rowIsMovable: A closure that can optionally be provided to declare which specific rows can be moved.
     - parameter section: The section for which the closure is called and must return whether the row is movable.
     - parameter row: The row for which the closure is called and must return whether the row is movable.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func allowMoving(_ movementPolicy: CellMovementPolicy<S>, rowIsMovable: ((_ section: S, _ row: Int) -> Bool)? = nil)
        -> TableViewMultiSectionBinder<C, S>
    {
        if let rowIsMovable = rowIsMovable {
            self.binder.handlers.add({ section, row in rowIsMovable(section, row) },
                                     toHandlerSetAt: \.cellMovableProviders,
                                     forScope: self.affectedSectionScope)
        }
        self.binder.handlers.add(movementPolicy, toHandlerSetAt: \.cellMovementPolicies, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Adds a handler to be called when a cell is deleted from one of the sections, whether from an editing control or
     being moved out of it.
     
     In the handler, the model object that is located at the given row must be deleted from the data array that backs
     this section so that the next time the section is reloaded, the model has been deleted. There is no need to call
     the `refresh` method on the binder in the handler. The handler is also given a 'deletion reason', which indicates
     whether the cell was deleted from the section because of a deletion control or because it was moved to a different
     location on the table.
     
     Note that, in the case of a move, this method is called before the `onInsert` handler for where it was moved to and
     the `row` value properly accounts for the deleted row, so no further bookkeeping should be required.
     
     - parameter handler: The closure to be called whenever a cell is deleted from the section.
     - parameter section: The section the cell was deleted from.
     - parameter row: The row the cell was deleted from in the section.
     - parameter reason: The reason the cell was deleted.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onDelete(_ handler: @escaping (S, Int, CellDeletionReason<S>) -> Void)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(handler, toHandlerSetAt: \.cellDeletedHandlers, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Adds a handler to be called when a cell is inserted into one of the sections, whether from an editing control or
     being moved into it.
     
     In the handler, a new model object must be inserted at the given row in the data array that backs this section
     so that the next time the section is reloaded, the model will have been inserted. There is no need to call the
     `refresh` method on the binder in the handler. The handler is also given an 'insertion reason', which indicates
     whether the cell was inserted in the section because of an insertion control or because it was moved to a different
     location on the table.
     
     Note that, in the case of a move, this method is called after the `onDelete` handler for where it was moved from
     and the `row` value properly accounts for the deleted row, so no further bookkeeping should be required. For
     readability, this `onInsert` handler should not handle the deletion of the model from the section it was moved
     from - instead, it is expected that an `onDelete` handler was bound to that section's binding chain.
     
     - parameter handler: The closure to be called whenever a cell is inserted from the section.
     - parameter section: The section the row was inserted into.
     - parameter row: The row the cell was inserted into in the section.
     - parameter reason: The reason the cell was inserted.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onInsert(_ handler: @escaping (_ section: S, _ row: Int, _ reason: CellInsertionReason<S>) -> Void)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(handler, toHandlerSetAt: \.cellInsertedHandlers, forScope: self.affectedSectionScope)
        return self
    }
    
    // MARK: -
    
    /**
     Adds a handler to provide the cell height for cells in the declared sections.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter section: The section of the cell to provide the height for.
     - parameter row: The row of the cell to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(handler, toHandlerSetAt: \.cellHeightProviders, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Adds a handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     
     - parameter handler: The closure to be called that will return the estimated height for cells in the section.
     - parameter section: The section of the cell to provide the estimated height for.
     - parameter row: The row of the cell to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(
            handler, toHandlerSetAt: \.cellEstimatedHeightProviders, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Adds a callback handler to provide the height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     - parameter section: The section of the header to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewMultiSectionBinder<C, S> {
        self.binder.handlers.add(handler, toHandlerSetAt: \.headerHeightProviders, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - parameter section: The section of the header to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(
            handler, toHandlerSetAt: \.headerEstimatedHeightProviders, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Adds a callback handler to provide the height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     - parameter section: The section of the footer to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewMultiSectionBinder<C, S> {
        self.binder.handlers.add(handler, toHandlerSetAt: \.footerHeightProviders, forScope: self.affectedSectionScope)
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - parameter section: The section of the footer to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> TableViewMultiSectionBinder<C, S>
    {
        self.binder.handlers.add(
            handler, toHandlerSetAt: \.footerEstimatedHeightProviders, forScope: self.affectedSectionScope)
        return self
    }
}
