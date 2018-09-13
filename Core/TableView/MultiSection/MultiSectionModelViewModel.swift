import UIKit

public class TableViewModelViewModelMultiSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection, M>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {        
    private let mapToViewModelFunc: (M) -> C.ViewModel
    internal var sectionBindResults: [S: TableViewModelViewModelSingleSectionBinder<C, S, M>] = [:]
    
    init(binder: SectionedTableViewBinder<S>, sections: [S], mapToViewModel: @escaping (M) -> C.ViewModel) {
        self.mapToViewModelFunc = mapToViewModel
        super.init(binder: binder, sections: sections)
    }
    
    public func createUpdateCallback() -> ([S: [M]]) -> Void {
        return { (models: [S: [M]]) in
            var _sections: [S] = []
            for (section, sectionModels) in models {
                _sections.append(section)
                self.binder.sectionCellModels[section] = sectionModels
                self.binder.sectionCellViewModels[section] = sectionModels.map(self.mapToViewModelFunc)
            }
            self.binder.reload(sections: _sections)
        }
    }
    
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C, _ model: M) -> Void) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        for section in self.sections {
            let bindResult = self.bindResult(for: section)
            bindResult.onTapped({ row, cell, model in
                handler(section, row, cell, model)
            })
        }
        return self
    }
    
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        for section in self.sections {
            let bindResult = self.bindResult(for: section)
            bindResult.onCellDequeue({ row, cell, model in
                handler(section, row, cell, model)
            })
        }
        return self
    }
    
    @discardableResult
    public override func bind<H>(headerType: H.Type, viewModels: [S: H.ViewModel]) -> TableViewModelViewModelMultiSectionBinder<C, S, M>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func headerTitles(_ titles: [S: String]) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.headerTitles(titles)
        return self
    }
    
    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModels: [S: F.ViewModel]) -> TableViewModelViewModelMultiSectionBinder<C, S, M>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func footerTitles(_ titles: [S: String]) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.footerTitles(titles)
        return self
    }
    
    @discardableResult
    public override func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    public override func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    public override func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.estimatedCellHeight(handler)
        return self
    }
    
    @discardableResult
    public override func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.headerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.estimatedHeaderHeight(handler)
        return self
    }
    
    @discardableResult
    public override func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.footerHeight(handler)
        return self
    }
    
    @discardableResult
    public override func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        super.estimatedFooterHeight(handler)
        return self
    }

}

internal extension TableViewModelViewModelMultiSectionBinder {
    internal func bindResult(`for` section: S) -> TableViewModelViewModelSingleSectionBinder<C, S, M> {
        if let bindResult = self.sectionBindResults[section] {
            return bindResult
        } else {
            let bindResult = TableViewModelViewModelSingleSectionBinder<C, S, M>(binder: self.binder, section: section, mapToViewModel: self.mapToViewModelFunc)
            self.sectionBindResults[section] = bindResult
            return bindResult
        }
    }
}

