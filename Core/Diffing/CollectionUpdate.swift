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
    let itemDeletions: [IndexPath]
    /// The index paths of items that were inserted.
    let itemInsertions: [IndexPath]
    /// The index paths of items that were updates.
    let itemUpdates: [IndexPath]
    /// The index paths of items that were moved.
    let itemMoves: [(from: IndexPath, to: IndexPath)]
    /// The section integers of section that were deleted.
    let sectionDeletions: IndexSet
    /// The section integers of section that were inserted.
    let sectionInsertions: IndexSet
    /// The section integers of section that were updated.
    let sectionUpdates: IndexSet
    /// The section integers of section that were updated, but whose data was not 'diffable' at the item scope.
    let undiffableSectionUpdates: IndexSet
    /// The section integers whose header or footer were updated.
    let sectionHeaderFooterUpdates: IndexSet
    /// The section integers of sections that were moved.
    let sectionMoves: [(from: Int, to: Int)]
    
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
            case let .moveSection(move):
                sectionMoves.append((move.from, move.to))
            case let .updateSection(at):
                sectionUpdates.insert(at)
            case let .updateUndiffableSection(at):
                undiffableSectionUpdates.insert(at)
            case let .updateSectionHeaderFooter(at):
                sectionHeaderFooterUpdates.insert(at)
            }
        }
        
        self.itemInsertions = itemInsertions
        self.itemDeletions = itemDeletions
        self.itemUpdates = itemUpdates
        self.itemMoves = itemMoves
        self.sectionMoves = sectionMoves
        self.sectionInsertions = sectionInsertions
        self.sectionUpdates = sectionUpdates
        self.sectionDeletions = sectionDeletions
        self.undiffableSectionUpdates = undiffableSectionUpdates
        self.sectionHeaderFooterUpdates = sectionHeaderFooterUpdates
    }
}
