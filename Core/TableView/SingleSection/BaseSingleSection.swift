import UIKit

/// Protocol that allows us to have Reactive extensions
public protocol TableViewSingleSectionBinderProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
}

// Need this second protocol so Reactive extension methods for binding celltype are only on 'inital' binders
public protocol TableViewInitialSingleSectionBinderProtocol: TableViewSingleSectionBinderProtocol { }

/**
 An abstract superclass for all single-section binders. This class contains the implementations for the
 handler methods that are common to all types of single-section binders. Specialized binder subclasses
 should override each of this class's methods to override their return type to themselves so any special
 methods of theirs can still be used in the chain.
 */
public class BaseTableViewSingleSectionBinder<C: UITableViewCell, S: TableViewSection> {    
    let binder: SectionedTableViewBinder<S>
    let section: S
    
    init(binder: SectionedTableViewBinder<S>, section: S) {
        self.binder = binder
        self.section = section
    }
    
    /**
     Binds the given header type to the declared section with the given view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section header with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     - parameter headerType: The class of the header to bind.
     - parameter viewModel: The view model to bind to the section's header when it is dequeued.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> BaseTableViewSingleSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
            self.addDequeueBlock(headerType: headerType)
            self.binder.sectionHeaderViewModels[self.section] = viewModel
            
            return self
    }
    
    /**
     Binds the given title to the section's header.
     
     This method will provide the given title as the title for the iOS native section headers. If you have bound a custom
     header type to the table view using the `bind(headerType:viewModel:)` method, this method will do nothing.
     - parameter title: The title to use for the section's header.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func headerTitle(_ title: String) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionHeaderTitles[self.section] = title
        return self
    }
    
    /**
     Binds the given footer type to the declared section with the given view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section footer with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     - parameter footerType: The class of the footer to bind.
     - parameter viewModel: The view model to bind to the section's footer when it is dequeued.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> BaseTableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
            self.addDequeueBlock(footerType: footerType)
            self.binder.sectionFooterViewModels[self.section] = viewModel
            
            return self
    }
    
    /**
     Binds the given title to the section's footer.
     
     This method will provide the given title as the title for the iOS native section footers. If you have bound a custom
     footer type to the table view using the `bind(footerType:viewModel:)` method, this method will do nothing.
     - parameter title: The title to use for the section's footer.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func footerTitle(_ title: String) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionFooterTitles[self.section] = title
        return self
    }
    
    
    /**
     Adds a handler to be called whenever a cell is dequeued in the declared section.
     
     The given handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell.
     The cell will be safely cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method. This method can be used to perform any additional configuration of the cell.
     - parameter handler: The closure to be called whenever a cell is dequeued in the bound section.
     - parameter row: The row of the cell that was dequeued.
     - parameter dequeuedCell: The cell that was dequeued that can now be configured.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> BaseTableViewSingleSectionBinder<C, S> {
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
     Adds a handler to be called whenever a cell in the declared section is tapped.
     
     The given handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped.
     The cell will be safely cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter row: The row of the cell that was tapped.
     - parameter tappedCell: The cell that was tapped.
     - returns: A section binder to continue the binding chain with.
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
     Adds a handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter row: The row of the cell to provide the height for.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionCellHeightBlocks[section] = handler
        return self
    }
    
    /**
     Adds a handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     - parameter handler: The closure to be called that will return the estimated height for cells in the section.
     - parameter row: The row of the cell to provide the estimated height for.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionEstimatedCellHeightBlocks[section] = handler
        return self
    }
    
    /**
     Adds a callback handler to provide the height for the section header in the declared section.
     - parameter handler: The closure to be called that will return the height for the section header.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func headerHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionHeaderHeightBlocks[section] = handler
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section header in the declared section.
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionHeaderEstimatedHeightBlocks[section] = handler
        return self
    }
    
    /**
     Adds a callback handler to provide the height for the section footer in the declared section.
     - parameter handler: The closure to be called that will return the height for the section footer.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func footerHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionFooterHeightBlocks[section] = handler
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section footer in the declared section.
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionFooterEstimatedHeightBlocks[section] = handler
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
            return nil
        }
        self.binder.sectionFooterDequeueBlocks[self.section] = footerDequeueBlock
    }
}

