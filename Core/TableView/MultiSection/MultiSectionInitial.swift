import UIKit

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methods that take a binding handler and give it to the original table view binder to store for callback.
 */
public class TableViewInitialMutliSectionBinder<S: TableViewSection>: BaseTableViewMutliSectionBinder<UITableViewCell, S>, TableViewInitialMutliSectionBinderProtocol {
    public typealias C = UITableViewCell
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     
     Use this method to use a custom `UITableViewCell` for cells in the bound sections with a table view binder. The
     cell must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible. The table view binder will then,
     for each section's view model in the `viewModels` array, dequeue a new cell of the specified type in the section
     and assign its associated view model.
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value are the view models for the cells
        created for the section. This dictionary does not need to contain a view models array for each section being
        bound - sections not present in the dictionary have no cells dequeued for them.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: [S: [NC.ViewModel]])
    -> TableViewViewModelMultiSectionBinder<NC, S> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        for section in self.sections {
            self.binder.nextDataModel.sectionCellViewModels[section] = viewModels[section] ?? []
            TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: section)
        }
        
        return TableViewViewModelMultiSectionBinder<NC, S>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents, the cells, and the view models for the cells. When binding with this method, various other event
     binding methods (most notably the `onTapped` event method) can have their handlers be passed in the associated
     model (cast to the same type as the models observable type) along with the row and cell.
     
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
    -> TableViewModelViewModelMultiSectionBinder<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Identifiable {
        for section in self.sections {
            let sectionModels: [NM] = models[section] ?? []
            let sectionViewModels: [NC.ViewModel] = sectionModels.map(mapToViewModel)
            TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: section)
            self.binder.nextDataModel.sectionCellModels[section] = sectionModels
            self.binder.nextDataModel.sectionCellViewModels[section] = sectionViewModels
        }
        
        return TableViewModelViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections, mapToViewModel: mapToViewModel)
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
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section. This dictionary does not need to contain a models array for each section being bound - sections not
        present in the dictionary have no cells dequeued for them.
     - returns: A section binder to continue the binding chain with.
    */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: [S: [NM]]) -> TableViewModelMultiSectionBinder<NC, S, NM>
    where NC: UITableViewCell & ReuseIdentifiable, NM: Identifiable {
        for section in self.sections {
            let sectionModels: [NM] = models[section] ?? []
            TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: section)
            self.binder.nextDataModel.sectionCellModels[section] = sectionModels
        }
        
        return TableViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections)
    }
}
