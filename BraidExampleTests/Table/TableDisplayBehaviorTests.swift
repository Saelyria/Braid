import UIKit
@testable import Braid
import Nimble

/// Tests to ensure the table properly ordered sections

class TableDisplayBehaviorTests: TableTestCase {
    enum Section: Int, TableViewSection {
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
     Test that cells are in the correct positions when displayed sections are reordered/removed.
     */
    func testReorderDisplayedSections() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var dequeuedCells: [Section: [UITableViewCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        let firstModels = ["1-1"]
        let secondModels = ["2-1", "2-2"]
        let thirdModels = ["3-1", "3-2", "3-3"]
        let fourthModels = ["4-1", "4-2", "4-3", "4-4"]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: { firstModels })
            .onDequeue { row, cell, model in
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
            .onDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
            }
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: { [.fourth: fourthModels] })
            .onDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
            }
        
        self.binder.onAnySection().dimensions(.cellHeight { _,_ in 2 })
        
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
        
        // reorder/remove sections
        self.binder.displayedSections = [.fourth, .first, .second]
        expect(self.tableView.visibleCells.count).toEventually(equal(7))
        
        expect(dequeuedCells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.fourth]?[safe: 3]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[4]))
        expect(dequeuedCells[.second]?[safe: 0]).toEventually(be(self.tableView.visibleCells[5]))
        expect(dequeuedCells[.second]?[safe: 1]).toEventually(be(self.tableView.visibleCells[6]))
    }
    
    /*
     Test that cells are in the correct positions when displayed sections are reordered/removed.
     */
    func testNoCellDataSectionsHidden() {
        var dequeuedCells: [Section: [UITableViewCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstHeader: String? = "H1"
        var firstModels = ["1-1"]
        var firstFooter: String? = "F1"
        
        var secondHeader: String? = "H2"
        var secondModels = ["2-1", "2-2"]
        var secondFooter: String? = "F2"
        
        var thirdHeader: String? = "H3"
        var thirdModels = ["3-1", "3-2", "3-3"]
        var thirdFooter: String? = "F3"
        
        var fourthHeader: String? = "H4"
        var fourthModels = ["4-1", "4-2", "4-3", "4-4"]
        var fourthFooter: String? = "F4"
        
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoCellData(orderingWith: {
            $0.sorted { $0.rawValue < $1.rawValue }
        })
        
        self.binder.onSection(.first)
            .bind(headerTitle: { firstHeader })
            .bind(cellType: TestCell.self, models: { firstModels })
            .bind(footerTitle: { firstFooter })
            .onDequeue { row, cell, model in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell, at: row)
                    models[.first]?.insert(model, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell
                    models[.first]?[row] = model
                }
            }
        
        self.binder.onSections(.second, .third)
            .bind(headerTitles: { [.second: secondHeader, .third: thirdHeader] })
            .bind(cellType: TestCell.self, models: {[
                .second: secondModels,
                .third: thirdModels
            ]})
            .bind(footerTitles: { [.second: secondFooter, .third: thirdFooter ]})
            .onDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
            }
        
        self.binder.onAllOtherSections()
            .bind(headerTitles: { [.fourth: fourthHeader]})
            .bind(cellType: TestCell.self, models: { [.fourth: fourthModels] })
            .bind(footerTitles: { [.fourth: fourthFooter]})
            .onDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
            }
        
        self.binder.onAnySection()
            .dimensions(
                .cellHeight { _, _ in 2 },
                .headerHeight { _ in 1 },
                .footerHeight { _ in 1 })
        
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
        
        // test headers and footers
        var allHeaderFooters = self.tableView.subviews.filter { $0 is UITableViewHeaderFooterView } as! [UITableViewHeaderFooterView]
        allHeaderFooters.sort { $0.frame.origin.y < $1.frame.origin.y }
        var headers = allHeaderFooters.filter { $0.textLabel?.text?.contains("H") == true }
        var footers = allHeaderFooters.filter { $0.textLabel?.text?.contains("F") == true }
        
        expect(headers.count).to(equal(4))
        expect(headers[0].textLabel?.text).to(equal("H1"))
        expect(headers[1].textLabel?.text).to(equal("H2"))
        expect(headers[2].textLabel?.text).to(equal("H3"))
        expect(headers[3].textLabel?.text).to(equal("H4"))
        
        expect(footers.count).to(equal(4))
        expect(footers[0].textLabel?.text).to(equal("F1"))
        expect(footers[1].textLabel?.text).to(equal("F2"))
        expect(footers[2].textLabel?.text).to(equal("F3"))
        expect(footers[3].textLabel?.text).to(equal("F4"))
        
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
        
        // reorder/remove sections
        firstHeader = nil
        firstModels = ["1-1"]
        firstFooter = nil
        
        secondHeader = "H2"
        secondModels = []
        secondFooter = nil
        
        thirdHeader = nil
        thirdModels = []
        thirdFooter = nil
        
        fourthHeader = nil
        fourthModels = ["4-1", "4-2", "4-3", "4-4"]
        fourthFooter = "F4"
        self.binder.refresh()
        
        // test that cells updated
        expect(self.binder.displayedSections.count).toEventually(equal(2))
        expect(self.tableView.visibleCells.count).toEventually(equal(5))
        
        expect(dequeuedCells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.fourth]?[safe: 3]).toEventually(be(self.tableView.visibleCells[4]))
        
        expect(self.tableView.headerView(forSection: 0)).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 1)).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 3)).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 4)).toEventually(beNil())
        
        expect(self.tableView.footerView(forSection: 0)).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 1)).toNotEventually(beNil())
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F4"))
        expect(self.tableView.footerView(forSection: 3)).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 4)).toEventually(beNil())
    }
    
    /*
     Test that cells are in the correct positions when displayed sections are reordered/removed.
     */
    func testNoDataSectionsHidden() {
        var dequeuedCells: [Section: [UITableViewCell]] = [.first: [], .second: [], .third: [], .fourth: []]
        var models: [Section: [String]] = [.first: [], .second: [], .third: [], .fourth: []]
        
        var firstHeader: String? = "H1"
        var firstModels = ["1-1"]
        var firstFooter: String? = "F1"
        
        var secondHeader: String? = "H2"
        var secondModels = ["2-1", "2-2"]
        var secondFooter: String? = "F2"
        
        var thirdHeader: String? = "H3"
        var thirdModels = ["3-1", "3-2", "3-3"]
        var thirdFooter: String? = "F3"
        
        var fourthHeader: String? = "H4"
        var fourthModels = ["4-1", "4-2", "4-3", "4-4"]
        var fourthFooter: String? = "F4"
        
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoData(orderingWith: {
            $0.sorted { $0.rawValue < $1.rawValue }
        })
        
        self.binder.onSection(.first)
            .bind(headerTitle: { firstHeader })
            .bind(cellType: TestCell.self, models: { firstModels })
            .bind(footerTitle: { firstFooter })
            .onDequeue { row, cell, model in
                if dequeuedCells[.first]?.indices.contains(row) == false {
                    dequeuedCells[.first]?.insert(cell, at: row)
                    models[.first]?.insert(model, at: row)
                } else {
                    dequeuedCells[.first]?[row] = cell
                    models[.first]?[row] = model
                }
        }
        
        self.binder.onSections(.second, .third)
            .bind(headerTitles: { [.second: secondHeader, .third: thirdHeader] })
            .bind(cellType: TestCell.self, models: {[
                .second: secondModels,
                .third: thirdModels
                ]})
            .bind(footerTitles: { [.second: secondFooter, .third: thirdFooter ]})
            .onDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
        }
        
        self.binder.onAllOtherSections()
            .bind(headerTitles: { [.fourth: fourthHeader]})
            .bind(cellType: TestCell.self, models: { [.fourth: fourthModels] })
            .bind(footerTitles: { [.fourth: fourthFooter]})
            .onDequeue { section, row, cell, model in
                if dequeuedCells[section]?.indices.contains(row) == false {
                    dequeuedCells[section]?.insert(cell, at: row)
                    models[section]?.insert(model, at: row)
                } else {
                    dequeuedCells[section]?[row] = cell
                    models[section]?[row] = model
                }
        }
        
        self.binder.onAnySection()
            .dimensions(
                .cellHeight { _, _ in 2 },
                .headerHeight { _ in 1 },
                .footerHeight { _ in 1 })
        
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
        
        // test headers and footers
        var allHeaderFooters = self.tableView.subviews.filter { $0 is UITableViewHeaderFooterView } as! [UITableViewHeaderFooterView]
        allHeaderFooters.sort { $0.frame.origin.y < $1.frame.origin.y }
        var headers = allHeaderFooters.filter { $0.textLabel?.text?.contains("H") == true }
        var footers = allHeaderFooters.filter { $0.textLabel?.text?.contains("F") == true }
        
        expect(headers.count).to(equal(4))
        expect(headers[0].textLabel?.text).to(equal("H1"))
        expect(headers[1].textLabel?.text).to(equal("H2"))
        expect(headers[2].textLabel?.text).to(equal("H3"))
        expect(headers[3].textLabel?.text).to(equal("H4"))
        
        expect(footers.count).to(equal(4))
        expect(footers[0].textLabel?.text).to(equal("F1"))
        expect(footers[1].textLabel?.text).to(equal("F2"))
        expect(footers[2].textLabel?.text).to(equal("F3"))
        expect(footers[3].textLabel?.text).to(equal("F4"))
        
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
        
        // reorder/remove sections
        firstHeader = nil
        firstModels = ["1-1"]
        firstFooter = nil
        
        secondHeader = "H2"
        secondModels = []
        secondFooter = nil
        
        thirdHeader = nil
        thirdModels = []
        thirdFooter = nil
        
        fourthHeader = nil
        fourthModels = ["4-1", "4-2", "4-3", "4-4"]
        fourthFooter = "F4"
        self.binder.refresh()
        
        // test that cells updated
        expect(self.binder.displayedSections.count).toEventually(equal(3))
        expect(self.tableView.visibleCells.count).toEventually(equal(5))
        
        expect(dequeuedCells[.first]?[safe: 0]).toEventually(be(self.tableView.visibleCells[0]))
        expect(dequeuedCells[.fourth]?[safe: 0]).toEventually(be(self.tableView.visibleCells[1]))
        expect(dequeuedCells[.fourth]?[safe: 1]).toEventually(be(self.tableView.visibleCells[2]))
        expect(dequeuedCells[.fourth]?[safe: 2]).toEventually(be(self.tableView.visibleCells[3]))
        expect(dequeuedCells[.fourth]?[safe: 3]).toEventually(be(self.tableView.visibleCells[4]))
        
        expect(self.tableView.headerView(forSection: 0)).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 1)).toNotEventually(beNil())
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(equal("H2"))
        expect(self.tableView.headerView(forSection: 2)).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 3)).toEventually(beNil())
        
        expect(self.tableView.footerView(forSection: 0)).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 1)).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 2)).toNotEventually(beNil())
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(equal("F4"))
        expect(self.tableView.footerView(forSection: 3)).toEventually(beNil())
    }
}
