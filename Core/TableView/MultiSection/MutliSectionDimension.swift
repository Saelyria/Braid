import Foundation

public class MultiSectionDimension<S: TableViewSection> {
    internal let bindingFunc: (SectionedTableViewBinder<S>, [S]?) -> Void
    
    internal init(bindingFunc: @escaping (SectionedTableViewBinder<S>, [S]?) -> Void) {
        self.bindingFunc = bindingFunc
    }
    
    /**
     Adds a handler to provide the cell height for cells in the declared sections.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter section: The section of the cell to provide the height for.
     - parameter row: The row of the cell to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> MultiSectionDimension<S>
    {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionCellHeightBlocks[section] = handler
                }
            } else {
                binder.handlers.dynamicSectionsCellHeightBlock = handler
            }
        })
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
    public class func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> MultiSectionDimension<S>
    {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionEstimatedCellHeightBlocks[section] = handler
                }
            } else {
                binder.handlers.dynamicSectionsEstimatedCellHeightBlock = handler
            }
        })
    }
    
    /**
     Adds a callback handler to provide the height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     - parameter section: The section of the header to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionHeaderHeightBlocks[section] = handler
                }
            } else {
                binder.handlers.dynamicSectionsHeaderHeightBlock = handler
            }
        })
    }

    /**
     Adds a callback handler to provide the estimated height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - parameter section: The section of the header to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionHeaderEstimatedHeightBlocks[section] = handler
                }
            } else {
                binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock = handler
            }
        })
    }
    
    /**
     Adds a callback handler to provide the height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     - parameter section: The section of the footer to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionFooterHeightBlocks[section] = handler
                }
            } else {
                binder.handlers.dynamicSectionsFooterHeightBlock = handler
            }
        })
    }

    /**
     Adds a callback handler to provide the estimated height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - parameter section: The section of the footer to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionFooterEstimatedHeightBlocks[section] = handler
                }
            } else {
                binder.handlers.dynamicSectionsFooterEstimatedHeightBlock = handler
            }
        })
    }
}
