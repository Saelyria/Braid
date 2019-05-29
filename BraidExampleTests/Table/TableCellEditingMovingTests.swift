import UIKit
@testable import Braid
import Nimble
import RxSwift

/// Cell binding test for cell insertion, deletion, and moving
class TableCellEditingMovingTests: TableTestCase {
    enum Section: TableViewSection {
        case first
        case second
        case third
        case fourth
    }
    
    var binder: SectionedTableViewBinder<Section>!
    var updateDelegate: MockUpdateDelegate!
    
    let initialFirstSectionModels: [TestModel] = [
        TestModel(0, "1-0")]
    let initialSecondThirdSectionModels: [Section: [TestModel]] = [
        .second: [
            TestModel(1, "2-0"),
            TestModel(2, "2-1")],
        .third: [
            TestModel(3, "3-0"),
            TestModel(4, "3-1"),
            TestModel(5, "3-2")]]
    let initialFourthSectionModels: [Section: [TestModel]] = [
        .fourth: [
            TestModel(6, "4-0"),
            TestModel(7, "4-1"),
            TestModel(8, "4-2"),
            TestModel(9, "4-3")]]
    
    override func setUp() {
        super.setUp()
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.updateDelegate = MockUpdateDelegate()
        self.binder.updateDelegate = self.updateDelegate
        self.binder.setupForTesting()
    }
    
    func testAllowMovingAppliesToCellsProperly() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [UITableViewCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: self.initialFirstSectionModels)
            .onDequeue { row, cell, model in
                dequeuedCells[.first]?.insert(cell, at: row)
                models[.first]?.insert(model, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: self.initialSecondThirdSectionModels)
            .allowMoving(.toSectionsIn([.second, .third]))
            .onDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: self.initialFourthSectionModels)
            .onDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
            }
        
        self.binder.finish()
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(1))
        expect(dequeuedCells[.second]?.count).toEventually(equal(2))
        expect(dequeuedCells[.third]?.count).toEventually(equal(3))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(4))
        
        expect(dequeuedCells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.third]?[safe: 0]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.third]?[safe: 1]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.third]?[safe: 2]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[7]))
        expect(dequeuedCells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[8]))
        expect(dequeuedCells[.fourth]?[safe: 3]).toEventually(be(self.tableView.visibleCells[9]))
        
        expect(dequeuedCells[.first]?[safe: 0]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.second]?[safe: 0]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.second]?[safe: 1]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.third]?[safe: 0]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.third]?[safe: 1]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.third]?[safe: 2]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.fourth]?[safe: 0]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.fourth]?[safe: 1]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.fourth]?[safe: 2]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.fourth]?[safe: 3]?.showsReorderControl).toEventually(equal(false))
        
        self.tableView.setEditing(true, animated: false)
        
        expect(dequeuedCells[.first]?[safe: 0]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.second]?[safe: 0]?.showsReorderControl).toEventually(equal(true))
        expect(dequeuedCells[.second]?[safe: 1]?.showsReorderControl).toEventually(equal(true))
        expect(dequeuedCells[.third]?[safe: 0]?.showsReorderControl).toEventually(equal(true))
        expect(dequeuedCells[.third]?[safe: 1]?.showsReorderControl).toEventually(equal(true))
        expect(dequeuedCells[.third]?[safe: 2]?.showsReorderControl).toEventually(equal(true))
        expect(dequeuedCells[.fourth]?[safe: 0]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.fourth]?[safe: 1]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.fourth]?[safe: 2]?.showsReorderControl).toEventually(equal(false))
        expect(dequeuedCells[.fourth]?[safe: 3]?.showsReorderControl).toEventually(equal(false))
    }
}
