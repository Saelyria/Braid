import UIKit
import Differ
#if RX_TABLEAU
import RxSwift
#endif

/**
 A protocol describing an enum whose cases or a struct whose instances correspond to sections in a table view.
*/
public protocol TableViewSection: Hashable { }

public extension TableViewSection {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public extension TableViewSection where Self: CollectionIdentifiable {
    public var hashValue: Int {
        return self.collectionId.hashValue
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
        self._sectionBinder = SectionedTableViewBinder(tableView: tableView, sectionedBy: _SingleSection.self)
        self._sectionBinder.displayedSections = [.table]
    }
    
    /// Starts binding on the table.
    public func onTable() -> TableViewSingleSectionBinder<UITableViewCell, _SingleSection> {
        self._sectionBinder.nextDataModel.uniquelyBoundSections.append(.table)
        return TableViewSingleSectionBinder<UITableViewCell, _SingleSection>(
            binder: self._sectionBinder, section: .table)
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
 conformance) to be compatible with a data binder. Specifically, they must at least conform to `ReuseIdentifiable`, and
 should conform to `UINibInitable` if they are meant to be created from a Nib.
 */
public class SectionedTableViewBinder<S: TableViewSection>: SectionedTableViewBinderProtocol {
    /// A behaviour detailing how sections on the managed table view are displayed in terms of order and visibility.
    public struct SectionDisplayBehavior {
        internal enum _Behavior {
            case hidesSectionsWithNoCellData
            case hidesSectionsWithNoData
            case manuallyManaged
        }
        
        /// The table binder will automatically hide sections when there are no cell items for it regardless of whether
        /// a header/footer is bound for the section. The associated value for this behavior is a function that, given
        /// the array of sections the binder has calculated will be shown, returns these sections in the correct order.
        public static func hidesSectionsWithNoCellData(orderingWith: @escaping ([S]) -> [S]) -> SectionDisplayBehavior {
            return SectionDisplayBehavior(behavior: .hidesSectionsWithNoCellData, orderingFunction: orderingWith)
        }
        /// The table binder will automatically hide sections when there are no cell and no header/footer items for it.
        /// This behavior means that a section will still be shown if it has a header or footer, even when it has no
        /// cells to show. The associated value for this behavior is a function that, given the array of sections the
        /// binder has calculated will be shown, returns these sections in the correct order.
        public static func hidesSectionsWithNoData(orderingWith: @escaping ([S]) -> [S]) -> SectionDisplayBehavior {
            return SectionDisplayBehavior(behavior: .hidesSectionsWithNoData, orderingFunction: orderingWith)
        }
        /// The table binder will only display sections manually set in its `displayedSections` property, in the order
        /// they appear in.
        public static var manuallyManaged: SectionDisplayBehavior {
            return SectionDisplayBehavior(behavior: .manuallyManaged, orderingFunction: nil)
        }
        
        internal let behavior: _Behavior
        internal let orderingFunction: (([S]) -> [S])?
    }
    
    /// The table view's displayed sections. This array can be changed or reordered at any time to dynamically update
    /// the displayed sections on the table view. Setting this property queues a table view animation.
    public var displayedSections: [S] {
        get {
            return self.currentDataModel.displayedSections
        }
        set {
            switch self.sectionDisplayBehavior.behavior {
            case .manuallyManaged: break
            default:
                print("WARNING: This table binder was setup to manage section visibility based on its data - ignoring attempt to set the 'displayedSections'.")
                return
            }
#if RX_TABLEAU
            self.displayedSectionsSubject.onNext(self.displayedSections)
#endif
            self.nextDataModel.displayedSections = newValue
        }
    }
    
    /// Whether this binder has had its binding completed by having its `finish()` method called.
    public private(set) var hasFinishedBinding: Bool = false
    /// The table view this binder performs binding for.
    public let tableView: UITableView
    
    /// The animation the binder will use to animate row deletions. The default value is `automatic`.
    public var rowDeletionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate row insertions. The default value is `automatic`.
    public var rowInsertionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section deletions. The default value is `automatic`.
    public var sectionDeletionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section insertions. The default value is `automatic`.
    public var sectionInsertionAnimation: UITableView.RowAnimation = .automatic
    
