import UIKit

public class TableViewModelViewModelMultiSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection, M>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {        
    private let mapToViewModelFunc: (M) -> C.ViewModel
    internal var sectionBindResults: [S: TableViewModelViewModelSingleSectionBinder<C, S, M>] = [:]
    
    init(binder: SectionedTableViewBinder<S>, sections: [S], mapToViewModel: @escaping (M) -> C.ViewModel) {
        super.init(binder: binder, sections: sections)
        self.mapToViewModelFunc = mapToViewModel
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

