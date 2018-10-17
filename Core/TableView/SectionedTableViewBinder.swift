import UIKit
import Differ
#if RX_TABLEAU
import RxSwift
#endif

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
    public func onTable() -> TableViewInitialSingleSectionBinder<_SingleSection> {
        return TableViewInitialSingleSectionBinder<_SingleSection>(binder: self._sectionBinder, section: .table)
    }
    
    public func finish() {
        self._sectionBinder.finish()
    }
}

public protocol SectionedTableViewBinderProtocol: AnyObject {
    associatedtype S: TableViewSection
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
public class SectionedTableViewBinder<S: TableViewSection>: SectionedTableViewBinderProtocol {
    /// The table view's displayed sections. This array can be changed or reordered at any time to dynamically update
    /// the displayed sections on the table view.
    public var displayedSections: [S] = [] {
        didSet {
#if RX_TABLEAU
            self.displayedSectionsSubject.onNext(self.displayedSections)
#endif
            self.nextDataModel.displayedSections = self.displayedSections
        }
    }
    
    /// Whether this binder has had its binding completed by having its `finish()` method called.
    public private(set) var hasFinishedBinding: Bool = false
    /// The table view this binder performs binding for.
    public private(set) var tableView: UITableView!
    
    public var rowDeletionAnimation: UITableView.RowAnimation = .automatic
    public var rowInsertionAnimation: UITableView.RowAnimation = .automatic
    public var sectionDeletionAnimation: UITableView.RowAnimation = .automatic
    public var sectionInsertionAnimation: UITableView.RowAnimation = .automatic

#if RX_TABLEAU
    let disposeBag = DisposeBag()
    let displayedSectionsSubject = BehaviorSubject<[S]>(value: [])
#endif

    private var tableViewDataSourceDelegate: (UITableViewDataSource & UITableViewDelegate)?
    
    // Blocks to call to dequeue a cell in a section.
    var sectionCellDequeueBlocks: [S: CellDequeueBlock] = [:]
    // Blocks to call to get the height for a cell in a section.
    var sectionCellHeightBlocks: [S: CellHeightBlock] = [:]
    // Blocks to call to get the estimated height for a cell in a section.
    var sectionEstimatedCellHeightBlocks: [S: CellHeightBlock] = [:]
    
    // Blocks to call to dequeue a header in a section.
    var sectionHeaderDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // Blocks to call to get the height for a section header.
    var sectionHeaderHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    // Blocks to call to get the estimated height for a section header.
    var sectionHeaderEstimatedHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    
    // Blocks to call to dequeue a footer in a section.
    var sectionFooterDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // Blocks to call to get the height for a section footer.
    var sectionFooterHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    // Blocks to call to get the estimated height for a section footer.
    var sectionFooterEstimatedHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    
    // Blocks to call when a cell is tapped in a section.
    var sectionCellTappedCallbacks: [S: CellTapCallback] = [:]
    // Callback blocks to call when a cell is dequeued in a section.
    var sectionCellDequeuedCallbacks: [S: CellDequeueCallback] = [:]
    
    private(set) var currentDataModel = TableViewDataModel<S>()
    var nextDataModel = TableViewDataModel<S>()
    
    private var hasRefreshQueued: Bool = false
    
    /**
     Create a new table view binder to manage the given table view whose sections are described by cases of the given
     enum or instances of the given struct conforming to `TableViewSection`.
     - parameter tableView: The `UITableView` that this binder manages.
     - parameter sectionModel: The enum whose cases or struct whose instances uniquely identify sections on the table
        view. This type must conform to the `TableViewSection` protocol.
     - parameter displayedSections: The sections to initially display on the table view when it is first shown.
    */
    public init(tableView: UITableView, sectionedBy sectionModel: S.Type, displayedSections: [S]) {
        self.tableView = tableView
        self.displayedSections = displayedSections
        self.nextDataModel.displayedSections = displayedSections
#if RX_TABLEAU
        self.displayedSectionsSubject.onNext(self.displayedSections)
#endif
    }
    
    /**
     Reloads the specified section with the given animation.
     - parameter section: The section to reload.
     - parameter animation: The row animation to use to reload the section.
    */
    public func reload(section: S, withAnimation animation: UITableView.RowAnimation = .automatic) {
        guard self.hasFinishedBinding else { return }
        if let sectionToReloadIndex = self.displayedSections.index(of: section) {
            let startIndex = self.displayedSections.startIndex
            let sectionInt = startIndex.distance(to: sectionToReloadIndex)
            let indexSet: IndexSet = [sectionInt]
            self.tableView.reloadSections(indexSet, with: animation)
        }
    }
    
    /**
     Reloads the specified sections with the given animation.
     - parameter sections: An array specifying the sections to reload.
     - parameter animation: The row animation to use to reload the sections.
    */
    public func reload(sections: [S], withAnimation animation: UITableView.RowAnimation = .automatic) {
        guard self.hasFinishedBinding else { return }
        var indexSet: IndexSet = []
        for section in sections {
            if let sectionToReloadIndex = self.displayedSections.index(of: section) {
                let startIndex = self.displayedSections.startIndex
                let sectionInt = startIndex.distance(to: sectionToReloadIndex)
                indexSet.update(with: sectionInt)
            }
        }
        if !indexSet.isEmpty {
            self.tableView.reloadSections(indexSet, with: animation)
        }
    }

