import UIKit
import Differ
#if RX_TABLEAU
import RxSwift
#endif

/**
 A protocol describing an enum whose cases or a struct whose instances correspond to sections in a table view.
*/
public protocol TableViewSection: Hashable, Identifiable { }

public extension TableViewSection {
    public var id: String {
        return String(self.hashValue)
    }
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
        self._sectionBinder = SectionedTableViewBinder(tableView: tableView, sectionedBy: _SingleSection.self, displayedSections: [.table])
    }
    
    /// Starts binding on the table.
    public func onTable() -> TableViewInitialSingleSectionBinder<_SingleSection> {
        self._sectionBinder.nextDataModel.uniquelyBoundSections.append(.table)
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
 binder.finish()
 ```
 
 `UITableViewCell`s need to conform to a few different protocols (whose conformance can be as simple as declaring
 conformance) to be compatible with a data binder. Specifically, they must at least conform to `ReuseIdentifiable` and
 `ViewModelBindable`, and should conform to `UINibInitable` if they are meant to be created from a Nib.
 */
public class SectionedTableViewBinder<S: TableViewSection>: SectionedTableViewBinderProtocol {
    /// The table view's displayed sections. This array can be changed or reordered at any time to dynamically update
    /// the displayed sections on the table view. Setting this property queues a table view animation.
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
    
    /// The animation the binder will use to animate row deletions. The default value is `automatic`.
    public var rowDeletionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate row insertions. The default value is `automatic`.
    public var rowInsertionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section deletions. The default value is `automatic`.
    public var sectionDeletionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section insertions. The default value is `automatic`.
    public var sectionInsertionAnimation: UITableView.RowAnimation = .automatic

#if RX_TABLEAU
    let disposeBag = DisposeBag()
    let displayedSectionsSubject = BehaviorSubject<[S]>(value: [])
#endif

    private var tableViewDataSourceDelegate: (UITableViewDataSource & UITableViewDelegate)?
    
    // Blocks to call to dequeue a cell in a section.
    var sectionCellDequeueBlocks: [S: CellDequeueBlock<S>] = [:]
    // Blocks to call to get the height for a cell in a section.
    var sectionCellHeightBlocks: [S: CellHeightBlock] = [:]
    // Blocks to call to get the estimated height for a cell in a section.
    var sectionEstimatedCellHeightBlocks: [S: CellHeightBlock] = [:]
    // A block to call to dequeue a cell in for an unspecified section.
    var cellDequeueBlock: CellDequeueBlock<S>?
    // A block to call to get the height for a cell in an unspecified section.
    var cellHeightBlock: CellHeightBlock?
    // A block to call to get the estimated height for a cell in an unspecified section.
    var estimatedCellHeightBlock: CellHeightBlock?
    
    // Blocks to call to dequeue a header in a section.
    var sectionHeaderDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // Blocks to call to get the height for a section header.
    var sectionHeaderHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    // Blocks to call to get the estimated height for a section header.
    var sectionHeaderEstimatedHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    // A block to call to dequeue a header in an unspecified section.
    var headerDequeueBlock: HeaderFooterDequeueBlock?
    // A block to call to get the height for a section header in an unspecified section.
    var headerHeightBlock: HeaderFooterHeightBlock?
    // A block to call to get the estimated height for a section header in an unspecified section.
    var headerEstimatedHeightBlock: HeaderFooterHeightBlock?
    
    // Blocks to call to dequeue a footer in a section.
    var sectionFooterDequeueBlocks: [S: HeaderFooterDequeueBlock] = [:]
    // Blocks to call to get the height for a section footer.
    var sectionFooterHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    // Blocks to call to get the estimated height for a section footer.
    var sectionFooterEstimatedHeightBlocks: [S: HeaderFooterHeightBlock] = [:]
    // A block to call to dequeue a footer in an unspecified section.
    var footerDequeueBlock: HeaderFooterDequeueBlock?
    // A block to call to get the height for a section footer in an unspecified section.
    var footerHeightBlock: HeaderFooterHeightBlock?
    // A block to call to get the estimated height for a section footer in an unspecified section.
    var footerEstimatedHeightBlock: HeaderFooterHeightBlock?
    
    // Blocks to call when a cell is tapped in a section.
    var sectionCellTappedCallbacks: [S: CellTapCallback<S>] = [:]
    // Callback blocks to call when a cell is dequeued in a section.
    var sectionCellDequeuedCallbacks: [S: CellDequeueCallback<S>] = [:]
    // A block to call when a cell is tapped in an unspecified section.
    var cellTappedCallback: CellTapCallback<S>?
    // A callback block to call when a cell is dequeued in an unspecified section.
    var cellDequeuedCallback: CellDequeueCallback<S>?
    
    // The data model currently shown by the table view.
    private(set) var currentDataModel = TableViewDataModel<S>()
    // The next data model to be shown by the table view. When this model's properties are updated, the binder will
    // queue appropriate animations on the table view to be done on the next render frame.
    private(set) var nextDataModel = TableViewDataModel<S>()
    
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
     Begins a binding chain whose handlers are used to provide information for the given section.
     
     This method is used to begin a binding chain. It does so by returning a 'section binder' - an object that exposes
     methods like `bind(cellType:models:)` or `onTapped(_:)` - that will, using the section given to this method, bind
     various handlers to events involving the section. This method must be called before the binder's `finish` method
     is called, and a reference to the given 'section binder' object should not be kept.
     
     - parameter section: The section to begin binding handlers to.
     - returns: A 'section binder' object used to begin binding handlers to the given section.
     */
    public func onSection(_ section: S) -> TableViewInitialSingleSectionBinder<S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        self.nextDataModel.uniquelyBoundSections.append(section)
        return TableViewInitialSingleSectionBinder<S>(binder: self, section: section)
    }
    
    /**
     Begins a binding chain whose handlers are used to provide information for the given sections.
     
     This method is used to begin a binding chain. It does so by returning a 'section binder' - an object that exposes
     methods like `bind(cellType:models:)` or `onTapped(_:)` - that will, using the sections given to this method, bind
     various handlers to events involving the sections. This method must be called before the binder's `finish` method
     is called, and a reference to the given 'section binder' object should not be kept.
     
     - parameter section: An array of sections to begin binding common handlers to.
     - returns: A 'mulit-section binder' object used to begin binding handlers to the given sections.
     */
    public func onSections(_ sections: [S]) -> TableViewInitialMutliSectionBinder<S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        guard sections.isEmpty == false else {
            fatalError("The given 'sections' array to begin a binding chain was empty.")
        }
        self.nextDataModel.uniquelyBoundSections.append(contentsOf: sections)
        
        return TableViewInitialMutliSectionBinder<S>(binder: self, sections: sections)
    }
    
    /**
     Begins a binding chain whose handlers are used to provide information for all current and future sections on the
     table.
     
     This method is used to begin a binding chain. It does so by returning a 'section binder' - an object that exposes
     methods like `bind(cellType:models:)` or `onTapped(_:)` - that will bind various handlers to events involving all
     sections on the table. This method must be called before the binder's `finish` method is called, and a reference to
     the given 'section binder' object should not be kept.
     
     Note that this method can be used together with more specialized calls for specific sections with the binder's
     `onSections(_:)` and `onSection(_:)` methods. If these more specialized methods are called, data provided from
     those binding chains will be used instead of the data provided by this method, effectively acting as an 'override'
     for the specialized sections.
    */
    public func onAllSections() -> TableViewInitialMutliSectionBinder<S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        return TableViewInitialMutliSectionBinder<S>(binder: self, sections: nil)
    }
    
    /**
     Tells that binder that all setup binding has been completed.
     
     This method must be called once all binding of cell/view types and data observers have been completed on the table,
     after which point no further binding can be done on the table with the binder's `onSection` methods.
    */
    public func finish() {
        self.hasFinishedBinding = true
        
//        let rowHeightBound = !self.sectionCellHeightBlocks.isEmpty || self.cellHeightBlock != nil
//        let headerHeightBound = !self.sectionHeaderHeightBlocks.isEmpty || self.headerHeightBlock != nil
//        let footerHeightBound = !self.sectionFooterHeightBlocks.isEmpty || self.footerHeightBlock != nil
//        let rowEstimatedHeightBound = !self.sectionEstimatedCellHeightBlocks.isEmpty || self.estimatedCellHeightBlock != nil
//        let headerEstimatedHeightBound = !self.sectionHeaderEstimatedHeightBlocks.isEmpty || self.headerEstimatedHeightBlock != nil
//        let footerEstimatedHeightBound = !self.sectionFooterEstimatedHeightBlocks.isEmpty || self.footerEstimatedHeightBlock != nil
//
//        if rowHeightBound && headerHeightBound && footerHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RHF, Void>(binder: self)
//        } else if rowHeightBound && headerHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RH, Void>(binder: self)
//        } else if rowEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RF, Void>(binder: self)
//        } else if headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_HF, Void>(binder: self)
//        } else if rowEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_R, Void>(binder: self)
//        } else if headerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_H, Void>(binder: self)
//        } else if footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_F, Void>(binder: self)
//        }
//
//        else if rowHeightBound && headerHeightBound && footerHeightBound
//        && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RHF, EH_RHF>(binder: self)
//        } else if rowHeightBound && headerHeightBound
//        && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RH, EH_RHF>(binder: self)
//        } else if rowEstimatedHeightBound && footerEstimatedHeightBound
//        && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RF, EH_RHF>(binder: self)
//        } else if headerEstimatedHeightBound && footerEstimatedHeightBound
//        && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_HF, EH_RHF>(binder: self)
//        } else if rowEstimatedHeightBound
//        && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_R, EH_RHF>(binder: self)
//        } else if headerEstimatedHeightBound
//        && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_H, EH_RHF>(binder: self)
//        } else if footerEstimatedHeightBound
//        && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_F, EH_RHF>(binder: self)
//        }
//
//        else if rowHeightBound && headerHeightBound && footerHeightBound
//            && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RHF, EH_RHF>(binder: self)
//        } else if rowHeightBound && headerHeightBound
//            && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RH, EH_RHF>(binder: self)
//        } else if rowEstimatedHeightBound && footerEstimatedHeightBound
//            && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RF, EH_RHF>(binder: self)
//        } else if headerEstimatedHeightBound && footerEstimatedHeightBound
//            && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_HF, EH_RHF>(binder: self)
//        } else if rowEstimatedHeightBound
//            && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_R, EH_RHF>(binder: self)
//        } else if headerEstimatedHeightBound
//            && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_H, EH_RHF>(binder: self)
//        } else if footerEstimatedHeightBound
//            && rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_F, EH_RHF>(binder: self)
//        }
//
//        else if rowEstimatedHeightBound && headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_RHF>(binder: self)
//        } else if rowEstimatedHeightBound && headerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_RH>(binder: self)
//        } else if rowEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_RF>(binder: self)
//        } else if headerEstimatedHeightBound && footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_HF>(binder: self)
//        } else if rowEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_R>(binder: self)
//        } else if headerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_H>(binder: self)
//        } else if footerEstimatedHeightBound {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_F>(binder: self)
//        } else {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, Void>(binder: self)
//        }
        self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate(binder: self)
        
        self.createNextDataModel()
        self.tableView.delegate = self.tableViewDataSourceDelegate
        self.tableView.dataSource = self.tableViewDataSourceDelegate
        self.tableView.reloadData()
    }
    
    // Sets the current data model to the queued 'next' data model, and creates a new 'next' data model.
    private func createNextDataModel() {
        self.currentDataModel = self.nextDataModel
        self.currentDataModel.delegate = nil
        self.nextDataModel = TableViewDataModel<S>(from: self.currentDataModel)
        self.nextDataModel.delegate = self
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
    /*
     The binder is set as the delegate on its 'next' data model. When this next model receives a data update, this
     method is called. The binder responds by queueing an update for the next render frame (using `DispatchQueue.async`)
     to animate the changes. This allows data changes made in different expressions within the same frame (i.e. changes
     made in different lines of code) to be batched and animated together.
    */
    func dataModelDidChange() {
        guard self.hasFinishedBinding, !self.hasRefreshQueued else { return }
        
        self.hasRefreshQueued = true
        DispatchQueue.main.async {
            let current = self.currentDataModel.asSectionModels()
            let next = self.nextDataModel.asSectionModels()
            
            self.createNextDataModel()
            
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
public enum _SingleSection: TableViewSection, CaseIterable {
    case table
}

typealias CellDequeueBlock<S: TableViewSection> = (S, UITableView, IndexPath) -> UITableViewCell
typealias HeaderFooterDequeueBlock = (UITableView, Int) -> UITableViewHeaderFooterView?
typealias CellTapCallback<S: TableViewSection> = (S, Int, UITableViewCell) -> Void
typealias CellDequeueCallback<S: TableViewSection> = (S, Int, UITableViewCell) -> Void
typealias CellHeightBlock = (Int) -> CGFloat
typealias HeaderFooterHeightBlock = () -> CGFloat
