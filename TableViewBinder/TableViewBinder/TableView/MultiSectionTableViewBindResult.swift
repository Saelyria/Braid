import UIKit
import RxSwift

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methodss that take a binding handler and give it to the original table view binder to store for callback.
*/
public class MultiSectionTableViewBindResult<C: UITableViewCell, S: TableViewSection> {
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
    public func bind<NC>(cellType: NC.Type, viewModels: [S: Observable<[NC.ViewModel]>]) -> MultiSectionTableViewBindResult<NC, S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        for section in self.sections {
            guard let sectionViewModels = viewModels[section] else {
                fatalError("No cell view models array given for the section '\(section)'")
            }
            let sectionBindResult = self.bindResult(for: section)
            sectionBindResult.bind(cellType: cellType, viewModels: sectionViewModels)
        }
        
        return MultiSectionTableViewBindResult<NC, S>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
    */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: [S: Observable<[NM]>], mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> MultiSectionTableViewBindResult<NC, S> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        for section in self.sections {
            guard let sectionModels = models[section] else {
                fatalError("No cell models array given for the section '\(section)'")
            }
            let sectionBindResult = self.bindResult(for: section)
            sectionBindResult.bind(cellType: cellType, models: sectionModels, mapToViewModelsWith: mapToViewModel)
        }
        
        return MultiSectionTableViewBindResult<NC, S>(binder: self.binder, sections: self.sections)
    }
    
    /**
     Bind the given header type to the declared section with the given observable for their view models.
    */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModels: [S: Observable<H.ViewModel>]) -> MultiSectionTableViewBindResult<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
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
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> MultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: SingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
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
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> MultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: SingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
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
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> MultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: SingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
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
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> MultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: SingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.estimatedCellHeight({ row in
                handler(section, row)
            })
        }
        return self
    }
    
    private func bindResult(`for` section: S) -> SingleSectionTableViewBindResult<C, S> {
        if let bindResult = self.sectionBindResults[section] {
            return bindResult
        } else {
            let bindResult = SingleSectionTableViewBindResult<C, S>(binder: self.binder, section: section)
            self.sectionBindResults[section] = bindResult
            return bindResult
        }
    }
}

/**
 A throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a number
 of methodss that take a binding handler and give it to the original table view binder to store for callback.
*/
public class MultiSectionModelTableViewBindResult<C: UITableViewCell, S: TableViewSection, M>: MultiSectionTableViewBindResult<C, S> {
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C, _ model: M) -> Void) -> MultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult = SingleSectionModelTableViewBindResult<C, S, M>(binder: self.binder, section: section)
            bindResult.onTapped({ row, cell, model in
                handler(section, row, cell, model)
            })
        }
        return self
    }
}

