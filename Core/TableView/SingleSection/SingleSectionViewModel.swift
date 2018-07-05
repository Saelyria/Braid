import UIKit

/**
 A binder for a section whose cells were setup to be dequeued with an array of the cell type's 'view model' type.
 */
public class TableViewViewModelSingleSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection>: BaseTableViewSingleSectionBinder<C, S> {
    /**
     Returns a closure that can be called to update the view models for the cells for the section.
     
     This closure is retrieved at the end of the binding sequence and stored somewhere useful. Whenever the
     underlying data the table view is displaying is updated, call this closure with the new view models
     and the table view binder will update the displayed cells to match the given array.
     */
    public func createSectionUpdateCallback() -> (_ viewModels: [C.ViewModel]) -> Void {
        return { (viewModels: [C.ViewModel]) in
            self.binder.sectionCellViewModels[self.section] = viewModels
            self.binder.reload(section: self.section)
        }
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
    override public func configureCell(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> TableViewViewModelSingleSectionBinder<C, S> {
        super.configureCell(handler)
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
}
