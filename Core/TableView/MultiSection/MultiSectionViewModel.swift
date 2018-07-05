import UIKit

public class TableViewViewModelMultiSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection>: BaseTableViewMutliSectionBinder<C, S> {
    internal var sectionBindResults: [S: TableViewViewModelSingleSectionBinder<C, S>] = [:]
}

