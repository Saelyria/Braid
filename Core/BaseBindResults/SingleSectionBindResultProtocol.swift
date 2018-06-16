import UIKit

/**
 A protocol declaring the shared methods of both the KVO and Rx variants of a single-section bind result.
 */
public protocol SingleSectionBindResultProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
    
    /// The bind result's original binder. This is mostly used internally and can be ignored.
    var binder: _BaseTableViewBinder<S> { get }
    /// The section the bind result is for. This is mostly used internally and can be ignored.
    var section: S { get }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> Self
    
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> Self
    
    /**
     Add a callback handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     */
    @discardableResult
    func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> Self
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     */
    @discardableResult
    func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> Self
}

// Extension that provides implementations for the methods that are the same between the KVO and Rx variants of a
// single-section bind result.
public extension SingleSectionBindResultProtocol {
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> Self {
        let dequeueCallback: CellDequeueCallback = { row, cell in
            guard let cell = cell as? C else { fatalError("Cell wasn't the right type; something went awry!") }
            handler(row, cell)
        }
        
        self.binder.sectionCellDequeuedCallbacks[self.section] = dequeueCallback
        return self
    }
    
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> Self {
        let tappedHandler: CellTapCallback = { row, cell in
            guard let cell = cell as? C else { fatalError("Cell wasn't the right type; something went awry!") }
            handler(row, cell)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }

    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> Self {
        self.binder.sectionCellHeightBlocks[section] = handler
        return self
    }

    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> Self {
        self.binder.sectionEstimatedCellHeightBlocks[section] = handler
        return self
    }
}

// Internal extension that provides partial implementation for methods that share some implementation between the KVO and
// Rx variants of a single-section bind result (e.g. cell dequeueing).
internal extension SingleSectionBindResultProtocol {
    ///
    internal func addDequeueBlock<NC>(cellType: NC.Type, viewModelBindHandler: @escaping (NC, NC.ViewModel) -> Void) where NC: UITableViewCell & BaseViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionCellDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a cell type bound to it - re-binding not supported.")
            return
        }
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.binder] (tableView, indexPath) in
            if let section = binder?._displayedSections[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC,
            let viewModel = (binder?.sectionCellViewModels[section] as? [NC.ViewModel])?[indexPath.row] {
                viewModelBindHandler(cell, viewModel)
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            print("ERROR: Didn't return the right cell type - something went awry!")
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
            if let section = binder?._displayedSections[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC {
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            print("ERROR: Didn't return the right cell type - something went awry!")
            return UITableViewCell()
        }
        self.binder.sectionCellDequeueBlocks[self.section] = cellDequeueBlock
    }
    
    
    internal func addDequeueBlock<H>(headerType: H.Type, viewModelBindHandler: @escaping (H, H.ViewModel) -> Void) where H: UITableViewHeaderFooterView & RxViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionHeaderDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a header type bound to it - re-binding not supported.")
            return
        }
        
        let headerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
            if let section = binder?._displayedSections[sectionInt],
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H,
            let viewModel = binder?.sectionHeaderViewModels[section] as? H.ViewModel {
                viewModelBindHandler(header, viewModel)
                return header
            }
            print("ERROR: Didn't return a header - something went awry!")
            return nil
        }
        self.binder.sectionHeaderDequeueBlocks[self.section] = headerDequeueBlock
    }
}
