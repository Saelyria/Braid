import UIKit

public class TableViewViewModelMultiSectionBinder<C: UITableViewCell & ViewModelBindable, S: TableViewSection>: BaseTableViewMutliSectionBinder<C, S>, TableViewMutliSectionBinderProtocol {
    
    internal var sectionBindResults: [S: TableViewViewModelSingleSectionBinder<C, S>] = [:]
}

