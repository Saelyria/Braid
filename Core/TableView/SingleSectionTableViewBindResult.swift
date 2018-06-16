import UIKit

public final class SingleSectionTableViewBindResult<C: UITableViewCell, S: TableViewSection>: SingleSectionBindResultProtocol {
    public var binder: _BaseTableViewBinder<S> {
        return self._binder
    }
    public let section: S
    let _binder: SectionedTableViewBinder<S>
    
    internal init(binder: SectionedTableViewBinder<S>, section: S) {
        self._binder = binder
        self.section = section
    }
    
    // MARK: Cell and header / footer view binding
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     */
    @discardableResult
    public func bind<NC, T: NSObject>(cellType: NC.Type, byObserving keyPath: KeyPath<T, [NC.ViewModel]>, on provider: T)
    -> SingleSectionTableViewBindResult<NC, S> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(cellType: cellType, viewModelBindHandler: { (cell, viewModel) in
            var cell = cell
            cell.viewModel = viewModel
        })
        
        let section = self.section
        let token = provider.observe(keyPath, options: [.initial, .new]) { [weak binder = self.binder] (_, value) in
            let viewModels: [NC.ViewModel]? = value.newValue
            binder?.sectionCellViewModels[section] = viewModels
            binder?.reload(section: section)
        }
        self._binder.observationTokens.append(token)
        
        return SingleSectionTableViewBindResult<NC, S>(binder: self._binder, section: self.section)
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
    public func bind<NC, NM, T: NSObject>(cellType: NC.Type, byObserving keyPath: KeyPath<T, [NM]>, on provider: T, mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> SingleSectionModelTableViewBindResult<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(cellType: cellType, viewModelBindHandler: { (cell, viewModel) in
            var cell = cell
            cell.viewModel = viewModel
        })
        
        let section = self.section
        let token = provider.observe(keyPath, options: [.initial, .new]) { [weak binder = self.binder] (_, value) in
            let models: [NM]? = value.newValue
            binder?.sectionCellModels[section] = models
            binder?.sectionCellViewModels[section] = models?.map(mapToViewModel)
            binder?.reload(section: section)
        }
        self._binder.observationTokens.append(token)
        
        return SingleSectionModelTableViewBindResult<NC, S, NM>(binder: self._binder, section: self.section)
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
    public func bind<NC, NM, T: NSObject>(cellType: NC.Type, byObserving keyPath: KeyPath<T, [NM]>, on provider: T)
    -> SingleSectionModelTableViewBindResult<NC, S, NM> where NC: UITableViewCell & ReuseIdentifiable {
        self.addDequeueBlock(cellType: cellType)

        let section = self.section
        let token = provider.observe(keyPath, options: [.initial, .new]) { [weak binder = self.binder] (_, value) in
            let models: [NM]? = value.newValue
            binder?.sectionCellModels[section] = models
            binder?.reload(section: section)
        }
        self._binder.observationTokens.append(token)
        
        return SingleSectionModelTableViewBindResult<NC, S, NM>(binder: self._binder, section: self.section)
    }
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: Observable<H.ViewModel>) -> RxSingleSectionTableViewBindResult<C, S>
    where H: UITableViewHeaderFooterView & RxViewModelBindable & ReuseIdentifiable {
        self.bind(headerType: headerType, viewModelBindHandler: { $0.viewModel = $1 })
        
        viewModel.subscribe(onNext: { [weak binder = self.binder] (viewModel: H.ViewModel) in
            binder?.sectionHeaderViewModels[self.section] = viewModel
            binder?.reload(section: self.section)
        }).disposed(by: self.binder.disposeBag)

        return self
    }
    
    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitle(_ title: Observable<String>) -> RxSingleSectionTableViewBindResult<C, S> {
        title.subscribe(onNext: { [weak binder = self.binder] (title: String) in
            binder?.sectionHeaderTitles[self.section] = title
            binder?.reload(section: self.section)
        }).disposed(by: self.binder.disposeBag)
        
        return self
    }
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModel: Observable<F.ViewModel>) -> RxSingleSectionTableViewBindResult<C, S>
        where F: UITableViewHeaderFooterView & RxViewModelBindable & ReuseIdentifiable {
            guard self.binder.sectionFooterDequeueBlocks[section] == nil else {
                print("WARNING: Section already has a header type bound to it - re-binding not supported.")
                return self
            }
            
            viewModel.subscribe(onNext: { [weak binder = self.binder] (viewModel: F.ViewModel) in
                binder?.sectionFooterViewModels[self.section] = viewModel
                binder?.reload(section: self.section)
            }).disposed(by: self.binder.disposeBag)
            
            let headerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
                if let section = binder?.displayedSections.value[sectionInt],
                    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: F.reuseIdentifier) as? F,
                    let viewModel = binder?.sectionFooterViewModels[section] as? F.ViewModel {
                    header.viewModel.value = viewModel
                    return header
                }
                return nil
            }
            self.binder.sectionFooterDequeueBlocks[section] = headerDequeueBlock
            
            return self
    }
    
    /**
     Bind the given observable title to the section's footer.
     */
    @discardableResult
    public func footerTitle(_ title: Observable<String>) -> SingleSectionTableViewBindResult<C, S> {
        title.subscribe(onNext: { [weak binder = self.binder] (title: String) in
            binder?.sectionFooterTitles[self.section] = title
            binder?.reload(section: self.section)
        }).disposed(by: self.binder.disposeBag)
        
        return self
    }
}

