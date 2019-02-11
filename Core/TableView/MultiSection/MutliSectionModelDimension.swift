import Foundation

public class MultiSectionModelDimension<S: TableViewSection, M>: MultiSectionDimension<S> {
    @discardableResult
    public override class func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: cellHeightBindingFunc(for: handler))
    }

    @discardableResult
    public override class func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: estimatedCellHeightBindingFunc(for: handler))
    }
    
    /**
     Adds a handler to provide the cell height for cells in the declared sections.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter section: The section of the cell to provide the height for.
     - parameter row: The row of the cell to provide the height for.
     - parameter model: The model for the cell to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func cellHeight(_ handler: @escaping (_ section: S, _ row: Int, _ model: M) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: { (binder, affectedSections) in
            let storedHandler: (S, Int) -> CGFloat = { section, row in
                guard let model = binder.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                    fatalError("Didn't get the right model type, something went awry!")
                }
                return handler(section, row, model)
            }
            
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionCellHeightBlocks[section] = storedHandler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsCellHeightBlock = storedHandler
            case .forAnySection:
                binder.handlers.anySectionCellHeightBlock = storedHandler
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
     - parameter model: The model for the cell to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public class func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int, _ model: M) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: { (binder, affectedSections) in
            let storedHandler: (S, Int) -> CGFloat = { section, row in
                guard let model = binder.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                    fatalError("Didn't get the right model type, something went awry!")
                }
                return handler(section, row, model)
            }
            
            switch affectedSections {
            case .forNamedSections(let sections):
                for section in sections {
                    binder.handlers.sectionEstimatedCellHeightBlocks[section] = storedHandler
                }
            case .forAllUnnamedSections:
                binder.handlers.dynamicSectionsEstimatedCellHeightBlock = storedHandler
            case .forAnySection:
                binder.handlers.anySectionEstimatedCellHeightBlock = storedHandler
            }
        })
    }
    
    @discardableResult
    public override class func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: headerHeightBindingFunc(for: handler))
    }
    
    @discardableResult
    public override class func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: estimatedHeaderHeightBindingFunc(for: handler))
    }
    
    @discardableResult
    public override class func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: footerHeightBindingFunc(for: handler))
    }
    
    @discardableResult
    public override class func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> MultiSectionModelDimension<S, M>
    {
        return MultiSectionModelDimension(bindingFunc: estimatedFooterHeightBindingFunc(for: handler))
    }
}
