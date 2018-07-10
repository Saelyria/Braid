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

