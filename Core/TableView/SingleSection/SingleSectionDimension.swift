import Foundation

public struct SingleSectionDimension<S: TableViewSection> {
    internal let bindingFunc: (SectionedTableViewBinder<S>, S) -> Void
    
    /**
     Adds a handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter row: The row of the cell to provide the height for.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionDimension<S> {
        return SingleSectionDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionCellHeightBlocks[section] = { (_, row: Int) in
                return handler(row)
            }
        })
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
    public static func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionDimension<S> {
        return SingleSectionDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionEstimatedCellHeightBlocks[section] = { (_, row: Int) in
                return handler(row)
            }
        })
    }
    
    /**
     Adds a callback handler to provide the height for the section header in the declared section.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func headerHeight(_ handler: @escaping () -> CGFloat) -> SingleSectionDimension<S> {
        return SingleSectionDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionHeaderHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section header in the declared section.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> SingleSectionDimension<S> {
        return SingleSectionDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionHeaderEstimatedHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }
    
    /**
     Adds a callback handler to provide the height for the section footer in the declared section.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func footerHeight(_ handler: @escaping () -> CGFloat) -> SingleSectionDimension<S> {
        return SingleSectionDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionFooterHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }
    
    /**
     Adds a callback handler to provide the estimated height for the section footer in the declared section.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> SingleSectionDimension<S> {
        return SingleSectionDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionFooterEstimatedHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }
}
