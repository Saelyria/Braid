import UIKit

/// Protocol that allows us to have Reactive extensions
public protocol TableViewSingleSectionBinderProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
}

/**
 A throwaway object created as a result of a table view binder's `onSection` method. This bind result object is where
 the user can declare which way they want cells for the section to be created - from an array of the cell's view
 models, an array of arbitrary models, or from an array of arbitrary models mapped to view models with a given function.
 */
public class TableViewSingleSectionBinder<C: UITableViewCell, S: TableViewSection>: BaseTableViewSingleSectionBinder<C, S> {
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
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
     
     When using this method, you pass in an observable array of your raw models and a function that transforms them into
     the view models for the cells. From there, the binder will handle dequeuing of your cells based on the observable
     models array.
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
     
     When using this method, you pass in an observable array of your raw models. From there, the binder will handle
     dequeuing of your cells based on the observable models array.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: [NM]) -> TableViewModelSingleSectionBinder<NC, S, NM>
    where NC: UITableViewCell & ReuseIdentifiable {
        self.addDequeueBlock(cellType: cellType)
        self.binder.sectionCellModels[self.section] = models
        
        return TableViewModelSingleSectionBinder<NC, S, NM>(binder: self.binder, section: self.section)
    }
}

internal extension TableViewSingleSectionBinder {
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

/**
 An abstract superclass for the bind result
*/
public class BaseTableViewSingleSectionBinder<C: UITableViewCell, S: TableViewSection>: TableViewSingleSectionBinderProtocol {
    let binder: SectionedTableViewBinder<S>
    let section: S
    
    init(binder: SectionedTableViewBinder<S>, section: S) {
        self.binder = binder
        self.section = section
    }
    
    // MARK: Header / footer view binding
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> BaseTableViewSingleSectionBinder<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(headerType: headerType)
        self.binder.sectionHeaderViewModels[self.section] = viewModel

        return self
    }
    
    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitle(_ title: String) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionHeaderTitles[self.section] = title
        return self
    }
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> BaseTableViewSingleSectionBinder<C, S>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(footerType: footerType)
        self.binder.sectionFooterViewModels[self.section] = viewModel
        
        return self
    }
    
    /**
     Bind the given observable title to the section's footer.
     */
    @discardableResult
    public func footerTitle(_ title: String) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionFooterTitles[self.section] = title
        return self
    }
    
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func configureCell(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> BaseTableViewSingleSectionBinder<C, S> {
        let dequeueCallback: CellDequeueCallback = { row, cell in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.sectionCellDequeuedCallbacks[self.section] = dequeueCallback
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> BaseTableViewSingleSectionBinder<C, S> {
        let tappedHandler: CellTapCallback = { row, cell in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    /**
     Add a callback handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionCellHeightBlocks[section] = handler
        return self
    }
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionEstimatedCellHeightBlocks[section] = handler
        return self
    }
}


// Internal extension with functions for the common setup of 'dequeue blocks' on the binder
internal extension BaseTableViewSingleSectionBinder {
    internal func addDequeueBlock<H>(headerType: H.Type) where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionHeaderDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a header type bound to it - re-binding not supported.")
            return
        }
        
        let headerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
            if let section = binder?.displayedSections[sectionInt],
            var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H,
            let viewModel = binder?.sectionHeaderViewModels[section] as? H.ViewModel {
                header.viewModel = viewModel
                return header
            }
            assertionFailure("ERROR: Didn't return a header - something went awry!")
            return nil
        }
        self.binder.sectionHeaderDequeueBlocks[self.section] = headerDequeueBlock
    }
    
    internal func addDequeueBlock<F>(footerType: F.Type) where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionFooterDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a footer type bound to it - re-binding not supported.")
            return
        }
        
        let footerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
            if let section = binder?.displayedSections[sectionInt],
            var footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: F.reuseIdentifier) as? F,
            let viewModel = binder?.sectionFooterViewModels[section] as? F.ViewModel {
                footer.viewModel = viewModel
                return footer
            }
            assertionFailure("ERROR: Didn't return a footer - something went awry!")
            return nil
        }
        self.binder.sectionFooterDequeueBlocks[self.section] = footerDequeueBlock
    }
}
