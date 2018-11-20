import UIKit
import RxSwift

extension TableViewMutliSectionBinder: ReactiveCompatible { }

public extension Reactive where Base: TableViewMutliSectionBinderProtocol {
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: Observable<[Base.S: [NC.ViewModel]]>)
        -> TableViewMutliSectionBinder<NC, Base.S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, affectedSections: scope)
        
        viewModels
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [Base.S: [NC.ViewModel]]) in
                binder?.updateCellModels(nil, viewModels: viewModels, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewMutliSectionBinder<NC, Base.S>(binder: bindResult.binder, sections: sections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[Base.S: [NM]]>,
        mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelMultiSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, affectedSections: scope)

        models
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [Base.S: [NM]]) in
                var viewModels: [Base.S: [Any]] = [:]
                for (s, m) in models {
                    viewModels[s] = m.map(mapToViewModel)
                }
                binder?.updateCellModels(models, viewModels: viewModels, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelMultiSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, sections: sections)
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
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[Base.S: [NM]]>)
        -> TableViewModelMultiSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, affectedSections: scope)
        
        models
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [Base.S: [NM]]) in
                binder?.updateCellModels(models, viewModels: nil, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelMultiSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, sections: sections)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, created according to the given
     models.
     
     Use this method if you want more manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, or you have some other
     particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: A dictionary where the key is a section and the value are the models for the cells created for
        the section. This dictionary does not need to contain a models array for each section being bound - sections not
        present in the dictionary have no cells dequeued for them.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ section: Base.S, _ row: Int, _ model: NM) -> UITableViewCell,
        models: Observable<[Base.S: [NM]]>)
        -> TableViewModelMultiSectionBinder<UITableViewCell, Base.S, NM>
    {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let sections = bindResult.sections
        let scope = bindResult.affectedSectionScope

        let _cellProvider = { [weak binder = bindResult.binder] (_ section: Base.S, _ row: Int) -> UITableViewCell in
            guard let models = binder?.currentDataModel.sectionCellModels[section] as? [NM] else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(section, row, models[row])
        }
        bindResult.binder.addCellDequeueBlock(cellProvider: _cellProvider, affectedSections: scope)
        
        models
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [Base.S: [NM]]) in
                binder?.updateCellModels(models, viewModels: nil, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelMultiSectionBinder<UITableViewCell, Base.S, NM>(binder: bindResult.binder, sections: sections)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared sections, along with the number of cells
     to create.
     
     Use this method if you want full manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, cells in the section are not necessarily backed by a data model type,
     or you have particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter section: The section the closure should provide a cell for.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for each section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ section: Base.S, _ row: Int) -> UITableViewCell,
        numberOfCells: Observable<[Base.S: Int]>)
        -> TableViewMutliSectionBinder<Base.C, Base.S>
    {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellProvider: cellProvider, affectedSections: scope)
        
        numberOfCells
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (numCells: [Base.S: Int]) in
                binder?.updateNumberOfCells(numCells, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        
        return bindResult
    }
    
    // MARK: -

    /**
     Bind the given header type to the declared section with the given observable for their view models.
     */
    @discardableResult
    public func bind<H>(
        headerType: H.Type,
        viewModels: Observable<[Base.S: H.ViewModel]>)
        -> Base
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addHeaderDequeueBlock(headerType: headerType, affectedSections: scope)
        
        viewModels
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [Base.S: H.ViewModel]) in
                binder?.updateHeaderViewModels(viewModels, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }

    /**
     Bind the given observable titles to the section's header.
     */
    @discardableResult
    public func bind(headerTitles: Observable<[Base.S: String?]>) -> Base {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let scope = bindResult.affectedSectionScope
        
        headerTitles
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (titles: [Base.S: String?]) in
                binder?.updateHeaderTitles(titles, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given footer type to the declared section with the given observable for its view model.
    */
    @discardableResult
    public func bind<F>(
        footerType: F.Type,
        viewModels: Observable<[Base.S: F.ViewModel]>)
        -> Base
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addFooterDequeueBlock(footerType: footerType, affectedSections: scope)
        
        viewModels
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [Base.S: F.ViewModel]) in
                binder?.updateFooterViewModels(viewModels, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's footer.
    */
    @discardableResult
    public func bind(footerTitles: Observable<[Base.S: String?]>) -> Base {
        guard let bindResult = self.base as? TableViewMutliSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let scope = bindResult.affectedSectionScope
        
        footerTitles
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (titles: [Base.S: String?]) in
                binder?.updateFooterTitles(titles, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
}
