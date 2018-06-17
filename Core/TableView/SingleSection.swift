import UIKit

public class SingleSectionTableViewBindResult<C: UITableViewCell, S: TableViewSection>: BaseSingleSectionTableViewBindResult<C, S> {
    var binder: SectionedTableViewBinder<S> {
        return self.baseBinder as! SectionedTableViewBinder<S>
    }
    
    required init(binder: SectionedTableViewBinder<S>, section: S) {
        super.init(binder: binder, section: section)
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
        self.binder.observationTokens.append(token)
        
        return SingleSectionTableViewBindResult<NC, S>(binder: self.binder, section: self.section)
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
        self.binder.observationTokens.append(token)
        
        return SingleSectionModelTableViewBindResult<NC, S, NM>(binder: self.binder, section: self.section)
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
        self.binder.observationTokens.append(token)
        
        return SingleSectionModelTableViewBindResult<NC, S, NM>(binder: self.binder, section: self.section)
    }
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> SingleSectionTableViewBindResult<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(headerType: headerType, viewModelBindHandler: { (header, viewModel) in
            var header = header
            header.viewModel = viewModel
        })
        self.binder.sectionHeaderViewModels[self.section] = viewModel

        return self
    }
    
    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitle(_ title: String) -> SingleSectionTableViewBindResult<C, S> {
        self.binder.sectionHeaderTitles[self.section] = title
        return self
    }
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> SingleSectionTableViewBindResult<C, S>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        self.addDequeueBlock(footerType: footerType, viewModelBindHandler: { (footer, viewModel) in
            var footer = footer
            footer.viewModel = viewModel
        })
        
        self.binder.sectionFooterViewModels[self.section] = viewModel
        
        return self
    }
    
    /**
     Bind the given observable title to the section's footer.
     */
    @discardableResult
    public func footerTitle(_ title: String) -> SingleSectionTableViewBindResult<C, S> {
        self.binder.sectionFooterTitles[self.section] = title
        return self
    }
    
    @discardableResult
    public override func configureCell(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> SingleSectionTableViewBindResult<C, S> {
        super.onCellDequeue(handler)
        return self
    }

    @discardableResult
    public override func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> SingleSectionTableViewBindResult<C, S> {
        super.onTapped(handler)
        return self
    }

    @discardableResult
    public override func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseSingleSectionTableViewBindResult<C, S> {
        super.cellHeight(handler)
        return self
    }

    @discardableResult
    public override func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionTableViewBindResult<C, S> {
        super.estimatedCellHeight(handler)
        return self
    }
}
