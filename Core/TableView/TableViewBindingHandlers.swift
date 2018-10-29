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

/// An object that stores the various handlers the binder uses.
class TableViewBindingHandlers<S: TableViewSection> {
    // Cell handlers
    
    // Blocks to call to dequeue a cell in a section.
    var sectionCellDequeueBlocks: [S: CellDequeueBlock<S>] = [:]
    // Blocks to call to get the height for a cell in a section.
    var sectionCellHeightBlocks: [S: CellHeightBlock<S>] = [:]
    // Blocks to call to get the estimated height for a cell in a section.
    var sectionEstimatedCellHeightBlocks: [S: CellHeightBlock<S>] = [:]
    
    // A block to call to dequeue a cell in dynamic sections.
    var dynamicSectionCellDequeueBlock: CellDequeueBlock<S>?
    // A block to call to get the height for cells in dynamic sections.
    var dynamicSectionsCellHeightBlock: CellHeightBlock<S>?
    // A block to call to get the estimated height for cells in dynamic sections.
    var dynamicSectionsEstimatedCellHeightBlock: CellHeightBlock<S>?
    
    // A fallback block to call to get the height for cells whose sections weren't given a unique block.
    var anySectionCellHeightBlock: CellHeightBlock<S>?
    // A fallback block to call to get the estimated height for cells whose sections weren't given a unique block.
    var anySectionEstimatedCellHeightBlock: CellHeightBlock<S>?
    
    // Header handlers
    
    // Blocks to call to dequeue a header in a section.
    var sectionHeaderDequeueBlocks: [S: HeaderFooterDequeueBlock<S>] = [:]
    // Blocks to call to get the height for a header.
    var sectionHeaderHeightBlocks: [S: HeaderFooterHeightBlock<S>] = [:]
    // Blocks to call to get the estimated height for a header.
    var sectionHeaderEstimatedHeightBlocks: [S: HeaderFooterHeightBlock<S>] = [:]
    
    // A block to call to dequeue headers in dynamic sections.
    var dynamicSectionsHeaderDequeueBlock: HeaderFooterDequeueBlock<S>?
    // A block to call to get the height for headers in dynamic sections.
    var dynamicSectionsHeaderHeightBlock: HeaderFooterHeightBlock<S>?
    // A block to call to get the estimated height for headers in dynamic sections.
    var dynamicSectionsHeaderEstimatedHeightBlock: HeaderFooterHeightBlock<S>?
    
    // A fallback block to call to get the height for headers whose sections weren't given a unique block.
    var anySectionHeaderHeightBlock: HeaderFooterHeightBlock<S>?
    // A fallback block to call to get the estimated height for headers whose sections weren't given a unique block.
    var anySectionHeaderEstimatedHeightBlock: HeaderFooterHeightBlock<S>?
    
    // Footer handlers
    
    // Blocks to call to dequeue a footer in a section.
    var sectionFooterDequeueBlocks: [S: HeaderFooterDequeueBlock<S>] = [:]
    // Blocks to call to get the height for a section footer.
    var sectionFooterHeightBlocks: [S: HeaderFooterHeightBlock<S>] = [:]
    // Blocks to call to get the estimated height for a section footer.
    var sectionFooterEstimatedHeightBlocks: [S: HeaderFooterHeightBlock<S>] = [:]
    
    // A block to call to dequeue footers in dynamic sections.
    var dynamicSectionsFooterDequeueBlock: HeaderFooterDequeueBlock<S>?
    // A block to call to get the height for footers in dynamic sections.
    var dynamicSectionsFooterHeightBlock: HeaderFooterHeightBlock<S>?
    // A block to call to get the estimated height for footers in dynamic sections.
    var dynamicSectionsFooterEstimatedHeightBlock: HeaderFooterHeightBlock<S>?
    
    // A fallback block to call to get the height for footers whose sections weren't given a unique block.
    var anySectionFooterHeightBlock: HeaderFooterHeightBlock<S>?
    // A fallback block to call to get the estimated height for footers whose sections weren't given a unique block.
    var anySectionFooterEstimatedHeightBlock: HeaderFooterHeightBlock<S>?
    
    // Events
    
    // Blocks to call when a cell is tapped in a section.
    var sectionCellTappedCallbacks: [S: CellTapCallback<S>] = [:]
    // Blocks to call when a cell is dequeued in a section.
    var sectionCellDequeuedCallbacks: [S: CellDequeueCallback<S>] = [:]
    
    // A block to call when a cell is tapped in a dynamic section.
    var dynamicSectionsCellTappedCallback: CellTapCallback<S>?
    // A block to call when a cell is dequeued in a dynamic section.
    var dynamicSectionsCellDequeuedCallback: CellDequeueCallback<S>?
    
    // A fallback block to call when a cell is tapped whose section wasn't given a unique block.
    var anySectionCellTappedCallback: CellTapCallback<S>?
    // A fallback block to call when a cell is dequeued whose section wasn't given a unique block.
    var anySectionCellDequeuedCallback: CellDequeueCallback<S>?
}