public class SingleSectionModelTableViewBindResult<C: UITableViewCell, S: TableViewSection, M>: SingleSectionTableViewBindResult<C, S> {
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped, along
     with the raw model object associated with the cell. The cell will be cast to the cell type bound to the section if
     this method is called in a chain after the `bind(cellType:viewModels:)` method.
     
     Note that this `onTapped` variation with the raw model object is only available if the
     `bind(cellType:models:mapToViewModelsWith:)` method was used to bind the cell type to the section.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C, _ model: M) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        let section = self.section
        let tappedHandler: CellTapCallback = {  [weak binder = self.binder] row, cell in
            guard let cell = cell as? C, let model = binder?.sectionCellModels[section]?[row] as? M else {
                fatalError("Cell or model wasn't the right type; something went awry!")
            }
            handler(row, cell, model)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C, _ model: M) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        let section = self.section
        let dequeueCallback: CellDequeueCallback = { [weak binder = self.binder] row, cell in
            guard let cell = cell as? C, let model = binder?.sectionCellModels[section]?[row] as? M else {
                fatalError("Cell wasn't the right type; something went awry!")
            }
            handler(row, cell, model)
        }
        
        self.binder.sectionCellDequeuedCallbacks[section] = dequeueCallback
        
        return self
    }
    
    @discardableResult
    override public func bind<H>(headerType: H.Type, viewModel: Observable<H.ViewModel>) -> SingleSectionModelTableViewBindResult<C, S, M>
        where H: UITableViewHeaderFooterView & RxViewModelBindable & ReuseIdentifiable {
            super.bind(headerType: headerType, viewModel: viewModel)
            return self
    }
    
    @discardableResult
    override public func headerTitle(_ title: Observable<String>) -> SingleSectionTableViewBindResult<C, S> {
        super.headerTitle(title)
        return self
    }
    
    @discardableResult
    override public func bind<F>(footerType: F.Type, viewModel: Observable<F.ViewModel>) -> SingleSectionModelTableViewBindResult<C, S, M>
        where F: UITableViewHeaderFooterView & RxViewModelBindable & ReuseIdentifiable {
            super.bind(footerType: footerType, viewModel: viewModel)
            return self
    }
    
    @discardableResult
    override public func footerTitle(_ title: Observable<String>) -> RxSingleSectionTableViewBindResult<C, S> {
        super.footerTitle(title)
        return self
    }
    
    @discardableResult
    override public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    override public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    override public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.cellHeight(handler)
        return self
    }
    
    @discardableResult
    override public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionModelTableViewBindResult<C, S, M> {
        super.estimatedCellHeight(handler)
        return self
    }
}


