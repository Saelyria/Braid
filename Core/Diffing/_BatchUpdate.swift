/*
 Forked from tonyarnold's 'Differ' library to add equality checking.
 
 https://github.com/tonyarnold/Differ
 */
import Foundation

struct BatchUpdate {
    struct MoveStep: Equatable {
        let from: IndexPath
        let to: IndexPath
    }
    
    let deletions: [IndexPath]
    let insertions: [IndexPath]
    let updates: [IndexPath]
    let moves: [MoveStep]
    
    init(diff: ExtendedDiff) {
        (deletions, insertions, updates, moves) = diff.reduce(([IndexPath](), [IndexPath](), [IndexPath](), [MoveStep]()), { (acc, element) in
            var (deletions, insertions, updates, moves) = acc
            switch element {
            case let .delete(at):
                deletions.append([0, at])
            case let .insert(at):
                insertions.append([0, at])
            case let .move(from, to):
                moves.append(MoveStep(from: [0, from], to: [0, to]))
            case let .update(at):
                updates.append([0, at])
            }
            return (deletions, insertions, updates, moves)
        })
    }
}

struct NestedBatchUpdate {
    let itemDeletions: [IndexPath]
    let itemInsertions: [IndexPath]
    let itemUpdates: [IndexPath]
    let itemMoves: [(from: IndexPath, to: IndexPath)]
    let sectionDeletions: IndexSet
    let sectionInsertions: IndexSet
    let sectionUpdates: IndexSet
    let undiffableSectionUpdates: IndexSet
    let sectionHeaderFooterUpdates: IndexSet
    let sectionMoves: [(from: Int, to: Int)]
    
    init(diff: NestedExtendedDiff) {
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
