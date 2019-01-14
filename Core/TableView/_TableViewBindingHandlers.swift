import UIKit

/// A closure type that returns a table view cell when given a section, table view, and index path.
typealias CellDequeueBlock<S: TableViewSection> = (S, UITableView, IndexPath) -> UITableViewCell
/// A closure type that returns a table header/footer view when given a section and table view.
typealias HeaderFooterDequeueBlock<S: TableViewSection> = (S, UITableView) -> UITableViewHeaderFooterView?
/// A closure type that calls a 'tapped' callback handler with a given section, row, and table view cell.
typealias CellTapCallback<S: TableViewSection> = (S, Int, UITableViewCell) -> Void
/// A closure type that calls a 'cell dequeued' callback handler with a given section, row, and table view cell.
typealias CellDequeueCallback<S: TableViewSection> = (S, Int, UITableViewCell) -> Void
/// A closure type that returns the height for a cell when given a section and row.
typealias CellHeightBlock<S: TableViewSection> = (S, Int) -> CGFloat
/// A closure type that returns the height for a table header/footer when given a section.
typealias HeaderFooterHeightBlock<S: TableViewSection> = (S) -> CGFloat

typealias ViewEventEmittingHandler<S: TableViewSection> = (S, Int, UITableViewCell, _ event: Any) -> Void

/// An object that stores the various handlers the binder uses.
class _TableViewBindingHandlers<S: TableViewSection> {
    // Cell handlers
    
    // Closures that will update the data on the binder's data model when 'refresh' is called
    lazy var modelUpdaters: [() -> Void] = { [] }()
    
    // Closures to call to dequeue a cell in a section.
    lazy var sectionCellDequeueBlocks: [S: CellDequeueBlock<S>] = { [:] }()
    var dynamicSectionCellDequeueBlock: CellDequeueBlock<S>?

    // Closures to call to get the height for a cell in a section.
    lazy var sectionCellHeightBlocks: [S: CellHeightBlock<S>] = { [:] }()
    var dynamicSectionsCellHeightBlock: CellHeightBlock<S>?
    var anySectionCellHeightBlock: CellHeightBlock<S>?
    
    // Closures to call to get the estimated height for a cell in a section.
    lazy var sectionEstimatedCellHeightBlocks: [S: CellHeightBlock<S>] = { [:] }()
    var dynamicSectionsEstimatedCellHeightBlock: CellHeightBlock<S>?
    var anySectionEstimatedCellHeightBlock: CellHeightBlock<S>?
    
    // A function for each section that determines whether the model for a given row was updated. In most cases, this
    // will be a wrapper around `Equatable` conformance. These functions return nil if it can't compare the objects
    // given to it (e.g. weren't the right type).
    lazy var sectionItemEqualityCheckers: [S: (Any, Any) -> Bool?] = { [:] }()
    var dynamicSectionItemEqualityChecker: ((Any, Any) -> Bool?)?
    
    // Handlers for custom cell view events in a section. Each section has another dictionary under it where the key is
    // a string describing a cell type that has view events, and the value is the handler associated with it that is
    // called whenever a cell of that type in the section emits an event.
    lazy var sectionViewEventHandlers: [S: [String: ViewEventEmittingHandler<S>]] = { [:] }()
    lazy var dynamicSectionViewEventHandler: [String: ViewEventEmittingHandler<S>] = { [:] }()
    
    // The prefetch behaviour for a section.
    lazy var sectionPrefetchBehavior: [S: PrefetchBehavior] = { [:] }()
    var dynamicSectionPrefetchBehavior: PrefetchBehavior?
    
    // Closures to be called to handle prefetching data.
    lazy var sectionPrefetchHandlers: [S: (Int) -> Void] = { [:] }()
    var dynamicSectionPrefetchHandler: ((Int) -> Void)?
    
    // MARK: -
    
    // Closures to call to get the titles for section headers
    lazy var sectionHeaderTitleProviders: [S: () -> String?] = { [:] }()
    var dynamicSectionHeaderTitleProvider: ((S) -> String?)?
    
    // Closures to call to get the view models for section footers
    lazy var sectionHeaderViewModelProviders: [S: () -> Any?] = { [:] }()
    var dynamicSectionHeaderViewModelProvider: ((S) -> Any?)?
    
    // Blocks to call to dequeue a header in a section.
    lazy var sectionHeaderDequeueBlocks: [S: HeaderFooterDequeueBlock<S>] = { [:] }()
    var dynamicSectionsHeaderDequeueBlock: HeaderFooterDequeueBlock<S>?

    // Blocks to call to get the height for a header.
    lazy var sectionHeaderHeightBlocks: [S: HeaderFooterHeightBlock<S>] = { [:] }()
    var dynamicSectionsHeaderHeightBlock: HeaderFooterHeightBlock<S>?
    var anySectionHeaderHeightBlock: HeaderFooterHeightBlock<S>?

    // Blocks to call to get the estimated height for a header.
    lazy var sectionHeaderEstimatedHeightBlocks: [S: HeaderFooterHeightBlock<S>] = { [:] }()
    var dynamicSectionsHeaderEstimatedHeightBlock: HeaderFooterHeightBlock<S>?
    var anySectionHeaderEstimatedHeightBlock: HeaderFooterHeightBlock<S>?
    
    // MARK: -
    
    // Closures to call to get the titles for section footers
    lazy var sectionFooterTitleProviders: [S: () -> String?] = { [:] }()
    var dynamicSectionFooterTitleProvider: ((S) -> String?)?
    
    // Closures to call to get the view models for section footers
    lazy var sectionFooterViewModelProviders: [S: () -> Any?] = { [:] }()
    var dynamicSectionFooterViewModelProvider: ((S) -> Any?)?
    
    // Blocks to call to dequeue a footer in a section.
    lazy var sectionFooterDequeueBlocks: [S: HeaderFooterDequeueBlock<S>] = { [:] }()
    var dynamicSectionsFooterDequeueBlock: HeaderFooterDequeueBlock<S>?

    // Blocks to call to get the height for a section footer.
    lazy var sectionFooterHeightBlocks: [S: HeaderFooterHeightBlock<S>] = { [:] }()
    var dynamicSectionsFooterHeightBlock: HeaderFooterHeightBlock<S>?
    var anySectionFooterHeightBlock: HeaderFooterHeightBlock<S>?

    // Blocks to call to get the estimated height for a section footer.
    lazy var sectionFooterEstimatedHeightBlocks: [S: HeaderFooterHeightBlock<S>] = { [:] }()
    var dynamicSectionsFooterEstimatedHeightBlock: HeaderFooterHeightBlock<S>?
    var anySectionFooterEstimatedHeightBlock: HeaderFooterHeightBlock<S>?

    // MARK: -
    
    // Blocks to call when a cell is tapped in a section.
    lazy var sectionCellTappedCallbacks: [S: CellTapCallback<S>] = { [:] }()
    var dynamicSectionsCellTappedCallback: CellTapCallback<S>?
    var anySectionCellTappedCallback: CellTapCallback<S>?

    // Blocks to call when a cell is dequeued in a section.
    lazy var sectionCellDequeuedCallbacks: [S: CellDequeueCallback<S>] = { [:] }()
    var dynamicSectionsCellDequeuedCallback: CellDequeueCallback<S>?
    var anySectionCellDequeuedCallback: CellDequeueCallback<S>?
}
