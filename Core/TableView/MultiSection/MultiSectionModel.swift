import UIKit

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methodss that take a binding handler and give it to the original table view binder to store for callback.
 */
public class TableViewModelMultiSectionBinder<C: UITableViewCell, S: TableViewSection, M>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {
    internal var sectionBindResults: [S: TableViewModelSingleSectionBinder<C, S, M>] = [:]
    
    public func createUpdateCallback() -> ([S: [M]]) -> Void {
        return { (models: [S: [M]]) in
            var _sections: [S] = []
            for (section, sectionModels) in models {
                _sections.append(section)
                self.binder.sectionCellModels[section] = sectionModels
            }
            self.binder.reload(sections: _sections)
        }
    }
    
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C, _ model: M) -> Void) -> TableViewModelMultiSectionBinder<C, S, M> {
        for section in self.sections {
            let bindResult = self.bindResult(for: section)
            bindResult.onTapped({ row, cell, model in
                handler(section, row, cell, model)
            })
        }
        return self
    }
    
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> TableViewModelMultiSectionBinder<C, S, M> {
        for section in self.sections {
            let bindResult = self.bindResult(for: section)
            bindResult.onCellDequeue({ row, cell, model in
                handler(section, row, cell, model)
            })
        }
        return self
    }
    
    @discardableResult
    public override func bind<H>(headerType: H.Type, viewModels: [S: H.ViewModel]) -> TableViewModelMultiSectionBinder<C, S, M>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func headerTitles(_ titles: [S: String]) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.headerTitles(titles)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModels: [S: F.ViewModel]) -> TableViewModelMultiSectionBinder<C, S, M>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func footerTitles(_ titles: [S: String]) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.footerTitles(titles)
        return self
    }
    
    @discardableResult
    public override func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    public override func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    public override func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.estimatedCellHeight(handler)
        return self
    }
    
    @discardableResult
    public override func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.estimatedHeaderHeight(handler)
        return self
    }
    
    @discardableResult
    public override func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelMultiSectionBinder<C, S, M> {
        super.estimatedFooterHeight(handler)
        return self
    }
}

internal extension TableViewModelMultiSectionBinder {
    internal func bindResult(`for` section: S) -> TableViewModelSingleSectionBinder<C, S, M> {
        if let bindResult = self.sectionBindResults[section] {
            return bindResult
        } else {
            let bindResult = TableViewModelSingleSectionBinder<C, S, M>(binder: self.binder, section: section)
            self.sectionBindResults[section] = bindResult
            return bindResult
        }
    }
}
