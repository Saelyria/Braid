internal protocol _TableViewDataModelDelegate: AnyObject {
    associatedtype S: TableViewSection
    
    func itemEqualityChecker(for section: S) -> ((Any, Any) -> Bool?)?
    func dataModelDidChange()
}

internal class _TableViewDataModel<S: TableViewSection> {
    weak var delegate: SectionedTableViewBinder<S>?
    
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
    
    init(from other: _TableViewDataModel<S>) {
        self.delegate = other.delegate
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

extension _TableViewDataModel {
    internal class SectionModel: Collection {
        typealias Index = Int
        
        let section: S
        let items: [Any]
        let itemEqualityChecker: ((Any, Any) -> Bool?)?
        
        init(section: S, items: [Any], itemEqualityChecker: ((Any, Any) -> Bool?)?) {
            self.section = section
            self.items = items
            self.itemEqualityChecker = itemEqualityChecker
        }
        
        var startIndex: Int {
            return items.startIndex
        }
        
        var endIndex: Int {
            return items.endIndex
        }
        
        subscript(i: Int) -> Any {
            return items[i]
        }
        
        func index(after i: Int) -> Int {
            return items.index(after: i)
        }
    }
    
    internal class DiffableSectionModel: SectionModel {
        let identifiableItems: [CollectionIdentifiable]
        
        init(section: S, items: [CollectionIdentifiable], itemEqualityChecker: ((Any, Any) -> Bool?)?) {
            self.identifiableItems = items
            super.init(section: section, items: items, itemEqualityChecker: itemEqualityChecker)
        }
    }
    
    /**
     Maps the data model to an array of diffable section models that can be used with Differ to animate changes on the
     table view. Returns nil if the data is not diffable (i.e. one or more of its data arrays did not contain models
     that conformed to `CollectionIdentifiable`).
     */
    func asDiffableSectionModels() -> [SectionModel] {
        return self.displayedSections.map { (section) -> SectionModel in
            var identifiableItems: [CollectionIdentifiable]?
            if let identifiableVMs = self.sectionCellViewModels as? [S: [CollectionIdentifiable]] {
                identifiableItems = identifiableVMs[section]
            } else if let identifiableMs = self.sectionCellModels as? [S: [CollectionIdentifiable]] {
                identifiableItems = identifiableMs[section]
            } else if self.sectionCellViewModels.isEmpty && self.sectionCellModels.isEmpty {
                identifiableItems = []
            }
            
            if let items = identifiableItems {
                return DiffableSectionModel(
                    section: section,
                    items: items,
                    itemEqualityChecker: self.delegate?.itemEqualityChecker(for: section))
            } else {
                let items: [Any] = self.sectionCellViewModels[section] ?? self.sectionCellModels[section] ?? []
                return SectionModel(
                    section: section,
                    items: items,
                    itemEqualityChecker: self.delegate?.itemEqualityChecker(for: section))
            }
        }
    }
    
    /**
     Creates a Differ 'nested extended diff' object from this data model and the 'other' given model. Returns nil if the
     data is not diffable (i.e. one or more of its data arrays did not contain models that conformed to
     `CollectionIdentifiable`).
     */
    func diff(from other: _TableViewDataModel<S>) -> NestedExtendedDiff? {
        let selfSectionModels = self.asDiffableSectionModels()
        let otherSectionModels = other.asDiffableSectionModels()
        return try? selfSectionModels.nestedExtendedDiff(
            to: otherSectionModels,
            isSameSection: { $0.section == $1.section },
            isSameElement: { _lhs, _rhs in
                if let lhs = _lhs as? CollectionIdentifiable, let rhs = _rhs as? CollectionIdentifiable {
                    return lhs.collectionId == rhs.collectionId
                }
                return false
            },
            isEqualElement: { sectionModel, lhs, rhs in
                return other.delegate?.itemEqualityChecker(for: sectionModel.section)?(lhs, rhs)
            })
    }
}
