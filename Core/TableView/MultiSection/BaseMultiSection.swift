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
    internal let sections: [S]?
    
    internal init(binder: SectionedTableViewBinder<S>, sections: [S]?) {
        self.binder = binder
        self.sections = sections
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
        self.binder.addHeaderDequeueBlock(headerType: headerType, forSections: self.sections)
        self.binder.updateHeaderViewModels(viewModels: viewModels, sections: self.sections)

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
        self.binder.updateHeaderTitles(titles: titles, sections: self.sections)

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
        self.binder.addFooterDequeueBlock(footerType: footerType, forSections: self.sections)
        self.binder.updateFooterViewModels(viewModels: viewModels, sections: self.sections)

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
        self.binder.updateFooterTitles(titles: titles, sections: self.sections)
        
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
        if self.isForAllSections {
            // TODO: this
//            self.binder.cellDequeueBlock =
        } else {
            for section in self.sections {
                self.binder.sectionCellDequeuedCallbacks[section] = { (row: Int, cell: UITableViewCell) in
                    guard let cell = cell as? C else {
                        assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                        return
                    }
                    handler(section, row, cell)
                }
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
        if self.isForAllSections {
            // TODO: this
//            self.binder.cellTappedCallback =
        } else {
            for section in self.sections {
                self.binder.sectionCellTappedCallbacks[section] = { (row, tappedCell) in
                    guard let tappedCell = tappedCell as? C else {
                        assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                        return
                    }
                    handler(section, row, tappedCell)
                }
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
        if self.isForAllSections {
            // TODO: this
        } else {
            for section in self.sections {
                self.binder.sectionCellHeightBlocks[section] = { (row: Int) in
                    return handler(section, row)
                }
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
        if self.isForAllSections {
            // TODO: this
        } else {
            for section in self.sections {
                self.binder.sectionEstimatedCellHeightBlocks[section] = { (row: Int) in
                    return handler(section, row)
                }
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
        if self.isForAllSections {
            // TODO: this
        } else {
            for section in self.sections {
                self.binder.sectionHeaderHeightBlocks[section] = {
                    return handler(section)
                }
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

/*
 When 'multi section binders' are created to bind data/handlers as a result of the `onAllSections` method, we need to
 make sure they don't overwrite data added to the data model from 'section binders' that were created from the more
 specific `onSection` or `onSections` methods. So, whenever 'multi section binders' go to update data, they need to
 check their 'isForAllSections' property and call these methods to do the work of updating the data to make sure
 overwriting doesn't happen.
*/
//extension BaseTableViewMutliSectionBinder {
//    static func updateNextHeaderFooterModelsForAllSections(binder: SectionedTableViewBinder<S>, titles: [S: String]?, viewModels: [S: Identifiable]?, isHeader: Bool) {
//        // We assume that the view models given in the dictionary are meant to be the state of the table if we're
//        // binding all sections (i.e. any sections not in the dictionary are to have their 'view models' data array
//        // emptied). However, we don't want to empty the arrays for sections that were bound 'uniquely' (i.e. with the
//        // 'onSection' or 'onSections' methods), as they have unique data or cell types that should not be overwritten
//        // by an 'onAllSections' data refresh.
//        for section in binder.currentDataModel.sectionCellModels.keys {
//            if binder.nextDataModel.uniquelyBoundSections.contains(section) == true {
//                continue
//            } else {
//                if isHeader {
//                    if titles != nil {
//                        binder.nextDataModel.sectionHeaderTitles[section] =  nil
//                    } else {
//                        binder.nextDataModel.sectionHeaderViewModels[section] = nil
//                    }
//                } else {
//                    if titles != nil {
//                        binder.nextDataModel.sectionFooterTitles[section] = nil
//                    } else {
//                        binder.nextDataModel.sectionFooterViewModels[section] = nil
//                    }
//                }
//            }
//        }
//
//        // Get the sections that are attempting to be bound from the dictionary keys
//        var givenSections: [S] = []
//        if let titleSections = titles?.keys {
//            givenSections = Array(titleSections)
//        } else if let viewModelSections = viewModels?.keys {
//            givenSections = Array(viewModelSections)
//        }
//
//        // Now, ensure we only overwrite the data for sections that were not uniquely bound by name.
//        let sectionsNotUniquelyBound: Set<S> = Set(givenSections).subtracting(binder.nextDataModel.uniquelyBoundSections)
//        for section in sectionsNotUniquelyBound {
//            if isHeader {
//                if let titles = titles {
//                    binder.nextDataModel.sectionHeaderTitles[section] = titles[section]
//                } else if let viewModels = viewModels {
//                    binder.nextDataModel.sectionHeaderViewModels[section] = viewModels[section]
//                }
//            } else {
//                if let titles = titles {
//                    binder.nextDataModel.sectionFooterTitles[section] = titles[section]
//                } else if let viewModels = viewModels {
//                    binder.nextDataModel.sectionFooterViewModels[section] = viewModels[section]
//                }
//            }
//        }
//    }
//}
