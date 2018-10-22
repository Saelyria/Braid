import UIKit

/**
 A section binder for a section whose cells were setup to be dequeued with an array of an arbitrary 'model' type,
 mapped to the cell's 'view model' type with a given mapping function.
 */
public class TableViewModelViewModelSingleSectionBinder<C, S: TableViewSection, M: Identifiable>: BaseTableViewSingleSectionBinder<C, S>, TableViewSingleSectionBinderProtocol
where C: UITableViewCell & ViewModelBindable {    
    private let mapToViewModelFunc: (M) -> C.ViewModel
    
    internal init(binder: SectionedTableViewBinder<S>, section: S, mapToViewModel: @escaping (M) -> C.ViewModel) {
        self.mapToViewModelFunc = mapToViewModel
        super.init(binder: binder, section: section)
    }
    
    /**
     Returns a closure that can be called to update the models for the cells for the section.
     
     This closure is retrieved at the end of the binding sequence and stored somewhere useful. Whenever the underlying
     data the table view is displaying is updated, call this closure with the new models and the table view binder will
     update the displayed cells in the section to match the given array.
    */
    public func createUpdateCallback() -> ([M]) -> Void {
        return { (models: [M]) in
            self.binder.nextDataModel.sectionCellModels[self.section] = models
            self.binder.nextDataModel.sectionCellViewModels[self.section] = models.map(self.mapToViewModelFunc)
        }
    }
    
    /**
     Adds a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped, along
     with the raw model object associated with the cell. The cell will be safely cast to the cell type bound to the
     section if this method is called in a chain after the `bind(cellType:viewModels:)` method.
     
     Note that this `onTapped` variation with the raw model object is only available if the
     `bind(cellType:models:mapToViewModelsWith:)` method was used to bind the cell type to the section.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter row: The row of the cell that was tapped.
     - parameter tappedCell: The cell that was tapped.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C, _ model: M) -> Void) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        let section = self.section
        let tappedHandler: CellTapCallback<S> = {  [weak binder = self.binder] (_, row, cell) in
            guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row, the dequeued cell, and the
     model object that the cell was dequeued to represent. The cell will be cast to the cell type bound to the section
     if this method is called in a chain after the `bind(cellType:viewModels:mapToViewModelsWith)` method. This method
     can be used to perform any additional configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in the bound section.
     - parameter row: The row of the cell that was dequeued.
     - parameter dequeuedCell: The cell that was dequeued that can now be configured.
     - parameter model: The model object that the cell was dequeued to represent in the table.
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        let section = self.section
        let dequeueCallback: CellDequeueCallback<S> = { [weak binder = self.binder] (_, row, cell) in
            guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        
        self.binder.sectionCellDequeuedCallbacks[section] = dequeueCallback
        
        return self
    }
    
    @discardableResult
    override public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> TableViewModelViewModelSingleSectionBinder<C, S, M>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func headerTitle(_ title: String) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.headerTitle(title)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> TableViewModelViewModelSingleSectionBinder<C, S, M>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func footerTitle(_ title: String) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.footerTitle(title)
        return self
    }
    
    @discardableResult
    override public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    override public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    override public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.estimatedCellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func footerHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.estimatedFooterHeight(handler)
        return self
    }
    
    @discardableResult
    override public func headerHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        super.estimatedHeaderHeight(handler)
        return self
    }
}
