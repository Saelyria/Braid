import UIKit

/**
 A throwaway object created as a result of a table view binder's `onSection` method. This bind result object is where
 the user can declare which way they want cells for the section to be created - from an array of the cell's view models,
 an array of arbitrary models, or from an array of arbitrary models mapped to view models with a given function.
 */
public class TableViewInitialSingleSectionBinder<S: TableViewSection>: BaseTableViewSingleSectionBinder<UITableViewCell, S> {
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given array.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: [NC.ViewModel]) -> TableViewViewModelSingleSectionBinder<NC, S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(cellType: cellType)
        self.binder.sectionCellViewModels[self.section] = viewModels
        
        return TableViewViewModelSingleSectionBinder<NC, S>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents, the cells, and the view models for the cells. When binding with this method, various other event
     binding methods (most notably the `onTapped` event method) can have their handlers be passed in the associated
     model (cast to the same type as the models observable type) along with the row and cell.
     
     When using this method, you pass in an array of your raw models and a function that transforms them into the view
     models for the cells. This function is stored so, if you later update the models for the section using the section
     binder's created 'update' callback, the models can be mapped to the cells' view models.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: [NM], mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> TableViewModelViewModelSingleSectionBinder<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(cellType: cellType)
        
        self.binder.sectionCellModels[self.section] = models
        self.binder.sectionCellViewModels[self.section] = models.map(mapToViewModel)
        
        return TableViewModelViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section, mapToViewModel: mapToViewModel)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given observable array of
     models.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents and the cells. When binding with this method, various other event binding methods (most notably the
     `onTapped` event method) can have their handlers be passed in the associated model (cast to the same type as the
     models observable type) along with the row and cell.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: [NM]) -> TableViewModelSingleSectionBinder<NC, S, NM>
    where NC: UITableViewCell & ReuseIdentifiable {
        self.addDequeueBlock(cellType: cellType)
        self.binder.sectionCellModels[self.section] = models
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
}

internal extension TableViewInitialSingleSectionBinder {
    internal func addDequeueBlock<NC>(cellType: NC.Type) where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionCellDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a cell type bound to it - re-binding not supported.")
            return
        }
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.binder] (tableView, indexPath) in
            if let section = binder?.displayedSections[indexPath.section],
            var cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC,
            let viewModel = (binder?.sectionCellViewModels[section] as? [NC.ViewModel])?[indexPath.row] {
                cell.viewModel = viewModel
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        self.binder.sectionCellDequeueBlocks[self.section] = cellDequeueBlock
    }
    
    internal func addDequeueBlock<NC>(cellType: NC.Type) where NC: UITableViewCell & ReuseIdentifiable {
        guard self.binder.sectionCellDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a cell type bound to it - re-binding not supported.")
            return
        }
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.binder] (tableView, indexPath) in
            if let section = binder?.displayedSections[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC {
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        self.binder.sectionCellDequeueBlocks[self.section] = cellDequeueBlock
    }
}

