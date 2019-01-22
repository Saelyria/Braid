import Foundation

public class SingleSectionModelDimension<S: TableViewSection, M>: SingleSectionDimension<S> {
    @discardableResult
    public override class func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat)
        -> SingleSectionModelDimension<S, M>
    {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionCellHeightBlocks[section] = { (_, row: Int) in
                return handler(row)
            }
        })
    }
    
    @discardableResult
    public override class func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat)
        -> SingleSectionModelDimension<S, M>
    {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionEstimatedCellHeightBlocks[section] = { (_, row: Int) in
                return handler(row)
            }
        })
    }
    
    /**
     Adds a handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter row: The row of the cell to provide the height for.
     - parameter model: The model for the cell to provide the height for.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public class func cellHeight(_ handler: @escaping (_ row: Int, _ model: M) -> CGFloat)
        -> SingleSectionModelDimension<S, M>
    {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionCellHeightBlocks[section] = { (_, row: Int) in
                guard let model = binder.currentDataModel.sectionCellModels[section]?[row] as? M else {
                    fatalError("Didn't get the right model type - something went awry!")
                }
                return handler(row, model)
            }
        })
    }
    
    /**
     Adds a handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     
     - parameter handler: The closure to be called that will return the estimated height for cells in the section.
     - parameter row: The row of the cell to provide the estimated height for.
     - parameter model: The model for the cell to provide the height for.
     
     - returns: The argument to a 'dimensions' call.
     */
    @discardableResult
    public class func estimatedCellHeight(_ handler: @escaping (_ row: Int, _ model: M) -> CGFloat)
        -> SingleSectionModelDimension<S, M>
    {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionEstimatedCellHeightBlocks[section] = { (_, row: Int) in
                guard let model = binder.currentDataModel.sectionCellModels[section]?[row] as? M else {
                    fatalError("Didn't get the right model type - something went awry!")
                }
                return handler(row, model)
            }
        })
    }
    
    @discardableResult
    public override class func headerHeight(_ handler: @escaping () -> CGFloat) -> SingleSectionModelDimension<S, M> {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionHeaderHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }

    @discardableResult
    public override class func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat)
        -> SingleSectionModelDimension<S, M>
    {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionHeaderEstimatedHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }
 
    @discardableResult
    public override class func footerHeight(_ handler: @escaping () -> CGFloat) -> SingleSectionModelDimension<S, M> {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionFooterHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }

    @discardableResult
    public override class func estimatedFooterHeight(_ handler: @escaping () -> CGFloat)
        -> SingleSectionModelDimension<S, M>
    {
        return SingleSectionModelDimension(bindingFunc: { (binder, section) in
            binder.handlers.sectionFooterEstimatedHeightBlocks[section] = { (_) in
                return handler()
            }
        })
    }
}
