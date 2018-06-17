import UIKit

public protocol MutliSectionBindResultProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
    
    /// The bind result's original binder. This is mostly used internally and can be ignored.
    var binder: _BaseTableViewBinder<S> { get }
    /// The sections the bind result is for. This is mostly used internally and can be ignored.
    var sections: [S] { get }
    
    @discardableResult
    public func configureCell(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> Self
    
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> Self
    
    /**
     Add a callback handler to provide the cell height for cells in the declared sections.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> Self
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared sections.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> Self
    
//    var sectionBindResults: [S: SingleSectionBindResultProtocol] //SingleSectionTableViewBindResult<C, S>]
}

extension MultiSectionBindResultProtocol {
    internal let binder: SectionedTableViewBinder<S>
    internal let sections: [S]
    internal var sectionBindResults: [S: SingleSectionTableViewBindResult<C, S>] = [:]
    
    internal init(binder: SectionedTableViewBinder<S>, sections: [S]) {
        self.binder = binder
        self.sections = sections
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
     */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, byObserving keyPath: KeyPath<T, [NC.ViewModel]>, on provider: T)
        -> MultiSectionTableViewBindResult<NC, S> where NC: UITableViewCell & RxViewModelBindable & ReuseIdentifiable {
            for section in self.sections {
                guard let sectionViewModels = viewModels[section] else {
                    fatalError("No cell view models array given for the section '\(section)'")
                }
                let sectionBindResult = self.bindResult(for: section)
                sectionBindResult.bind(cellType: cellType, byObserving: keyPath, on: provider)
            }
            
            return MultiSectionTableViewBindResult<NC, S>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
     */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, byObserving keyPath: KeyPath<T, [NM]>, on provider: T, mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
        -> RxMultiSectionModelTableViewBindResult<NC, S, NM> where NC: UITableViewCell & RxViewModelBindable & ReuseIdentifiable {
            for section in self.sections {
                guard let sectionModels = models[section] else {
                    fatalError("No cell models array given for the section '\(section)'")
                }
                let sectionBindResult = self.bindResult(for: section)
                sectionBindResult.bind(cellType: cellType, models: sectionModels, mapToViewModelsWith: mapToViewModel)
            }
            
            return RxMultiSectionModelTableViewBindResult<NC, S, NM>(binder: self.binder, sections: self.sections)
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
    public func bind<NC, NM>(cellType: NC.Type, models: [S: Observable<[NM]>])
        -> RxMultiSectionModelTableViewBindResult<NC, S, NM> where NC: UITableViewCell & ReuseIdentifiable {
            for section in self.sections {
                guard let sectionModels = models[section] else {
                    fatalError("No cell models array given for the section '\(section)'")
                }
                let sectionBindResult = self.bindResult(for: section)
                sectionBindResult.bind(cellType: cellType, models: sectionModels)
            }
            
            return RxMultiSectionModelTableViewBindResult<NC, S, NM>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given header type to the declared section with the given observable for their view models.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModels: [S: Observable<H.ViewModel>]) -> RxMultiSectionTableViewBindResult<C, S>
        where H: UITableViewHeaderFooterView & RxViewModelBindable & ReuseIdentifiable {
            for section in self.sections {
                guard let sectionViewModel = viewModels[section] else {
                    fatalError("No header view model given for the section '\(section)'")
                }
                let sectionBindResult = self.bindResult(for: section)
                sectionBindResult.bind(headerType: headerType, viewModel: sectionViewModel)
            }
            
            return self
    }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared sections.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.onCellDequeue({ row, cell in
                handler(section, row, cell)
            })
        }
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared sections is tapped.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.onTapped({ row, cell in
                handler(section, row, cell)
            })
        }
        return self
    }
    
    /**
     Add a callback handler to provide the cell height for cells in the declared sections.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.cellHeight({ row in
                handler(section, row)
            })
        }
        return self
    }
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared sections.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.estimatedCellHeight({ row in
                handler(section, row)
            })
        }
        return self
    }

}
