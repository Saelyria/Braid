import UIKit

/**
 An object used to continue a binding chain.
 
 This is a throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a
 number of methods that take a binding handler and give it to the original table view binder to store for callback. A
 reference to this object should not be kept and should only be used in a binding chain.
 */
public class TableViewModelMultiSectionBinder<C: UITableViewCell, S: TableViewSection, M>
    : TableViewMultiSectionBinder<C, S>
{
    /**
     Adds a handler to be called whenever a cell in one of the declared sections is tapped.
     
     The given handler is called whenever a cell in one of the sections being bound  is tapped, passing in the row and
     cell that was tapped. The cell will be safely cast to the cell type bound to the section if this method is called
     in a chain after a cell binding method method.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter section: The section in which a cell was tapped.
     - parameter row: The row of the cell that was tapped.
     - parameter cell: The cell that was tapped.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ cell: C, _ model: M) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        let tappedHandler: CellTapCallback<S> = {  [weak binder = self.binder] (section, row, cell) in
            guard let cell = cell as? C,
            let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell, model)
        }
        
        if let sections = self.sections {
            for section in sections {
                self.binder.handlers.sectionCellTappedCallbacks[section] = tappedHandler
            }
        } else {
            self.binder.handlers.dynamicSectionsCellTappedCallback = tappedHandler
        }

        return self
    }
    
    /**
     Adds a handler to be called whenever a cell is dequeued in one of the declared sections.
     
     The given handler is called whenever a cell in one of the sections being bound is dequeued, passing in the row and
     the dequeued cell. The cell will be safely cast to the cell type bound to the section if this method is called in a
     chain after a cell binding method method. This method can be used to perform any additional configuration of the
     cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in one of the bound sections.
     - parameter section: The section in which a cell was dequeued.
     - parameter row: The row of the cell that was dequeued.
     - parameter cell: The cell that was dequeued that can now be configured.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ cell: C, _ model: M) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        let dequeueCallback: CellDequeueCallback<S> = { [weak binder = self.binder] (section, row, cell) in
            guard let cell = cell as? C,
            let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell, model)
        }
        
        if let sections = self.sections {
            for section in sections {
                self.binder.handlers.sectionDequeuedCallbacks[section] = dequeueCallback
            }
        } else {
            self.binder.handlers.dynamicSectionsCellDequeuedCallback = dequeueCallback
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
     - parameter section: The section in which a cell emitted an event.
     - parameter row: The row of the cell that emitted an event.
     - parameter cell: The cell that emitted an event.
     - parameter event: The custom event that the cell emitted.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onEvent<EventCell>(
        from cellType: EventCell.Type,
        _ handler: @escaping (_ section: S, _ row: Int, _ cell: EventCell, _ event: EventCell.ViewEvent, _ model: M) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
        where EventCell: UITableViewCell & ViewEventEmitting
    {
        super.onEvent(from: cellType) { [weak binder = self.binder] section, row, cell, event in
            guard let model = binder?.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell, event, model)
        }
        return self
    }
    
    // MARK: -
    
    @discardableResult
    public override func bind<H>(
        headerType: H.Type,
        viewModels: [S : H.ViewModel?])
        -> TableViewModelMultiSectionBinder<C, S, M>
        where H : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(headerType: headerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func bind<H>(
        headerType: H.Type,
        viewModels: @escaping () -> [S : H.ViewModel?])
        -> TableViewModelMultiSectionBinder<C, S, M>
        where H : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(headerType: headerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func bind(
        headerTitles: [S : String?])
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.bind(headerTitles: headerTitles)
        return self
    }
    
    @discardableResult
    public override func bind(
        headerTitles: @escaping () -> [S : String?])
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.bind(headerTitles: headerTitles)
        return self
    }
    
    @discardableResult
    public override func bind<F>(
        footerType: F.Type,
        viewModels: [S : F.ViewModel?])
        -> TableViewModelMultiSectionBinder<C, S, M>
        where F : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(footerType: footerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func bind<F>(
        footerType: F.Type,
        viewModels: @escaping () -> [S : F.ViewModel?])
        -> TableViewModelMultiSectionBinder<C, S, M>
        where F : UITableViewHeaderFooterView & ViewModelBindable
    {
        super.bind(footerType: footerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func bind(
        footerTitles: [S : String?])
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.bind(footerTitles: footerTitles)
        return self
    }
    
    @discardableResult
    public override func bind(
        footerTitles: @escaping () -> [S : String?])
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.bind(footerTitles: footerTitles)
        return self
    }
    
    // MARK: -
    
    @discardableResult
    public override func onDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ cell: C) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.onDequeue(handler)
        return self
    }
    
    @discardableResult
    public override func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ cell: C) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    public override func onEvent<EventCell>(
        from cellType: EventCell.Type,
        _ handler: @escaping (_ section: S, _ row: Int, _ cell: EventCell, _ event: EventCell.ViewEvent) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
        where EventCell: UITableViewCell & ViewEventEmitting
    {
        super.onEvent(from: cellType, handler)
        return self
    }
    
    // MARK: -

    @discardableResult
    public override func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        return super.cellHeight(handler)
    }
    
    @discardableResult
    public override func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        return super.estimatedCellHeight(handler)
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
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int, _ model: M) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        let storedHandler: (S, Int) -> CGFloat = { section, row in
            guard let model = binder.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                fatalError("Didn't get the right model type, something went awry!")
            }
            return handler(section, row, model)
        }
        
        switch self.affectedSectionScope {
        case .forNamedSections(let sections):
            for section in sections {
                self.binder.handlers.sectionCellHeightBlocks[section] = storedHandler
            }
        case .forAllUnnamedSections:
            self.binder.handlers.dynamicSectionsCellHeightBlock = storedHandler
        case .forAnySection:
            self.binder.handlers.anySectionCellHeightBlock = storedHandler
        }
        return self
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
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int, _ model: M) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        let storedHandler: (S, Int) -> CGFloat = { section, row in
            guard let model = binder.currentDataModel.item(inSection: section, row: row)?.model as? M else {
                fatalError("Didn't get the right model type, something went awry!")
            }
            return handler(section, row, model)
        }
        
        switch self.affectedSectionScope {
        case .forNamedSections(let sections):
            for section in sections {
                self.binder.handlers.sectionEstimatedCellHeightBlocks[section] = storedHandler
            }
        case .forAllUnnamedSections:
            self.binder.handlers.dynamicSectionsEstimatedCellHeightBlock = storedHandler
        case .forAnySection:
            self.binder.handlers.anySectionEstimatedCellHeightBlock = storedHandler
        }
        return self
    }
    
    @discardableResult
    public override func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        return super.headerHeight(handler)
    }
    
    @discardableResult
    public override func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        return super.estimatedHeaderHeight(handler)
    }
    
    @discardableResult
    public override func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        return super.footerHeight(handler)
    }
    
    @discardableResult
    public override func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        return super.estimatedFooterHeight(handler)
    }

}
