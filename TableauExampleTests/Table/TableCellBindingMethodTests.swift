import UIKit
@testable import Tableau
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
    
    private var binder: SectionedTableViewBinder<Section>!
    
    override func setUp() {
        super.setUp()
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.binder.setupForTesting()
    }
    
    // MARK: -
    
    /*
     Test the 'cell type + model' binding chain method.
     */
    func testCellTypeModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [UITableViewCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: ["1-1"])
            .onCellDequeue { row, cell, model in
                dequeuedCells[.first]?.insert(cell, at: row)
                models[.first]?.insert(model, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: [
                .second: ["2-1", "2-2"],
                .third: ["3-1", "3-2", "3-3"]
            ])
            .onCellDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: [
                .fourth: ["4-1", "4-2", "4-3", "4-4",]
            ])
            .onCellDequeue { section, row, cell, model in
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
        
        expect(models[.first]?[safe: 0]).toEventually(equal("1-1"))
        expect(models[.second]?[safe: 0]).toEventually(equal("2-1"))
        expect(models[.second]?[safe: 1]).toEventually(equal("2-2"))
        expect(models[.third]?[safe: 0]).toEventually(equal("3-1"))
        expect(models[.third]?[safe: 1]).toEventually(equal("3-2"))
        expect(models[.third]?[safe: 2]).toEventually(equal("3-3"))
        expect(models[.fourth]?[safe: 0]).toEventually(equal("4-1"))
        expect(models[.fourth]?[safe: 1]).toEventually(equal("4-2"))
        expect(models[.fourth]?[safe: 2]).toEventually(equal("4-3"))
        expect(models[.fourth]?[safe: 3]).toEventually(equal("4-4"))
    }
    
    /*
     Test the 'cell type + view model' binding chain method.
     */
    func testCellTypeViewModelBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self, viewModels: [
                TestViewModelCell.ViewModel(id: "1-1"),
            ])
            .onCellDequeue { row, cell in
                dequeuedCells[.first]?.insert(cell, at: row)
                viewModels[.first]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self, viewModels: [
                .second: [
                    TestViewModelCell.ViewModel(id: "2-1"),
                    TestViewModelCell.ViewModel(id: "2-2"),
                ],
                .third: [
                    TestViewModelCell.ViewModel(id: "3-1"),
                    TestViewModelCell.ViewModel(id: "3-2"),
                    TestViewModelCell.ViewModel(id: "3-3")

                ]
            ])
            .onCellDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self, viewModels: [
                .fourth: [
                    TestViewModelCell.ViewModel(id: "4-1"),
                    TestViewModelCell.ViewModel(id: "4-2"),
                    TestViewModelCell.ViewModel(id: "4-3"),
                    TestViewModelCell.ViewModel(id: "4-4")
                ]
            ])
            .onCellDequeue { section, row, cell in
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
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-3"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-3"))
        expect(viewModels[.fourth]?[safe: 3]??.id).toEventually(equal("4-4"))
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
                  models: ["1-1",],
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { row, cell, model in
                dequeuedCells[.first]?.insert(cell, at: row)
                models[.first]?.insert(model, at: row)
                viewModels[.first]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self,
                  models: [
                    .second: ["2-1", "2-2"],
                    .third: ["3-1", "3-2", "3-3"] ],
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
                dequeuedCells[section]?.insert(cell, at: row)
                models[section]?.insert(model, at: row)
                viewModels[section]?.insert(cell.viewModel, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self,
                  models: [.fourth: ["4-1", "4-2", "4-3", "4-4"] ],
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
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
        
        expect(models[.first]?[safe: 0]).toEventually(equal("1-1"))
        expect(models[.second]?[safe: 0]).toEventually(equal("2-1"))
        expect(models[.second]?[safe: 1]).toEventually(equal("2-2"))
        expect(models[.third]?[safe: 0]).toEventually(equal("3-1"))
        expect(models[.third]?[safe: 1]).toEventually(equal("3-2"))
        expect(models[.third]?[safe: 2]).toEventually(equal("3-3"))
        expect(models[.fourth]?[safe: 0]).toEventually(equal("4-1"))
        expect(models[.fourth]?[safe: 1]).toEventually(equal("4-2"))
        expect(models[.fourth]?[safe: 2]).toEventually(equal("4-3"))
        expect(models[.fourth]?[safe: 3]).toEventually(equal("4-4"))
        
        // test that we got the right number of view models
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(1))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(4))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-3"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-3"))
        expect(viewModels[.fourth]?[safe: 3]??.id).toEventually(equal("4-4"))
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
                models: ["1-1"],
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
                models: [
                    .second: ["2-1", "2-2"],
                    .third: ["3-1", "3-2", "3-3"]
                ],
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
                models: [
                    .fourth: ["4-1", "4-2", "4-3", "4-4"],
                ],
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
        
        expect(models[.first]?[safe: 0]).toEventually(equal("1-1"))
        expect(models[.second]?[safe: 0]).toEventually(equal("2-1"))
        expect(models[.second]?[safe: 1]).toEventually(equal("2-2"))
        expect(models[.third]?[safe: 0]).toEventually(equal("3-1"))
        expect(models[.third]?[safe: 1]).toEventually(equal("3-2"))
        expect(models[.third]?[safe: 2]).toEventually(equal("3-3"))
        expect(models[.fourth]?[safe: 0]).toEventually(equal("4-1"))
        expect(models[.fourth]?[safe: 1]).toEventually(equal("4-2"))
        expect(models[.fourth]?[safe: 2]).toEventually(equal("4-3"))
        expect(models[.fourth]?[safe: 3]).toEventually(equal("4-4"))
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
            .onCellDequeue { row, cell in
                dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
            }
        
        self.binder.onSections(.second, .third)
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: [.second: 2, .third: 3])
            .onCellDequeue { section, row, cell in
                dequeuedCells[section]?.insert(cell as! TestCell, at: row)
            }
        
        self.binder.onAllOtherSections()
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: [.fourth: 4])
            .onCellDequeue { section, row, cell in
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
    func testCellTypeViewModelClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstModels: [TestViewModelCell.ViewModel] = ["1-1", "1-2"].map { TestViewModelCell.ViewModel(id: $0) }
        var secondModels: [TestViewModelCell.ViewModel] = ["2-1", "2-2"].map { TestViewModelCell.ViewModel(id: $0) }
        var thirdModels: [TestViewModelCell.ViewModel] = ["3-1", "3-2"].map { TestViewModelCell.ViewModel(id: $0) }
        var fourthModels: [TestViewModelCell.ViewModel] = ["4-1", "4-2"].map { TestViewModelCell.ViewModel(id: $0) }
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self, viewModels: { firstModels })
            .onCellDequeue { row, cell in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell, at: row)
                    viewModels[.first]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell
                    viewModels[.first]?[row] = cell.viewModel
                }
        }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self, viewModels: {[
                .second: secondModels,
                .third: thirdModels
                ]})
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self, viewModels: {[
                .fourth: fourthModels
                ]})
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(2))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        
        // update the models then refresh the table
        firstModels = ["1-1", "1-2*", "1-3"].map { TestViewModelCell.ViewModel(id: $0) }
        secondModels = ["2-1", "2-2*", "2-3"].map { TestViewModelCell.ViewModel(id: $0) }
        thirdModels = ["3-1", "3-2*", "3-3"].map { TestViewModelCell.ViewModel(id: $0) }
        fourthModels = ["4-1", "4-2*", "4-3"].map { TestViewModelCell.ViewModel(id: $0) }
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(3))
        expect(viewModels[.second]?.count).toEventually(equal(3))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(3))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2*"))
        expect(viewModels[.first]?[safe: 2]??.id).toEventually(equal("1-3"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2*"))
        expect(viewModels[.second]?[safe: 2]??.id).toEventually(equal("2-3"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2*"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-3"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2*"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-3"))
    }
    
    /*
     Test the 'cell type + model + view model mapping' binding chain method.
     */
    func testCellTypeModelViewModelClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstModels = ["1-1", "1-2"]
        var secondModels = ["2-1", "2-2"]
        var thirdModels = ["3-1", "3-2"]
        var fourthModels = ["4-1", "4-2"]
        
        self.binder.onSection(.first)
            .bind(cellType: TestViewModelCell.self,
                  models: { firstModels },
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { row, cell, model in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell, at: row)
                    models[.first]?.insert(model, at: row)
                    viewModels[.first]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell
                    models[.first]?[row] = model
                    viewModels[.first]?[row] = cell.viewModel
                }
        }
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestViewModelCell.self,
                  models: {[.second: secondModels, .third: thirdModels ]},
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestViewModelCell.self,
                  models: { [.fourth: fourthModels ] },
                  mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(2))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(3))
        expect(viewModels[.second]?.count).toEventually(equal(3))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(3))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2*"))
        expect(viewModels[.first]?[safe: 2]??.id).toEventually(equal("1-3"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2*"))
        expect(viewModels[.second]?[safe: 2]??.id).toEventually(equal("2-3"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2*"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-3"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2*"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-3"))
        
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
     Test the 'cell provider + model' binding chain method.
     */
    func testCellProviderModelClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstModels = ["1-1", "1-2"]
        var secondModels = ["2-1", "2-2"]
        var thirdModels = ["3-1", "3-2"]
        var fourthModels = ["4-1", "4-2"]
        
        self.binder.onSection(.first)
            .bind(
                models: { firstModels },
                cellProvider: { table, row, model in
                    if dequeuedCells[.first]?.indices.contains(row) == false {
                        models[.first]?.insert(model, at: row)
                    } else {
                        models[.first]?[row] = model
                    }
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { row, cell, model in
                expect(model).to(equal(models[.first]?[row]))
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onSections(.second, .third)
            .bind(
                models: { [.second: secondModels, .third: thirdModels] },
                cellProvider: { (table, section, row, model: String) in
                    if dequeuedCells[section]?.indices.contains(row) == false {
                        models[section]?.insert(model, at: row)
                    } else {
                        models[section]?[row] = model
                    }
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onAllOtherSections()
            .bind(
                models: { [.fourth: fourthModels] },
                cellProvider: { (table, section, row, model: String) in
                    if dequeuedCells[section]?.indices.contains(row) == false {
                        models[section]?.insert(model, at: row)
                    } else {
                        models[section]?[row] = model
                    }
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
        }
        
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
     Test the 'cell provider + number of cells' binding chain method.
     */
    func testCellProviderClosureBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var numberOfCells = 2
        
        self.binder.onSection(.first)
            .bind(cellProvider: { table, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: { numberOfCells })
            .onCellDequeue { row, cell in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onSections(.second, .third)
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: {[.second: numberOfCells, .third: numberOfCells]})
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onAllOtherSections()
            .bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: {[.fourth: numberOfCells]})
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
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
        
        numberOfCells = 3
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
    }
    
    // MARK: -

    /*
     Test the 'cell type + model' binding chain method.
     */
    func testCellTypeModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [UITableViewCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[String]> =  BehaviorSubject(value: ["1-1", "1-2"])
        let secondThirdModels: BehaviorSubject<[Section: [String]]>
            = BehaviorSubject(value: [.second: ["2-1", "2-2"], .third: ["3-1", "3-2"]])
        let fourthModels: BehaviorSubject<[Section: [String]]>
            = BehaviorSubject(value: [.fourth: ["4-1", "4-2"]])
        
        self.binder.onSection(.first)
            .rx.bind(cellType: TestCell.self, models: firstModels.asObservable())
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
            .rx.bind(cellType: TestCell.self, models: secondThirdModels)
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
            .rx.bind(cellType: TestCell.self, models: fourthModels)
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
        firstModels.on(.next(["1-1", "1-2*", "1-3"]))
        secondThirdModels.on(.next([
            .second: ["2-1", "2-2*", "2-3"],
            .third: ["3-1", "3-2*", "3-3"]
            ]))
        fourthModels.on(.next([.fourth: ["4-1", "4-2*", "4-3"]]))
        
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
    func testCellTypeViewModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[TestViewModelCell.ViewModel]>
            = BehaviorSubject(value: ["1-1", "1-2"].map { TestViewModelCell.ViewModel(id: $0) })
        let secondThirdModels: BehaviorSubject<[Section: [TestViewModelCell.ViewModel]]>
            = BehaviorSubject(value: [.second: ["2-1", "2-2"].map { TestViewModelCell.ViewModel(id: $0) },
                                      .third: ["3-1", "3-2"].map { TestViewModelCell.ViewModel(id: $0) }])
        let fourthModels: BehaviorSubject<[Section: [TestViewModelCell.ViewModel]]>
            = BehaviorSubject(value: [.fourth: ["4-1", "4-2"].map { TestViewModelCell.ViewModel(id: $0) }])
        
        
        self.binder.onSection(.first)
            .rx.bind(cellType: TestViewModelCell.self, viewModels: firstModels)
            .onCellDequeue { row, cell in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell, at: row)
                    viewModels[.first]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell
                    viewModels[.first]?[row] = cell.viewModel
                }
        }
        
        self.binder.onSections(.second, .third)
            .rx.bind(cellType: TestViewModelCell.self, viewModels: secondThirdModels)
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
        self.binder.onAllOtherSections()
            .rx.bind(cellType: TestViewModelCell.self, viewModels: fourthModels)
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(2))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        
        // update the models then refresh the table
        firstModels.on(.next(["1-1", "1-2*", "1-3"].map { TestViewModelCell.ViewModel(id: $0) }))
        secondThirdModels.on(.next([
            .second: ["2-1", "2-2*", "2-3"].map { TestViewModelCell.ViewModel(id: $0) },
            .third: ["3-1", "3-2*", "3-3"].map { TestViewModelCell.ViewModel(id: $0) }
            ]))
        fourthModels.on(.next([.fourth: ["4-1", "4-2*", "4-3"].map { TestViewModelCell.ViewModel(id: $0) }]))
        
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(3))
        expect(viewModels[.second]?.count).toEventually(equal(3))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(3))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2*"))
        expect(viewModels[.first]?[safe: 2]??.id).toEventually(equal("1-3"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2*"))
        expect(viewModels[.second]?[safe: 2]??.id).toEventually(equal("2-3"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2*"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-3"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2*"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-3"))
    }
    
    /*
     Test the 'cell type + model + view model mapping' binding chain method.
     */
    func testCellTypeModelViewModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestViewModelCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        var viewModels: [Section: [TestViewModelCell.ViewModel?]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[String]> =  BehaviorSubject(value: ["1-1", "1-2"])
        let secondThirdModels: BehaviorSubject<[Section: [String]]>
            = BehaviorSubject(value: [.second: ["2-1", "2-2"], .third: ["3-1", "3-2"]])
        let fourthModels: BehaviorSubject<[Section: [String]]>
            = BehaviorSubject(value: [.fourth: ["4-1", "4-2"]])
        
        self.binder.onSection(.first)
            .rx.bind(cellType: TestViewModelCell.self,
                     models: firstModels,
                     mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { row, cell, model in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell, at: row)
                    models[.first]?.insert(model, at: row)
                    viewModels[.first]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell
                    models[.first]?[row] = model
                    viewModels[.first]?[row] = cell.viewModel
                }
        }
        
        self.binder.onSections(.second, .third)
            .rx.bind(cellType: TestViewModelCell.self,
                     models: secondThirdModels,
                     mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
        self.binder.onAllOtherSections()
            .rx.bind(cellType: TestViewModelCell.self,
                     models: fourthModels,
                     mapToViewModels: { TestViewModelCell.ViewModel(id: $0) })
            .onCellDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                    viewModels[section]?.insert(cell.viewModel, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                    viewModels[section]?[row] = cell.viewModel
                }
        }
        
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(2))
        expect(viewModels[.second]?.count).toEventually(equal(2))
        expect(viewModels[.third]?.count).toEventually(equal(2))
        expect(viewModels[.fourth]?.count).toEventually(equal(2))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2"))
        
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
        firstModels.on(.next(["1-1", "1-2*", "1-3"]))
        secondThirdModels.on(.next([
            .second: ["2-1", "2-2*", "2-3"],
            .third: ["3-1", "3-2*", "3-3"]
            ]))
        fourthModels.on(.next([.fourth: ["4-1", "4-2*", "4-3"]]))
        
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
        expect(viewModels.count).toEventually(equal(4))
        expect(viewModels[.first]?.count).toEventually(equal(3))
        expect(viewModels[.second]?.count).toEventually(equal(3))
        expect(viewModels[.third]?.count).toEventually(equal(3))
        expect(viewModels[.fourth]?.count).toEventually(equal(3))
        
        expect(viewModels[.first]?[safe: 0]??.id).toEventually(equal("1-1"))
        expect(viewModels[.first]?[safe: 1]??.id).toEventually(equal("1-2*"))
        expect(viewModels[.first]?[safe: 2]??.id).toEventually(equal("1-3"))
        expect(viewModels[.second]?[safe: 0]??.id).toEventually(equal("2-1"))
        expect(viewModels[.second]?[safe: 1]??.id).toEventually(equal("2-2*"))
        expect(viewModels[.second]?[safe: 2]??.id).toEventually(equal("2-3"))
        expect(viewModels[.third]?[safe: 0]??.id).toEventually(equal("3-1"))
        expect(viewModels[.third]?[safe: 1]??.id).toEventually(equal("3-2*"))
        expect(viewModels[.third]?[safe: 2]??.id).toEventually(equal("3-3"))
        expect(viewModels[.fourth]?[safe: 0]??.id).toEventually(equal("4-1"))
        expect(viewModels[.fourth]?[safe: 1]??.id).toEventually(equal("4-2*"))
        expect(viewModels[.fourth]?[safe: 2]??.id).toEventually(equal("4-3"))
        
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
     Test the 'cell provider + model' binding chain method.
     */
    func testCellProviderModelRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels: BehaviorSubject<[String]> =  BehaviorSubject(value: ["1-1", "1-2"])
        let secondThirdModels: BehaviorSubject<[Section: [String]]>
            = BehaviorSubject(value: [.second: ["2-1", "2-2"], .third: ["3-1", "3-2"]])
        let fourthModels: BehaviorSubject<[Section: [String]]>
            = BehaviorSubject(value: [.fourth: ["4-1", "4-2"]])
        
        self.binder.onSection(.first)
            .rx.bind(
                models: firstModels,
                cellProvider: { table, row, model in
                    if dequeuedCells[.first]?.indices.contains(row) == false {
                        models[.first]?.insert(model, at: row)
                    } else {
                        models[.first]?[row] = model
                    }
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { row, cell, model in
                expect(model).to(equal(models[.first]?[row]))
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onSections(.second, .third)
            .rx.bind(
                models: secondThirdModels,
                cellProvider: { (table, section, row, model: String) in
                    if dequeuedCells[section]?.indices.contains(row) == false {
                        models[section]?.insert(model, at: row)
                    } else {
                        models[section]?[row] = model
                    }
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onAllOtherSections()
            .rx.bind(
                models: fourthModels,
                cellProvider: { (table, section, row, model: String) in
                    if dequeuedCells[section]?.indices.contains(row) == false {
                        models[section]?.insert(model, at: row)
                    } else {
                        models[section]?[row] = model
                    }
                    return table.dequeue(TestCell.self)
            })
            .onCellDequeue { section, row, cell, model in
                expect(model).to(equal(models[section]?[row]))
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
        }
        
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
        firstModels.on(.next(["1-1", "1-2*", "1-3"]))
        secondThirdModels.on(.next([
            .second: ["2-1", "2-2*", "2-3"],
            .third: ["3-1", "3-2*", "3-3"]
            ]))
        fourthModels.on(.next([.fourth: ["4-1", "4-2*", "4-3"]]))
        
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
     Test the 'cell provider + number of cells' binding chain method.
     */
    func testCellProviderRxBindingMethod() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [TestCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstNumCells: BehaviorSubject<Int> = BehaviorSubject(value: 2)
        let secondThirdNumCells: BehaviorSubject<[Section: Int]>
            = BehaviorSubject(value: [.second: 2, .third: 2])
        let fourthNumCells: BehaviorSubject<[Section: Int]>
            = BehaviorSubject(value: [.fourth: 2])
        
        self.binder.onSection(.first)
            .rx.bind(cellProvider: { table, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: firstNumCells)
            .onCellDequeue { row, cell in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onSections(.second, .third)
            .rx.bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: secondThirdNumCells)
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
        }
        
        self.binder.onAllOtherSections()
            .rx.bind(cellProvider: { table, section, row in
                return table.dequeue(TestCell.self)
            }, numberOfCells: fourthNumCells)
            .onCellDequeue { section, row, cell in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell as! TestCell, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell as! TestCell
                }
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
        
        firstNumCells.on(.next(3))
        secondThirdNumCells.on(.next([.second: 3, .third: 3]))
        fourthNumCells.on(.next([.fourth: 3]))
        
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
    }
}
