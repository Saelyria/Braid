import UIKit
#if RX_BRAID
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
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.collectionId)
    }
}

public extension TableViewSection where Self: RawRepresentable, Self.RawValue: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/**
 An object that dequeues and binds data to cells in sections for a given table view.
 
 A table view data binder is setup with a given table view to manage. After being created, the table view has a cell
 type and observable models bound to it via the `bind(cellType:models:)` method. This method should be called shortly
 after the data binder and table view are setup (likely in `viewDidLoad`).
 
 Using a table view binder is done with chaining function calls. A typical setup would look something like this:
 
 ```
 var cellModels: [MyModel] = ...
 
 let binder = TableViewBinder(tableView: tableView)
 binder.onTable()
    .bind(cellType: MyCell.self, models: cellModels)
    .onDequeue { [unowned self] (row: Int, cell: MyCell, model: MyModel) in
        // called when a cell in section `one` is dequeued
    }
    .onTapped { [unowned self] (row: Int, cell: MyCell, model: MyModel) in
        // called when a cell in section `one` is tapped
    }
 ```
 */
public class TableViewBinder {
    private let _sectionBinder: SectionedTableViewBinder<_SingleSection>
    
    /// Instantiate a new table view binder for the given table view.
    public required init(tableView: UITableView) {
        self._sectionBinder = SectionedTableViewBinder(tableView: tableView, sectionedBy: _SingleSection.self)
        self._sectionBinder.displayedSections = [.table]
    }
    
    /**
     Begins a binding chain whose handlers are used to provide data and respond to events for the whole table.
    
     This method must be called before the binder's `finish` method is called, and a reference to the given 'section
     binder' object should not be kept.
     
     - returns: A 'section binder' object used to begin binding handlers to the table.
    */
    public func onTable() -> TableViewSingleSectionBinder<UITableViewCell, _SingleSection> {
        return TableViewSingleSectionBinder<UITableViewCell, _SingleSection>(
            binder: self._sectionBinder, section: .table)
    }
    
    /**
     Has the binder call all bound model- or view model-providing closures bound to its sections and apply the new data
     to the table. This method does not need to be used for binders that use RxSwift.
     */
    public func refresh() {
        self._sectionBinder.refresh()
    }
    
    /**
     Tells that binder that all setup binding has been completed.
     
     This method must be called once all binding of cell/view types and data observers have been completed on the table,
     after which point no further binding can be done on the table with the binder's `onTable` methods.
     */
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
 
 var cellModels: [MyModel] = ...
 
 let binder = RxSectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
 binder.onSection(.one)
    .bind(cellType: MyCell.self, models: cellModels)
    .onDequeue { [unowned self] (row: Int, cell: MyCell, model: MyModel) in
        // called when a cell in section `one` is dequeued
    }
    .onTapped { [unowned self] (row: Int, cell: MyCell, model: MyModel) in
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
        
        /**
         The table binder will automatically hide sections when there are no cell items for it regardless of whether a
         header/footer is bound for the section. The associated value for this behavior is a function that, given the
         array of sections the binder has calculated will be shown, returns these sections in the correct order.
        */
        public static func hidesSectionsWithNoCellData(orderingWith: @escaping ([S]) -> [S]) -> SectionDisplayBehavior {
            return SectionDisplayBehavior(behavior: .hidesSectionsWithNoCellData, orderingFunction: orderingWith)
        }
        /**
         The table binder will automatically hide sections when there are no cell and no header/footer items for it.
         This behavior means that a section will still be shown if it has a header or footer, even when it has no cells
         to show. The associated value for this behavior is a function that, given the array of sections the binder has
         calculated will be shown, returns these sections in the correct order.
        */
        public static func hidesSectionsWithNoData(orderingWith: @escaping ([S]) -> [S]) -> SectionDisplayBehavior {
            return SectionDisplayBehavior(behavior: .hidesSectionsWithNoData, orderingFunction: orderingWith)
        }
        /**
         The table binder will only display sections manually set in its `displayedSections` property, in the order they
         appear there.
        */
        public static var manuallyManaged: SectionDisplayBehavior {
            return SectionDisplayBehavior(behavior: .manuallyManaged, orderingFunction: nil)
        }
        
        internal let behavior: _Behavior
        internal let orderingFunction: (([S]) -> [S])?
    }
    
