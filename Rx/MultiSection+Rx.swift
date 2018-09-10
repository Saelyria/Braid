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
        
        for section in bindResult.sections {
            guard let sectionViewModels: Observable<[NC.ViewModel]> = viewModels[section] else {
                fatalError("No cell view models array given for the section '\(section)'")
            }
            let sectionBindResult = TableViewInitialSingleSectionBinder<Base.S>(binder: bindResult.binder, section: section)
            bindResult.baseSectionBindResults[section] = sectionBindResult
            sectionBindResult.rx.bind(cellType: cellType, viewModels: sectionViewModels)
        }
        
        return TableViewViewModelMultiSectionBinder<NC, Base.S>(binder: bindResult.binder, sections: bindResult.sections)
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
        
        for section in bindResult.sections {
            guard let sectionModels: Observable<[NM]> = models[section] else {
                fatalError("No cell models array given for the section '\(section)'")
            }
            let sectionBindResult = TableViewInitialSingleSectionBinder<Base.S>(binder: bindResult.binder, section: section)
            bindResult.baseSectionBindResults[section] = sectionBindResult
            sectionBindResult.rx.bind(cellType: cellType, models: sectionModels, mapToViewModelsWith: mapToViewModel)
        }
            
        return TableViewModelViewModelMultiSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, sections: bindResult.sections, mapToViewModel: mapToViewModel)
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
        
        for section in bindResult.sections {
            guard let sectionModels: Observable<[NM]> = models[section] else {
                fatalError("No cell models array given for the section '\(section)'")
            }
            let sectionBindResult = TableViewInitialSingleSectionBinder<Base.S>(binder: bindResult.binder, section: section)
            bindResult.baseSectionBindResults[section] = sectionBindResult
            sectionBindResult.rx.bind(cellType: cellType, models: sectionModels)
        }
        
        return TableViewModelMultiSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, sections: bindResult.sections)
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
        
        for section in bindResult.sections {
            if let sectionViewModel: Observable<H.ViewModel?> = viewModels[section] {
                let sectionBindResult = TableViewInitialSingleSectionBinder<Base.S>(binder: bindResult.binder, section: section)
                sectionBindResult.rx.bind(headerType: headerType, viewModel: sectionViewModel)
            }
        }
        
        return self.base
    }

    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitle(_ titles: [Base.S: Observable<String?>]) -> Base {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in bindResult.sections {
            if let titleObservable: Observable<String?> = titles[section] {
                let sectionBindResult = TableViewInitialSingleSectionBinder<Base.S>(binder: bindResult.binder, section: section)
                sectionBindResult.rx.headerTitle(titleObservable)
            }
        }
        
        return self.base
    }
    
    /**
     Bind the given footer type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModels: [Base.S: Observable<F.ViewModel?>]) -> Base
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in bindResult.sections {
            if let sectionViewModel: Observable<F.ViewModel?> = viewModels[section] {
                let sectionBindResult = TableViewInitialSingleSectionBinder<Base.S>(binder: bindResult.binder, section: section)
                sectionBindResult.rx.bind(footerType: footerType, viewModel: sectionViewModel)
            }
        }
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's footer.
     */
    @discardableResult
    public func footerTitle(_ titles: [Base.S: Observable<String?>]) -> Base {
        guard let bindResult = self.base as? BaseTableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        for section in bindResult.sections {
            if let titleObservable: Observable<String?> = titles[section] {
                let sectionBindResult = TableViewInitialSingleSectionBinder<Base.S>(binder: bindResult.binder, section: section)
                sectionBindResult.rx.footerTitle(titleObservable)
            }
        }
        
        return self.base
    }
}
