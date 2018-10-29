import Differ

/**
 A protocol describing a model or view model type that can be uniquely identified in a data set.
 
 Tableau uses this protocol to uniquely identify models or view models to track these objects as they are added,
 deleted, or moved in the collections of data given to binder objects. This information is then used to create diffs
 that Tableau can then animate on table or collection views.
 
 The `id` property should uniquely identify an object, like a serial number on a product or license plate on a car, and
 should not change when the object is 'updated' (e.g. a car keeps the same license plate if its tires are changed or it
 is repainted). In other words, this `id` should identify an object's 'identity', not its 'equity'. Obeying this
 distinction allows Tableau to identify when a model has 'moved' in a dataset (it found its `id` in a position different
 than where it was before) versus when a model has 'updated' (its `id` is the same, just the other properties on the
 model have changed).
*/
public protocol CollectionIdentifiable {
    var id: String { get }
}

internal protocol TableViewDataModelDelegate: AnyObject {
    func dataModelDidChange()
}

/**
 An object representing the data state of a table view. The data in the table is 'identifiable', and can thus changes
 in the data can be diff'd and animated on the table view.
 */
internal class AnimatableTableViewDataModel<S: TableViewSection> {
    internal struct SectionModel: Equatable, Collection {
        typealias Index = Int
        
        let section: S
        let items: [CollectionIdentifiable]
        
        var startIndex: Int {
            return items.startIndex
        }
        
        var endIndex: Int {
            return items.endIndex
        }
        
        subscript(i: Int) -> CollectionIdentifiable {
            return items[i]
        }
        
        func index(after i: Int) -> Int {
            return items.index(after: i)
        }
        
        static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
            return lhs.section == rhs.section
        }
    }
    
    // The sections that were bound uniquely with either the `onSection` or `onSections` methods. This is used to
    // ensure that updates to data bound with `onAllSections` does not overwrite data for these sections.
    var uniquelyBoundSections: [S] = []
    
    // The displayed section on the table view.
    var displayedSections: [S] = [] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    // The view models for the cells for a section.
    var sectionCellViewModels: [S: [CollectionIdentifiable]] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The raw models for the cells for a section.
    var sectionCellModels: [S: [CollectionIdentifiable]] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The number of cells to create for a section when the user manages dequeueing themselves.
    var sectionNumberOfCells: [S: Int] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }

    // The view models for the headers for a section.
    var sectionHeaderViewModels: [S: CollectionIdentifiable] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }

    // The view models for the footers for a section.
    var sectionFooterViewModels: [S: CollectionIdentifiable] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    weak var delegate: TableViewDataModelDelegate?
    
    init() { }
    
    init(from other: AnimatableTableViewDataModel<S>) {
        self.uniquelyBoundSections = other.uniquelyBoundSections
        self.displayedSections = other.displayedSections
        self.sectionCellViewModels = other.sectionCellViewModels
        self.sectionCellModels = other.sectionCellModels
        self.sectionHeaderViewModels = other.sectionHeaderViewModels
        self.sectionHeaderTitles = other.sectionHeaderTitles
        self.sectionFooterViewModels = other.sectionFooterViewModels
        self.sectionFooterTitles = other.sectionFooterTitles
    }
    
    func asSectionModels() -> [SectionModel] {
        return self.displayedSections.map { (section) -> SectionModel in
            return SectionModel(section: section, items: self.sectionCellViewModels[section] ?? self.sectionCellModels[section] ?? [])
        }
    }

    func diff(from other: AnimatableTableViewDataModel<S>) -> NestedExtendedDiff {
        return self.asSectionModels().nestedExtendedDiff(to: other.asSectionModels(), isEqualElement: { $0.id == $1.id })
    }
}

/**
 An object representing the data state of a table view.
 */
internal class TableViewDataModel<S: TableViewSection> {
    // The sections that were bound uniquely with either the `onSection` or `onSections` methods. This is used to
    // ensure that updates to data bound with `onAllSections` does not overwrite data for these sections.
    var uniquelyBoundSections: [S] = []
    
    // The displayed section on the table view.
    var displayedSections: [S] = [] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    // The view models for the cells for a section.
    var sectionCellViewModels: [S: [Any]] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The raw models for the cells for a section.
    var sectionCellModels: [S: [Any]] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The number of cells to create for a section when the user manages dequeueing themselves.
    var sectionNumberOfCells: [S: Int] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    // The view models for the headers for a section.
    var sectionHeaderViewModels: [S: Any] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    // The view models for the footers for a section.
    var sectionFooterViewModels: [S: Any] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    weak var delegate: TableViewDataModelDelegate?
    
    init() { }
    
    init(from other: TableViewDataModel<S>) {
        self.uniquelyBoundSections = other.uniquelyBoundSections
        self.displayedSections = other.displayedSections
        self.sectionCellViewModels = other.sectionCellViewModels
        self.sectionCellModels = other.sectionCellModels
        self.sectionHeaderViewModels = other.sectionHeaderViewModels
        self.sectionHeaderTitles = other.sectionHeaderTitles
        self.sectionFooterViewModels = other.sectionFooterViewModels
        self.sectionFooterTitles = other.sectionFooterTitles
    }
}