    /// The table view's displayed sections. This array can be changed or reordered at any time to dynamically update
    /// the displayed sections on the table view if the section display behavior is set to 'manually managed'. Setting
    /// this property queues a table view animation.
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
#if RX_BRAID
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
    /// The animation the binder will use to animate row updates. The default value is `automatic`.
    public var rowUpdateAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section deletions. The default value is `automatic`.
    public var sectionDeletionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section updates. The default value is `automatic`.
    public var sectionUpdateAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section insertions. The default value is `automatic`.
    public var sectionInsertionAnimation: UITableView.RowAnimation = .automatic
    /// The animation the binder will use to animate section updates for sections whose items were 'undiffable' (i.e.
    /// did not conform to `CollectionIdentifiable` or `Equatable`). The default value is `fade`.
    public var undiffableSectionUpdateAnimation: UITableView.RowAnimation = .fade
    /// The animation the binder will use to animate section updates when the section's header or footer updates. The
    /// default value is `none`.
    public var sectionHeaderFooterUpdateAnimation: UITableView.RowAnimation = .none
    /// Whether the binder should animate changes in data on its table view. Defaults to `true`.
    public var animateChanges: Bool = true
    
    /// Whether the binder should automatically register cells and header/footer views bound to it when cell types are
    /// given. Defaults to `true`.
    public var automaticallyRegister: Bool = true
    
    /// An object that will perform table view animations on behalf of the table view binder.
    public weak var updateDelegate: TableViewUpdateDelegate?
    
    /// A value indicating how this table view binder manages the visibility of sections bound to it.
    public var sectionDisplayBehavior: SectionDisplayBehavior {
        didSet {
            self.dataModelDidChange()
        }
    }
    
    // we need to ensure that event emit handlers are called after table updates in case the cells are removed, so
    // have both made into operations that we can create dependencies between
    var tableUpdateOperation: Operation?
    var viewEventOperations: [Operation] = []
    
#if RX_BRAID
    let disposeBag = DisposeBag()
    let displayedSectionsSubject = BehaviorSubject<[S]>(value: [])
#endif

    private var tableViewDataSourceDelegate: (UITableViewDataSource & UITableViewDelegate)?
    
    private(set) var handlers = _TableViewBindingHandlers<S>()
    
    // The data model currently shown by the table view.
    private(set) var currentDataModel = _TableViewDataModel<S>()
    // The next data model to be shown by the table view. When this model's properties are updated, the binder will
    // queue appropriate animations on the table view to be done on the next render frame.
    private(set) var nextDataModel = _TableViewDataModel<S>()
    
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
    
    deinit {
        // clean up the 'view emit handlers' assigned to any view emittign cells on the table to avoid retain cycles
        for view in self.tableView.subviews {
            if let view = view as? AnyViewEventEmitting {
                view.eventEmitHandler = nil
            }
        }
    }
    
