import UIKit
import RxSwift

/**
 A throwaway object created when a table view binder's `onSection(_:)` method is called. This object declares a number
 of methodss that take a binding handler and give it to the original table view binder to store for callback.
 */
public class SingleSectionTableViewBindResult<C: UITableViewCell, S: TableViewSection> {
    internal let binder: SectionedTableViewBinder<S>
    internal let section: S
    
    internal init(binder: SectionedTableViewBinder<S>, section: S) {
        self.binder = binder
        self.section = section
    }
    
    // MARK: Cell and header / footer view binding
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
    */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: Observable<[NC.ViewModel]>) -> SingleSectionTableViewBindResult<NC, S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        let section = self.section
        guard self.binder.sectionCellDequeueBlocks[section] == nil else {
            fatalError("Section already has a cell type bound to it - re-binding not supported.")
        }
        
        viewModels.subscribe(onNext: { [weak binder = self.binder] (viewModels: [NC.ViewModel]) in
            binder?.sectionCellViewModels[section] = viewModels
            binder?.reload(section: section)
        }).disposed(by: self.binder.disposeBag)
        
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
        
        let tableViewBindResult = SingleSectionTableViewBindResult<NC, S>(binder: self.binder, section: self.section)
        return tableViewBindResult
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
    -> SingleSectionModelTableViewBindResult<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        let section = self.section
        guard self.binder.sectionCellDequeueBlocks[section] == nil else {
            fatalError("Section already has a cell type bound to it - re-binding not supported.")
        }
        
        models.subscribe(onNext: { [weak binder = self.binder] (models: [NM]) in
            binder?.sectionCellModels[section] = models
            binder?.sectionCellViewModels[section] = models.map(mapToViewModel)
            binder?.reload(section: section)
        }).disposed(by: self.binder.disposeBag)
        
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
        
        let tableViewBindResult = SingleSectionModelTableViewBindResult<NC, S, NM>(binder: self.binder, section: self.section)
        return tableViewBindResult
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
    -> SingleSectionModelTableViewBindResult<NC, S, NM> where NC: UITableViewCell & ReuseIdentifiable {
        let section = self.section
        guard self.binder.sectionCellDequeueBlocks[section] == nil else {
            fatalError("Section already has a cell type bound to it - re-binding not supported.")
        }
        
        models.subscribe(onNext: { [weak binder = self.binder] (models: [NM]) in
            binder?.sectionCellModels[section] = models
            binder?.reload(section: section)
        }).disposed(by: self.binder.disposeBag)
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.binder] (tableView, indexPath) in
            if let section = binder?.displayedSections.value[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC {
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            return UITableViewCell()
        }
        self.binder.sectionCellDequeueBlocks[section] = cellDequeueBlock
        
        let tableViewBindResult = SingleSectionModelTableViewBindResult<NC, S, NM>(binder: self.binder, section: self.section)
        return tableViewBindResult
    }
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
    */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: Observable<H.ViewModel>) -> SingleSectionTableViewBindResult<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionHeaderDequeueBlocks[section] == nil else {
            print("WARNING: Section already has a header type bound to it - re-binding not supported.")
            return self
        }
        
        viewModel.subscribe(onNext: { [weak binder = self.binder] (viewModel: H.ViewModel) in
            binder?.sectionHeaderViewModels[self.section] = viewModel
            binder?.reload(section: self.section)
        }).disposed(by: self.binder.disposeBag)
        
        let headerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
            if let section = binder?.displayedSections.value[sectionInt],
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H,
                let viewModel = binder?.sectionHeaderViewModels[section] as? H.ViewModel {
                header.viewModel.value = viewModel
                return header
            }
            return nil
        }
        self.binder.sectionHeaderDequeueBlocks[section] = headerDequeueBlock
        
        return self
    }
    
    /**
     Bind the given observable title to the section's header.
    */
    @discardableResult
    public func headerTitle(_ title: Observable<String>) -> SingleSectionTableViewBindResult<C, S> {
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
    public func bind<F>(footerType: F.Type, viewModel: Observable<F.ViewModel>) -> SingleSectionTableViewBindResult<C, S>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
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
    
    // MARK: Event binding
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
    */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> SingleSectionTableViewBindResult<C, S> {
        let dequeueCallback: CellDequeueCallback = { row, cell in
            guard let cell = cell as? C else { fatalError("Cell wasn't the right type; something went awry!") }
            handler(row, cell)
        }
        
        self.binder.sectionCellDequeuedCallbacks[section] = dequeueCallback
        
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
    */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> SingleSectionTableViewBindResult<C, S> {
        let tappedHandler: CellTapCallback = { row, cell in
            guard let cell = cell as? C else { fatalError("Cell wasn't the right type; something went awry!") }
            handler(row, cell)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    // MARK: Height bindings
    
    /**
     Add a callback handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
    */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionTableViewBindResult<C, S> {
        self.binder.sectionCellHeightBlocks[section] = handler
        return self
    }
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
    */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionTableViewBindResult<C, S> {
        self.binder.sectionEstimatedCellHeightBlocks[section] = handler
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
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C, _ model: M) -> Void) -> SingleSectionTableViewBindResult<C, S> {
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
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
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
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        super.bind(footerType: footerType, viewModel: viewModel)
        return self
    }
    
    @discardableResult
    override public func footerTitle(_ title: Observable<String>) -> SingleSectionTableViewBindResult<C, S> {
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
