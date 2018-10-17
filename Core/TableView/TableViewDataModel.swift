import Differ

public protocol Identifiable {
    var id: String { get }
}

extension String: Identifiable {
    public var id: String { return self }
}

internal protocol TableViewDataModelDelegate: AnyObject {
    func dataModelDidChange()
}

/**
 An object representing the data state of a table view.
 */
internal class TableViewDataModel<S: TableViewSection> {
    internal struct SectionModel: Equatable, Collection {
        typealias Index = Int
        
        let section: S
        let items: [Identifiable]
        
        var startIndex: Int {
            return items.startIndex
        }
        
        var endIndex: Int {
            return items.endIndex
        }
        
        subscript(i: Int) -> Identifiable {
            return items[i]
        }
        
        func index(after i: Int) -> Int {
            return items.index(after: i)
        }
        
        static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
            return lhs.section == rhs.section
        }
    }
    
    // The displayed section on the table view.
    var displayedSections: [S] = [] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    // The view models for the cells for a section.
    var sectionCellViewModels: [S: [Identifiable]] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // The raw models for the cells for a section.
    var sectionCellModels: [S: [Identifiable]] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }

    // The view models for the headers for a section.
    var sectionHeaderViewModels: [S: Identifiable] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }

    // The view models for the footers for a section.
    var sectionFooterViewModels: [S: Identifiable] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:] {
        didSet { self.delegate?.dataModelDidChange() }
    }
    
    weak var delegate: TableViewDataModelDelegate?
    
    init() { }
    
    init(from other: TableViewDataModel<S>) {
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

    func diff(from other: TableViewDataModel<S>) -> NestedExtendedDiff {
        return self.asSectionModels().nestedExtendedDiff(to: other.asSectionModels(), isEqualElement: { $0.id == $1.id })
    }
}