    /// A value indicating how this table view binder manages the visibility of sections bound to it.
    public var sectionDisplayBehavior: SectionDisplayBehavior {
        didSet {
            self.dataModelDidChange()
        }
    }
    
#if RX_TABLEAU
    let disposeBag = DisposeBag()
    let displayedSectionsSubject = BehaviorSubject<[S]>(value: [])
#endif

    private var tableViewDataSourceDelegate: (UITableViewDataSource & UITableViewDelegate)?
    
    private(set) var handlers = TableViewBindingHandlers<S>()
    
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
     - parameter sectionDisplayBehavior: An enum indicating how the binder should manage the order and visibility of
        sections. This defaults to `manuallyManageSections`, meaning the binder's `displayedSections` property must be
        set to determine the visibility and order of sections.
    */
    public init(tableView: UITableView,
                sectionedBy sectionModel: S.Type,
                sectionDisplayBehavior: SectionDisplayBehavior = .manuallyManaged)
    {
        self.tableView = tableView
        self.sectionDisplayBehavior = sectionDisplayBehavior
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
     Begins a binding chain whose handlers are used to provide data and respond to events for the given section.
     
     This method must be called before the binder's `finish` method is called, and a reference to the given 'section
     binder' object should not be kept.
     
     - parameter section: The section to begin binding handlers to.
     
     - returns: A 'section binder' object used to begin binding handlers to the given section.
     */
    public func onSection(_ section: S) -> TableViewSingleSectionBinder<UITableViewCell, S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        self.nextDataModel.uniquelyBoundSections.append(section)
        return TableViewSingleSectionBinder<UITableViewCell, S>(binder: self, section: section)
    }
    
    /**
     Begins a binding chain whose handlers are used to provide data and respond to events for the given sections.

     This method must be called before the binder's `finish` method is called, and a reference to the given 'section
     binder' object should not be kept.
     
     - parameter section: An array of sections to begin binding common handlers to.
     
     - returns: A 'multi-section binder' object used to begin binding handlers to the given sections.
     */
    public func onSections(_ sections: [S]) -> TableViewMutliSectionBinder<UITableViewCell, S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        guard sections.isEmpty == false else {
            fatalError("The given 'sections' array to begin a binding chain was empty.")
        }
        self.nextDataModel.uniquelyBoundSections.append(contentsOf: sections)
        
        return TableViewMutliSectionBinder<UITableViewCell, S>(binder: self, sections: sections)
    }

    /**
     Begins a binding chain to add simple data or callback handlers for any bound sections on the table.
     
     Binding chains started with this method cannot perform the core data binding for sections (like binding cells or
     section titles that are unique to certain sections). Instead, chains started by this method are used to add
     handlers that will be called for events in any section on the table, like 'on tapped'.
     
     - returns: A 'multi-section binder' object used to begin binding handlers to the given sections.
    */
    public func onAnySection() -> AnySectionBinder<S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        return AnySectionBinder<S>(binder: self)
    }
    
