
internal protocol _TableViewDataModelDelegate: AnyObject {
    associatedtype S: TableViewSection
    
    func itemEqualityChecker(for section: S) -> ((Any, Any) -> Bool?)?
    func dataModelDidChange()
}

/// An object that holds all the data for a table view at a given moment. Diffs can be generated between data model
/// instances to animate table view changes.
internal class _TableViewDataModel<S: TableViewSection> {
    private(set) var sectionModels: [_TableViewSectionDataModel<S>] = [] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    /**
     Returns the section model for the given section. If one does not already exist, one will be created.
    */
    func sectionModel(for section: S) -> _TableViewSectionDataModel<S> {
        if let sectionModel = self.sectionModels.first(where: { $0.section == section }) {
            return sectionModel
        }
        let sectionModel = _TableViewSectionDataModel(section: section)
        sectionModel.onUpdate = { [weak self] in
            self?.delegate?.dataModelDidChange()
        }
        self.sectionModels.append(sectionModel)
        return sectionModel
    }
    
    /**
     Returns the item for the given row and section.
    */
    func item(inSection section: S, row: Int) -> _TableViewItemModel? {
        let model = self.sectionModels.first { $0.section == section }
        if model?.items.indices.contains(row) == true {
            return model?.items[row]
        } else {
            return nil
        }
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

    // Sections whose cell data was just updated. This is set by the binder.
    var cellUpdatedSections: Set<S> = []
    // Sections whose header/footer data was just updated. This is set by the binder.
    var headerFooterUpdatedSections: Set<S> = []
    
    // Returns a set containing all sections that have cell data bound.
    var sectionsWithCellData: Set<S> {
        return Set(self.sectionModels.filter { sectionModel -> Bool in
            return sectionModel.items.count > 0
        }.map { $0.section })
    }
    
    // Returns a set of sections that have any kind of data in them (cells, headers, or footers).
    var sectionsWithData: Set<S> {
        return Set(self.sectionModels.filter { sectionModel -> Bool in
            return sectionModel.items.count > 0
                || sectionModel.headerTitle != nil
                || sectionModel.headerViewModel != nil
                || sectionModel.footerTitle != nil
                || sectionModel.footerViewModel != nil
        }.map { $0.section })
    }
    
    init() { }
    
    init(from other: _TableViewDataModel<S>) {
        self.delegate = other.delegate
        self.headerTitleBound = other.headerTitleBound
        self.headerViewBound = other.headerViewBound
        self.footerTitleBound = other.footerTitleBound
        self.footerViewBound = other.footerViewBound
        self.displayedSections = other.displayedSections
        self.sectionModels = other.sectionModels.map { _TableViewSectionDataModel(from: $0) }
        for sectionModel in self.sectionModels {
            sectionModel.onUpdate = { [weak self] in
                self?.delegate?.dataModelDidChange()
            }
        }
    }
}

extension _TableViewDataModel {
    /**
     Creates a Differ 'nested extended diff' object from this data model and the 'other' given model. Returns nil if the
     data is not diffable (i.e. one or more of its data arrays did not contain models that conformed to
     `CollectionIdentifiable`).
     */
    func diff(from other: _TableViewDataModel<S>) -> _NestedExtendedDiff? {
        let selfSectionModels = self.displayedSections.map { self.sectionModel(for: $0) }
        let otherSectionModels = other.displayedSections.map { other.sectionModel(for: $0) }
        let binder = self.delegate ?? other.delegate
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
                // if the update behavior for the section was 'manually', return that there wasn't an equality checker -
                // we don't want to incur reloads for this update behavior
                if let updateBehavior = binder?.handlers.cellUpdateBehaviors.namedSection[sectionModel.section]
                ?? binder?.handlers.cellUpdateBehaviors.dynamicSections, updateBehavior == .manually {
                    return nil
                } else {
                    return binder?.itemEqualityChecker(for: sectionModel.section)?(lhs, rhs)
                }
        }) else {
            return nil
        }
        
        // Reload sections whose header or footer were updated
        for section in other.headerFooterUpdatedSections.filter({ !other.cellUpdatedSections.contains($0) }) {
            guard let i = other.displayedSections.firstIndex(of: section) else { continue }
            // If the section was deleted or inserted, don't add it to the sections to update
            guard diff.elements.filter({ element in
                switch element {
                case .deleteSection(let at), .insertSection(let at): return at == i
                default: return false
                }
            }).isEmpty else { continue }
            diff.elements.append(.updateSectionHeaderFooter(i))
        }
        
        // Reload sections that were updated whose items weren't equatable
        for section in other.cellUpdatedSections.filter({ other.delegate?.itemEqualityChecker(for: $0) == nil }) {
            guard let i = other.displayedSections.firstIndex(of: section) else { continue }
            // If the section was deleted or inserted, don't add it to the sections to update
            guard diff.elements.filter({ element in
                switch element {
                case .deleteSection(let at), .insertSection(let at): return at == i
                default: return false
                }
            }).isEmpty else { continue }
            
            if let updateBehavior = binder?.handlers.cellUpdateBehaviors.namedSection[section]
            ?? binder?.handlers.cellUpdateBehaviors.dynamicSections, updateBehavior == .manually {
                // do nothing - the chain declared that cells are updated manually, so don't force a section reload
            } else {
                diff.elements.append(.updateUndiffableSection(i))
            }
                
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

internal class _TableViewSectionDataModel<S: TableViewSection> {
    enum CellDataType {
        case models
        case viewModels
        case modelsViewModels
        case number
    }
    
    let section: S
    
    var headerTitle: String? {
        didSet { self.onUpdate?() }
    }
    var headerViewModel: Any? {
        didSet { self.onUpdate?() }
    }
    var items: [_TableViewItemModel] = [] {
        didSet { self.onUpdate?() }
    }
    var footerTitle: String? {
        didSet { self.onUpdate?() }
    }
    var footerViewModel: Any? {
        didSet { self.onUpdate?() }
    }
    
    var cellDataType: CellDataType = .models
    
    fileprivate var onUpdate: (() -> Void)?
    
    fileprivate init(section: S) {
        self.section = section
    }
    
    fileprivate init(from other: _TableViewSectionDataModel<S>) {
        self.section = other.section
        self.headerTitle = other.headerTitle
        self.headerViewModel = other.headerViewModel
        self.cellDataType = other.cellDataType
        self.items = other.items
        self.footerTitle = other.footerTitle
        self.footerViewModel = other.footerViewModel
    }
}

extension _TableViewSectionDataModel: Collection {
    typealias Index = Int

    subscript(i: Int) -> Any {
        let item = items[i]
        
        // get the 'items' (be it view models, models, or the number of cells) that are used for cells for the
        // section. Prefer whichever is diffable.
        if self.cellDataType == .viewModels
            || self.cellDataType == .modelsViewModels
            && !(item.model is CollectionIdentifiable),
            let viewModel = item.viewModel as? CollectionIdentifiable {
            return viewModel
        } else if self.cellDataType == .models
            || self.cellDataType == .modelsViewModels,
            let model = item.model as? CollectionIdentifiable {
            return model
        } else if self.cellDataType == .number {
            return item
        } else {
            return item.viewModel ?? item.model ?? item
        }
    }
    
    var startIndex: Int {
        return items.startIndex
    }
    
    var endIndex: Int {
        return items.endIndex
    }
    
    func index(after i: Int) -> Int {
        return items.index(after: i)
    }
}

internal struct _TableViewItemModel {
    var isNumberPlaceholder: Bool
    var model: Any?
    var viewModel: Any?
}

