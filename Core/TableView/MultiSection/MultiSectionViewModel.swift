import UIKit

public class TableViewViewModelMultiSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {
    internal var sectionBindResults: [S: TableViewViewModelSingleSectionBinder<C, S>] = [:]

    public func createUpdateCallback() -> ([S: [C.ViewModel]]) -> Void {
        return { (viewModels: [S: [C.ViewModel]]) in
            var _sections: [S] = []
            for (section, sectionModels) in viewModels {
                _sections.append(section)
                self.binder.sectionCellViewModels[section] = sectionModels
            }
            self.binder.reload(sections: _sections)
        }
    }
    
    @discardableResult
    public override func bind<H>(headerType: H.Type, viewModels: [S: H.ViewModel]) -> TableViewViewModelMultiSectionBinder<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(headerType: headerType, viewModels: viewModels)
        return self
    }

    @discardableResult
    public override func headerTitles(_ titles: [S: String]) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.headerTitles(titles)
        return self
    }

    @discardableResult
    public override func bind<F>(footerType: F.Type, viewModels: [S: F.ViewModel]) -> TableViewViewModelMultiSectionBinder<C, S>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModels: viewModels)
        return self
    }

    @discardableResult
    public override func footerTitles(_ titles: [S: String]) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.footerTitles(titles)
        return self
    }

    @discardableResult
    public override func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.onCellDequeue(handler)
        return self
    }

    @discardableResult
    public override func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.onTapped(handler)
        return self
    }

    @discardableResult
    public override func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.cellHeight(handler)
        return self
    }

    @discardableResult
    public override func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.estimatedCellHeight(handler)
        return self
    }

    @discardableResult
    public override func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.headerHeight(handler)
        return self
    }

    @discardableResult
    public override func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.estimatedHeaderHeight(handler)
        return self
    }
 
    @discardableResult
    public override func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.footerHeight(handler)
        return self
    }

    @discardableResult
    public override func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> TableViewViewModelMultiSectionBinder<C, S> {
        super.estimatedFooterHeight(handler)
        return self
    }
}

