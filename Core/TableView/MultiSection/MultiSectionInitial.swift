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
        for section in self.sections {
            TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: section)
            // if we're not binding for all sections, go ahead and write to the next model. Otherwise, there are checks
            // that need to be done with the `updateNextModelForAllSections` method.
            if !self.isForAllSections {
                self.binder.nextDataModel.sectionCellViewModels[section] = viewModels[section]
            }
        }
        
        if self.isForAllSections {
            TableViewInitialMutliSectionBinder<S>.updateNextModelForAllSections(binder: self.binder, models: nil, viewModels: viewModels)
        }
        
        return TableViewViewModelMultiSectionBinder<NC, S>(binder: self.binder, sections: self.sections, isForAllSections: self.isForAllSections)
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
    -> TableViewModelViewModelMultiSectionBinder<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Identifiable {
        for section in self.sections {
            TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: section)
            // if we're not binding for all sections, go ahead and write to the next model. Otherwise, there are checks
            // that need to be done with the `updateNextModelForAllSections` method.
            if !self.isForAllSections {
                let sectionModels: [NM]? = models[section]
                let sectionViewModels: [NC.ViewModel]? = sectionModels?.map(mapToViewModel)
                self.binder.nextDataModel.sectionCellModels[section] = sectionModels
                self.binder.nextDataModel.sectionCellViewModels[section] = sectionViewModels
            }
        }
        
        if self.isForAllSections {
            var viewModels: [S: [Identifiable]] = [:]
            for (s, m) in models {
                viewModels[s] = m.map(mapToViewModel)
            }
            TableViewInitialMutliSectionBinder<S>.updateNextModelForAllSections(binder: self.binder, models: models, viewModels: viewModels)
        }
        
        return TableViewModelViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections, mapToViewModel: mapToViewModel, isForAllSections: self.isForAllSections)
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
    where NC: UITableViewCell & ReuseIdentifiable, NM: Identifiable {
        for section in self.sections {
            TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: section)
            // if we're not binding for all sections, go ahead and write to the next model. Otherwise, there are checks
            // that need to be done with the `updateNextModelForAllSections` method.
            if !self.isForAllSections {
                let sectionModels: [NM]? = models[section]
                self.binder.nextDataModel.sectionCellModels[section] = sectionModels
            }
        }
        
        if self.isForAllSections {
            TableViewInitialMutliSectionBinder<S>.updateNextModelForAllSections(binder: self.binder, models: models, viewModels: nil)
        }
        
        return TableViewModelMultiSectionBinder<NC, S, NM>(binder: self.binder, sections: self.sections, isForAllSections: self.isForAllSections)
    }
    
    // Internal function used by all the 'initial section cell binding' methods. This method checks against the
    // 'uniquely bound sections' array if this multi-section binder is binding 'for all sections' to ensure that it
    // doesn't overwrite anything. It's given arrays of models, view models, and/or a mapping function to populate the
    // binder's next data model.
    static func updateNextModelForAllSections(binder: SectionedTableViewBinder<S>, models: [S: [Identifiable]]?, viewModels: [S: [Identifiable]]?) {
        // We assume that the view models given in the dictionary are meant to be the state of the table if we're
        // binding all sections (i.e. any sections not in the dictionary are to have their 'view models' data array
        // emptied). However, we don't want to empty the arrays for sections that were bound 'uniquely' (i.e. with the
        // 'onSection' or 'onSections' methods), as they have unique data or cell types that should not be overwritten
        // by an 'onAllSections' data refresh.
        for section in binder.currentDataModel.sectionCellModels.keys {
            if binder.nextDataModel.uniquelyBoundSections.contains(section) == true {
                continue
            } else {
                binder.nextDataModel.sectionCellModels = [:]
                binder.nextDataModel.sectionCellViewModels = [:]
            }
        }
        
        // Get the sections that are attempting to be bound from the dictionary keys
        var givenSections: [S] = []
        if let modelSections = models?.keys {
            givenSections = Array(modelSections)
        } else if let viewModelSections = viewModels?.keys {
            givenSections = Array(viewModelSections)
        }
        
        // Now, ensure we only overwrite the data for sections that were not uniquely bound by name.
        let sectionsNotUniquelyBound: Set<S> = Set(givenSections).subtracting(binder.nextDataModel.uniquelyBoundSections)
        for section in sectionsNotUniquelyBound {
            if let models = models {
                binder.nextDataModel.sectionCellModels[section] = models[section]
            }
            if let viewModels = viewModels {
                binder.nextDataModel.sectionCellViewModels[section] = viewModels[section]
            }
        }
    }
}
