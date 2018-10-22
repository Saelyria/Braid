import UIKit

public class TableViewModelViewModelMultiSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection, M: Identifiable>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {
    private let mapToViewModelFunc: (M) -> C.ViewModel
    
    init(binder: SectionedTableViewBinder<S>, sections: [S]?, mapToViewModel: @escaping (M) -> C.ViewModel) {
        self.mapToViewModelFunc = mapToViewModel
        super.init(binder: binder, sections: sections)
    }
    
    public func createUpdateCallback() -> ([S: [M]]) -> Void {
        return { [weak binder = self.binder, sections = self.sections, mapToViewModel = self.mapToViewModelFunc] (models: [S: [M]]) in
            var viewModels: [S: [Identifiable]] = [:]
            for (s, m) in models {
                viewModels[s] = m.map(mapToViewModel)
            }
            binder?.updateCellModels(models, viewModels: viewModels, sections: sections)
        }
    }
    
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C, _ model: M) -> Void) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        let tappedHandler: CellTapCallback<S> = {  [weak binder = self.binder] (section, row, cell) in
            guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell, model)
        }
        
        if let sections = self.sections {
            for section in sections {
                self.binder.sectionCellTappedCallbacks[section] = tappedHandler
            }
        } else {
            self.binder.cellTappedCallback = tappedHandler
        }

        return self
    }
    
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> TableViewModelViewModelMultiSectionBinder<C, S, M> {
        let dequeueCallback: CellDequeueCallback<S> = { [weak binder = self.binder] (section, row, cell) in
            guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell, model)
        }
        
        if let sections = self.sections {
            for section in sections {
                self.binder.sectionCellDequeuedCallbacks[section] = dequeueCallback
            }
        } else {
            self.binder.cellDequeuedCallback = dequeueCallback
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
