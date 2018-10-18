import UIKit
import RxSwift

extension BaseTableViewMutliSectionBinder: ReactiveCompatible { }

public extension Reactive where Base: TableViewInitialMutliSectionBinderProtocol {
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: [Base.S: Observable<[NC.ViewModel]>]) -> TableViewViewModelMultiSectionBinder<NC, Base.S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewInitialMutliSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in viewModels.keys {
            guard bindResult.sections.contains(section) else {
                assertionFailure("Call to 'bind(cellType:viewModels:)' included an Observable for the section '\(section)', when the binding chain was started for the following sections: \(bindResult.sections). This is unsupported.")
                continue
            }
            guard let sectionViewModels: Observable<[NC.ViewModel]> = viewModels[section] else { continue }

            TableViewInitialSingleSectionBinder<Base.S>.addDequeueBlock(cellType: cellType, binder: bindResult.binder, section: section)
            
            sectionViewModels
                .asDriver(onErrorJustReturn: [])
                .asObservable()
                .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [NC.ViewModel]) in
                    binder?.nextDataModel.sectionCellViewModels[section] = viewModels
                }).disposed(by: bindResult.binder.disposeBag)
        }
        
        return TableViewViewModelMultiSectionBinder<NC, Base.S>(binder: bindResult.binder, sections: bindResult.sections, isForAllSections: bindResult.isForAllSections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: [Base.S: Observable<[NM]>], mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> TableViewModelViewModelMultiSectionBinder<NC, Base.S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewInitialMutliSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in models.keys {
            guard bindResult.sections.contains(section) else {
                assertionFailure("Call to 'bind(cellType:models:mapToViewModelsWith:)' included an Observable for the section '\(section)', when the binding chain was started for the following sections: \(bindResult.sections). This is unsupported.")
                continue
            }
            guard let sectionModels: Observable<[NM]> = models[section] else { continue }
            
            TableViewInitialSingleSectionBinder<Base.S>.addDequeueBlock(cellType: cellType, binder: bindResult.binder, section: section)
            
            sectionModels
                .asDriver(onErrorJustReturn: [])
                .asObservable()
                .subscribe(onNext: { [weak binder = bindResult.binder] (models: [NM]) in
                    let viewModels = models.map(mapToViewModel)
                    binder?.nextDataModel.sectionCellModels[section] = viewModels
                    binder?.nextDataModel.sectionCellViewModels[section] = viewModels
                }).disposed(by: bindResult.binder.disposeBag)
        }
            
        return TableViewModelViewModelMultiSectionBinder<NC, Base.S, NM>(binder: bindResult.binder,
            sections: bindResult.sections, mapToViewModel: mapToViewModel, isForAllSections: bindResult.isForAllSections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating a cell for each item in the given observable array of
     models.
     
     Using this method allows a convenient mapping between the raw model objects that each cell in your table
     represents and the cells. When binding with this method, various other event binding methods (most notably the
     `onTapped` event method) can have their handlers be passed in the associated model (cast to the same type as the
     models observable type) along with the row and cell.
     
     When using this method, you pass in an observable array of your raw models for each section in a dictionary. Each
     section being bound to must have an observable array of models in the dictionary. From there, the binder will
     handle dequeuing of your cells based on the observable models array for each section. It is also expected that,
     when using this method, you will also use an `onCellDequeue` event handler to configure the cell, where you are
     given the model and the dequeued cell.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: [Base.S: Observable<[NM]>])
    -> TableViewModelMultiSectionBinder<NC, Base.S, NM> where NC: UITableViewCell & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewInitialMutliSectionBinder<Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in models.keys {
            guard bindResult.sections.contains(section) else {
                assertionFailure("Call to 'bind(cellType:models:)' included an Observable for the section '\(section)', when the binding chain was started for the following sections: \(bindResult.sections). This is unsupported.")
                continue
            }
            guard let sectionModels: Observable<[NM]> = models[section] else { continue }
            
            TableViewInitialSingleSectionBinder<Base.S>.addDequeueBlock(cellType: cellType, binder: bindResult.binder, section: section)
            
            sectionModels
                .asDriver(onErrorJustReturn: [])
                .asObservable()
                .subscribe(onNext: { [weak binder = bindResult.binder] (models: [NM]) in
                    binder?.nextDataModel.sectionCellModels[section] = models
                }).disposed(by: bindResult.binder.disposeBag)
        }
        
        return TableViewModelMultiSectionBinder<NC, Base.S, NM>(
            binder: bindResult.binder, sections: bindResult.sections, isForAllSections: bindResult.isForAllSections)
    }

}

