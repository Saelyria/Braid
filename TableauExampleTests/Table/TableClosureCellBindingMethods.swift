import UIKit
@testable import Tableau
import Nimble

// Cell binding test for non-RxSwift, updatable (i.e. using closures) binding methods

class TableClosureCellBindingMethods: TableTestCase {
    enum Section: TableViewSection {
        case first
        case second
        case third
        case fourth
    }
    
    private var binder: SectionedTableViewBinder<Section>!
    
    override func setUp() {
        super.setUp()
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.binder.setupForTesting()
    }
    
    /*
     Test the 'cell type + model' binding chain method.
     */
    func testCellTypeModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [UITableViewCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstModels = ["1-1", "1-2"]
        var secondModels = ["2-1", "2-2"]
        var thirdModels = ["3-1", "3-2"]
        var fourthModels = ["4-1", "4-2"]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: { firstModels })
            .onCellDequeue { row, cell, model in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell, at: row)
                    models[.first]?.insert(model, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell
                    models[.first]?[row] = model
                }
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: {[
                .second: secondModels,
                .third: thirdModels
            ]})
            .onCellDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: {[
                .fourth: fourthModels
            ]})
            .onCellDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
            }
        
        self.binder.onAnySection().cellHeight { _,_ in 2 }
        
        self.binder.finish()
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(8))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(2))
        expect(dequeuedCells[.second]?.count).toEventually(equal(2))
        expect(dequeuedCells[.third]?.count).toEventually(equal(2))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(2))
        
        expect(dequeuedCells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.first]?[safe: 1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.third]?[safe: 0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.third]?[safe: 1]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[7]))
        
        // test that we got the right number of models
        expect(models.count).toEventually(equal(4))
        expect(models[.first]?.count).toEventually(equal(2))
        expect(models[.second]?.count).toEventually(equal(2))
        expect(models[.third]?.count).toEventually(equal(2))
        expect(models[.fourth]?.count).toEventually(equal(2))
        
        expect(models[.first]?[safe: 0]).toEventually(equal("1-1"))
        expect(models[.first]?[safe: 1]).toEventually(equal("1-2"))
        expect(models[.second]?[safe: 0]).toEventually(equal("2-1"))
        expect(models[.second]?[safe: 1]).toEventually(equal("2-2"))
        expect(models[.third]?[safe: 0]).toEventually(equal("3-1"))
        expect(models[.third]?[safe: 1]).toEventually(equal("3-2"))
        expect(models[.fourth]?[safe: 0]).toEventually(equal("4-1"))
        expect(models[.fourth]?[safe: 1]).toEventually(equal("4-2"))
        
        // update the models then refresh the table
        firstModels = ["1-1", "1-2*", "1-3"]
        secondModels = ["2-1", "2-2*", "2-3"]
        thirdModels = ["3-1", "3-2*", "3-3"]
        fourthModels = ["4-1", "4-2*", "4-3"]
        self.binder.refresh()
        
        expect(self.tableView.visibleCells.count).toEventually(equal(12))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(3))
        expect(dequeuedCells[.second]?.count).toEventually(equal(3))
        expect(dequeuedCells[.third]?.count).toEventually(equal(3))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(3))
        
        expect(dequeuedCells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.first]?[safe: 1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.first]?[safe: 2]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.second]?[safe: 2]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.third]?[safe: 0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.third]?[safe: 1]).toEventually(be(self.tableView.visibleCells[7]))
        expect(dequeuedCells[.third]?[safe: 2]).toEventually(be(self.tableView.visibleCells[8]))
        expect(dequeuedCells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[9]))
        expect(dequeuedCells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[10]))
        expect(dequeuedCells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[11]))
        
        // test that we got the right number of models
        expect(models.count).toEventually(equal(4))
        expect(models[.first]?.count).toEventually(equal(3))
        expect(models[.second]?.count).toEventually(equal(3))
        expect(models[.third]?.count).toEventually(equal(3))
        expect(models[.fourth]?.count).toEventually(equal(3))
        
        expect(models[.first]?[safe: 0]).toEventually(equal("1-1"))
        expect(models[.first]?[safe: 1]).toEventually(equal("1-2*"))
        expect(models[.first]?[safe: 2]).toEventually(equal("1-3"))
        expect(models[.second]?[safe: 0]).toEventually(equal("2-1"))
        expect(models[.second]?[safe: 1]).toEventually(equal("2-2*"))
        expect(models[.second]?[safe: 2]).toEventually(equal("2-3"))
        expect(models[.third]?[safe: 0]).toEventually(equal("3-1"))
        expect(models[.third]?[safe: 1]).toEventually(equal("3-2*"))
        expect(models[.third]?[safe: 2]).toEventually(equal("3-3"))
        expect(models[.fourth]?[safe: 0]).toEventually(equal("4-1"))
        expect(models[.fourth]?[safe: 1]).toEventually(equal("4-2*"))
        expect(models[.fourth]?[safe: 2]).toEventually(equal("4-3"))
    }
    
    /*
     Test the 'cell type + view model' binding chain method.
     */
    func testCellTypeViewModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self, viewModels: {[
                TestViewModelCell.ViewModel(id: "1"),
                TestViewModelCell.ViewModel(id: "2")
            ]})
            .onCellDequeue { row, cell in
                dequeuedCells[.first]?.insert(cell, at: row)
                viewModels[.first]?.insert(cell.viewModel, at: row)
        }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self, viewModels: {[
                .second: [
                    TestViewModelCell.ViewModel(id: "3"),
                    TestViewModelCell.ViewModel(id: "4"),
                ],
                .third: [
                    TestViewModelCell.ViewModel(id: "5"),
                    TestViewModelCell.ViewModel(id: "6")
                ]
            ]})
            .onCellDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
        }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self, viewModels: {[
                .fourth: [
                    TestViewModelCell.ViewModel(id: "7"),
                    TestViewModelCell.ViewModel(id: "8")
                ]
            ]})
            .onCellDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
        }
        
        self.binder.finish()
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(8))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(2))
        expect(dequeuedCells[.second]?.count).toEventually(equal(2))
        expect(dequeuedCells[.third]?.count).toEventually(equal(2))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(2))
        
        expect(dequeuedCells[.first]?[0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.first]?[1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.second]?[0]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.second]?[1]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.third]?[0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.third]?[1]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.fourth]?[0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.fourth]?[1]).toEventually(be(self.tableView.visibleCells[7]))
        
        // test that we got the right number of view models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(2))
        
        expect(viewModels[.first]?[0]?.id).toEventually(equal("1"))
        expect(viewModels[.first]?[1]?.id).toEventually(equal("2"))
        expect(viewModels[.second]?[0]?.id).toEventually(equal("3"))
        expect(viewModels[.second]?[1]?.id).toEventually(equal("4"))
        expect(viewModels[.third]?[0]?.id).toEventually(equal("5"))
        expect(viewModels[.third]?[1]?.id).toEventually(equal("6"))
        expect(viewModels[.fourth]?[0]?.id).toEventually(equal("7"))
        expect(viewModels[.fourth]?[1]?.id).toEventually(equal("8"))
    }
    
    /*
     Test the 'cell type + model + view model mapping' binding chain method.
     */
    func testCellTypeModelViewModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self,
                  models: {["1", "2"]},
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { row, cell, model in
                dequeuedCells[.first]?.insert(cell, at: row)
                models[.first]?.insert(model, at: row)
                viewModels[.first]?.insert(cell.viewModel, at: row)
        }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self,
                  models: {[
                    .second: ["3", "4"],
                    .third: ["5", "6"] ]},
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
        }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self,
                  models: {[.fourth: ["7", "8"] ]},
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
        }
        
        self.binder.finish()
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(8))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(2))
        expect(dequeuedCells[.second]?.count).toEventually(equal(2))
        expect(dequeuedCells[.third]?.count).toEventually(equal(2))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(2))
        
        expect(dequeuedCells[.first]?[0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.first]?[1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.second]?[0]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.second]?[1]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.third]?[0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.third]?[1]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.fourth]?[0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.fourth]?[1]).toEventually(be(self.tableView.visibleCells[7]))
        
        // test that we got the right number of models
        expect(models.count).toEventually(equal(4))
        expect(models[.first]?.count).toEventually(equal(2))
        expect(models[.second]?.count).toEventually(equal(2))
        expect(models[.third]?.count).toEventually(equal(2))
        expect(models[.fourth]?.count).toEventually(equal(2))
        
        expect(models[.first]?[0]).toEventually(equal("1"))
        expect(models[.first]?[1]).toEventually(equal("2"))
        expect(models[.second]?[0]).toEventually(equal("3"))
        expect(models[.second]?[1]).toEventually(equal("4"))
        expect(models[.third]?[0]).toEventually(equal("5"))
        expect(models[.third]?[1]).toEventually(equal("6"))
        expect(models[.fourth]?[0]).toEventually(equal("7"))
        expect(models[.fourth]?[1]).toEventually(equal("8"))
        
        // test that we got the right number of view models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(2))
        
        expect(viewModels[.first]?[0]?.id).toEventually(equal("1"))
        expect(viewModels[.first]?[1]?.id).toEventually(equal("2"))
        expect(viewModels[.second]?[0]?.id).toEventually(equal("3"))
        expect(viewModels[.second]?[1]?.id).toEventually(equal("4"))
        expect(viewModels[.third]?[0]?.id).toEventually(equal("5"))
        expect(viewModels[.third]?[1]?.id).toEventually(equal("6"))
        expect(viewModels[.fourth]?[0]?.id).toEventually(equal("7"))
        expect(viewModels[.fourth]?[1]?.id).toEventually(equal("8"))
    }
    
    /*
     Test the 'cell provider + model' binding chain method.
     */
    func testCellProviderModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(
                models: {["1", "2"]},
                cellProvider: { table, row, model in
                    models[.first]?.insert(model, at: row)
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { row, cell, model in
                expect(model).to(equal(models[.first]?[row]))
                dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
        }
        
        self.binder.onSections(.second, .third)
            .bind(
                models: {[
                    .second: ["3", "4"],
                    .third: ["5", "6"]
                ]},
                cellProvider: { (table, section, row, model: String) in
                    models[section]?.insert(model, at: row)
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
        }
        
        self.binder.onAllOtherSections()
            .bind(
                models: {[.fourth: ["7", "8"],]},
                cellProvider: { (table, section, row, model: String) in
                    models[section]?.insert(model, at: row)
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
        }
        
        self.binder.finish()
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(8))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(2))
        expect(dequeuedCells[.second]?.count).toEventually(equal(2))
        expect(dequeuedCells[.third]?.count).toEventually(equal(2))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(2))
        
        expect(dequeuedCells[.first]?[0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.first]?[1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.second]?[0]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.second]?[1]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.third]?[0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.third]?[1]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.fourth]?[0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.fourth]?[1]).toEventually(be(self.tableView.visibleCells[7]))
        
        // test that we got the right number of models
        expect(models.count).toEventually(equal(4))
        expect(models[.first]?.count).toEventually(equal(2))
        expect(models[.second]?.count).toEventually(equal(2))
        expect(models[.third]?.count).toEventually(equal(2))
        expect(models[.fourth]?.count).toEventually(equal(2))
        
        expect(models[.first]?[0]).toEventually(equal("1"))
        expect(models[.first]?[1]).toEventually(equal("2"))
        expect(models[.second]?[0]).toEventually(equal("3"))
        expect(models[.second]?[1]).toEventually(equal("4"))
        expect(models[.third]?[0]).toEventually(equal("5"))
        expect(models[.third]?[1]).toEventually(equal("6"))
        expect(models[.fourth]?[0]).toEventually(equal("7"))
        expect(models[.fourth]?[1]).toEventually(equal("8"))
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
            }, numberOfCells: {2})
            .onCellDequeue { row, cell in
                dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
        }
        
        self.binder.onSections(.second, .third)
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: {[.second: 2, .third: 2]})
            .onCellDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
        }
        
        self.binder.onAllOtherSections()
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: {[.fourth: 2]})
            .onCellDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
        }
        
        self.binder.finish()
        
        // test we got the right number of cells and that they relate to the right cells on the table
        expect(self.tableView.visibleCells.count).toEventually(equal(8))
        
        expect(dequeuedCells.count).toEventually(equal(4))
        expect(dequeuedCells[.first]?.count).toEventually(equal(2))
        expect(dequeuedCells[.second]?.count).toEventually(equal(2))
        expect(dequeuedCells[.third]?.count).toEventually(equal(2))
        expect(dequeuedCells[.fourth]?.count).toEventually(equal(2))
        
        expect(dequeuedCells[.first]?[0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.first]?[1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.second]?[0]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.second]?[1]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.third]?[0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.third]?[1]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.fourth]?[0]).toEventually(be(self.tableView.visibleCells[6]))
        expect(dequeuedCells[.fourth]?[1]).toEventually(be(self.tableView.visibleCells[7]))
    }
}
