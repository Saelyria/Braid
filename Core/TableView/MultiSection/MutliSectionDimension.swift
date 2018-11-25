import Foundation

public class MultiSectionDimension<S: TableViewSection> {
    /// A function called by the 'dimensions' function that passes in the binder to bind the handlers to, the sections
    /// (nil if the binding handlers are for 'dynamic' sections from the 'onAllSections' method), and a boolean
    /// indicating whether the binding is for 'all sections'. Functions of this type will then perform the work of
    /// taking passed-in handlers and putting them in the correct handler dictionaries on the binder.
    typealias BindingFunc = (SectionedTableViewBinder<S>, SectionBindingScope<S>) -> Void
    
    internal let bindingFunc: BindingFunc
    
    internal init(bindingFunc: @escaping BindingFunc) {
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
        return MultiSectionDimension<S>(bindingFunc: cellHeightBindingFunc(for: handler))
    }
    
    // allows implementation to be shared between this and 'multi section model dimension'
    internal class func cellHeightBindingFunc(for handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> BindingFunc
    {
        return { (binder, affectedSections) in
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionCellHeightBlocks[section] = handler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsCellHeightBlock = handler
            case .forAnySection:
                binder.handlers.anySectionCellHeightBlock = handler
            }
        }
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
        return MultiSectionDimension<S>(bindingFunc: estimatedCellHeightBindingFunc(for: handler))
    }
    
    // allows implementation to be shared between this and 'multi section model dimension'
    internal class func estimatedCellHeightBindingFunc(for handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> BindingFunc
    {
        return { (binder, affectedSections) in
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionEstimatedCellHeightBlocks[section] = handler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsEstimatedCellHeightBlock = handler
            case .forAnySection:
                binder.handlers.anySectionEstimatedCellHeightBlock = handler
            }
        }
    }
    
    /**
     Adds a callback handler to provide the height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     - parameter section: The section of the header to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: headerHeightBindingFunc(for: handler))
    }
    
    // allows implementation to be shared between this and 'multi section model dimension'
    internal class func headerHeightBindingFunc(for handler: @escaping (_ section: S) -> CGFloat)
        -> BindingFunc
    {
        return { (binder, affectedSections) in
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionHeaderHeightBlocks[section] = handler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsHeaderHeightBlock = handler
            case .forAnySection:
                binder.handlers.anySectionHeaderHeightBlock = handler
            }
        }
    }

    /**
     Adds a callback handler to provide the estimated height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - parameter section: The section of the header to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: estimatedHeaderHeightBindingFunc(for: handler))
    }
    
    // allows implementation to be shared between this and 'multi section model dimension'
    internal class func estimatedHeaderHeightBindingFunc(for handler: @escaping (_ section: S) -> CGFloat)
        -> BindingFunc
    {
        return { (binder, affectedSections) in
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionHeaderEstimatedHeightBlocks[section] = handler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsHeaderEstimatedHeightBlock = handler
            case .forAnySection:
                binder.handlers.anySectionHeaderEstimatedHeightBlock = handler
            }
        }
    }
    
    /**
     Adds a callback handler to provide the height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     - parameter section: The section of the footer to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: footerHeightBindingFunc(for: handler))
    }
    
    // allows implementation to be shared between this and 'multi section model dimension'
    internal class func footerHeightBindingFunc(for handler: @escaping (_ section: S) -> CGFloat)
        -> BindingFunc
    {
        return { (binder, affectedSections) in
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionFooterHeightBlocks[section] = handler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsFooterHeightBlock = handler
            case .forAnySection:
                binder.handlers.anySectionFooterHeightBlock = handler
            }
        }
    }

    /**
     Adds a callback handler to provide the estimated height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - parameter section: The section of the footer to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> MultiSectionDimension<S> {
        return MultiSectionDimension<S>(bindingFunc: estimatedFooterHeightBindingFunc(for: handler))
    }
    
    // allows implementation to be shared between this and 'multi section model dimension'
    internal class func estimatedFooterHeightBindingFunc(for handler: @escaping (_ section: S) -> CGFloat)
        -> BindingFunc
    {
        return { (binder, affectedSections) in
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionFooterEstimatedHeightBlocks[section] = handler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsFooterEstimatedHeightBlock = handler
            case .forAnySection:
                binder.handlers.anySectionFooterEstimatedHeightBlock = handler
            }
        }
    }
}
