import UIKit

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methods that take a binding handler and give it to the original table view binder to store for callback.
 */
public class TableViewInitialMutliSectionBinder<S: TableViewSection>: BaseTableViewMutliSectionBinder<UITableViewCell, S>, TableViewInitialMutliSectionBinderProtocol {
    public typealias C = UITableViewCell
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value are the view models for the cells
        created for the section. This dictionary does not need to contain a view models array for each section being
        bound - sections not present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: [S: [NC.ViewModel]])
    -> TableViewViewModelMultiSectionBinder<NC, S> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: self.sections)
        self.binder.updateCellModels(nil, viewModels: viewModels, sections: self.sections)
        
        return TableViewViewModelMultiSectionBinder<NC, S>(binder: self.binder, sections: self.sections)
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
    public func bind<NC, NM>(cellType: NC.Type, models: [S: [NM]], mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> TableViewModelViewModelMultiSectionBinder<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: self.sections)
        var viewModels: [S: [Any]] = [:]
        for (s, m) in models {
            viewModels[s] = m.map(mapToViewModel)
        }
        self.binder.updateCellModels(models, viewModels: viewModels, sections: self.sections)
        
        return TableViewModelViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections, mapToViewModel: mapToViewModel)
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
    public func bind<NC, NM>(cellType: NC.Type, models: [S: [NM]]) -> TableViewModelMultiSectionBinder<NC, S, NM>
    where NC: UITableViewCell & ReuseIdentifiable {
        self.binder.addCellDequeueBlock(cellType: cellType, sections: self.sections)
        self.binder.updateCellModels(models, viewModels: nil, sections: self.sections)

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
        cellProvider: @escaping (_ section: S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: [S: [NM]])
        -> TableViewModelMultiSectionBinder<UITableViewCell, S, NM>
    {
        let _cellProvider = { [weak binder = self.binder] (_ section: S, _ row: Int) -> UITableViewCell in
            guard let models = binder?.currentDataModel.sectionCellModels[section] as? [NM] else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(section, row, models[row])
        }
        self.binder.addCellDequeueBlock(cellProvider: _cellProvider, sections: self.sections)
        self.binder.updateCellModels(models, viewModels: nil, sections: self.sections)

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
        cellProvider: @escaping (_ section: S, _ row: Int) -> UITableViewCell,
        numberOfCells: [S: Int])
        -> TableViewProviderMultiSectionBinder<S>
    {
        self.binder.addCellDequeueBlock(cellProvider: cellProvider, sections: self.sections)
        self.binder.updateNumberOfCells(numberOfCells, sections: self.sections)
        
        return TableViewProviderMultiSectionBinder<S>(binder: self.binder, sections: self.sections)
    }
}
