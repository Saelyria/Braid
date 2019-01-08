import UIKit
@testable import Tableau
import Nimble
import RxSwift

/// Cell binding test for RxSwift binding methods

class TableRxCellBindingMethods: TableTestCase {
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
    func testCellTypeViewModelBindingMethod() {
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
    func testCellTypeModelViewModelBindingMethod() {
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
    func testCellProviderModelBindingMethod() {
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
    func testCellProviderBindingMethod() {
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
