import UIKit
@testable import Braid
import Nimble
import RxSwift

/// Cell binding test for non-RxSwift, non-updatable (i.e. not using closures) binding methods

class TableCellBindingMethodTests: TableTestCase {
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
    
    let updatedFirstSectionModels: [TestModel] = [
        TestModel(0, "1-0"),
        TestModel(10, "1-1")]
    let updatedSecondThirdSectionModels: [Section: [TestModel]] = [
        .second: [
            TestModel(1, "2-0"),
            TestModel(2, "2-1*")],
        .third: [
            TestModel(4, "3-1"),
            TestModel(5, "3-2")]]
    let updatedFourthSectionModels: [Section: [TestModel]] = [
        .fourth: [
            TestModel(7, "4-1*"),
            TestModel(8, "4-2"),
            TestModel(9, "4-0")]]
    
    override func setUp() {
        super.setUp()
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.updateDelegate = MockUpdateDelegate()
        self.binder.updateDelegate = self.updateDelegate
        self.binder.setupForTesting()
    }
    
    // MARK: -
    
    /*
     Test the 'cell type + model' binding chain method.
     */
    func testCellTypeModelBindingMethod() {
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

        
        // test that we got the right number of models
        expect(models.count).toEventually(equal(4))
        expect(models[.first]?.count).toEventually(equal(1))
        expect(models[.second]?.count).toEventually(equal(2))
        expect(models[.third]?.count).toEventually(equal(3))
        expect(models[.fourth]?.count).toEventually(equal(4))
        
        expect(models[.first]?[safe: 0]).toEventually(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).toEventually(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).toEventually(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).toEventually(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).toEventually(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).toEventually(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).toEventually(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).toEventually(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).toEventually(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).toEventually(equal(TestModel(9, "4-3")))
    }
    
    /*
     Test the 'cell type + view model' binding chain method.
     */
    func testCellTypeViewModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self,
                  viewModels: self.initialFirstSectionModels.map { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { row, cell in
                dequeuedCells[.first]?.insert(cell, at: row)
                viewModels[.first]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self,
                  viewModels: self.initialSecondThirdSectionModels.mapValues { $0.map { TestViewModelCell.ViewModel(id: $0.value) } })
            .onDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self,
                  viewModels: self.initialFourthSectionModels.mapValues { $0.map { TestViewModelCell.ViewModel(id: $0.value) } })
            .onDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
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
        
