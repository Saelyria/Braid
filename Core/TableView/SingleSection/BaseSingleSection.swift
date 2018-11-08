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
    public func bind<H>(
        headerType: H.Type,
        viewModel: H.ViewModel?,
        updatedWith updateHandler: ((_ updateCallback: (_ newViewModel: H.ViewModel?) -> Void) -> Void)? = nil)
        -> BaseTableViewSingleSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addHeaderDequeueBlock(headerType: headerType, sections: [self.section])
        self.binder.updateHeaderViewModels([self.section: viewModel], sections: [self.section])
        
        let updateCallback: (H.ViewModel?) -> Void
        updateCallback = { [weak binder = self.binder, section = self.section] (viewModel) in
            binder?.updateHeaderViewModels([section: viewModel], sections: [section])
        }
        updateHandler?(updateCallback)
        
        return self
    }
    
    /**
     Binds the given title to the section's header.
     
     This method will provide the given title as the title for the iOS native section headers. If you have bound a custom
     header type to the table view using the `bind(headerType:viewModel:)` method, this method will do nothing.
     
     - parameter headerTitle: The title to use for the section's header.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        headerTitle: String?,
        updateWith updateHandler: ((_ updateCallback: (_ newTitle: String?) -> Void) -> Void)? = nil)
        -> BaseTableViewSingleSectionBinder<C, S>
    {
        self.binder.updateHeaderTitles([self.section: headerTitle], sections: [self.section])
        
        let updateCallback: (String?) -> Void
        updateCallback = { [weak binder = self.binder, section = self.section] (title) in
            binder?.updateHeaderTitles([section: title], sections: [section])
        }
        updateHandler?(updateCallback)

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
    public func bind<F>(
        footerType: F.Type,
        viewModel: F.ViewModel?,
        updatedWith updateHandler: ((_ updateCallback: (_ newViewModel: F.ViewModel?) -> Void) -> Void)? = nil)
        -> BaseTableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        self.binder.addFooterDequeueBlock(footerType: footerType, sections: [self.section])
        self.binder.updateFooterViewModels([self.section: viewModel], sections: [self.section])
        
        let updateCallback: (F.ViewModel?) -> Void
        updateCallback = { [weak binder = self.binder, section = self.section] (viewModel) in
            binder?.updateFooterViewModels([section: viewModel], sections: [section])
        }
        updateHandler?(updateCallback)
        
        return self
    }
    
    /**
     Binds the given title to the section's footer.
     
     This method will provide the given title as the title for the iOS native section footers. If you have bound a custom
     footer type to the table view using the `bind(footerType:viewModel:)` method, this method will do nothing.
     
     - parameter footerTitle: The title to use for the section's footer.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        footerTitle: String?,
        updateWith updateHandler: ((_ updateCallback: (_ newTitle: String?) -> Void) -> Void)? = nil)
        -> BaseTableViewSingleSectionBinder<C, S>
    {
        self.binder.updateFooterTitles([self.section: footerTitle], sections: [self.section])
        
        let updateCallback: (String?) -> Void
        updateCallback = { [weak binder = self.binder, section = self.section] (title) in
            binder?.updateFooterTitles([section: title], sections: [section])
        }
        updateHandler?(updateCallback)
 
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
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void)
        -> BaseTableViewSingleSectionBinder<C, S>
    {
        let dequeueCallback: CellDequeueCallback<S> = { (_, row, cell) in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.handlers.sectionCellDequeuedCallbacks[self.section] = dequeueCallback
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
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void)
        -> BaseTableViewSingleSectionBinder<C, S>
    {
        let tappedHandler: CellTapCallback<S> = { (_, row, cell) in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.handlers.sectionCellTappedCallbacks[self.section] = tappedHandler
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
        self.binder.handlers.sectionCellHeightBlocks[self.section] = { (_, row: Int) in
            return handler(row)
        }
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
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat)
        -> BaseTableViewSingleSectionBinder<C, S>
    {
        self.binder.handlers.sectionEstimatedCellHeightBlocks[self.section] = { (_, row: Int) in
            return handler(row)
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the height for the section header in the declared section.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func headerHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionHeaderHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section header in the declared section.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionHeaderEstimatedHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the height for the section footer in the declared section.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func footerHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionFooterHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section footer in the declared section.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.handlers.sectionFooterEstimatedHeightBlocks[section] = { (_) in
            return handler()
        }
        return self
    }
}
