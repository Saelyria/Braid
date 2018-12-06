import UIKit

/**
 An object that will update a table view on behalf of a table view binder.
 
 Whenever a table view binder detects changes to its data, it will internally create a 'diff' object that represents
 these changes (i.e. insertions, deletions, moves, and updates). A 'table view update delegate' is given this diff
 by a section binder, which is expected to then apply the updates to the table view.
 
 Use of an 'update delegate' instead of using the built-in automatic updating allows more fine-grained control over
 things like the animations used for the various rows/sections (or if anything is animated at all).
 */
public protocol TableViewUpdateDelegate: AnyObject {
    /**
     Asks the update delegate to apply the given updates to the given table view.
     
     - parameter updates: An object indicating the index paths of updates items/sections.
     - parameter tableView: The table view that the updates should be animated on.
    */
    func animate(updates: CollectionUpdate, on tableView: UITableView)
}
