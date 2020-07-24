/*
 Forked from tonyarnold's 'Differ' library to add equality checking.
 
 https://github.com/tonyarnold/Differ
 */
import Foundation

/**
 An object that details the section and item updates (insertions, moves, deletions, and updates) from a data update.
 */
public struct CollectionUpdate {
    /// The index paths of items that were deleted.
    public let itemDeletions: [IndexPath]
    /// The index paths of items that were inserted.
    public let itemInsertions: [IndexPath]
    /// The index paths of items that were updates.
    public let itemUpdates: [IndexPath]
    /// The index paths of items that were moved.
    public let itemMoves: [(from: IndexPath, to: IndexPath)]
    /// The section integers of section that were deleted.
    public let sectionDeletions: IndexSet
    /// The section integers of section that were inserted.
    public let sectionInsertions: IndexSet
    /// The section integers of section that were updated.
    public let sectionUpdates: IndexSet
    /// The section integers of section that were updated, but whose data was not 'diffable' at the item scope.
    public let undiffableSectionUpdates: IndexSet
    /// The section integers whose header or footer were updated.
    public let sectionHeaderFooterUpdates: IndexSet
    /// The section integers of sections that were moved.
    public let sectionMoves: [(from: Int, to: Int)]
    
    internal init(
        itemDeletions: [IndexPath] = [],
        itemInsertions: [IndexPath] = [],
        itemUpdates: [IndexPath] = [],
        itemMoves: [(from: IndexPath, to: IndexPath)] = [],
        sectionDeletions: IndexSet = [],
        sectionInsertions: IndexSet = [],
        sectionUpdates: IndexSet = [],
        undiffableSectionUpdates: IndexSet = [],
        sectionHeaderFooterUpdates: IndexSet = [],
        sectionMoves: [(from: Int, to: Int)] = [])
    {
        self.itemDeletions = itemDeletions
        self.itemInsertions = itemInsertions
        self.itemUpdates = itemUpdates
        self.itemMoves = itemMoves
        self.sectionDeletions = sectionDeletions
        self.sectionInsertions = sectionInsertions
        self.sectionUpdates = sectionUpdates
        self.undiffableSectionUpdates = undiffableSectionUpdates
        self.sectionHeaderFooterUpdates = sectionHeaderFooterUpdates
        self.sectionMoves = sectionMoves
    }
    
    internal init(diff: _NestedExtendedDiff) {
        var itemDeletions: [IndexPath] = []
        var itemInsertions: [IndexPath] = []
        var itemUpdates: [IndexPath] = []
        var itemMoves: [(IndexPath, IndexPath)] = []
        var sectionDeletions: IndexSet = []
        var sectionInsertions: IndexSet = []
        var sectionUpdates: IndexSet = []
        var undiffableSectionUpdates: IndexSet = []
        var sectionHeaderFooterUpdates: IndexSet = []
        var sectionMoves: [(from: Int, to: Int)] = []
        
        diff.forEach { element in
            switch element {
            case let .deleteElement(at, section):
                itemDeletions.append([section, at])
            case let .insertElement(at, section):
                itemInsertions.append([section, at])
            case let .moveElement(from, to):
                itemMoves.append(([from.section, from.item], [to.section, to.item]))
            case let .updateElement(at, section):
                itemUpdates.append([section, at])
            case let .deleteSection(at):
                sectionDeletions.insert(at)
            case let .insertSection(at):
                sectionInsertions.insert(at)
            case let .moveSection(from, to):
                sectionMoves.append((from, to))
            case let .updateSection(at):
                sectionUpdates.insert(at)
            case let .updateUndiffableSection(at):
                undiffableSectionUpdates.insert(at)
            case let .updateSectionHeaderFooter(at):
                sectionHeaderFooterUpdates.insert(at)
            }
        }
        
        self.init(
            itemDeletions: itemDeletions,
            itemInsertions: itemInsertions,
            itemUpdates: itemUpdates,
            itemMoves: itemMoves,
            sectionDeletions: sectionDeletions,
            sectionInsertions: sectionInsertions,
            sectionUpdates: sectionUpdates,
            undiffableSectionUpdates: undiffableSectionUpdates,
            sectionHeaderFooterUpdates: sectionHeaderFooterUpdates,
            sectionMoves: sectionMoves)
    }
}
