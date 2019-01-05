internal protocol _TableViewDataModelDelegate: AnyObject {
    associatedtype S: TableViewSection
    
    func itemEqualityChecker(for section: S) -> ((Any, Any) -> Bool?)?
    func dataModelDidChange()
}

internal class _TableViewDataModel<S: TableViewSection> {
    enum CellDataType {
        case models
        case viewModels
        case modelsViewModels
        case number
    }
    
    weak var delegate: SectionedTableViewBinder<S>?
    
    // The sections that were bound uniquely with either the `onSection` or `onSections` methods. This is used to
    // ensure that updates to data bound with `onAllSections` does not overwrite data for these sections.
    var uniquelyBoundCellSections: [S] = []
    var uniquelyBoundHeaderSections: [S] = []
    var uniquelyBoundFooterSections: [S] = []
    
    var headerViewBound: Bool = false
    var footerViewBound: Bool = false
    var headerTitleBound: Bool = false
    var footerTitleBound: Bool = false
    
    // The displayed section on the table view.
    var displayedSections: [S] = [] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The type of data used for data for the cells for the given sections (models, view models, or raw number of cells)
    var sectionCellDataType: [S: CellDataType] = [:]
    // The number of cells to create for a section when the user manages dequeueing themselves.
    var sectionNumberOfCells: [S: Int] = [:] {
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
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }

    // Sections whose cell data was just updated. This is set by the binder.
    var cellUpdatedSections: Set<S> = []
    // Sections whose header/footer data was just updated. This is set by the binder.
    var headerFooterUpdatedSections: Set<S> = []
    
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
        self.uniquelyBoundCellSections = other.uniquelyBoundCellSections
        self.uniquelyBoundFooterSections = other.uniquelyBoundFooterSections
        self.uniquelyBoundHeaderSections = other.uniquelyBoundHeaderSections
        self.headerTitleBound = other.headerTitleBound
        self.headerViewBound = other.headerViewBound
        self.footerTitleBound = other.footerTitleBound
        self.footerViewBound = other.footerViewBound
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
    
    /**
     Maps the data model to an array of diffable section models that can be used with Differ to animate changes on the
     table view. Returns nil if the data is not diffable (i.e. one or more of its data arrays did not contain models
     that conformed to `CollectionIdentifiable`).
     */
    func asDiffableSectionModels() -> [SectionModel] {
        return self.displayedSections.map { (section) -> SectionModel in
            // get the 'items' (be it view models, models, or the number of cells) that are used for cells for the
            // section. Prefer whichever is diffable.
            var items: [Any]?
            
            if self.sectionCellDataType[section] == .viewModels
            || self.sectionCellDataType[section] == .modelsViewModels
            && !(self.sectionCellModels is [S: [CollectionIdentifiable]]),
            let identifiableVMs = self.sectionCellViewModels as? [S: [CollectionIdentifiable]] {
                items = identifiableVMs[section]
            }
            
            else if self.sectionCellDataType[section] == .models
            || self.sectionCellDataType[section] == .modelsViewModels,
            let identifiableMs = self.sectionCellModels as? [S: [CollectionIdentifiable]] {
                items = identifiableMs[section]
            }
            
            else if self.sectionCellDataType[section] == .number, let numCells = self.sectionNumberOfCells[section] {
                // make an array of empty data for its count
                for _ in 0..<numCells {
                    items?.append(0)
                }
            }
            
            else {
                items = self.sectionCellViewModels[section] ?? self.sectionCellModels[section]
            }
            
            return SectionModel(
                section: section,
                items: items ?? [],
                itemEqualityChecker: self.delegate?.itemEqualityChecker(for: section))
        }
    }
    
    /**
     Creates a Differ 'nested extended diff' object from this data model and the 'other' given model. Returns nil if the
     data is not diffable (i.e. one or more of its data arrays did not contain models that conformed to
     `CollectionIdentifiable`).
     */
    func diff(from other: _TableViewDataModel<S>) -> _NestedExtendedDiff? {
        let selfSectionModels = self.asDiffableSectionModels()
        let otherSectionModels = other.asDiffableSectionModels()
        guard var diff = try? selfSectionModels.nestedExtendedDiff(
            to: otherSectionModels,
            isSameSection: { $0.section == $1.section },
            isSameElement: { _lhs, _rhs in
                if let lhs = _lhs as? CollectionIdentifiable, let rhs = _rhs as? CollectionIdentifiable {
                    return lhs.collectionId == rhs.collectionId
                }
                return nil
            },
            isEqualElement: { sectionModel, lhs, rhs in
                return sectionModel.itemEqualityChecker?(lhs, rhs)
        }) else {
            return nil
        }
        
        // Reload sections whose header or footer were updated
        for section in other.headerFooterUpdatedSections.filter({ !other.cellUpdatedSections.contains($0) }) {
            guard let i = other.displayedSections.firstIndex(of: section) else { continue }
            diff.elements.append(.updateSectionHeaderFooter(i))
        }
        
        // Reload sections that were updated whose items weren't equatable
        for section in other.cellUpdatedSections.filter({ other.delegate?.itemEqualityChecker(for: $0) == nil }) {
            guard let i = other.displayedSections.firstIndex(of: section) else { continue }
            diff.elements.append(.updateUndiffableSection(i))
            
            // For undiffable sections, perform inserts/deletes on the end of the section if the counts are different
            if let lhs = selfSectionModels.first(where: { $0.section == section }),
            let rhs = otherSectionModels.first(where: { $0.section == section }) {
                if lhs.items.count < rhs.items.count {
                    let difference = rhs.items.count - lhs.items.count
                    for at in rhs.items.count - difference..<rhs.items.count {
                        diff.elements.append(.insertElement(at, section: i))
                    }
                } else if lhs.items.count > rhs.items.count {
                    let difference = lhs.items.count - rhs.items.count
                    for at in lhs.items.count - difference..<lhs.items.count {
                        diff.elements.append(.deleteElement(at, section: i))
                    }
                }
            }
        }
        
        return diff
    }
}
