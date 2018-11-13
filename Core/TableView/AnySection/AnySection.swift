import UIKit

/**
 An object used to continue a binding chain.
 
 This is a throwaway object created when a table view binder's `onAnySection()` method is called. This object declares a
 number of methods that take a binding handler and give it to the original table view binder to store for callback. A
 reference to this object should not be kept and should only be used in a binding chain.
*/
public class AnySectionBinder<S: TableViewSection> {
    internal let binder: SectionedTableViewBinder<S>
    
    internal init(binder: SectionedTableViewBinder<S>) {
        self.binder = binder
    }
    
    /**
     Adds a handler to be called whenever a cell is dequeued in any section.
     
     The given handler is called whenever a cell in any section on the table is dequeued, passing in the section, row,
     and the dequeued cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in one of the bound sections.
     - parameter section: The section in which a cell was dequeued.
     - parameter row: The row of the cell that was dequeued.
     - parameter dequeuedCell: The cell that was dequeued that can now be configured.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: UITableViewCell) -> Void)
        -> AnySectionBinder<S>
    {
        self.binder.handlers.anySectionCellDequeuedCallback = handler

        return self
    }
    
    /**
     Adds a handler to be called whenever a cell in any section is tapped.
     
     The given handler is called whenever a cell in any section is tapped, passing in the section, row, and cell that
     was tapped.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter section: The section in which a cell was tapped.
     - parameter row: The row of the cell that was tapped.
     - parameter tappedCell: The cell that was tapped.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: UITableViewCell) -> Void)
        -> AnySectionBinder<S>
    {
        self.binder.handlers.anySectionCellTappedCallback = handler
        
        return self
    }
    
    /**
     Adds a handler to provide the cell height for any section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter section: The section of the cell to provide the height for.
     - parameter row: The row of the cell to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> AnySectionBinder<S> {
        self.binder.handlers.anySectionCellHeightBlock = handler
        
        return self
    }
    
    /**
     Adds a handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     
     - parameter handler: The closure to be called that will return the estimated height for cells in the section.
     - parameter section: The section of the cell to provide the estimated height for.
     - parameter row: The row of the cell to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> AnySectionBinder<S> {
        self.binder.handlers.anySectionEstimatedCellHeightBlock = handler
        
        return self
    }
    
    /**
     Adds a callback handler to provide the height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     - parameter section: The section of the header to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> AnySectionBinder<S> {
        self.binder.handlers.anySectionHeaderHeightBlock = handler
        
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - parameter section: The section of the header to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> AnySectionBinder<S> {
        self.binder.handlers.anySectionHeaderEstimatedHeightBlock = handler
        
        return self
    }
    
    /**
     Adds a callback handler to provide the height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     - parameter section: The section of the footer to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> AnySectionBinder<S> {
        self.binder.handlers.anySectionFooterHeightBlock = handler
        
        return self
    }
    
    /**
     Adds a callback handler to provide the estimated height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - parameter section: The section of the footer to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> AnySectionBinder<S> {
        self.binder.handlers.anySectionFooterEstimatedHeightBlock = handler
        
        return self
    }
}
