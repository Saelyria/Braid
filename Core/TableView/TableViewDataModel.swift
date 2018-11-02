import Differ

internal protocol TableViewDataModelDelegate: AnyObject {
    func dataModelDidChange()
}

internal class TableViewDataModel<S: TableViewSection> {
    weak var delegate: TableViewDataModelDelegate?
    
    // The sections that were bound uniquely with either the `onSection` or `onSections` methods. This is used to
    // ensure that updates to data bound with `onAllSections` does not overwrite data for these sections.
    var uniquelyBoundSections: [S] = []
    // The displayed section on the table view.
    var displayedSections: [S] = [] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The number of cells to create for a section when the user manages dequeueing themselves.
    var sectionNumberOfCells: [S: Int] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:] {
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
    // The view models for the headers for a section.
    var sectionHeaderViewModels: [S: Any] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The view models for the footers for a section.
    var sectionFooterViewModels: [S: Any] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    // Returns a set containing all sections that have cell data bound.
    var sectionsWithCellData: Set<S> {
        let numCells = Set(self.sectionNumberOfCells.filter { $0.value > 0 }.keys)
        let models = self.sectionCellModels.filter { !$0.value.isEmpty }.keys
        let viewModels = self.sectionCellViewModels.filter { !$0.value.isEmpty }.keys
        return numCells.union(models).union(viewModels)
    }
    
    // Returns a set of sections that have any kind of data in them (cells, headers, or footers).
    var sectionsWithData: Set<S> {
        let headerModels = self.sectionHeaderViewModels.keys
        let footerModels = self.sectionFooterViewModels.keys
        let headerTitles = self.sectionHeaderTitles.keys
        let footerTitles = self.sectionFooterTitles.keys
        return self.sectionsWithCellData.union(headerModels).union(footerModels).union(headerTitles).union(footerTitles)
    }
    
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

extension TableViewDataModel {
    internal struct DiffableSectionModel: Equatable, Collection {
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
        
        static func == (lhs: DiffableSectionModel, rhs: DiffableSectionModel) -> Bool {
            return lhs.section == rhs.section
        }
    }
    
    /**
     Maps the data model to an array of diffable section models that can be used with Differ to animate changes on the
     table view. Returns nil if the data is not diffable (i.e. one or more of its data arrays did not contain models
     that conformed to `CollectionIdentifiable`).
     */
    func asDiffableSectionModels() -> [DiffableSectionModel]? {
        return try? self.displayedSections.map { (section) throws -> DiffableSectionModel in
            var _identifiableItems: [CollectionIdentifiable]?
            if let identifiableVMs = self.sectionCellViewModels as? [S: [CollectionIdentifiable]] {
                _identifiableItems = identifiableVMs[section]
            } else if let identifiableMs = self.sectionCellModels as? [S: [CollectionIdentifiable]] {
                _identifiableItems = identifiableMs[section]
            } else if self.sectionCellViewModels.isEmpty && self.sectionCellModels.isEmpty {
                _identifiableItems = []
            }
            guard let identifiableItems = _identifiableItems else { throw NSError(domain: "", code: 0, userInfo: nil) }
            
            return DiffableSectionModel(section: section, items: identifiableItems)
        }
    }
    
    /**
     Creates a Differ 'nested extended diff' object from this data model and the 'other' given model. Returns nil if the
     data is not diffable (i.e. one or more of its data arrays did not contain  models that conformed to
     `CollectionIdentifiable`).
     */
    func diff(from other: TableViewDataModel<S>) -> NestedExtendedDiff? {
        guard let selfSectionModels = self.asDiffableSectionModels(), let otherSectionModels = other.asDiffableSectionModels() else {
            return nil
        }
        return selfSectionModels.nestedExtendedDiff(to: otherSectionModels, isEqualElement: { $0.collectionId == $1.collectionId })
    }
}
