import UIKit

/// Protocol that allows us to have Reactive extensions
public protocol TableViewSingleSectionBinderProtocol {
    associatedtype C: UITableViewCell
    associatedtype S: TableViewSection
}

// Need this second protocol so Reactive extension methods for binding celltype are only on 'inital' binders
public protocol TableViewInitialSingleSectionBinderProtocol: TableViewSingleSectionBinderProtocol { }

/**
 An abstract superclass for all single-section binders. This class contains the implementations for the
 handler methods that are common to all types of single-section binders. Specialized binder subclasses
 should override each of this class's methods to override their return type to themselves so any special
 methods of theirs can still be used in the chain.
 */
public class BaseTableViewSingleSectionBinder<C: UITableViewCell, S: TableViewSection> {    
    let binder: SectionedTableViewBinder<S>
    let section: S
    
    init(binder: SectionedTableViewBinder<S>, section: S) {
        self.binder = binder
        self.section = section
    }
    
    // MARK: Header / footer view binding
    
    /**
     Bind the given header type to the declared section with the given observable for its view model.
     
     Use this method to use a custom `UITableViewHeaderFooterView` with a table view binder. The view must conform to
     `ViewModelBindable` and `ReuseIdentifiable` to be compatible with a table view binder. The binder will reload the
     header's section when the given observable view model changes.
     */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: H.ViewModel) -> BaseTableViewSingleSectionBinder<C, S>
        where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
            self.addDequeueBlock(headerType: headerType)
            self.binder.sectionHeaderViewModels[self.section] = viewModel
            
            return self
    }
    
    /**
     Bind the given observable title to the section's header.
     */
    @discardableResult
    public func headerTitle(_ title: String) -> BaseTableViewSingleSectionBinder<C, S> {
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
    public func bind<F>(footerType: F.Type, viewModel: F.ViewModel) -> BaseTableViewSingleSectionBinder<C, S>
        where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
            self.addDequeueBlock(footerType: footerType)
            self.binder.sectionFooterViewModels[self.section] = viewModel
            
            return self
    }
    
    /**
     Bind the given observable title to the section's footer.
     */
    @discardableResult
    public func footerTitle(_ title: String) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionFooterTitles[self.section] = title
        return self
    }
    
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
     
     The handler is called whenever a cell in the section is dequeued, passing in the row and the dequeued cell. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> BaseTableViewSingleSectionBinder<C, S> {
        let dequeueCallback: CellDequeueCallback = { row, cell in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.sectionCellDequeuedCallbacks[self.section] = dequeueCallback
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
     
     The handler is called whenever a cell in the section is tapped, passing in the row and cell that was tapped. The
     cell will be cast to the cell type bound to the section if this method is called in a chain after the
     `bind(cellType:viewModels:)` method.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> BaseTableViewSingleSectionBinder<C, S> {
        let tappedHandler: CellTapCallback = { row, cell in
            guard let cell = cell as? C else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(row, cell)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    /**
     Add a callback handler to provide the cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the height for.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionCellHeightBlocks[section] = handler
        return self
    }
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared section.
     
     The given handler is called whenever the section reloads for each visible row, passing in the row the handler
     should provide the estimated height for.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> BaseTableViewSingleSectionBinder<C, S> {
        self.binder.sectionEstimatedCellHeightBlocks[section] = handler
        return self
    }
}


// Internal extension with functions for the common setup of 'dequeue blocks' on the binder
internal extension BaseTableViewSingleSectionBinder {
    internal func addDequeueBlock<H>(headerType: H.Type) where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionHeaderDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a header type bound to it - re-binding not supported.")
            return
        }
        
        let headerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
            if let section = binder?.displayedSections[sectionInt],
                var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H,
                let viewModel = binder?.sectionHeaderViewModels[section] as? H.ViewModel {
                header.viewModel = viewModel
                return header
            }
            assertionFailure("ERROR: Didn't return a header - something went awry!")
            return nil
        }
        self.binder.sectionHeaderDequeueBlocks[self.section] = headerDequeueBlock
    }
    
    internal func addDequeueBlock<F>(footerType: F.Type) where F: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionFooterDequeueBlocks[self.section] == nil else {
            print("WARNING: Section already has a footer type bound to it - re-binding not supported.")
            return
        }
        
        let footerDequeueBlock: HeaderFooterDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
            if let section = binder?.displayedSections[sectionInt],
                var footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: F.reuseIdentifier) as? F,
                let viewModel = binder?.sectionFooterViewModels[section] as? F.ViewModel {
                footer.viewModel = viewModel
                return footer
            }
            assertionFailure("ERROR: Didn't return a footer - something went awry!")
            return nil
        }
        self.binder.sectionFooterDequeueBlocks[self.section] = footerDequeueBlock
    }
}

