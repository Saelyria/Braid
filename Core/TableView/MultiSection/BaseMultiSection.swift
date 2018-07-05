import UIKit

public class BaseTableViewMutliSectionBinder<C: UITableViewCell, S: TableViewSection>: TableViewMutliSectionBinderProtocol {
    internal let binder: SectionedTableViewBinder<S>
    internal let sections: [S]
    internal var baseSectionBindResults: [S: BaseTableViewSingleSectionBinder<C, S>] = [:]
    
    internal init(binder: SectionedTableViewBinder<S>, sections: [S]) {
        self.binder = binder
        self.sections = sections
    }
    
    /**
     Bind the given header type to the declared section with the given observable for their view models.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModels: [S: H.ViewModel]) -> BaseTableViewMutliSectionBinder<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        for section in self.sections {
            guard let sectionViewModel = viewModels[section] else {
                fatalError("No header view model given for the section '\(section)'")
            }
            let sectionBindResult = self.baseBindResult(for: section)
            sectionBindResult.bind(headerType: headerType, viewModel: sectionViewModel)
        }
        
        return self
    }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared sections.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            let bindResult: BaseTableViewSingleSectionBinder<C, S> = self.baseBindResult(for: section)
            bindResult.configureCell({ row, cell in
                handler(section, row, cell)
            })
        }
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared sections is tapped.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            let bindResult: BaseTableViewSingleSectionBinder<C, S> = self.baseBindResult(for: section)
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
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            let bindResult: BaseTableViewSingleSectionBinder<C, S> = self.baseBindResult(for: section)
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
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            let bindResult: BaseTableViewSingleSectionBinder<C, S> = self.baseBindResult(for: section)
            bindResult.estimatedCellHeight({ row in
                handler(section, row)
            })
        }
        return self
    }
    
    internal func baseBindResult(`for` section: S) -> BaseTableViewSingleSectionBinder<C, S> {
        if let bindResult = self.baseSectionBindResults[section] {
            return bindResult
        } else {
            let bindResult = BaseTableViewSingleSectionBinder<C, S>(binder: self.binder, section: section)
            self.baseSectionBindResults[section] = bindResult
            return bindResult
        }
    }
}

