import UIKit
import RxSwift

extension TableViewSingleSectionBinder: ReactiveCompatible { }

public extension Reactive where Base: TableViewSingleSectionBinderProtocol {
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     
     When using this method, you pass in an observable array of the cell's view models. From there, the binder will
     handle dequeuing of your cells based on the observable view models array.
    */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: Observable<[NC.ViewModel]>)
        -> TableViewSingleSectionBinder<NC, Base.S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     
     When using this method, you pass in an observable array of the cell's view models. From there, the binder will
     handle dequeuing of your cells based on the observable view models array.
     */
    @discardableResult
    public func bind<NC>(
        cellType: NC.Type,
        viewModels: Observable<[NC.ViewModel]>)
        -> TableViewSingleSectionBinder<NC, Base.S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        bindResult.binder.addCellEqualityChecker(
            itemType: NC.ViewModel.self, affectedSections: bindResult.affectedSectionScope)
        return self._bind(cellType: cellType, viewModels: viewModels)
    }
    
    private func _bind<NC>(
        cellType: NC.Type,
        viewModels: Observable<[NC.ViewModel]>)
        -> TableViewSingleSectionBinder<NC, Base.S>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let section = bindResult.section
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, affectedSections: scope)
        
        viewModels
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModels: [NC.ViewModel]) in
                binder?.updateCellModels(nil, viewModels: [section: viewModels], affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewSingleSectionBinder<NC, Base.S>(binder: bindResult.binder, section: section)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given observable array of
     models.
     
     When using this method, you pass in an observable array of your raw models. From there, the binder will handle
     dequeuing of your cells based on the observable models array. It's expected that you will add an `onCellDequeue`
     handler to your chain when using this method to configure dequeued cells with their associated model objects.
    */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, models: models)
    }
    
    /**
     Bind the given cell type to the declared section, creating a cell for each item in the given observable array of
     models.
     
     When using this method, you pass in an observable array of your raw models. From there, the binder will handle
     dequeuing of your cells based on the observable models array. It's expected that you will add an `onCellDequeue`
     handler to your chain when using this method to configure dequeued cells with their associated model objects.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        bindResult.binder.addCellEqualityChecker(itemType: NM.self, affectedSections: bindResult.affectedSectionScope)
        return self._bind(cellType: cellType, models: models)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let section = bindResult.section
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, affectedSections: scope)
        
        models
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [NM]) in
                let scope: SectionBindingScope<Base.S> = .forNamedSections([section])
                binder?.updateCellModels([section: models], viewModels: nil, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelSingleSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, section: bindResult.section)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in an observable array of your raw models and a function that transforms them into
     the view models for the cells. From there, the binder will handle dequeuing of your cells based on the observable
     models array. Whenever a cell is dequeued, the binder will create an instance of the cell's view model from the
     associated model using the given `mapToViewModel` function.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>,
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in an observable array of your raw models and a function that transforms them into
     the view models for the cells. From there, the binder will handle dequeuing of your cells based on the observable
     models array. Whenever a cell is dequeued, the binder will create an instance of the cell's view model from the
     associated model using the given `mapToViewModel` function.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>,
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        bindResult.binder.addCellEqualityChecker(
            itemType: NC.ViewModel.self, affectedSections: bindResult.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in an observable array of your raw models and a function that transforms them into
     the view models for the cells. From there, the binder will handle dequeuing of your cells based on the observable
     models array. Whenever a cell is dequeued, the binder will create an instance of the cell's view model from the
     associated model using the given `mapToViewModel` function.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>,
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable,
        NC.ViewModel: Equatable & CollectionIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        bindResult.binder.addCellEqualityChecker(
            itemType: NC.ViewModel.self, affectedSections: bindResult.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    /**
     Bind the given cell type to the declared section, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     
     When using this method, you pass in an observable array of your raw models and a function that transforms them into
     the view models for the cells. From there, the binder will handle dequeuing of your cells based on the observable
     models array. Whenever a cell is dequeued, the binder will create an instance of the cell's view model from the
     associated model using the given `mapToViewModel` function.
     */
    @discardableResult
    public func bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>,
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable, NM: Equatable & CollectionIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        bindResult.binder.addCellEqualityChecker(
            itemType: NM.self, affectedSections: bindResult.affectedSectionScope)
        return self._bind(cellType: cellType, models: models, mapToViewModels: mapToViewModels)
    }
    
    private func _bind<NC, NM>(
        cellType: NC.Type,
        models: Observable<[NM]>,
        mapToViewModels: @escaping (NM) -> NC.ViewModel)
        -> TableViewModelSingleSectionBinder<NC, Base.S, NM>
        where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let section = bindResult.section
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellType: cellType, affectedSections: scope)
        
        models
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [NM]) in
                let viewModels = models.map(mapToViewModels)
                binder?.updateCellModels([section: models], viewModels: [section: viewModels], affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelSingleSectionBinder<NC, Base.S, NM>(binder: bindResult.binder, section: bindResult.section)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     Use this method if you want more manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, or you have some other
     particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ tableView: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: Observable<[NM]>)
        -> TableViewModelSingleSectionBinder<UITableViewCell, Base.S, NM>
    {
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    /**
     Bind a custom handler that will provide table view cells for the declared section, created according to the given
     models.
     
     Use this method if you want more manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, the cell type is not known at compile-time, or you have some other
     particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter model: The model the cell is dequeued for.
     - parameter models: The models objects to bind to the dequeued cells for this section.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<NM>(
        cellProvider: @escaping (_ tableView: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: Observable<[NM]>)
        -> TableViewModelSingleSectionBinder<UITableViewCell, Base.S, NM>
        where NM: Equatable & CollectionIdentifiable
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        bindResult.binder.addCellEqualityChecker(
            itemType: NM.self, affectedSections: bindResult.affectedSectionScope)
        return self._bind(cellProvider: cellProvider, models: models)
    }
    
    private func _bind<NM>(
        cellProvider: @escaping (_ tableView: UITableView, _ row: Int, _ model: NM) -> UITableViewCell,
        models: Observable<[NM]>)
        -> TableViewModelSingleSectionBinder<UITableViewCell, Base.S, NM>
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let section = bindResult.section
        let scope = bindResult.affectedSectionScope
        
        let _cellProvider: (UITableView, Base.S, Int) -> UITableViewCell
        _cellProvider = { [weak binder = bindResult.binder] (tableView, section, row) in
            guard let models = binder?.currentDataModel.sectionCellModels[section] as? [NM] else {
                fatalError("Model type wasn't as expected, something went awry!")
            }
            return cellProvider(tableView, row, models[row])
        }
        bindResult.binder.addCellDequeueBlock(cellProvider: _cellProvider, affectedSections: scope)
        
        models
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (models: [NM]) in
                binder?.updateCellModels([section: models], viewModels: nil, affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return TableViewModelSingleSectionBinder<UITableViewCell, Base.S, NM>(binder: bindResult.binder, section: section)
    }

    
    /**
     Bind a custom handler that will provide table view cells for the section, along with the number of cells to create.
     
     Use this method if you want full manual control over cell dequeueing. You might decide to use this method if you
     use different cell types in the same section, cells in the section are not necessarily backed by a data model type,
     or you have particularly complex use cases.
     
     - parameter cellProvider: A closure that is used to dequeue cells for the section.
     - parameter row: The row in the section the closure should provide a cell for.
     - parameter numberOfCells: The number of cells to create for the section using the provided closure.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind(
        cellProvider: @escaping (_ tableView: UITableView, _ row: Int) -> UITableViewCell,
        numberOfCells: Observable<Int>)
        -> TableViewSingleSectionBinder<Base.C, Base.S>
    {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let section = bindResult.section
        let scope = bindResult.affectedSectionScope
        
        bindResult.binder.addCellDequeueBlock(cellProvider: cellProvider, affectedSections: scope)
        
        numberOfCells
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (numCells: Int) in
                binder?.updateNumberOfCells([section: numCells], affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return bindResult
    }
    
    // MARK: -

    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: Observable<H.ViewModel?>) -> Base
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let section = bindResult.section
        let scope = bindResult.affectedSectionScope

        bindResult.binder.addHeaderDequeueBlock(headerType: headerType, affectedSections: scope)
        
        viewModel
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModel: H.ViewModel?) in
                binder?.updateHeaderViewModels([section: viewModel], affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func bind(headerTitle: Observable<String?>) -> Base {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        bindResult.binder.nextDataModel.headerTitleBound = true
        
        let section = bindResult.section
        headerTitle
            .subscribeOn(MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak binder = bindResult.binder] (title: String?) in
                let scope: SectionBindingScope<Base.S> = .forNamedSections([section])
                binder?.updateHeaderTitles([section: title], affectedSections: scope)
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
    public func bind<F>(footerType: F.Type, viewModel: Observable<F.ViewModel?>) -> Base
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        let section = bindResult.section
        let scope = bindResult.affectedSectionScope

        bindResult.binder.addFooterDequeueBlock(footerType: footerType, affectedSections: scope)
        
        viewModel
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak binder = bindResult.binder] (viewModel: F.ViewModel?) in
                binder?.updateFooterViewModels([section: viewModel], affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
    
    /**
     Bind the given observable title to the section's footer.
     */
    @discardableResult
    public func bind(footerTitle: Observable<String?>) -> Base {
        guard let bindResult = self.base as? TableViewSingleSectionBinder<Base.C, Base.S> else {
            fatalError("ERROR: Couldn't convert `base` into a bind result; something went awry!")
        }
        
        bindResult.binder.nextDataModel.footerTitleBound = true
        
        let section = bindResult.section
        footerTitle
            .subscribeOn(MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak binder = bindResult.binder] (title: String?) in
                let scope: SectionBindingScope<Base.S> = .forNamedSections([section])
                binder?.updateFooterTitles([section: title], affectedSections: scope)
            }).disposed(by: bindResult.binder.disposeBag)
        
        return self.base
    }
}