public extension Reactive where Base: TableViewMutliSectionBinderProtocol {
    /**
     Bind the given header type to the declared section with the given observable for their view models.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModels: [Base.S: Observable<H.ViewModel?>]) -> Base
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in viewModels.keys {
            guard bindResult.sections.contains(section) else {
                assertionFailure("Call to 'bind(headerType:viewModels:)' included an Observable for the section '\(section)', when the binding chain was started for the following sections: \(bindResult.sections). This is unsupported.")
                continue
            }
            guard let sectionViewModel: Observable<H.ViewModel?> = viewModels[section] else { continue }

            BaseTableViewSingleSectionBinder<Base.C, Base.S>.addHeaderFooterDequeueBlock(
                type: headerType, binder: bindResult.binder, section: section, isHeader: true)
            
            sectionViewModel
                .asDriver(onErrorJustReturn: nil)
                .asObservable()
                .subscribe(onNext: { [weak binder = bindResult.binder] (viewModel: H.ViewModel?) in
                    binder?.nextDataModel.sectionHeaderViewModels[section] = viewModel
                }).disposed(by: bindResult.binder.disposeBag)
        }
        
        return self.base
    }

    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitles(_ titles: [Base.S: Observable<String?>]) -> Base {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in titles.keys {
            guard bindResult.sections.contains(section) else {
                assertionFailure("Call to 'headerTitles(_:)' included an Observable for the section '\(section)', when the binding chain was started for the following sections: \(bindResult.sections). This is unsupported.")
                continue
            }
            guard let title = titles[section] else { continue }
            
            title
                .asDriver(onErrorJustReturn: nil)
                .asObservable()
                .distinctUntilChanged()
                .subscribe(onNext: { [weak binder = bindResult.binder] (title: String?) in
                    binder?.nextDataModel.sectionHeaderTitles[section] = title
                }).disposed(by: bindResult.binder.disposeBag)
        }
        
        return self.base
    }
    
    /**
     Bind the given footer type to the declared section with the given observable for its view model.
    */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModels: [Base.S: Observable<F.ViewModel?>]) -> Base
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in viewModels.keys {
            guard bindResult.sections.contains(section) else {
                assertionFailure("Call to 'bind(footerType:viewModels:)' included an Observable for the section '\(section)', when the binding chain was started for the following sections: \(bindResult.sections). This is unsupported.")
                continue
            }
            guard let sectionViewModel: Observable<F.ViewModel?> = viewModels[section] else { continue }
            
            BaseTableViewSingleSectionBinder<Base.C, Base.S>.addHeaderFooterDequeueBlock(
                type: footerType, binder: bindResult.binder, section: section, isHeader: false)
            
            sectionViewModel
                .asDriver(onErrorJustReturn: nil)
                .asObservable()
                .subscribe(onNext: { [weak binder = bindResult.binder] (viewModel: F.ViewModel?) in
                    binder?.nextDataModel.sectionFooterViewModels[section] = viewModel
                }).disposed(by: bindResult.binder.disposeBag)
        }
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's footer.
    */
    @discardableResult
    public func footerTitles(_ titles: [Base.S: Observable<String?>]) -> Base {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in bindResult.sections {
            guard bindResult.sections.contains(section) else {
                assertionFailure("Call to 'footerTitles(_:)' included an Observable for the section '\(section)', when the binding chain was started for the following sections: \(bindResult.sections). This is unsupported.")
                continue
            }
            guard let title = titles[section] else { continue }
            
            title
                .asDriver(onErrorJustReturn: nil)
                .asObservable()
                .distinctUntilChanged()
                .subscribe(onNext: { [weak binder = bindResult.binder] (title: String?) in
                    binder?.nextDataModel.sectionFooterTitles[section] = title
                }).disposed(by: bindResult.binder.disposeBag)
        }
        
        return self.base
    }
}
