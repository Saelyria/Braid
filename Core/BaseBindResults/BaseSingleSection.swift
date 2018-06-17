import UIKit

public protocol BaseSingleSectionTableViewBindResultProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
    
    /// The bind result's original binder. This is mostly used internally and can be ignored.
    var baseBinder: _BaseTableViewBinder<S> { get }
    /// The section the bind result is for. This is mostly used internally and can be ignored.
    var section: S { get }
}

/**
 A protocol declaring the shared methods of both the KVO and Rx variants of a single-section bind result.
 */
public class BaseSingleSectionTableViewBindResult<C: UITableViewCell, S: TableViewSection> {
    /// The bind result's original binder. This is mostly used internally and can be ignored.
    let baseBinder: _BaseTableViewBinder<S>
    /// The section the bind result is for. This is mostly used internally and can be ignored.
    let section: S
    
    internal init(binder: _BaseTableViewBinder<S>, section: S) {
        self.baseBinder = binder
        self.section = section
    }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func configureCell(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> BaseSingleSectionTableViewBindResult<C, S> {
        let dequeueCallback: CellDequeueCallback = { row, cell in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.baseBinder.sectionCellDequeuedCallbacks[self.section] = dequeueCallback
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> BaseSingleSectionTableViewBindResult<C, S> {
        let tappedHandler: CellTapCallback = { row, cell in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.baseBinder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }

    /**
     Add a callback handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseSingleSectionTableViewBindResult<C, S> {
        self.baseBinder.sectionCellHeightBlocks[section] = handler
        return self
    }

    /**
     Add a callback handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     */

    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseSingleSectionTableViewBindResult<C, S> {
        self.baseBinder.sectionEstimatedCellHeightBlocks[section] = handler
        return self
    }
}

// Internal extension that provides partial implementation for methods that share some implementation between the KVO and
// Rx variants of a single-section bind result (e.g. cell dequeueing). Subclasses should call these methods in their unique
// binding methods, making sure to populate the 'section view model' or 'section model' dictionaries on their table view binder.
// If the value is meant to be observed, the subclass should observe it, set up a method to populate these dictionaries on change,
// then call the table view's 'reload' method (or reload the affected section).
internal extension BaseSingleSectionTableViewBindResult {
    internal func addDequeueBlock<NC>(cellType: NC.Type, viewModelBindHandler: @escaping (NC, NC.ViewModel) -> Void) where NC: UITableViewCell & BaseViewModelBindable & ReuseIdentifiable {
        guard self.baseBinder.sectionCellDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a cell type bound to it - re-binding not supported.")
            return
        }
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.baseBinder] (tableView, indexPath) in
            if let section = binder?._displayedSections[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC,
            let viewModel = (binder?.sectionCellViewModels[section] as? [NC.ViewModel])?[indexPath.row] {
                viewModelBindHandler(cell, viewModel)
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        self.baseBinder.sectionCellDequeueBlocks[self.section] = cellDequeueBlock
    }
    
    internal func addDequeueBlock<NC>(cellType: NC.Type) where NC: UITableViewCell & ReuseIdentifiable {
        guard self.baseBinder.sectionCellDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a cell type bound to it - re-binding not supported.")
            return
        }
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.baseBinder] (tableView, indexPath) in
            if let section = binder?._displayedSections[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC {
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            assertionFailure("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        self.baseBinder.sectionCellDequeueBlocks[self.section] = cellDequeueBlock
    }
    
    
    internal func addDequeueBlock<H>(headerType: H.Type, viewModelBindHandler: @escaping (H, H.ViewModel) -> Void) where H: UITableViewHeaderFooterView & BaseViewModelBindable & ReuseIdentifiable {
        guard self.baseBinder.sectionHeaderDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a header type bound to it - re-binding not supported.")
            return
        }
        
        let headerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.baseBinder] (tableView, sectionInt) in
            if let section = binder?._displayedSections[sectionInt],
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H,
            let viewModel = binder?.sectionHeaderViewModels[section] as? H.ViewModel {
                viewModelBindHandler(header, viewModel)
                return header
            }
            assertionFailure("ERROR: Didn't return a header - something went awry!")
            return nil
        }
        self.baseBinder.sectionHeaderDequeueBlocks[self.section] = headerDequeueBlock
    }
    
    internal func addDequeueBlock<F>(footerType: F.Type, viewModelBindHandler: @escaping (F, F.ViewModel) -> Void) where F: UITableViewHeaderFooterView & BaseViewModelBindable & ReuseIdentifiable {
        guard self.baseBinder.sectionFooterDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a footer type bound to it - re-binding not supported.")
            return
        }
        
        let footerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.baseBinder] (tableView, sectionInt) in
            if let section = binder?._displayedSections[sectionInt],
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: F.reuseIdentifier) as? F,
            let viewModel = binder?.sectionFooterViewModels[section] as? F.ViewModel {
                viewModelBindHandler(header, viewModel)
                return header
            }
            assertionFailure("ERROR: Didn't return a footer - something went awry!")
            return nil
        }
        self.baseBinder.sectionFooterDequeueBlocks[self.section] = footerDequeueBlock
    }
}
