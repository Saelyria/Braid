import UIKit
import RxSwift

extension BaseTableViewMutliSectionBinder: ReactiveCompatible { }

public extension Reactive where Base: TableViewInitialMutliSectionBinderProtocol {
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: Observable<[Base.S: [NC.ViewModel]]>) -> TableViewViewModelMultiSectionBinder<NC, Base.S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewInitialMutliSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, sections: sections)
        
        viewModels
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [Base.S: [NC.ViewModel]]) in
                binder?.updateCellModels(nil, viewModels: viewModels, sections: sections)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewViewModelMultiSectionBinder<NC, Base.S>(binder: bindResult.binder, sections: sections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: Observable<[Base.S: [NM]]>, mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> TableViewModelViewModelMultiSectionBinder<NC, Base.S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Identifiable {
        guard let bindResult = self.base as? TableViewInitialMutliSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, sections: sections)

        models
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [Base.S: [NM]]) in
                var viewModels: [Base.S: [Identifiable]] = [:]
                for (s, m) in models {
                    viewModels[s] = m.map(mapToViewModel)
                }
                binder?.updateCellModels(models, viewModels: viewModels, sections: sections)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelViewModelMultiSectionBinder<NC, Base.S, NM>(
            binder: bindResult.binder, sections: sections, mapToViewModel: mapToViewModel)
    }
    
    /**
     Bind the given cell type to the declared sections, creating a cell for each item in the given observable array of
     models.
     
     When using this method, you pass in an observable array of your raw models for each section in a dictionary. Each
     section being bound to must have an observable array of models in the dictionary. From there, the binder will
     handle dequeuing of your cells based on the observable models array for each section. It is also expected that,
     when using this method, you will also use an `onCellDequeue` event handler to configure the cell, where you are
     given the model and the dequeued cell.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: Observable<[Base.S: [NM]]>)
    -> TableViewModelMultiSectionBinder<NC, Base.S, NM> where NC: UITableViewCell & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewInitialMutliSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, sections: sections)
        
        models
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [Base.S: [NM]]) in
                binder?.updateCellModels(models, viewModels: nil, sections: sections)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelMultiSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, sections: sections)
    }
}

public extension Reactive where Base: TableViewMutliSectionBinderProtocol {
    /**
     Bind the given header type to the declared section with the given observable for their view models.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModels: Observable<[Base.S: H.ViewModel]>) -> Base
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        
        bindResult.binder.addHeaderDequeueBlock(headerType: headerType, sections: sections)
        
        viewModels
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [Base.S: H.ViewModel]) in
                binder?.updateHeaderViewModels(viewModels, sections: sections)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }

    /**
     Bind the given observable titles to the section's header.
     */
    @discardableResult
    public func headerTitles(_ titles: Observable<[Base.S: String?]>) -> Base {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        
        titles
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
            .subscribe(onNext: { [weak binder = bindResult.binder] (titles: [Base.S: String?]) in
                binder?.updateHeaderTitles(titles, sections: sections)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given footer type to the declared section with the given observable for its view model.
    */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModels: Observable<[Base.S: F.ViewModel]>) -> Base
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        
        bindResult.binder.addFooterDequeueBlock(footerType: footerType, sections: sections)
        
        viewModels
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [Base.S: F.ViewModel]) in
                binder?.updateFooterViewModels(viewModels, sections: sections)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's footer.
    */
    @discardableResult
    public func footerTitles(_ titles: Observable<[Base.S: String?]>) -> Base {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        
        titles
            .asDriver(onErrorJustReturn: [:])
            .asObservable()
            .subscribe(onNext: { [weak binder = bindResult.binder] (titles: [Base.S: String?]) in
                binder?.updateFooterTitles(titles, sections: sections)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
}
