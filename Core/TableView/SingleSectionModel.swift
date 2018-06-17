import UIKit

public class SingleSectionModelTableViewBindResult<C: UITableViewCell, S: TableViewSection, M>: SingleSectionTableViewBindResult<C, S> {
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped, along
     with the raw model object associated with the cell. The cell will be cast to the cell type bound to the section if
     this method is called in a chain after the `bind(cellType:viewModels:)` method.
     
     Note that this `onTapped` variation with the raw model object is only available if the
     `bind(cellType:models:mapToViewModelsWith:)` method was used to bind the cell type to the section.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C, _ model: M) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        let section = self.section
        let tappedHandler: CellTapCallback = {  [weak binder = self.binder] (row, cell) in
            guard let cell = cell as? C, let model = binder?.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func configureCell(_ handler: @escaping (_ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        let section = self.section
        let dequeueCallback: CellDequeueCallback = { [weak binder = self.binder] row, cell in
            guard let cell = cell as? C, let model = binder?.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell, model)
        }
        
        self.binder.sectionCellDequeuedCallbacks[section] = dequeueCallback
        
        return self
    }
    
    @discardableResult
    override public func bind<H>(headerType: H.Type, viewModel: Observable<H.ViewModel>) -> SingleSectionModelTableViewBindResult<C, S, M>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func headerTitle(_ title: String) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.headerTitle(title)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> SingleSectionModelTableViewBindResult<C, S, M>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func footerTitle(_ title: String) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.footerTitle(title)
        return self
    }
    
    @discardableResult
    override public func configureCell(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    override public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    override public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.estimatedCellHeight(handler)
        return self
    }
}


