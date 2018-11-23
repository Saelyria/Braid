/*
 Forked from tonyarnold's 'Differ' library to add equality checking.
 
 https://github.com/tonyarnold/Differ
 */

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
    
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    var elements: [Element]

    init(elements: [Element]) {
        self.elements = elements
    }
}

extension Collection where Index == Int, Element: Collection, Element.Index == Int {
    /**
     Creates a diff between the callee and `other` collection. It diffs elements two levels deep (therefore "nested")
    
     - parameters:
     - other: a collection to compare the callee to
     - isSameSection: a closure that determines whether the two section are meant to represent the same item (i.e.
        'identity')
     - isSameElement: a closure that determines whether the two items are meant to represent the same item (i.e.
        'identity')
     - isEqual: a closure that determines whether the two items (deemed to represent the same item) are 'equal' (i.e.
        whether the second instance of the item has any changes from the first that would warrant a cell update)
     - returns: a `NestedDiff` between the calee and `other` collection
    */
    func nestedDiff(
        to: Self,
        isSameSection: ComparisonHandler<Self>,
        isSameElement: NestedComparisonHandler<Self>,
        isEqualElement: NestedElementComparisonHandler<Self>)
        throws -> NestedDiff
    {
        let diffTraces = try outputDiffPathTraces(to: to, isSame: isSameSection)
        
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
        
        let elementDiff = try zip(zip(fromSections, toSections), matchingSectionTraces)
            .flatMap { (args) -> [NestedDiff.Element] in
                let (sections, trace) = args
                return try sections.0.diff(sections.1, isSame: isSameElement, isEqual: { lhs, rhs in
                    return isEqualElement(sections.0, lhs, rhs)
                }).map { diffElement -> NestedDiff.Element in
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
            return "DE(s:\(section),r:\(row))"
        case let .deleteSection(section):
            return "DS(s:\(section))"
        case let .insertElement(row, section):
            return "IE(s:\(section),r:\(row))"
        case let .insertSection(section):
            return "IS(s:\(section))"
        case let .updateSection(section):
            return "US(s:\(section))"
        case let .updateElement(row, section):
            return "UE(s:\(section),r:\(row))"
        }
    }
}

extension NestedDiff: ExpressibleByArrayLiteral {
    
    init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
}
