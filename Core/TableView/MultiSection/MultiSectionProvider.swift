import UIKit

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methods that take a binding handler and give it to the original table view binder to store for callback.
 */
public class TableViewProviderMultiSectionBinder<S: TableViewSection>: BaseTableViewMutliSectionBinder<UITableViewCell, S>, TableViewMutliSectionBinderProtocol {
    public typealias C = UITableViewCell
    
    /**
     Returns a closure that can be called to update the models for the cells for the sections.
     
     This closure is retrieved at the end of the binding sequence and stored somewhere useful. Whenever the underlying
     data the table view is displaying is updated, call this closure with the new models and the table view binder will
     update the displayed cells in its sections to match the given arrays.
     */
    public func createUpdateCallback() -> (_ numberOfCells: [S: Int]) -> Void {
        return { [weak binder = self.binder, sections = self.sections] (numCells: [S: Int]) in
            binder?.updateNumberOfCells(numCells, sections: sections)
        }
    }
    
    @discardableResult
    public override func bind<H>(headerType: H.Type, viewModels: [S: H.ViewModel]) -> TableViewProviderMultiSectionBinder<S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func headerTitles(_ titles: [S: String]) -> TableViewProviderMultiSectionBinder<S> {
        super.headerTitles(titles)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModels: [S: F.ViewModel]) -> TableViewProviderMultiSectionBinder<S>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func footerTitles(_ titles: [S: String]) -> TableViewProviderMultiSectionBinder<S> {
        super.footerTitles(titles)
        return self
    }
    
    @discardableResult
    public override func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> TableViewProviderMultiSectionBinder<S> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    public override func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> TableViewProviderMultiSectionBinder<S> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    public override func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewProviderMultiSectionBinder<S> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewProviderMultiSectionBinder<S> {
        super.estimatedCellHeight(handler)
        return self
    }
    
    @discardableResult
    public override func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewProviderMultiSectionBinder<S> {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewProviderMultiSectionBinder<S> {
        super.estimatedHeaderHeight(handler)
        return self
    }
    
    @discardableResult
    public override func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewProviderMultiSectionBinder<S> {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewProviderMultiSectionBinder<S> {
        super.estimatedFooterHeight(handler)
        return self
    }
}
