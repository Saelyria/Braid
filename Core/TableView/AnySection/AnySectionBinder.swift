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
     - parameter cell: The cell that was dequeued that can now be configured.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ cell: UITableViewCell) -> Void)
        -> AnySectionBinder<S>
    {
        self.binder.handlers.anySectionDequeuedCallback = handler

        return self
    }
    
    /**
     Adds a handler to be called whenever a cell in any section is tapped.
     
     The given handler is called whenever a cell in any section is tapped, passing in the section, row, and cell that
     was tapped.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter section: The section in which a cell was tapped.
     - parameter row: The row of the cell that was tapped.
     - parameter cell: The cell that was tapped.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ cell: UITableViewCell) -> Void)
        -> AnySectionBinder<S>
    {
        self.binder.handlers.anySectionCellTappedCallback = handler
        
        return self
    }
    
    /**
     Add handlers for various dimensions of cells for the sections being bound.
     
     This method is called with handlers that provide dimensions like cell or header heights and estimated heights. The
     various handlers are made with the static functions on `MultiSectionDimension`. A typical dimension-binding call
     looks something like this:
     
     ```
     binder.onAnySection()
        .dimensions(
            .cellHeight { _, _ in UITableViewAutomaticDimension },
            .estimatedCellHeight { section, row in
                switch section {
                case .first: return 120
                case .second: return 100
                }
            },
            .headerHeight { _ in 50 })
     ```
     
     - parameter dimensions: A variadic list of dimensions bound for the sections being bound. These 'dimension' objects
     are returned from the various dimension-binding static functions on `MultiSectionDimension`.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func dimensions(_ dimensions: MultiSectionDimension<S>...) -> AnySectionBinder<S> {
        self._dimensions(dimensions)
        return self
    }
    
    internal func _dimensions(_ dimensions: [MultiSectionDimension<S>]) {
        for dimension in dimensions {
            dimension.bindingFunc(self.binder, .forAnySection)
        }
    }
}
