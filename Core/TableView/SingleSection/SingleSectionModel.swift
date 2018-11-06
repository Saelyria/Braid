import UIKit

/**
 A section binder for a section whose cells were setup to be dequeued with an array of an arbitrary 'model' type.
 */
public class TableViewModelSingleSectionBinder<C: UITableViewCell, S: TableViewSection, M>: BaseTableViewSingleSectionBinder<C, S>, TableViewSingleSectionBinderProtocol {
    /**
     Creates a cell model update callback in the handler that can be used to update the models for the section being
     bound.
     
     This method is called with a handler that is passed in a closure that is used to update the models for the
     section being bound. The passed-in 'update callback' closure should be stored somewhere useful to be called anytime
     after the binder has finished binding. This method can be used anywhere in the binding chain after the cell is
     bound.
     
     This method's usage generally looks something like this:
     ```
     let updateSomeSection: ([MyModel]) -> Void
     
     binder.onSection(.someSection)
        .bind(cellType: MyCellType.self, models: [...])
        .updateCells(with: { [unowned self] updateCallback in
            self.updateSomeSection = updateCallback
        })
     ...
     
     let newModels: [MyModel] = ...
     updateSomeSection(newModels)
     ```
     
     - parameter handler: A handler that is called immediately that is passed in an 'update callback' closure. This
        closure can be called at any time after the binder's `finish` method is called to update the models for the
        section.
     - parameter models: The array of models the cells in the section should be updated with.
     */
    @discardableResult
    public func updateCells(with handler: ((_ models: [M]) -> Void) -> Void) -> TableViewModelSingleSectionBinder<C, S, M> {
        let updateCallback = { [weak binder = self.binder, section = self.section] (models: [M]) -> Void in
            binder?.updateCellModels([section: models], viewModels: nil, sections: [section])
        }
        handler(updateCallback)
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped, along
     with the raw model object associated with the cell. The cell will be safely cast to the cell type bound to the
     section if this method is called in a chain after the `bind(cellType:viewModels:)` method.
     
     Note that this `onTapped` variation with the raw model object is only available if the `bind(cellType:models:)`
     method was used to bind the cell type to the section.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter row: The row of the cell that was tapped.
     - parameter tappedCell: The cell that was tapped.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     - returns: A section binder to continue the binding chain with.
    */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C, _ model: M) -> Void) -> TableViewModelSingleSectionBinder<C, S, M> {
        let section = self.section
        let tappedHandler: CellTapCallback<S> = {  [weak binder = self.binder] (_, row, cell) in
            guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        
        self.binder.handlers.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row, the dequeued cell, and the
     model object that the cell was dequeued to represent. The cell will be cast to the cell type bound to the section
     if this method is called in a chain after the `bind(cellType:viewModels:)` method. This method can be used to
     perform any additional configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in the bound section.
     - parameter row: The row of the cell that was dequeued.
     - parameter dequeuedCell: The cell that was dequeued that can now be configured.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> TableViewModelSingleSectionBinder<C, S, M> {
        let section = self.section
        let dequeueCallback: CellDequeueCallback<S> = { [weak binder = self.binder] (_, row, cell) in
            guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        
        self.binder.handlers.sectionCellDequeuedCallbacks[section] = dequeueCallback
        
        return self
    }
    
    @discardableResult
    override public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> TableViewModelSingleSectionBinder<C, S, M>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func headerTitle(_ title: String) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.headerTitle(title)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> TableViewModelSingleSectionBinder<C, S, M>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func footerTitle(_ title: String) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.footerTitle(title)
        return self
    }
    
    @discardableResult
    override public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    override public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    override public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.estimatedCellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func footerHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.estimatedFooterHeight(handler)
        return self
    }
    
    @discardableResult
    override public func headerHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelSingleSectionBinder<C, S, M> {
        super.estimatedHeaderHeight(handler)
        return self
    }
}