    /**
     Declares a section to begin binding handlers to.
     
     This method is used to begin a binding chain. It does so by returning a 'section binder' - an object that exposes
     methods like `bind(cellType:models:)` or `onTapped(_:)` - that will, using the section given to this method, bind
     various handlers to events involving the section.
     - parameter section: The section to begin binding handlers to.
     - returns: A 'section binder' object used to begin binding handlers to the given section.
     */
    public func onSection(_ section: S) -> TableViewInitialSingleSectionBinder<S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        return TableViewInitialSingleSectionBinder<S>(binder: self, section: section)
    }
    
    /**
     Declares multiple sections to begin binding shared handlers to.
     
     This method is used to begin a binding chain. It does so by returning a 'section binder' - an object that exposes
     methods like `bind(cellType:models:)` or `onTapped(_:)` - that will, using the sections given to this method, bind
     various handlers to events involving the sections.
     - parameter section: An array of sections to begin binding common handlers to.
     - returns: A 'mulit-section binder' object used to begin binding handlers to the given sections.
     */
    public func onSections(_ sections: [S]) -> TableViewInitialMutliSectionBinder<S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        return TableViewInitialMutliSectionBinder<S>(binder: self, sections: sections)
    }
    
    public func onAllSections() {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
    }
    
    public func finish() {
        self.hasFinishedBinding = true
        
        let rowEstimatedHeightBound = !self.sectionEstimatedCellHeightBlocks.isEmpty
        let headerEstimatedHeightBound = !self.sectionHeaderEstimatedHeightBlocks.isEmpty
        let footerEstimatedHeightBound = !self.sectionFooterEstimatedHeightBlocks.isEmpty
        
        if rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, EstimatedHeightOption_RowHeaderFooter>(binder: self)
        } else if rowEstimatedHeightBound && headerEstimatedHeightBound {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, EstimatedHeightOption_RowHeader>(binder: self)
        } else if rowEstimatedHeightBound && footerEstimatedHeightBound {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, EstimatedHeightOption_RowFooter>(binder: self)
        } else if headerEstimatedHeightBound && footerEstimatedHeightBound {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, EstimatedHeightOption_HeaderFooter>(binder: self)
        } else if rowEstimatedHeightBound {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, EstimatedHeightOption_Row>(binder: self)
        } else if headerEstimatedHeightBound {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, EstimatedHeightOption_Header>(binder: self)
        } else if footerEstimatedHeightBound {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, EstimatedHeightOption_Footer>(binder: self)
        } else {
            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void>(binder: self)
        }
        
        self.currentDataModel = self.nextDataModel
        self.currentDataModel.delegate = nil
        self.nextDataModel = TableViewDataModel<S>(from: self.currentDataModel)
        self.nextDataModel.delegate = self
        self.tableView.delegate = self.tableViewDataSourceDelegate
        self.tableView.dataSource = self.tableViewDataSourceDelegate
        self.tableView.reloadData()
    }
}

public extension SectionedTableViewBinder where S: CaseIterable {
    /**
     Create a new table view binder to manage the given table view whose sections are described by cases of the given
     enum. The table view will initially display all sections of the table view included in the given enum type.
     - parameter tableView: The `UITableView` that this binder manages.
     - parameter sectionModel: The enum whose cases uniquely identify sections on the table view. This enum must conform
        to the `TableViewSection` protocol.
     */
    public convenience init(tableView: UITableView, sectionedBy sectionEnum: S.Type) {
        var sections: [S] = []
        for `case` in S.allCases {
            sections.append(`case`)
        }
        self.init(tableView: tableView, sectionedBy: sectionEnum, displayedSections: sections)
    }
}

extension SectionedTableViewBinder: TableViewDataModelDelegate {
    func dataModelDidChange() {
        guard self.hasFinishedBinding, !self.hasRefreshQueued else { return }
        
        self.hasRefreshQueued = true
        DispatchQueue.main.async {
            let current = self.currentDataModel.asSectionModels()
            let next = self.nextDataModel.asSectionModels()
            
            self.currentDataModel = self.nextDataModel
            self.currentDataModel.delegate = nil
            self.nextDataModel = TableViewDataModel<S>(from: self.currentDataModel)
            self.nextDataModel.delegate = self
            
            self.tableView.animateRowAndSectionChanges(
                oldData: current,
                newData: next,
                isEqualSection: { $0.section == $1.section },
                isEqualElement: { $0.id == $1.id },
                rowDeletionAnimation: self.rowDeletionAnimation,
                rowInsertionAnimation: self.rowInsertionAnimation,
                sectionDeletionAnimation: self.sectionDeletionAnimation,
                sectionInsertionAnimation: self.sectionInsertionAnimation)
            
            self.hasRefreshQueued = false
        }
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
typealias HeaderFooterHeightBlock = () -> CGFloat
