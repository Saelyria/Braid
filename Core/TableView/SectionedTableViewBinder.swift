import UIKit

/**
 A protocol describing an enum whose cases or a struct whose instances correspond to sections in a table view.
 */
public protocol TableViewSection: Hashable { }

/**
 An object that dequeues and binds data to cells in sections for a given table view.
 
 A table view data binder is setup with a given table view to manage. After being created, the table view has a cell
 type and observable models bound to it via the `bind(cellType:models:)` method. This method should be called shortly
 after the data binder and table view are setup (likely in `viewDidLoad`).
 
 Model objects passed into the `bind` method are RxSwift `Observable`s, to which the data binder will subscribe and
 automatically refresh the section with the updated data. Being a simple `Observable`, this data source can be a
 `Variable` array on the view controller, or can even be the `Observable` result of a network call. Every time the data
 source observable updates, the data binder will use the `count` of the data source's array to dequeue cells of
 `cellType` and bind the data to the cells.
 
 Using a table view binder is done with chaining function calls. A typical setup would look something like this:
 
 ```
 var cellModels: Observable<[MyCellModel]>
 
 let binder = TableViewBinder(tableView: tableView)
 binder.onTable()
    .bind(cellType: MyCell.self, models: cellModels)
    .onDequeue { [unowned self] (row: Int, cell: MyCell) in
        // called when a cell in section `one` is dequeued
    }
    .onTapped { [unowned self] (row: Int, cell: MyCell) in
        // called when a cell in section `one` is tapped
    }
 ```
 
 `UITableViewCell`s need to conform to a few different protocols (whose conformance can be as simple as declaring
 conformance) to be compatible with a data binder. Specifically, they must at least conform to `ReuseIdentifiable` and
 `ViewModelBindable`, and should conform to `UINibInitable` if they are meant to be created from a Nib.
 */
public class TableViewBinder {
    private let _sectionBinder: SectionedTableViewBinder<_SingleSection>
    
    /**
     Instantiate a new table view binder for the given table view.
     */
    public required init(tableView: UITableView) {
        self._sectionBinder = SectionedTableViewBinder(tableView: tableView, sectionedBy: _SingleSection.self, displayedSections: [.table])
    }
    
    /// Starts binding on the table.
    public func onTable() -> SingleSectionTableViewBindResult<UITableViewCell, _SingleSection> {
        return SingleSectionTableViewBindResult(binder: self._sectionBinder, section: .table)
    }
}


/**
 An object that dequeues and binds data to cells in sections for a given table view.
 
 A table view data binder is setup with a given table view and an enum whose cases correspond to sections on the table
 view. This enum must conform to `TableViewSection`. After being created, each section of the table view has a cell
 type and observable models bound to it via the `bind(cellType:models:)` method. This method should be called shortly
 after the data binder and table view are setup (likely in `viewDidLoad`) for each section of the table view.
 
 Model objects passed into the `bind` method are RxSwift `Observable`s, to which the data binder will subscribe and
 automatically refresh the section with the updated data. Being a simple `Observable`, this data source can be a
 `Variable` array on the view controller, or can even be the `Observable` result of a network call. Every time the data
 source observable updates, the data binder will use the `count` of the data source's array to dequeue cells of
 `cellType` for its section and bind the data to the cells.
 
 Using a table view binder is done with chaining function calls. A typical setup would look something like this:
 
 ```
 enum Section: TableViewSection {
    case one
    case two
    case three
 }
 
 var cellModels: Observable<[MyCellModel]>
 
 let binder = RxSectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
binder.onSection(.one)
    .bind(cellType: MyCell.self, models: cellModels)
    .onDequeue { [unowned self] (row: Int, cell: MyCell) in
        // called when a cell in section `one` is dequeued
    }
    .onTapped { [unowned self] (row: Int, cell: MyCell) in
        // called when a cell in section `one` is tapped
    }
 ```
 
 `UITableViewCell`s need to conform to a few different protocols (whose conformance can be as simple as declaring
 conformance) to be compatible with a data binder. Specifically, they must at least conform to `ReuseIdentifiable` and
 `ViewModelBindable`, and should conform to `UINibInitable` if they are meant to be created from a Nib.
 */
public class SectionedTableViewBinder<S: TableViewSection>: _BaseTableViewBinder<S> {
    /// The currently displayed sections of the table view. Updating the value of this will automatically cause the data
    /// binder to update its associated table view. Defaults to the section enum's `allSections` value if not set.
    public var displayedSections: [S] = [] {
        didSet {
            self._displayedSections = self.displayedSections
            // TODO: create diff and reload affected sections
            self.tableView.reloadData()
        }
    }
    
    var observationTokens: [NSKeyValueObservation] = []
    
    // TODO: this is currently not working; the casting of 'allCases' is weird
    //    public convenience init<S>(tableView: UITableView, sectionedBy sectionEnum: S.Type) where S: CaseIterable {
    //        self.init(tableView: tableView, sectionedBy: sectionEnum, displayedSections: S.allCases as! [S])
    //    }
    
    /**
     Create a new table view data binder with the given table view whose sections are defined by the given section enum.
     The table view will initially display the given array of sections.
     */
    public required init(tableView: UITableView, sectionedBy sectionEnum: S.Type, displayedSections: [S]) {
        super.init(tableView: tableView, sectionedBy: sectionEnum, displayedSections: displayedSections)
        self.displayedSections = displayedSections
    }
    
    /**
     Declares a section to begin binding handlers to.
     */
    public func onSection(_ section: S) -> SingleSectionTableViewBindResult<UITableViewCell, S> {
        return SingleSectionTableViewBindResult<UITableViewCell, S>(binder: self, section: section)
    }
    
    /**
     Declares sections to begin binding handlers to.
     */
    public func onSections(_ sections: [S]) -> MultiSectionTableViewBindResult<UITableViewCell, S> {
        return MultiSectionTableViewBindResult<UITableViewCell, S>(binder: self, sections: sections)
    }
}

/// An internal section enum used by a `TableViewBinder`.
public enum _SingleSection: TableViewSection {
    case table
}

typealias CellDequeueBlock = (UITableView, IndexPath) -> UITableViewCell
typealias HeaderFooterDequeueBlock = (UITableView, Int) -> UITableViewHeaderFooterView?
typealias CellTapCallback = (Int, UITableViewCell) -> Void
typealias CellDequeueCallback = (Int, UITableViewCell) -> Void
typealias CellHeightBlock = (Int) -> CGFloat
