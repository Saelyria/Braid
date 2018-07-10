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
}

