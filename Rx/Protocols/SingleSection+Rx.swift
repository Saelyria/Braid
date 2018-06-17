import UIKit
import RxSwift

private var binderDisposeBagKey: String = "binder_dispose_bag"
extension _BaseTableViewBinder {
    var disposeBag: DisposeBag {
        get {
            return objc_getAssociatedObject(self, &binderDisposeBagKey) as! DisposeBag
        }
        set {
            objc_setAssociatedObject(self, &binderDisposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

public extension Reactive where Base: BaseSingleSectionTableViewBindResultProtocol {
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: Observable<[NC.ViewModel]>) -> Base
    where NC: UITableViewCell & RxViewModelBindable & ReuseIdentifiable {
        guard let result = self.base as? BaseSingleSectionTableViewBindResult<Base.C, Base.S> else { return self.base }
        
        let section = self.base.section
        guard self.base.baseBinder.sectionCellDequeueBlocks[section] == nil else {
            fatalError("Section already has a cell type bound to it - re-binding not supported.")
        }
        
        viewModels.subscribe(onNext: { [weak binder = self.base.baseBinder] (viewModels: [NC.ViewModel]) in
            binder?.sectionCellViewModels[section] = viewModels
            binder?.reload(section: section)
        }).disposed(by: self.base.baseBinder.disposeBag)
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.binder] (tableView, indexPath) in
            if let section = binder?.displayedSections.value[indexPath.section],
                let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC,
                let viewModel = (binder?.sectionCellViewModels[section] as? [NC.ViewModel])?[indexPath.row] {
                cell.viewModel.value = viewModel
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            return UITableViewCell()
        }
        self.binder.sectionCellDequeueBlocks[section] = cellDequeueBlock
        
        let tableViewBindResult = RxSingleSectionTableViewBindResult<NC, S>(binder: self.binder, section: self.section)
        return tableViewBindResult
    }
}
