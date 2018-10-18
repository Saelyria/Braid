import UIKit

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methods that take a binding handler and give it to the original table view binder to store for callback.
 */
public class TableViewModelMultiSectionBinder<C: UITableViewCell, S: TableViewSection, M: Identifiable>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {
    internal var sectionBindResults: [S: TableViewModelSingleSectionBinder<C, S, M>] = [:]
    
    public func createUpdateCallback() -> ([S: [M]]) -> Void {
        return { (models: [S: [M]]) in
            for (section, sectionModels) in models {
                self.binder.nextDataModel.sectionCellModels[section] = sectionModels
            }
        }
    }
    
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C, _ model: M) -> Void) -> TableViewModelMultiSectionBinder<C, S, M> {
        for section in self.sections {
            let tappedHandler: CellTapCallback = {  [weak binder = self.binder] (row, cell) in
                guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                    assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                    return
                }
                handler(section, row, cell, model)
            }
            self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        }
        return self
    }
    
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> TableViewModelMultiSectionBinder<C, S, M> {
        for section in self.sections {
            let dequeueCallback: CellDequeueCallback = { [weak binder = self.binder] row, cell in
                guard let cell = cell as? C, let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                    assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                    return
                }
                handler(section, row, cell, model)
            }
            
            self.binder.sectionCellDequeuedCallbacks[section] = dequeueCallback
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
