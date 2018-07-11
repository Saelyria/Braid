import UIKit
import RxSwift

extension BaseTableViewSingleSectionBinder: ReactiveCompatible { }

public extension Reactive where Base: TableViewInitialSingleSectionBinderProtocol {
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: Observable<[NC.ViewModel]>) -> TableViewViewModelSingleSectionBinder<NC, Base.S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewInitialSingleSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        bindResult.addDequeueBlock(cellType: cellType)
        
        let section = bindResult.section
        viewModels.subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [NC.ViewModel]) in
            binder?.sectionCellViewModels[section] = viewModels
            binder?.reload(section: section)
        }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewViewModelSingleSectionBinder<NC, Base.S>(binder: bindResult.binder, section: bindResult.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given observable array of
     models.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents and the cells. When binding with this method, various other event binding methods (most notably the
     `onTapped` event method) can have their handlers be passed in the associated model (cast to the same type as the
     models observable type) along with the row and cell.
     
     When using this method, you pass in an observable array of your raw models. From there, the binder will handle
     dequeuing of your cells based on the observable models array.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: Observable<[NM]>)
    -> TableViewModelSingleSectionBinder<NC, Base.S, NM> where NC: UITableViewCell & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewInitialSingleSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        bindResult.addDequeueBlock(cellType: cellType)
        
        let section = bindResult.section
        models.subscribe(onNext: { [weak binder = bindResult.binder] (models: [NM]) in
            binder?.sectionCellModels[section] = models
            binder?.reload(section: section)
        }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelSingleSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, section: bindResult.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents, the cells, and the view models for the cells. When binding with this method, various other event
     binding methods (most notably the `onTapped` event method) can have their handlers be passed in the associated
     model (cast to the same type as the models observable type) along with the row and cell.
     
     When using this method, you pass in an observable array of your raw models and a function that transforms them into
     the view models for the cells. From there, the binder will handle dequeuing of your cells based on the observable
     models array.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: Observable<[NM]>, mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelViewModelSingleSectionBinder<NC, Base.S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
            guard let bindResult = self.base as? TableViewInitialSingleSectionBinder<Base.S> else {
                fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
            }
            
            bindResult.addDequeueBlock(cellType: cellType)
            
            let section = bindResult.section
            models.subscribe(onNext: { [weak binder = bindResult.binder] (models: [NM]) in
                binder?.sectionCellModels[section] = models
                binder?.sectionCellViewModels[section] = models.map(mapToViewModel)
                binder?.reload(section: section)
            }).disposed(by: bindResult.binder.disposeBag)
            
            return TableViewModelViewModelSingleSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, section: bindResult.section, mapToViewModel: mapToViewModel)
    }

}

public extension Reactive where Base: TableViewSingleSectionBinderProtocol {
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: Observable<H.ViewModel>) -> Base
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? BaseTableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        bindResult.addDequeueBlock(headerType: headerType)

        let section = bindResult.section
        viewModel.subscribe(onNext: { [weak binder = bindResult.binder] (viewModel: H.ViewModel) in
            binder?.sectionHeaderViewModels[section] = viewModel
            binder?.reload(section: section)
        }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitle(_ title: Observable<String>) -> Base {
        guard let bindResult = self.base as? BaseTableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        let section = bindResult.section
        title.subscribe(onNext: { [weak binder = bindResult.binder] (title: String) in
            binder?.sectionHeaderTitles[section] = title
            binder?.reload(section: section)
        }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given footer type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModel: Observable<F.ViewModel>) -> Base
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? BaseTableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        bindResult.addDequeueBlock(footerType: footerType)
        
        let section = bindResult.section
        viewModel.subscribe(onNext: { [weak binder = bindResult.binder] (viewModel: F.ViewModel) in
            binder?.sectionFooterViewModels[section] = viewModel
            binder?.reload(section: section)
        }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's footer.
     */
    @discardableResult
    public func footerTitle(_ title: Observable<String>) -> Base {
        guard let bindResult = self.base as? BaseTableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        let section = bindResult.section
        title.subscribe(onNext: { [weak binder = bindResult.binder] (title: String) in
            binder?.sectionFooterTitles[section] = title
            binder?.reload(section: section)
        }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
}
