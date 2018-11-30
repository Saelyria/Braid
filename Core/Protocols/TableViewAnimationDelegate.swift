import UIKit

/**
 An object that will update a table view on behalf of a table view binder.
 
 Whenever a table view binder detects changes to its data, it will internally create a 'diff' object that represents
 these changes (i.e. insertions, deletions, moves, and updates). A 'table view update delegate' is given this diff
 by a section binder, which is expected to then apply the updates to the table view.
 */
public protocol TableViewUpdateDelegate {
    func animate(updates: CollectionUpdate, on tableView: UITableView)
}
