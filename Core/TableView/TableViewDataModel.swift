import Differ

public protocol Identifiable {
    var id: String { get }
}

/**
 An object representing the data state of a table view.
 */
internal class TableViewDataModel<S: TableViewSection>: Equatable {
    // The displayed section on the table view.
    var displayedSections: [S] = []
    
    // The view models for the cells for a section.
    var sectionCellViewModels: [S: [Identifiable]] = [:]
    // The raw models for the cells for a section.
    var sectionCellModels: [S: [Identifiable]] = [:]

    // The view models for the headers for a section.
    var sectionHeaderViewModels: [S: Identifiable] = [:]
    // Titles for the headers for a section.
    var sectionHeaderTitles: [S: String] = [:]

    // The view models for the footers for a section.
    var sectionFooterViewModels: [S: Identifiable] = [:]
    // Titles for the footers for a section.
    var sectionFooterTitles: [S: String] = [:]
    
    static func == (lhs: TableViewDataModel<S>, rhs: TableViewDataModel<S>) -> Bool {
        return false
    }
}
