import UIKit

/// Protocol that allows us to have Reactive extensions
public protocol TableViewMutliSectionBinderProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
}

// Need this second protocol so Reactive extension methods for binding celltype are only on 'inital' binders
public protocol TableViewInitialMutliSectionBinderProtocol: TableViewMutliSectionBinderProtocol { }

public class BaseTableViewMutliSectionBinder<C: UITableViewCell, S: TableViewSection> {
    internal let binder: SectionedTableViewBinder<S>
    internal let sections: [S]
    internal var baseSectionBindResults: [S: BaseTableViewSingleSectionBinder<C, S>] = [:]
    
    internal init(binder: SectionedTableViewBinder<S>, sections: [S]) {
        self.binder = binder
        self.sections = sections
    }
    
    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitles(_ titles: [S: String]) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            if let title = titles[section] {
                let sectionBindResult = self.baseBindResult(for: section)
                sectionBindResult.headerTitle(title)
            }
        }
        
        return self
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
    
    @discardableResult
    public func footerTitles(_ titles: [S: String]) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            if let title = titles[section] {
                let sectionBindResult = self.baseBindResult(for: section)
                sectionBindResult.footerTitle(title)
            }
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
    
    /**
     Add a callback handler to provide the height for the section header in the declared section.
     */
    @discardableResult
    public func headerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionHeaderHeightBlocks[section] = {
                return handler(section)
            }
        }
        return self
    }
    
    /**
     Add a callback handler to provide the estimated height for the section header in the declared section
     */
    @discardableResult
    public func estimatedHeaderHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionHeaderEstimatedHeightBlocks[section] = {
                return handler(section)
            }
        }
        return self
    }
    
    /**
     Add a callback handler to provide the height for the section footer in the declared section.
     */
    @discardableResult
    public func footerHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionFooterHeightBlocks[section] = {
                return handler(section)
            }
        }
        return self
    }
    
    /**
     Add a callback handler to provide the estimated height for the section footer in the declared section
     */
    @discardableResult
    public func estimatedFooterHeight(_ handler: @escaping (_ section: S) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionFooterEstimatedHeightBlocks[section] = {
                return handler(section)
            }
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

