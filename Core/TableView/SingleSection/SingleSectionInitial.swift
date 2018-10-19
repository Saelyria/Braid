import UIKit

/**
 A throwaway object created as a result of a table view binder's `onSection` method. This bind result object is where
 the user can declare which way they want cells for the section to be created - from an array of the cell's view models,
 an array of arbitrary models, or from an array of arbitrary models mapped to view models with a given function.
 */
public class TableViewInitialSingleSectionBinder<S: TableViewSection>: BaseTableViewSingleSectionBinder<UITableViewCell, S>, TableViewInitialSingleSectionBinderProtocol {
    public typealias C = UITableViewCell
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models from a given array.
     
     - parameter cellType: The class of the header to bind.
     - parameter viewModels: The view models to bind to the the dequeued cells for this section.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: [NC.ViewModel]) -> TableViewViewModelSingleSectionBinder<NC, S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: self.section)
        self.binder.nextDataModel.sectionCellViewModels[self.section] = viewModels
        
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
    public func bind<NC, NM>(cellType: NC.Type, models: [NM], mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> TableViewModelViewModelSingleSectionBinder<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Identifiable {
        TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: self.section)
        
        self.binder.nextDataModel.sectionCellModels[self.section] = models
        self.binder.nextDataModel.sectionCellViewModels[self.section] = models.map(mapToViewModel)
        
        return TableViewModelViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section, mapToViewModel: mapToViewModel)
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
    where NC: UITableViewCell & ReuseIdentifiable, NM: Identifiable {
        TableViewInitialSingleSectionBinder<S>.addDequeueBlock(cellType: cellType, binder: self.binder, section: self.section)
        self.binder.nextDataModel.sectionCellModels[self.section] = models
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
}

internal extension TableViewInitialSingleSectionBinder {
    internal static func addDequeueBlock<NC>(cellType: NC.Type, binder: SectionedTableViewBinder<S>, section: S)
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        guard binder.sectionCellDequeueBlocks[section] == nil else {
            print("WARNING: Section already has a cell type bound to it - re-binding not supported.")
            return
        }
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = binder] (tableView, indexPath) in
            if let section = binder?.displayedSections[indexPath.section],
            var cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC,
            let viewModel = (binder?.currentDataModel.sectionCellViewModels[section] as? [NC.ViewModel])?[indexPath.row] {
                cell.viewModel = viewModel
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        binder.sectionCellDequeueBlocks[section] = cellDequeueBlock
    }
    
    internal static func addDequeueBlock<NC>(cellType: NC.Type, binder: SectionedTableViewBinder<S>, section: S)
    where NC: UITableViewCell & ReuseIdentifiable {
        guard binder.sectionCellDequeueBlocks[section] == nil else {
            print("WARNING: Section already has a cell type bound to it - re-binding not supported.")
            return
        }
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = binder] (tableView, indexPath) in
            if let section = binder?.displayedSections[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC {
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        binder.sectionCellDequeueBlocks[section] = cellDequeueBlock
    }
}