    /**
     Begins a binding chain whose handlers are used to provide information for all current and future sections on the
     table not bound uniquely.
     
     For sections the binder is setup with that were not 'uniquely' bound with the `onSection(_:)` or `onSections(_:)`
     methods, it will fall back on the data provided by this method to build them. This method is generally used when
     your sections are not necessarily known at compile-time (e.g. your sections are given to your table in a network
     respone).
     
     This method shares functionality with the `onAllOtherSections` method - the different naming allows you to more
     expressively describe your table binding according to your usage.
     
     - returns: A 'multi-section binder' object used to begin binding handlers to the given sections.
     */
    public func onAllSections() -> TableViewMutliSectionBinder<UITableViewCell, S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        return TableViewMutliSectionBinder<UITableViewCell, S>(binder: self, sections: nil)
    }
    
    /**
     Begins a binding chain whose handlers are used to provide information for all current and future sections on the
     table not bound uniquely.
     
     For sections the binder is setup with that were not 'uniquely' bound with the `onSection(_:)` or `onSections(_:)`
     methods, it will fall back on the data provided by this method to build them. This method is generally used when
     your sections are not necessarily known at compile-time (e.g. your sections are given to your table in a network
     respone).
     
     This method shares functionality with the `onAllSections` method - the different naming allows you to more
     expressively describe your table binding according to your usage.
     
     - returns: A 'multi-section binder' object used to begin binding handlers to the given sections.
     */
    public func onAllOtherSections() -> TableViewMutliSectionBinder<UITableViewCell, S> {
        return self.onAllSections()
    }
    
    /**
     Tells that binder that all setup binding has been completed.
     
     This method must be called once all binding of cell/view types and data observers have been completed on the table,
     after which point no further binding can be done on the table with the binder's `onSection` methods.
    */
    public func finish() {
        self.applyDisplayedSectionBehavior()
        self.hasFinishedBinding = true
        
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
    
    // Set section visibility/order according to the assigned 'section display behaviour' on the 'next data model'.
    private func applyDisplayedSectionBehavior() {
        switch self.sectionDisplayBehavior.behavior {
        case .hidesSectionsWithNoCellData:
            guard let orderingFunction = self.sectionDisplayBehavior.orderingFunction else {
                fatalError("A 'hides sections with no cell data' behaviour had no ordering function - something went awry!")
            }
            let sections = Array(self.nextDataModel.sectionsWithCellData)
            self.nextDataModel.displayedSections = orderingFunction(sections)
        case .hidesSectionsWithNoData:
            guard let orderingFunction = self.sectionDisplayBehavior.orderingFunction else {
                fatalError("A 'hides sections with no data' behaviour had no ordering function - something went awry!")
            }
            let sections = Array(self.nextDataModel.sectionsWithData)
            self.nextDataModel.displayedSections = orderingFunction(sections)
        default: break
        }
    }
}

public extension SectionedTableViewBinder.SectionDisplayBehavior where S: Comparable {
    /**
     The table binder will automatically hide sections when there are no cell items for it regardless of whether a
     header/footer is bound for the section. The sections will be sorted according to their `Comparable` conformance.
    */
    public static var hidesSectionsWithNoCellData: SectionedTableViewBinder.SectionDisplayBehavior {
        let orderingFunc = { (unordered: [S]) -> [S] in
            return unordered.sorted()
        }
        return SectionedTableViewBinder.SectionDisplayBehavior(
            behavior: .hidesSectionsWithNoCellData, orderingFunction: orderingFunc)
    }
    
    /**
     The table binder will automatically hide sections when there are no cell and no header/footer items for it. This
     behavior means that a section will still be shown if it has a header or footer, even when it has no cells to show.
     The sections will be sorted according to their `Comparable` conformance.
    */
    public static var hidesSectionsWithNoData: SectionedTableViewBinder.SectionDisplayBehavior {
        let orderingFunc = { (unordered: [S]) -> [S] in
            return unordered.sorted()
        }
        return SectionedTableViewBinder.SectionDisplayBehavior(
            behavior: .hidesSectionsWithNoData, orderingFunction: orderingFunc)
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
            self.applyDisplayedSectionBehavior()
            
            // If we were able to create 'diffable section models' from the data models (i.e. the cell models or view
            // models conformed to 'CollectionIdentifiable'), then animate the changes.
            if let current = self.currentDataModel.asDiffableSectionModels(),
            let next = self.nextDataModel.asDiffableSectionModels() {
                self.createNextDataModel()
                
                self.tableView.animateRowAndSectionChanges(
                    oldData: current,
                    newData: next,
                    isEqualSection: { $0.section == $1.section },
                    isEqualElement: { $0.collectionId == $1.collectionId },
                    rowDeletionAnimation: self.rowDeletionAnimation,
                    rowInsertionAnimation: self.rowInsertionAnimation,
                    sectionDeletionAnimation: self.sectionDeletionAnimation,
                    sectionInsertionAnimation: self.sectionInsertionAnimation)
            }
            // otherwise, just do a plain table view reload.
            else {
                self.createNextDataModel()
                self.tableView.reloadData()
            }
            
            self.hasRefreshQueued = false
        }
    }
}

/// An internal section enum used by a `TableViewBinder`.
public enum _SingleSection: TableViewSection, CaseIterable {
    case table
}
