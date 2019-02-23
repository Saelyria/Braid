import UIKit

/**
 An object used to continue a binding chain.
 
 This is a throwaway object created when a table view binder's `onSection(_:)` method is called. This object declares a
 number of methods that take a binding handler and give it to the original table view binder to store for callback. A
 reference to this object should not be kept and should only be used in a binding chain.
*/
public class TableViewModelSingleSectionBinder<C: UITableViewCell, S: TableViewSection, M>
    : TableViewSingleSectionBinder<C, S>
{    
    /**
     Adds a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped, along
     with the raw model object associated with the cell. The cell will be safely cast to the cell type bound to the
     section if this method is called in a chain after the a cell binding method method.
     
     Note that this `onTapped` variation with the raw model object is only available if a cell binding method that takes
     a model type was used to bind the cell type to the section.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter row: The row of the cell that was tapped.
     - parameter cell: The cell that was tapped.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     
     - returns: A section binder to continue the binding chain with.
    */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ cell: C, _ model: M) -> Void)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        let section = self.section
        super.onTapped {  [weak binder = self.binder] (row, cell) in
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                assertionFailure("ERROR: Model wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row, the dequeued cell, and the
     model object that the cell was dequeued to represent. The cell will be cast to the cell type bound to the section
     if this method is called in a chain after a cell binding method. This method can be used to perform any additional
     configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in the bound section.
     - parameter row: The row of the cell that was dequeued.
     - parameter cell: The cell that was dequeued that can now be configured.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onDequeue(_ handler: @escaping (_ row: Int, _ cell: C, _ model: M) -> Void)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        let section = self.section
        super.onDequeue { [weak binder = self.binder] (row, cell) in
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                assertionFailure("ERROR: Model wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        return self
    }
    
    /**
     Adds a handler to be called when a cell of the given type emits a custom view event.
     
     To use this method, the given cell type must conform to `ViewEventEmitting`. This protocol has the cell declare an
     associated `ViewEvent` enum type whose cases define custom events that can be observed from the binding chain.
     When a cell emits an event via its `emit(event:)` method, the handler given to this method is called with the
     event and various other objects that allows the view controller to respond.
     
     - parameter cellType: The event-emitting cell type to observe events from.
     - parameter handler: The closure to be called whenever a cell of the given cell type emits a custom event.
     - parameter row: The row of the cell that emitted an event.
     - parameter cell: The cell that emitted an event.
     - parameter event: The custom event that the cell emitted.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     
     - returns: A section binder to continue the binding chain with.
    */
    @discardableResult
    public func onEvent<EventCell>(
        from cellType: EventCell.Type,
        _ handler: @escaping (_ row: Int, _ cell: EventCell, _ event: EventCell.ViewEvent, _ model: M) -> Void)
        -> TableViewModelSingleSectionBinder<C, S, M>
        where EventCell: UITableViewCell & ViewEventEmitting
    {
        let section = self.section
        super.onEvent(from: cellType) { [weak binder = self.binder] row, cell, event in
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                assertionFailure("ERROR: Model wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, event, model)
        }
        return self
    }
    
    // MARK: -
    
    @discardableResult
    public override func bind<H>(
        headerType: H.Type,
        viewModel: H.ViewModel?)
        -> TableViewModelSingleSectionBinder<C, S, M>
        where H : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(headerType: headerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func bind<H>(
        headerType: H.Type,
        viewModel: @escaping () -> H.ViewModel?)
        -> TableViewModelSingleSectionBinder<C, S, M>
        where H : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(headerType: headerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func bind(
        headerTitle: String?)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.bind(headerTitle: headerTitle)
        return self
    }
    
    @discardableResult
    public override func bind(
        headerTitle: @escaping () -> String?)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.bind(headerTitle: headerTitle)
        return self
    }
    
    @discardableResult
    public override func bind<F>(
        footerType: F.Type,
        viewModel: F.ViewModel?)
        -> TableViewModelSingleSectionBinder<C, S, M>
        where F : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(footerType: footerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func bind<F>(
        footerType: F.Type,
        viewModel: @escaping () -> F.ViewModel?)
        -> TableViewModelSingleSectionBinder<C, S, M>
        where F : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(footerType: footerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func bind(
        footerTitle: String?)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.bind(footerTitle: footerTitle)
        return self
    }
    
    @discardableResult
    public override func bind(
        footerTitle: @escaping () -> String?)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.bind(footerTitle: footerTitle)
        return self
    }
    
    // MARK: -
    
    @discardableResult
    override public func onDequeue(_ handler: @escaping (_ row: Int, _ cell: C) -> Void)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.onDequeue(handler)
        return self
    }
    
    @discardableResult
    override public func onTapped(_ handler: @escaping (_ row: Int, _ cell: C) -> Void)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    override public func onEvent<EventCell>(
        from: EventCell.Type,
        _ handler: @escaping (_ row: Int, _ cell: EventCell, _ event: EventCell.ViewEvent) -> Void)
        -> TableViewModelSingleSectionBinder<C, S, M>
        where EventCell: UITableViewCell & ViewEventEmitting
    {
        super.onEvent(from: from, handler)
        return self
    }
    
    // MARK: -

    @discardableResult
    public override func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.estimatedCellHeight(handler)
        return self
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
    public func cellHeight(_ handler: @escaping (_ row: Int, _ model: M) -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        let section = self.section
        super.cellHeight { [weak binder = self.binder] (row: Int) in
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                fatalError("Didn't get the right model type - something went awry!")
            }
            return handler(row, model)
        }
        return self
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
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int, _ model: M) -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        let section = self.section
        super.estimatedCellHeight { [weak binder = self.binder] (row: Int) in
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                fatalError("Didn't get the right model type - something went awry!")
            }
            return handler(row, model)
        }
        return self
    }
    
    @discardableResult
    public override func headerHeight(_ handler: @escaping () -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.estimatedHeaderHeight(handler)
        return self
    }
    
    @discardableResult
    public override func footerHeight(_ handler: @escaping () -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedFooterHeight(_ handler: @escaping () -> CGFloat)
        -> TableViewModelSingleSectionBinder<C, S, M>
    {
        super.estimatedFooterHeight(handler)
        return self
    }

}
