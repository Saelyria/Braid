import UIKit

/**
 A section binder for a section whose cells were setup to be dequeued with an array of the cell type's 'view model'
 type.
 */
public class TableViewViewModelSingleSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection>: BaseTableViewSingleSectionBinder<C, S>, TableViewSingleSectionBinderProtocol {
    /**
     Creates a cell view model update callback in the handler that can be used to update the view models for the
     section being bound.
     
     This method is called with a handler that is passed in a closure that is used to update the view models for the
     section being bound. It can be used anywhere in the binding chain after the cell is bound. This method's usage
     generally looks something like this:
     ```
     let updateSomeSection: ([MyCellType.ViewModel]) -> Void
     
     binder.onSection(.someSection)
        .bind(cellType: MyCellType.self, viewModels: [...])
        .updateCells(with: { [unowned self] updateCallback in
            self.updateSomeSection = updateCallback
        })
     ...
     
     let newViewModels: [MyCellType.ViewModel] = ...
     updateSomeSection(newViewModels)
     ```
     
     - parameter handler: A handler that is called immediately that is passed in an 'update callback' closure. This
        closure can be called at any time after the binder's `finish` method is called to update the view models for the
        section.
     - parameter viewModels: The array of view models the cells in the section should be updated with.
    */
    @discardableResult
    public func updateCells(with handler: ((_ viewModels: [C.ViewModel]) -> Void) -> Void) -> TableViewViewModelSingleSectionBinder<C, S> {
        let updateCallback = { [weak binder = self.binder, section = self.section] (viewModels: [C.ViewModel]) -> Void in
            binder?.updateCellModels(nil, viewModels: [section: viewModels], sections: [section])
        }
        handler(updateCallback)
        return self
    }
    
    @discardableResult
    override public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> TableViewViewModelSingleSectionBinder<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func headerTitle(_ title: String) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.headerTitle(title)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> TableViewViewModelSingleSectionBinder<C, S>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    public override func footerTitle(_ title: String) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.footerTitle(title)
        return self
    }
    
    @discardableResult
    override public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    override public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    override public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.estimatedCellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func footerHeight(_ handler: @escaping () -> CGFloat) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.estimatedFooterHeight(handler)
        return self
    }
    
    @discardableResult
    override public func headerHeight(_ handler: @escaping () -> CGFloat) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.estimatedHeaderHeight(handler)
        return self
    }
}
