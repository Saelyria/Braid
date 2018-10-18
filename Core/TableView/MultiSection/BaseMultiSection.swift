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
    internal let isForAllSections: Bool
    internal var baseSectionBindResults: [S: BaseTableViewSingleSectionBinder<C, S>] = [:]
    
    internal init(binder: SectionedTableViewBinder<S>, sections: [S], isForAllSections: Bool) {
        self.binder = binder
        self.sections = sections
        self.isForAllSections = isForAllSections
    }
    
    /**
     Binds the given header type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section header with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter headerType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value is the header view model for the
        header created for the section. This dictionary does not need to contain a view model for each section being
        bound - sections not present in the dictionary have no header view created for them. This view models dictionary
        should not contain entries for sections not declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModels: [S: H.ViewModel]) -> BaseTableViewMutliSectionBinder<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        for section in self.sections {
            if viewModels[section] != nil {
                BaseTableViewSingleSectionBinder<C, S>.addHeaderFooterDequeueBlock(type: headerType, binder: self.binder, section: section, isHeader: true)
            }
            self.binder.nextDataModel.sectionHeaderViewModels[section] = viewModels[section]
        }
        return self
    }
    
    /**
     Binds the given titles to the section's headers.
     
     This method will provide the given titles as the titles for the iOS native section headers. If you have bound a
     custom header type to the table view using the `bind(headerType:viewModels:)` method, this method will do nothing.
     
     - parameter titles: A dictionary where the key is a section and the value is the title for the section. This
        dictionary does not need to contain a title for each section being bound - sections not present in the
        dictionary have no title assigned to them. This titles dictionary cannot contain entries for sections not
        declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func headerTitles(_ titles: [S: String]) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.nextDataModel.sectionHeaderTitles[section] = titles[section]
        }
        return self
    }
    
    /**
     Binds the given footer type to the declared section with the given view models for each section.
     
     Use this method to use a custom `UITableViewHeaderFooterView` subclass for the section footer with a table view
     binder. The view must conform to `ViewModelBindable` and `ReuseIdentifiable` to be compatible.
     
     - parameter footerType: The class of the header to bind.
     - parameter viewModels: A dictionary where the key is a section and the value is the footer view model for the
        footer created for the section. This dictionary does not need to contain a view model for each section being
        bound - sections not present in the dictionary have no footer view created for them. This view models dictionary
        cannot contain entries for sections not declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func bind<F>(footerType: F.Type, viewModels: [S: F.ViewModel]) -> BaseTableViewMutliSectionBinder<C, S>
    where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        for section in self.sections {
            BaseTableViewSingleSectionBinder<C, S>.addHeaderFooterDequeueBlock(type: footerType, binder: self.binder, section: section, isHeader: false)
            self.binder.nextDataModel.sectionFooterViewModels[section] = viewModels[section]
        }
        return self
    }
    
    /**
     Binds the given titles to the section's footers.
     
     This method will provide the given titles as the titles for the iOS native section footers. If you have bound a
     custom footer type to the table view using the `bind(footerType:viewModels:)` method, this method will do nothing.
     
     - parameter titles: A dictionary where the key is a section and the value is the title for the footer section. This
        dictionary does not need to contain a footer title for each section being bound - sections not present in the
        dictionary have no footer title assigned to them. This titles dictionary cannot contain entries for sections not
        declared as a part of the current binding chain.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func footerTitles(_ titles: [S: String]) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.nextDataModel.sectionFooterTitles[section] = titles[section]
        }
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell is dequeued in one of the declared sections.
     
     The given handler is called whenever a cell in one of the sections being bound is dequeued, passing in the row and
     the dequeued cell. The cell will be safely cast to the cell type bound to the section if this method is called in a
     chain after the `bind(cellType:viewModels:)` method. This method can be used to perform any additional
     configuration of the cell.
     
     - parameter handler: The closure to be called whenever a cell is dequeued in one of the bound sections.
     - parameter section: The section in which a cell was dequeued.
     - parameter row: The row of the cell that was dequeued.
     - parameter dequeuedCell: The cell that was dequeued that can now be configured.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionCellDequeuedCallbacks[section] = { (row: Int, cell: UITableViewCell) in
                guard let cell = cell as? C else {
                    assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                    return
                }
                handler(section, row, cell)
            }
        }
        return self
    }
    
    /**
     Adds a handler to be called whenever a cell in one of the declared sections is tapped.
     
     The given handler is called whenever a cell in one of the sections being bound  is tapped, passing in the row and
     cell that was tapped. The cell will be safely cast to the cell type bound to the section if this method is called
     in a chain after the `bind(cellType:viewModels:)` method.
     
     - parameter handler: The closure to be called whenever a cell is tapped in the bound section.
     - parameter section: The section in which a cell was tapped.
     - parameter row: The row of the cell that was tapped.
     - parameter tappedCell: The cell that was tapped.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionCellTappedCallbacks[section] = { (row, tappedCell) in
                guard let tappedCell = tappedCell as? C else {
                    assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                    return
                }
                handler(section, row, tappedCell)
            }
        }
        return self
    }
    
    /**
     Adds a handler to provide the cell height for cells in the declared sections.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     
     - parameter handler: The closure to be called that will return the height for cells in the section.
     - parameter section: The section of the cell to provide the height for.
     - parameter row: The row of the cell to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionCellHeightBlocks[section] = { (row: Int) in
                return handler(section, row)
            }
        }
        return self
    }
    
    /**
     Adds a handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     
     - parameter handler: The closure to be called that will return the estimated height for cells in the section.
     - parameter section: The section of the cell to provide the estimated height for.
     - parameter row: The row of the cell to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> BaseTableViewMutliSectionBinder<C, S> {
        for section in self.sections {
            self.binder.sectionEstimatedCellHeightBlocks[section] = { (row: Int) in
                return handler(section, row)
            }
        }
        return self
    }
    
    /**
     Adds a callback handler to provide the height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section header.
     - parameter section: The section of the header to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
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
     Adds a callback handler to provide the estimated height for section headers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section header.
     - parameter section: The section of the header to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
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
     Adds a callback handler to provide the height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the height for the section footer.
     - parameter section: The section of the footer to provide the height for.
     
     - returns: A section binder to continue the binding chain with.
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
     Adds a callback handler to provide the estimated height for section footers in the declared sections.
     
     - parameter handler: The closure to be called that will return the estimated height for the section footer.
     - parameter section: The section of the footer to provide the estimated height for.
     
     - returns: A section binder to continue the binding chain with.
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
}

