import UIKit

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methodss that take a binding handler and give it to the original table view binder to store for callback.
 */
public class TableViewModelMultiSectionBinder<C: UITableViewCell, S: TableViewSection, M>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {    
    internal var sectionBindResults: [S: TableViewModelSingleSectionBinder<C, S, M>] = [:]
    
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
