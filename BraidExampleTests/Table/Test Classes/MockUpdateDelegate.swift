import Braid

class MockUpdateDelegate: TableViewUpdateDelegate {
    var onUpdate: ((CollectionUpdate) -> Void)?
    
    func animate(updates: CollectionUpdate, on tableView: UITableView) {
        tableView.performBatchUpdates({
            tableView.deleteRows(at: updates.itemDeletions, with: .none)
            tableView.insertRows(at: updates.itemInsertions, with: .none)
            updates.itemMoves.forEach { tableView.moveRow(at: $0.from, to: $0.to) }
            tableView.deleteSections(updates.sectionDeletions, with: .none)
            tableView.insertSections(updates.sectionInsertions, with: .none)
            updates.sectionMoves.forEach { tableView.moveSection($0.from, toSection: $0.to) }
            
            tableView.reloadRows(at: updates.itemUpdates, with: .none)
            tableView.reloadSections(updates.sectionUpdates, with: .none)
            tableView.reloadSections(updates.sectionHeaderFooterUpdates, with: .none)
            tableView.reloadSections(updates.undiffableSectionUpdates, with: .none)
        }, completion: nil)

        self.onUpdate?(updates)
    }
}
