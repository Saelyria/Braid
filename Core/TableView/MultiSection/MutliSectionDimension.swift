import Foundation

public struct MultiSectionDimension<S: TableViewSection> {
    internal let bindingFunc: (SectionedTableViewBinder<S>, [S]?) -> Void
    
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
    public static func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
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
     Adds a handler to provide the cell height for cells in the declared sections.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func cellHeight(_ handler: @escaping () -> CGFloat)
        -> MultiSectionDimension<S>
    {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionCellHeightBlocks[section] = { _, _ in return handler() }
                }
            } else {
                binder.handlers.dynamicSectionsCellHeightBlock = { _, _ in return handler() }
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
    public static func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
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
     Adds a handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     
     - parameter handler: The closure to be called that will return the estimated height for cells in the section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func estimatedCellHeight(_ handler: @escaping () -> CGFloat)
        -> MultiSectionDimension<S>
    {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionEstimatedCellHeightBlocks[section] = { _, _ in return handler() }
                }
            } else {
                binder.handlers.dynamicSectionsEstimatedCellHeightBlock = { _, _ in return handler() }
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
    public static func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
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
     Adds a callback handler to provide the height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func headerHeight(_ handler: @escaping () -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionHeaderHeightBlocks[section] = { _ in return handler() }
                }
            } else {
                binder.handlers.dynamicSectionsHeaderHeightBlock = { _ in return handler() }
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
    public static func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
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
     Adds a callback handler to provide the estimated height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionHeaderEstimatedHeightBlocks[section] = { _ in return handler() }
                }
            } else {
                binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock = { _ in return handler() }
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
    public static func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
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
     Adds a callback handler to provide the height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func footerHeight(_ handler: @escaping () -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionFooterHeightBlocks[section] = { _ in return handler() }
                }
            } else {
                binder.handlers.dynamicSectionsFooterHeightBlock = { _ in return handler() }
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
    public static func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
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
    
    /**
     Adds a callback handler to provide the estimated height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public static func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: { (binder, sections) in
            if let sections = sections {
                for section in sections {
                    binder.handlers.sectionFooterEstimatedHeightBlocks[section] = { _ in return handler() }
                }
            } else {
                binder.handlers.dynamicSectionsFooterEstimatedHeightBlock = { _ in return handler() }
            }
        })
    }
}