    /**
     Has the binder call all bound model- or view model-providing closures bound to its sections and apply the new data
     to the table. This method does not need to be used for binders that use RxSwift.
    */
    public func refresh() {
        for updater in self.handlers.modelUpdaters {
            updater()
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
        return TableViewSingleSectionBinder<UITableViewCell, S>(binder: self, section: section)
    }
    
    /**
     Begins a binding chain whose handlers are used to provide data and respond to events for the given sections.

     This method must be called before the binder's `finish` method is called, and a reference to the given 'section
     binder' object should not be kept.
     
     - parameter section: An array of sections to begin binding handlers to.
     
     - returns: A 'multi-section binder' object used to begin binding handlers to the given sections.
     */
    public func onSections(_ sections: S...) -> TableViewMultiSectionBinder<UITableViewCell, S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        guard sections.isEmpty == false else {
            fatalError("The given 'sections' array to begin a binding chain was empty.")
        }
        return TableViewMultiSectionBinder<UITableViewCell, S>(binder: self, sections: sections)
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
    public func onAllSections() -> TableViewMultiSectionBinder<UITableViewCell, S> {
        guard !self.hasFinishedBinding else {
            fatalError("This table view binder has finished binding - additional binding must occur before its `finish()` method is called.")
        }
        return TableViewMultiSectionBinder<UITableViewCell, S>(binder: self, sections: nil)
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
    public func onAllOtherSections() -> TableViewMultiSectionBinder<UITableViewCell, S> {
        return self.onAllSections()
    }
    
    /**
     Tells that binder that all setup binding has been completed.
     
     This method must be called once all binding of cell/view types and data observers have been completed on the table,
     after which point no further binding can be done on the table with the binder's `onSection` methods.
    */
    public func finish() {
        // make sure 'refresh' is always called first, especially before the 'data source delegate' is created
        self.refresh()
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
        self.nextDataModel = _TableViewDataModel<S>(from: self.currentDataModel)
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
    static var hidesSectionsWithNoCellData: SectionedTableViewBinder.SectionDisplayBehavior {
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
    static var hidesSectionsWithNoData: SectionedTableViewBinder.SectionDisplayBehavior {
        let orderingFunc = { (unordered: [S]) -> [S] in
            return unordered.sorted()
        }
        return SectionedTableViewBinder.SectionDisplayBehavior(
            behavior: .hidesSectionsWithNoData, orderingFunction: orderingFunc)
    }
}

extension SectionedTableViewBinder: _TableViewDataModelDelegate {
    func itemEqualityChecker(for section: S) -> ((Any, Any) -> Bool?)? {
        if self.nextDataModel.uniquelyBoundCellSections.contains(section) {
            return self.handlers.sectionItemEqualityCheckers[section]
        }
        return self.handlers.dynamicSectionItemEqualityChecker
    }
    
    /*
     The binder is set as the delegate on its 'next' data model. When this next model receives a data update, this
     method is called. The binder responds by queueing an update for the next render frame (using `DispatchQueue.async`)
     to animate the changes. This allows data changes made in different expressions within the same frame (i.e. changes
     made in different lines of code) to be batched and animated together.
    */
    func dataModelDidChange() {
        guard self.hasFinishedBinding, !self.hasRefreshQueued else { return }        

        self.hasRefreshQueued = true
        
        let tableUpdateOp = BlockOperation(block: { [weak self] in
            guard let self = self else { return }
            
            defer {
                self.tableUpdateOperation = nil
                self.hasRefreshQueued = false
            }
            
            self.applyDisplayedSectionBehavior()
            
            if !self.animateChanges {
                self.createNextDataModel()
                self.tableView.reloadData()
                return
            }
            
            let update: CollectionUpdate
            if let diff = self.currentDataModel.diff(from: self.nextDataModel) {
                self.createNextDataModel()
                update = CollectionUpdate(diff: diff)
            } else {
                self.createNextDataModel()
                let sections: IndexSet = IndexSet(self.currentDataModel.displayedSections.enumerated().map { i, _ in i })
                update = CollectionUpdate(undiffableSectionUpdates: sections)
            }

            if let delegate = self.updateDelegate {
                delegate.animate(updates: update, on: self.tableView)
            } else {
                if #available(iOS 11.0, *) {
                    self.tableView.performBatchUpdates({
                        self.tableView.deleteRows(at: update.itemDeletions, with: self.rowDeletionAnimation)
                        self.tableView.insertRows(at: update.itemInsertions, with: self.rowInsertionAnimation)
                        update.itemMoves.forEach { self.tableView.moveRow(at: $0.from, to: $0.to) }
                        self.tableView.deleteSections(update.sectionDeletions, with: self.sectionDeletionAnimation)
                        self.tableView.insertSections(update.sectionInsertions, with: self.sectionInsertionAnimation)
                        update.sectionMoves.forEach { self.tableView.moveSection($0.from, toSection: $0.to) }
                        
                        self.tableView.reloadRows(at: update.itemUpdates, with: self.rowUpdateAnimation)
                        self.tableView.reloadSections(update.sectionUpdates, with: self.sectionUpdateAnimation)
                        self.tableView.reloadSections(update.sectionHeaderFooterUpdates, with: self.sectionHeaderFooterUpdateAnimation)
                        self.tableView.reloadSections(update.undiffableSectionUpdates, with: self.undiffableSectionUpdateAnimation)
                    }, completion: nil)
                } else {
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: update.itemDeletions, with: self.rowDeletionAnimation)
                    self.tableView.insertRows(at: update.itemInsertions, with: self.rowInsertionAnimation)
                    update.itemMoves.forEach { self.tableView.moveRow(at: $0.from, to: $0.to) }
                    self.tableView.deleteSections(update.sectionDeletions, with: self.sectionDeletionAnimation)
                    self.tableView.insertSections(update.sectionInsertions, with: self.sectionInsertionAnimation)
                    update.sectionMoves.forEach { self.tableView.moveSection($0.from, toSection: $0.to) }
                    
                    self.tableView.reloadRows(at: update.itemUpdates, with: self.rowUpdateAnimation)
                    self.tableView.reloadSections(update.sectionUpdates, with: self.sectionUpdateAnimation)
                    self.tableView.reloadSections(update.sectionHeaderFooterUpdates, with: self.sectionHeaderFooterUpdateAnimation)
                    self.tableView.reloadSections(update.undiffableSectionUpdates, with: self.undiffableSectionUpdateAnimation)
                    self.tableView.endUpdates()
                }
            }
        })
        
        for eventOperation in self.viewEventOperations {
            if !eventOperation.dependencies.contains(tableUpdateOp) {
                eventOperation.addDependency(tableUpdateOp)
            }
        }
        self.tableUpdateOperation = tableUpdateOp
        OperationQueue.main.addOperation(tableUpdateOp)
    }
}

/// An internal section enum used by a `TableViewBinder`.
public enum _SingleSection: TableViewSection, CaseIterable {
    case table
}