        // test that we got the right number of models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(1))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(4))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-0"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-1"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-0"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-0"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 3]??.id).toEventually(equal("4-3"))
    }
    
    /*
     Test the 'cell type + model + view model mapping' binding chain method.
     */
    func testCellTypeModelViewModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self,
                  models: self.initialFirstSectionModels,
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { row, cell, model in
                dequeuedCells[.first]?.insert(cell, at: row)
                models[.first]?.insert(model, at: row)
                viewModels[.first]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self,
                  models: self.initialSecondThirdSectionModels,
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self,
                  models: self.initialFourthSectionModels,
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
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
        
        
        // test that we got the right number of models
        expect(models.count).toEventually(equal(4))
        expect(models[.first]?.count).toEventually(equal(1))
        expect(models[.second]?.count).toEventually(equal(2))
        expect(models[.third]?.count).toEventually(equal(3))
        expect(models[.fourth]?.count).toEventually(equal(4))
        
        expect(models[.first]?[safe: 0]).toEventually(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).toEventually(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).toEventually(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).toEventually(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).toEventually(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).toEventually(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).toEventually(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).toEventually(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).toEventually(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).toEventually(equal(TestModel(9, "4-3")))
        
        // test that we got the right number of view models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(1))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(4))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-0"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-1"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-0"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-0"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 3]??.id).toEventually(equal("4-3"))
    }

    /*
     Test the 'cell provider + model' binding chain method.
     */
    func testCellProviderModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]

        self.binder.onSection(.first)
            .bind(
                cellProvider: { table, row, model in
                    models[.first]?.insert(model, at: row)
                    return table.dequeue(TestCell.self)
                }, models: self.initialFirstSectionModels)
            .onDequeue { row, cell, model in
                expect(model).to(equal(models[.first]?[row]))
                dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(
                cellProvider: { (table, section, row, model: TestModel) in
                    models[section]?.insert(model, at: row)
                    return table.dequeue(TestCell.self)
                }, models: self.initialSecondThirdSectionModels)
            .onDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(
                cellProvider: { (table, section, row, model: TestModel) in
                    models[section]?.insert(model, at: row)
                    return table.dequeue(TestCell.self)
                }, models: self.initialFourthSectionModels)
            .onDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
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
        
        
        // test that we got the right number of models
        expect(models.count).toEventually(equal(4))
        expect(models[.first]?.count).toEventually(equal(1))
        expect(models[.second]?.count).toEventually(equal(2))
        expect(models[.third]?.count).toEventually(equal(3))
        expect(models[.fourth]?.count).toEventually(equal(4))
        
        expect(models[.first]?[safe: 0]).toEventually(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).toEventually(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).toEventually(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).toEventually(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).toEventually(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).toEventually(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).toEventually(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).toEventually(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).toEventually(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).toEventually(equal(TestModel(9, "4-3")))
    }
    
    /*
     Test the 'cell provider + number of cells' binding chain method.
     */
    func testCellProviderBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellProvider: { table, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: 1)
            .onDequeue { row, cell in
                dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: [.second: 2, .third: 3])
            .onDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: [.fourth: 4])
            .onDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
            }
        
        self.binder.finish()
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(1))
        expect(dequeuedCells[.second]?.count).toEventually(equal(2))
        expect(dequeuedCells[.third]?.count).toEventually(equal(3))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(4))
        
        expect(dequeuedCells[.first]?[0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.second]?[0]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.second]?[1]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.third]?[0]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.third]?[1]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.third]?[2]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.fourth]?[0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.fourth]?[1]).toEventually(be(self.tableView.visibleCells[7]))
        expect(dequeuedCells[.fourth]?[2]).toEventually(be(self.tableView.visibleCells[8]))
        expect(dequeuedCells[.fourth]?[3]).toEventually(be(self.tableView.visibleCells[9]))
    }
    
    // MARK: -
    
    /*
     Test the 'cell type + model' binding chain method.
     */
    func testCellTypeModelClosureBindingMethod() {
        var updates: CollectionUpdate?
        self.updateDelegate?.onUpdate = { updates = $0 }
        
        var firstSectionModels = self.initialFirstSectionModels
        var secondThirdSectionModels = self.initialSecondThirdSectionModels
        var fourthSectionModels = self.initialFourthSectionModels
        
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: { firstSectionModels })
            .onDequeue { row, cell, model in
                cell.model = model
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: { secondThirdSectionModels })
            .onDequeue { section, row, cell, model in
                cell.model = model
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: { fourthSectionModels })
            .onDequeue { section, row, cell, model in
                cell.model = model
            }
        
        self.binder.onAnySection().cellHeight { _,_ in 2 }
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(1))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(3))
        expect(models[.fourth]?.count).to(equal(4))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).to(equal(TestModel(9, "4-3")))
        
        // update the models then refresh the table
        firstSectionModels = self.updatedFirstSectionModels
        secondThirdSectionModels = self.updatedSecondThirdSectionModels
        fourthSectionModels = self.updatedFourthSectionModels
        self.binder.refresh()
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(2))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(2))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(2))
        expect(models[.fourth]?.count).to(equal(3))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.first]?[safe: 1]).to(equal(TestModel(10, "1-1")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1*")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(7, "4-1*")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(9, "4-0")))
        
        expect(updates?.itemInsertions).to(contain(IndexPath(row: 1, section: 0)))
        expect(updates?.itemUpdates).to(contain(IndexPath(row: 1, section: 1)))
        expect(updates?.itemDeletions).to(contain(IndexPath(row: 0, section: 2)))
        expect(updates?.itemDeletions).to(contain(IndexPath(row: 0, section: 3)))
        expect(updates?.itemUpdates).to(contain(IndexPath(row: 1, section: 3)))
        expect(updates?.itemUpdates).to(contain(IndexPath(row: 3, section: 3)))
    }
    
    /*
     Test the 'cell type + view model' binding chain method.
     */
    func testCellTypeViewModelClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstViewModels: [TestViewModelCell.ViewModel] = self.initialFirstSectionModels.map { TestViewModelCell.ViewModel(id: $0.value) }
        var secondThirdViewModels: [Section: [TestViewModelCell.ViewModel]] = self.initialSecondThirdSectionModels.mapValues {
            $0.map { TestViewModelCell.ViewModel(id: $0.value) }
        }
        var fourthViewModels: [Section: [TestViewModelCell.ViewModel]] = self.initialFourthSectionModels.mapValues {
            $0.map { TestViewModelCell.ViewModel(id: $0.value) }
        }
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self, viewModels: { firstViewModels })
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self, viewModels: { secondThirdViewModels })
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self, viewModels: { fourthViewModels })
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).toEventually(equal(4))
        expect(cells[.first]?.count).toEventually(equal(1))
        expect(cells[.second]?.count).toEventually(equal(2))
        expect(cells[.third]?.count).toEventually(equal(3))
        expect(cells[.fourth]?.count).toEventually(equal(4))
        
        expect(cells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).toEventually(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).toEventually(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).toEventually(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).toEventually(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(1))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(4))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-0"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-1"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-0"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-0"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 3]??.id).toEventually(equal("4-3"))
        
        // update the models then refresh the table
        firstViewModels = self.updatedFirstSectionModels.map { TestViewModelCell.ViewModel(id: $0.value) }
        secondThirdViewModels = self.updatedSecondThirdSectionModels.mapValues {
            $0.map { TestViewModelCell.ViewModel(id: $0.value) }
        }
        fourthViewModels = self.updatedFourthSectionModels.mapValues {
            $0.map { TestViewModelCell.ViewModel(id: $0.value) }
        }
        self.binder.refresh()
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        expect(cells.count).toEventually(equal(4))
        expect(cells[.first]?.count).toEventually(equal(2))
        expect(cells[.second]?.count).toEventually(equal(2))
        expect(cells[.third]?.count).toEventually(equal(2))
        expect(cells[.fourth]?.count).toEventually(equal(3))
        
        expect(cells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).toEventually(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(3))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-0"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-1"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-1*"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1*"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-0"))
    }
    
    /*
     Test the 'cell type + model + view model mapping' binding chain method.
     */
    func testCellTypeModelViewModelClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstSectionModels = self.initialFirstSectionModels
        var secondThirdSectionModels = self.initialSecondThirdSectionModels
        var fourthSectionModels = self.initialFourthSectionModels
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self,
                  models: { firstSectionModels },
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { (_, cell, model) in
                cell.model = model
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self,
                  models: { secondThirdSectionModels },
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { (_, _, cell, model) in
                cell.model = model
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self,
                  models: { fourthSectionModels },
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { (_, _, cell, model) in
                cell.model = model
            }
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(1))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(3))
        expect(models[.fourth]?.count).to(equal(4))
        expect(viewModels.count).to(equal(4))
        expect(viewModels[.first]?.count).to(equal(1))
        expect(viewModels[.second]?.count).to(equal(2))
        expect(viewModels[.third]?.count).to(equal(3))
        expect(viewModels[.fourth]?.count).to(equal(4))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).to(equal(TestModel(9, "4-3")))
        expect(viewModels[.first]?[safe: 0]??.id).to(equal("1-0"))
        expect(viewModels[.second]?[safe: 0]??.id).to(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).to(equal("2-1"))
        expect(viewModels[.third]?[safe: 0]??.id).to(equal("3-0"))
        expect(viewModels[.third]?[safe: 1]??.id).to(equal("3-1"))
        expect(viewModels[.third]?[safe: 2]??.id).to(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).to(equal("4-0"))
        expect(viewModels[.fourth]?[safe: 1]??.id).to(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 2]??.id).to(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 3]??.id).to(equal("4-3"))
        
        // update the models then refresh the table
        firstSectionModels = self.updatedFirstSectionModels
        secondThirdSectionModels = self.updatedSecondThirdSectionModels
        fourthSectionModels = self.updatedFourthSectionModels
        self.binder.refresh()
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(2))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(2))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(2))
        expect(models[.fourth]?.count).to(equal(3))
        expect(viewModels.count).to(equal(4))
        expect(viewModels[.first]?.count).to(equal(2))
        expect(viewModels[.second]?.count).to(equal(2))
        expect(viewModels[.third]?.count).to(equal(2))
        expect(viewModels[.fourth]?.count).to(equal(3))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.first]?[safe: 1]).to(equal(TestModel(10, "1-1")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1*")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(7, "4-1*")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(9, "4-0")))
        expect(viewModels[.first]?[safe: 0]??.id).to(equal("1-0"))
        expect(viewModels[.first]?[safe: 1]??.id).to(equal("1-1"))
        expect(viewModels[.second]?[safe: 0]??.id).to(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).to(equal("2-1*"))
        expect(viewModels[.third]?[safe: 0]??.id).to(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).to(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).to(equal("4-1*"))
        expect(viewModels[.fourth]?[safe: 1]??.id).to(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 2]??.id).to(equal("4-0"))
    }
    
    /*
     Test the 'cell provider + model' binding chain method.
     */
    func testCellProviderModelClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstSectionModels = self.initialFirstSectionModels
        var secondThirdSectionModels = self.initialSecondThirdSectionModels
        var fourthSectionModels = self.initialFourthSectionModels
        
        self.binder.onSection(.first)
            .bind(
                cellProvider: { table, row, model in
                    let cell = table.dequeue(TestCell.self)
                    cell.model = model
                    return cell
                }, models: { firstSectionModels })
        
        self.binder.onSections(.second, .third)
            .bind(
                cellProvider: { (table, section, row, model) in
                    let cell = table.dequeue(TestCell.self)
                    cell.model = model
                    return cell
                }, models: { secondThirdSectionModels })
        
        self.binder.onAllOtherSections()
            .bind(
                cellProvider: { (table, section, row, model) in
                    let cell = table.dequeue(TestCell.self)
                    cell.model = model
                    return cell
            }, models: { fourthSectionModels })
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(1))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(3))
        expect(models[.fourth]?.count).to(equal(4))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).to(equal(TestModel(9, "4-3")))
        
        // update the models then refresh the table
        firstSectionModels = self.updatedFirstSectionModels
        secondThirdSectionModels = self.updatedSecondThirdSectionModels
        fourthSectionModels = self.updatedFourthSectionModels
        self.binder.refresh()
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(2))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(2))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(2))
        expect(models[.fourth]?.count).to(equal(3))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.first]?[safe: 1]).to(equal(TestModel(10, "1-1")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1*")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(7, "4-1*")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(9, "4-0")))
    }
    
    /*
     Test the 'cell provider + number of cells' binding chain method.
     */
    func testCellProviderClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstNum = 1
        var secondThirdNum: [Section: Int] = [.second: 2, .third: 3]
        var fourthNum: [Section: Int] = [.fourth: 4]
        
        self.binder.onSection(.first)
            .bind(cellProvider: { table, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: { firstNum })
        
        self.binder.onSections(.second, .third)
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: { secondThirdNum })
        
        self.binder.onAllOtherSections()
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: { fourthNum })
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        firstNum = 2
        secondThirdNum = [.second: 3, .third: 4]
        fourthNum = [.fourth: 3]
        self.binder.refresh()
        
        expect(self.tableView.visibleCells.count).toEventually(equal(12))
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(3))
        expect(cells[.third]?.count).to(equal(4))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.second]?[safe: 2]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.third]?[safe: 3]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[9]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[10]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[11]))
    }
    
    // MARK: -

    /*
     Test the 'cell type + model' binding chain method.
     */
    func testCellTypeModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[TestModel]> = BehaviorSubject(value: self.initialFirstSectionModels)
        let secondThirdModels: BehaviorSubject<[Section: [TestModel]]> = BehaviorSubject(value: self.initialSecondThirdSectionModels)
        let fourthModels: BehaviorSubject<[Section: [TestModel]]> = BehaviorSubject(value: self.initialFourthSectionModels)
        
        self.binder.onSection(.first)
            .rx.bind(cellType: TestCell.self, models: firstModels.asObservable())
            .onDequeue { row, cell, model in
                cell.model = model
            }
        
        self.binder.onSections(.second, .third)
            .rx.bind(cellType: TestCell.self, models: secondThirdModels)
            .onDequeue { section, row, cell, model in
                cell.model = model
            }
        
        self.binder.onAllOtherSections()
            .rx.bind(cellType: TestCell.self, models: fourthModels)
            .onDequeue { section, row, cell, model in
                cell.model = model
            }
        
        self.binder.onAnySection().cellHeight { _,_ in 2 }
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(1))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(3))
        expect(models[.fourth]?.count).to(equal(4))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).to(equal(TestModel(9, "4-3")))
        
        // update the models then refresh the table
        firstModels.on(.next(self.updatedFirstSectionModels))
        secondThirdModels.on(.next(self.updatedSecondThirdSectionModels))
        fourthModels.on(.next(self.updatedFourthSectionModels))
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(2))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(2))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(2))
        expect(models[.fourth]?.count).to(equal(3))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.first]?[safe: 1]).to(equal(TestModel(10, "1-1")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1*")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(7, "4-1*")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(9, "4-0")))
    }
    
    /*
     Test the 'cell type + view model' binding chain method.
     */
    func testCellTypeViewModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[TestViewModelCell.ViewModel]>
            = BehaviorSubject(value: self.initialFirstSectionModels.map { TestViewModelCell.ViewModel(id: $0.value) })
        let secondThirdModels: BehaviorSubject<[Section: [TestViewModelCell.ViewModel]]>
            = BehaviorSubject(value: self.initialSecondThirdSectionModels.mapValues {
                $0.map { TestViewModelCell.ViewModel(id: $0.value) }
            })
        let fourthModels: BehaviorSubject<[Section: [TestViewModelCell.ViewModel]]>
            = BehaviorSubject(value: self.initialFourthSectionModels.mapValues {
                $0.map { TestViewModelCell.ViewModel(id: $0.value) }
            })
        
        self.binder.onSection(.first)
            .rx.bind(cellType: TestViewModelCell.self, viewModels: firstModels)
        
        self.binder.onSections(.second, .third)
            .rx.bind(cellType: TestViewModelCell.self, viewModels: secondThirdModels)
        
        self.binder.onAllOtherSections()
            .rx.bind(cellType: TestViewModelCell.self, viewModels: fourthModels)
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).toEventually(equal(4))
        expect(cells[.first]?.count).toEventually(equal(1))
        expect(cells[.second]?.count).toEventually(equal(2))
        expect(cells[.third]?.count).toEventually(equal(3))
        expect(cells[.fourth]?.count).toEventually(equal(4))
        
        expect(cells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).toEventually(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).toEventually(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).toEventually(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).toEventually(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(1))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(4))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-0"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-1"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-0"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-0"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 3]??.id).toEventually(equal("4-3"))
        
        // update the models then refresh the table
        firstModels.on(.next(self.updatedFirstSectionModels.map { TestViewModelCell.ViewModel(id: $0.value) }))
        secondThirdModels.on(.next(self.updatedSecondThirdSectionModels.mapValues {
            $0.map { TestViewModelCell.ViewModel(id: $0.value) }
        }))
        fourthModels.on(.next(self.updatedFourthSectionModels.mapValues {
            $0.map { TestViewModelCell.ViewModel(id: $0.value) }
        }))
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        expect(cells.count).toEventually(equal(4))
        expect(cells[.first]?.count).toEventually(equal(2))
        expect(cells[.second]?.count).toEventually(equal(2))
        expect(cells[.third]?.count).toEventually(equal(2))
        expect(cells[.fourth]?.count).toEventually(equal(3))
        
        expect(cells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).toEventually(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(3))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-0"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-1"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-1*"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1*"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-0"))
    }
    
    /*
     Test the 'cell type + model + view model mapping' binding chain method.
     */
    func testCellTypeModelViewModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[TestModel]> = BehaviorSubject(value: self.initialFirstSectionModels)
        let secondThirdModels: BehaviorSubject<[Section: [TestModel]]>
            = BehaviorSubject(value: self.initialSecondThirdSectionModels)
        let fourthModels: BehaviorSubject<[Section: [TestModel]]>
            = BehaviorSubject(value: self.initialFourthSectionModels)
        
        self.binder.onSection(.first)
            .rx.bind(cellType: TestViewModelCell.self,
                     models: firstModels,
                     mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { row, cell, model in
                cell.model = model
            }
        
        self.binder.onSections(.second, .third)
            .rx.bind(cellType: TestViewModelCell.self,
                     models: secondThirdModels,
                     mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { section, row, cell, model in
                cell.model = model
            }
        
        self.binder.onAllOtherSections()
            .rx.bind(cellType: TestViewModelCell.self,
                     models: fourthModels,
                     mapToViewModels: { TestViewModelCell.ViewModel(id: $0.value) })
            .onDequeue { section, row, cell, model in
                cell.model = model
            }
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(1))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(3))
        expect(models[.fourth]?.count).to(equal(4))
        expect(viewModels.count).to(equal(4))
        expect(viewModels[.first]?.count).to(equal(1))
        expect(viewModels[.second]?.count).to(equal(2))
        expect(viewModels[.third]?.count).to(equal(3))
        expect(viewModels[.fourth]?.count).to(equal(4))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).to(equal(TestModel(9, "4-3")))
        expect(viewModels[.first]?[safe: 0]??.id).to(equal("1-0"))
        expect(viewModels[.second]?[safe: 0]??.id).to(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).to(equal("2-1"))
        expect(viewModels[.third]?[safe: 0]??.id).to(equal("3-0"))
        expect(viewModels[.third]?[safe: 1]??.id).to(equal("3-1"))
        expect(viewModels[.third]?[safe: 2]??.id).to(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).to(equal("4-0"))
        expect(viewModels[.fourth]?[safe: 1]??.id).to(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 2]??.id).to(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 3]??.id).to(equal("4-3"))
        
        // update the models then refresh the table
        firstModels.on(.next(self.updatedFirstSectionModels))
        secondThirdModels.on(.next(self.updatedSecondThirdSectionModels))
        fourthModels.on(.next(self.updatedFourthSectionModels))
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestViewModelCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        viewModels = cells.mapValues { $0.map { $0.viewModel } }
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(2))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(2))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(2))
        expect(models[.fourth]?.count).to(equal(3))
        expect(viewModels.count).to(equal(4))
        expect(viewModels[.first]?.count).to(equal(2))
        expect(viewModels[.second]?.count).to(equal(2))
        expect(viewModels[.third]?.count).to(equal(2))
        expect(viewModels[.fourth]?.count).to(equal(3))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.first]?[safe: 1]).to(equal(TestModel(10, "1-1")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1*")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(7, "4-1*")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(9, "4-0")))
        expect(viewModels[.first]?[safe: 0]??.id).to(equal("1-0"))
        expect(viewModels[.first]?[safe: 1]??.id).to(equal("1-1"))
        expect(viewModels[.second]?[safe: 0]??.id).to(equal("2-0"))
        expect(viewModels[.second]?[safe: 1]??.id).to(equal("2-1*"))
        expect(viewModels[.third]?[safe: 0]??.id).to(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).to(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).to(equal("4-1*"))
        expect(viewModels[.fourth]?[safe: 1]??.id).to(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 2]??.id).to(equal("4-0"))
    }
    
    /*
     Test the 'cell provider + model' binding chain method.
     */
    func testCellProviderModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [TestModel]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[TestModel]> =  BehaviorSubject(value: self.initialFirstSectionModels)
        let secondThirdModels: BehaviorSubject<[Section: [TestModel]]>
            = BehaviorSubject(value: self.initialSecondThirdSectionModels)
        let fourthModels: BehaviorSubject<[Section: [TestModel]]>
            = BehaviorSubject(value: self.initialFourthSectionModels)
        
        self.binder.onSection(.first)
            .rx.bind(
                cellProvider: { table, row, model in
                    let cell = table.dequeue(TestCell.self)
                    cell.model = model
                    return cell
                }, models: firstModels)
        
        self.binder.onSections(.second, .third)
            .rx.bind(
                cellProvider: { (table, section, row, model) in
                    let cell = table.dequeue(TestCell.self)
                    cell.model = model
                    return cell
                }, models: secondThirdModels)
        
        self.binder.onAllOtherSections()
            .rx.bind(
                cellProvider: { (table, section, row, model) in
                    let cell = table.dequeue(TestCell.self)
                    cell.model = model
                    return cell
                }, models: fourthModels)
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(1))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(3))
        expect(models[.fourth]?.count).to(equal(4))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(3, "3-0")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 2]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(6, "4-0")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(7, "4-1")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 3]).to(equal(TestModel(9, "4-3")))
        
        // update the models then refresh the table
        firstModels.on(.next(self.updatedFirstSectionModels))
        secondThirdModels.on(.next(self.updatedSecondThirdSectionModels))
        fourthModels.on(.next(self.updatedFourthSectionModels))
        
        expect(self.tableView.visibleCells.count).toEventually(equal(9))
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        models = cells.mapValues { $0.map { $0.model as? TestModel }.compactMap { $0 } }
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(2))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        
        // test that we got the right number of models
        expect(models.count).to(equal(4))
        expect(models[.first]?.count).to(equal(2))
        expect(models[.second]?.count).to(equal(2))
        expect(models[.third]?.count).to(equal(2))
        expect(models[.fourth]?.count).to(equal(3))
        
        expect(models[.first]?[safe: 0]).to(equal(TestModel(0, "1-0")))
        expect(models[.first]?[safe: 1]).to(equal(TestModel(10, "1-1")))
        expect(models[.second]?[safe: 0]).to(equal(TestModel(1, "2-0")))
        expect(models[.second]?[safe: 1]).to(equal(TestModel(2, "2-1*")))
        expect(models[.third]?[safe: 0]).to(equal(TestModel(4, "3-1")))
        expect(models[.third]?[safe: 1]).to(equal(TestModel(5, "3-2")))
        expect(models[.fourth]?[safe: 0]).to(equal(TestModel(7, "4-1*")))
        expect(models[.fourth]?[safe: 1]).to(equal(TestModel(8, "4-2")))
        expect(models[.fourth]?[safe: 2]).to(equal(TestModel(9, "4-0")))
   }
    
    /*
     Test the 'cell provider + number of cells' binding chain method.
     */
    func testCellProviderRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var cells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstNumCells: BehaviorSubject<Int> = BehaviorSubject(value: 1)
        let secondThirdNumCells: BehaviorSubject<[Section: Int]>
            = BehaviorSubject(value: [.second: 2, .third: 3])
        let fourthNumCells: BehaviorSubject<[Section: Int]>
            = BehaviorSubject(value: [.fourth: 4])
        
        self.binder.onSection(.first)
            .rx.bind(cellProvider: { table, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: firstNumCells)
        
        self.binder.onSections(.second, .third)
            .rx.bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: secondThirdNumCells)
        
        self.binder.onAllOtherSections()
            .rx.bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: fourthNumCells)
        
        self.binder.finish()
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(10))
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(1))
        expect(cells[.second]?.count).to(equal(2))
        expect(cells[.third]?.count).to(equal(3))
        expect(cells[.fourth]?.count).to(equal(4))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 3]).to(be(self.tableView.visibleCells[9]))
        
        firstNumCells.on(.next(2))
        secondThirdNumCells.on(.next([.second: 3, .third: 4]))
        fourthNumCells.on(.next([.fourth: 3]))
        
        expect(self.tableView.visibleCells.count).toEventually(equal(12))
        
        cells = self.binder.cellsInSections(type: TestCell.self)
        
        expect(cells.count).to(equal(4))
        expect(cells[.first]?.count).to(equal(2))
        expect(cells[.second]?.count).to(equal(3))
        expect(cells[.third]?.count).to(equal(4))
        expect(cells[.fourth]?.count).to(equal(3))
        
        expect(cells[.first]?[safe: 0]).to(be(self.tableView.visibleCells[0]))
        expect(cells[.first]?[safe: 1]).to(be(self.tableView.visibleCells[1]))
        expect(cells[.second]?[safe: 0]).to(be(self.tableView.visibleCells[2]))
        expect(cells[.second]?[safe: 1]).to(be(self.tableView.visibleCells[3]))
        expect(cells[.second]?[safe: 2]).to(be(self.tableView.visibleCells[4]))
        expect(cells[.third]?[safe: 0]).to(be(self.tableView.visibleCells[5]))
        expect(cells[.third]?[safe: 1]).to(be(self.tableView.visibleCells[6]))
        expect(cells[.third]?[safe: 2]).to(be(self.tableView.visibleCells[7]))
        expect(cells[.third]?[safe: 3]).to(be(self.tableView.visibleCells[8]))
        expect(cells[.fourth]?[safe: 0]).to(be(self.tableView.visibleCells[9]))
        expect(cells[.fourth]?[safe: 1]).to(be(self.tableView.visibleCells[10]))
        expect(cells[.fourth]?[safe: 2]).to(be(self.tableView.visibleCells[11]))
    }
}
