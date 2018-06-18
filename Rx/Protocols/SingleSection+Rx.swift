import UIKit
import RxSwift

private var binderDisposeBagKey: String = "binder_dispose_bag"
extension SectionedTableViewBinder {
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
        guard let tableViewBindResult = self.base as? SingleSectionTableViewBindResult<Base.C, Base.S> else { return self.base }
        
        tableViewBindResult.addDequeueBlock(cellType: cellType, viewModelBindHandler: { (cell, viewModel) in
            cell.viewModel.value = viewModel
        })
        
        let section = tableViewBindResult.section
        viewModels.subscribe(onNext: { [weak binder = tableViewBindResult.binder] (viewModels: [NC.ViewModel]) in
            binder?.sectionCellViewModels[section] = viewModels
            binder?.reload(section: section)
        }).disposed(by: tableViewBindResult.binder.disposeBag)
        
        return self.base
    }
}
