import XCTest
@testable import Braid
import Nimble

class TableDimensionTests: TableTestCase {
    enum Section: TableViewSection {
        case first
        case second
        case third
    }
    
    private var binder: SectionedTableViewBinder<Section>!

    override func setUp() {
        super.setUp()
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
    }

    /*
     Test that the cell height given on a 'unique' binding chain (i.e. 'onSection' or 'onSections') is used for the cell
     heights in the bound sections.
    */
    func testCellHeightOnUniqueBindingChain() {
        self.binder.displayedSections = [.first, .second, .third]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: [1, 2, 3])
            .cellHeight { _, _ in 1 }
        
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: [
                .second: [1, 2],
                .third: [1]
            ])
            .cellHeight { _, _ in 2 }

                
        self.binder.finish()
        
        expect(self.tableView.visibleCells.count).toEventually(equal(6))
        
        expect(self.tableView.visibleCells[0].frame.height).toEventually(equal(1))
        expect(self.tableView.visibleCells[1].frame.height).toEventually(equal(1))
        expect(self.tableView.visibleCells[2].frame.height).toEventually(equal(1))
        
        expect(self.tableView.visibleCells[3].frame.height).toEventually(equal(2))
        expect(self.tableView.visibleCells[4].frame.height).toEventually(equal(2))
        
        expect(self.tableView.visibleCells[5].frame.height).toEventually(equal(2))
    }
}
