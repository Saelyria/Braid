import UIKit
import RxSwift

/**
 A protocol describing an enum whose cases correspond to sections in a table view.
 */
public protocol TableViewSection: Hashable {
    static var allSections: [Self] { get }
}

/**
 An object that dequeues and binds data to cells in sections for a given table view.
 
 A table view data binder is setup with a given table view and an enum whose cases correspond to sections on the table
 view. This enum must conform to `TableViewSectionEnum`. After being created, each section of the table view has a cell
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
 
 let binder = SectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
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
public class SectionedTableViewBinder<S: TableViewSection> {
    /// The currently displayed sections of the table view. Updating the value of this will automatically cause the data
    /// binder to update its associated table view. Defaults to the section enum's `allSections` value if not set.
    public let displayedSections: Variable<[S]> = Variable<[S]>([])
    
    var tableView: UITableView!
    private var tableViewDataSourceDelegate: _TableViewDataSourceDelegate<S>!
    
    // Blocks to call to dequeue a cell in a section.
    var sectionCellDequeueBlocks: [S: CellDequeueBlock] = [:]
    // The view models for the cells for a section.
    var sectionCellViewModels: [S: [Any]] = [:]
    // The raw models for the cells for a section.
    var sectionCellModels: [S: [Any]] = [:]
    
    // Blocks to call to dequeue a header in a section.
    var sectionHeaderDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // The view models for the headers for a section.
    var sectionHeaderViewModels: [S: Any] = [:]
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:]
    
    // Blocks to call to dequeue a footer in a section.
    var sectionFooterDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // The view models for the footers for a section.
    var sectionFooterViewModels: [S: Any] = [:]
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:]
    
    // Blocks to call when a cell is tapped in a section.
    var sectionCellTappedCallbacks: [S: CellTapCallback] = [:]
    // Callback blocks to call when a cell is dequeued in a section.
    var sectionCellDequeuedCallbacks: [S: CellDequeueCallback] = [:]
    // Blocks to call to get the height for a cell in a section.
    var sectionCellHeightBlocks: [S: CellHeightBlock] = [:]
    // Blocks to call to get the estimated height for a cell in a section.
    var sectionEstimatedCellHeightBlocks: [S: CellHeightBlock] = [:]
    

    
    let disposeBag: DisposeBag = DisposeBag()
    
    /**
     Create a new table view data binder with the given table view whose sections are defined by the given section enum.
     The table view will initially display all sections in the given section enum.
     */
    public required init(tableView: UITableView, sectionedBy sectionEnum: S.Type) {
        self.tableView = tableView
        self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate(binder: self)
        tableView.delegate = self.tableViewDataSourceDelegate
        tableView.dataSource = self.tableViewDataSourceDelegate
        
        self.displayedSections.value = S.allSections
        
        let sections: Observable<[S]> = self.displayedSections.asObservable()
        Observable.zip(sections.skip(1), sections) { ($0, $1) }
            .subscribe(onNext: { [weak self] (previousDisplayedSections, newDisplayedSections) in
                self?.tableView.reloadData() //TODO: reload affected sections
            }).disposed(by: self.disposeBag)
    }
    
    /**
     Create a new table view data binder with the given table view whose sections are defined by the given section enum.
     The table view will initially display only the sections contained in the given array.
     */
    public convenience init(tableView: UITableView, sectionedBy sectionEnum: S.Type, initialDisplayedSections: [S]) {
        self.init(tableView: tableView, sectionedBy: sectionEnum)
        self.displayedSections.value = initialDisplayedSections
    }
    
    /**
     Declares the section to begin binding handlers to.
     */
    public func onSection(_ section: S) -> SingleSectionTableViewBindResult<UITableViewCell, S> {
        return SingleSectionTableViewBindResult<UITableViewCell, S>(binder: self, section: section)
    }

    /**
     Declares the sections to begin binding handlers to.
     */
    public func onSections(_ sections: [S]) -> MultiSectionTableViewBindResult<UITableViewCell, S> {
        return MultiSectionTableViewBindResult<UITableViewCell, S>(binder: self, sections: sections)
    }
    
    /// Reloads the specified section.
    public func reload(section: S) {
        if let sectionToReloadIndex = self.displayedSections.value.index(of: section) {
            let startIndex = self.displayedSections.value.startIndex
            let sectionInt = startIndex.distance(to: sectionToReloadIndex)
            let indexSet: IndexSet = [sectionInt]
            self.tableView.reloadSections(indexSet, with: .none)
        } else {
            self.tableView.reloadData()
        }
    }
}

/// An internal section enum used by a `TableViewBinder`.
public enum _SingleSection: TableViewSection {
    case table
    
    public static let allSections: [_SingleSection] = [.table]
}

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
        self._sectionBinder = SectionedTableViewBinder(tableView: tableView, sectionedBy: _SingleSection.self)
    }
    
    /// Starts binding on the table.
    public func onTable() -> SingleSectionTableViewBindResult<UITableViewCell, _SingleSection> {
        return SingleSectionTableViewBindResult(binder: self._sectionBinder, section: .table)
    }
}


typealias CellDequeueBlock = (UITableView, IndexPath) -> UITableViewCell
typealias HeaderFooterDequeueBlock = (UITableView, Int) -> UITableViewHeaderFooterView?
typealias CellTapCallback = (Int, UITableViewCell) -> Void
typealias CellDequeueCallback = (Int, UITableViewCell) -> Void
typealias CellHeightBlock = (Int) -> CGFloat
