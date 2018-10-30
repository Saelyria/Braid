import UIKit

/**
 A throwaway object created as a result of a table view binder's `onSection` method. This bind result object is where
 the user can declare which way they want cells for the section to be created - from an array of the cell's view models,
 an array of arbitrary models, or from an array of arbitrary models mapped to view models with a given function.
 */
public class TableViewInitialSingleSectionBinder<S: TableViewSection>:
    BaseTableViewSingleSectionBinder<UITableViewCell, S>,
    TableViewInitialSingleSectionBinderProtocol
{
    public typealias C = UITableViewCell
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: The view models to bind to the the dequeued cells for this section.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: [NC.ViewModel]) -> TableViewViewModelSingleSectionBinder<NC, S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: [self.section])
        self.binder.updateCellModels(nil, viewModels: [self.section: viewModels], sections: [self.section])
        
        return TableViewViewModelSingleSectionBinder<NC, S>(binder: self.binder, section: self.section)
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
        -> TableViewModelViewModelSingleSectionBinder<NC, S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: CollectionIdentifiable
    {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: [self.section])
        let viewModels = [self.section: models.map(mapToViewModel)]
        self.binder.updateCellModels([self.section: models], viewModels: viewModels, sections: [self.section])

        return TableViewModelViewModelSingleSectionBinder<NC, S, NM>(
            binder: self.binder, section: self.section, mapToViewModel: mapToViewModel)
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
    public func bind<NC, NM>(cellType: NC.Type, models: [NM]) -> TableViewModelSingleSectionBinder<NC, S, NM>
    where NC: UITableViewCell & ReuseIdentifiable, NM: CollectionIdentifiable {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: [self.section])
        self.binder.updateCellModels([self.section: models], viewModels: nil, sections: [self.section])
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
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
        self.binder.updateCellModels([self.section: models], viewModels: nil, sections: [self.section])
        
        return TableViewModelSingleSectionBinder<UITableViewCell, S, NM>(binder: self.binder, section: self.section)
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
        -> TableViewProviderSingleSectionBinder<S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, sections: [self.section])
        self.binder.updateNumberOfCells([self.section: numberOfCells], sections: [self.section])
        
        return TableViewProviderSingleSectionBinder<S>(binder: self.binder, section: self.section)
    }
}
