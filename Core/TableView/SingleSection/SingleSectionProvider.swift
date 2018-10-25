import UIKit

/**
 A section binder for a section whose cells are dequeued manually (we were just given a closure and the number of cells
 to create).
 */
public class TableViewProviderSingleSectionBinder<S: TableViewSection>: BaseTableViewSingleSectionBinder<UITableViewCell, S>, TableViewSingleSectionBinderProtocol {
    public typealias C = UITableViewCell
    
    /**
     Returns a closure that can be called to update the number of cells in the section.
     
     This closure is retrieved at the end of the binding sequence and stored somewhere useful. Whenever the underlying
     data the table view is displaying is updated, call this closure with the new number of cells and the table view
     binder will update the displayed cells in the section to match the given number.
     */
    public func createUpdateCallback() -> (_ numberOfCells: Int) -> Void {
        return { [weak binder = self.binder, section = self.section] (numCells: Int) in
            binder?.updateNumberOfCells([section: numCells], sections: [section])
        }
    }
    
    @discardableResult
    override public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> TableViewProviderSingleSectionBinder<S>
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
            super.bind(headerType: headerType, viewModel: viewModel)
            return self
    }
    
    @discardableResult
    public override func headerTitle(_ title: String) -> TableViewProviderSingleSectionBinder<S> {
        super.headerTitle(title)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> TableViewProviderSingleSectionBinder<S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
            super.bind(footerType: footerType, viewModel: viewModel)
            return self
    }
    
    @discardableResult
    public override func footerTitle(_ title: String) -> TableViewProviderSingleSectionBinder<S> {
        super.footerTitle(title)
        return self
    }
    
    @discardableResult
    override public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> TableViewProviderSingleSectionBinder<S> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    override public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> TableViewProviderSingleSectionBinder<S> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    override public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewProviderSingleSectionBinder<S> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> TableViewProviderSingleSectionBinder<S> {
        super.estimatedCellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func footerHeight(_ handler: @escaping () -> CGFloat) -> TableViewProviderSingleSectionBinder<S> {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedFooterHeight(_ handler: @escaping () -> CGFloat) -> TableViewProviderSingleSectionBinder<S> {
        super.estimatedFooterHeight(handler)
        return self
    }
    
    @discardableResult
    override public func headerHeight(_ handler: @escaping () -> CGFloat) -> TableViewProviderSingleSectionBinder<S> {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedHeaderHeight(_ handler: @escaping () -> CGFloat) -> TableViewProviderSingleSectionBinder<S> {
        super.estimatedHeaderHeight(handler)
        return self
    }
}
