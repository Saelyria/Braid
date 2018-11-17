struct NestedDiff: DiffProtocol {
    
    typealias Index = Int
    
    enum Element {
        case deleteSection(Int)
        case insertSection(Int)
        case updateSection(Int)
        case updateElement(Int, section: Int)
        case deleteElement(Int, section: Int)
        case insertElement(Int, section: Int)
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection. `i` must be less than `endIndex`.
    /// - Returns: The index value immediately after `i`.
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    /// An array of particular diff operations
    var elements: [Element]
    
    /// Initializes a new `NestedDiff` from a given array of diff operations.
    ///
    /// - Parameters:
    ///   - elements: an array of particular diff operations
    init(elements: [Element]) {
        self.elements = elements
    }
}

extension Collection
where Element: Collection {
    
    /// Creates a diff between the callee and `other` collection. It diffs elements two levels deep (therefore "nested")
    ///
    /// - Parameters:
    ///   - other: a collection to compare the calee to
    /// - Returns: a `NestedDiff` between the calee and `other` collection
    func nestedDiff(
        to: Self,
        isSameSection: EqualityChecker<Self>,
        isSameElement: NestedElementEqualityChecker<Self>
        ) -> NestedDiff {
        let diffTraces = outputDiffPathTraces(to: to, isSame: isSameSection)
        
        // Diff sections
        let sectionDiff = Diff(traces: diffTraces).map { element -> NestedDiff.Element in
            switch element {
            case let .delete(at):
                return .deleteSection(at)
            case let .insert(at):
                return .insertSection(at)
            case let .update(at):
                return .updateSection(at)
            }
        }
        
        // Diff matching sections (moves, deletions, insertions)
        let filterMatchPoints = { (trace: Trace) -> Bool in
            if case .matchPoint = trace.type() {
                return true
            }
            return false
        }
        
        // offset & section
        
        let matchingSectionTraces = diffTraces
            .filter(filterMatchPoints)
        
        let fromSections = matchingSectionTraces.map {
            itemOnStartIndex(advancedBy: $0.from.x)
        }
        
        let toSections = matchingSectionTraces.map {
            to.itemOnStartIndex(advancedBy: $0.from.y)
        }
        
        let elementDiff = zip(zip(fromSections, toSections), matchingSectionTraces)
            .flatMap { (args) -> [NestedDiff.Element] in
                let (sections, trace) = args
                return sections.0.diff(sections.1, isSame: isSameElement).map { diffElement -> NestedDiff.Element in
                    switch diffElement {
                    case let .delete(at):
                        return .deleteElement(at, section: trace.from.x)
                    case let .insert(at):
                        return .insertElement(at, section: trace.from.y)
                    case let .update(at):
                        return .updateElement(at, section: trace.from.y)
                    }
                }
        }
        
        return NestedDiff(elements: sectionDiff + elementDiff)
    }
}

extension NestedDiff.Element: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .deleteElement(row, section):
            return "DE(\(row),\(section))"
        case let .deleteSection(section):
            return "DS(\(section))"
        case let .insertElement(row, section):
            return "IE(\(row),\(section))"
        case let .insertSection(section):
            return "IS(\(section))"
        case let .updateSection(section):
            return "US(\(section))"
        case let .updateElement(row, section):
            return "UE(\(row),\(section))"
        }
    }
}

extension NestedDiff: ExpressibleByArrayLiteral {
    
    init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
}