import XCTest
@testable import Braid
import Nimble
import RxSwift

class TableHeaderFooterTests: TableTestCase {
    enum Section: Int, TableViewSection, Comparable {
        case first
        case second
        case third
        case fourth
    }
    
    private var binder: SectionedTableViewBinder<Section>!
    
    override func setUp() {
        super.setUp()
        self.tableView.tableFooterView = UIView()
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
    }
    
    func testTitles() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        self.binder.onSection(.first)
            .bind(headerTitle: "H1")
            .bind(footerTitle: "F1")
            .bind(cellType: TestCell.self, models: [])
        
        self.binder.onSections(.second, .third)
            .bind(headerTitles: [.second: "H2", .third: "H3"])
            .bind(footerTitles: [.second: "F2", .third: "F3"])
            .bind(cellType: TestCell.self, models: [.second: [], .third: []])
        
        self.binder.onAllOtherSections()
            .bind(headerTitles: [.fourth: "H4"])
            .bind(cellType: TestCell.self, models: [.fourth: []])
            .bind(footerTitles: [.fourth: "F4"])
        
        self.binder.onAnySection()
            .cellHeight { _, _ in 2 }
            .headerHeight { _ in 1 }
            .footerHeight { _ in 1 }
        
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(equal("H2"))
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(equal("H4"))
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(equal("F1"))
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(equal("F3"))
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(equal("F4"))
    }
    
    func testViewModels() {
        self.tableView.register(TestHeaderFooter.self)
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        self.binder.onSection(.first)
            .bind(headerType: TestHeaderFooter.self, viewModel: TestHeaderFooter.ViewModel(title: "H1"))
            .bind(headerTitle: "wrong")
            .bind(footerType: TestHeaderFooter.self, viewModel: TestHeaderFooter.ViewModel(title: "F1"))
            .bind(footerTitle: "wrong")
            .bind(cellType: TestCell.self, models: [])
        
        self.binder.onSections(.second, .third)
            .bind(headerType: TestHeaderFooter.self, viewModels: [
                .second: TestHeaderFooter.ViewModel(title: "H2"),
                .third: TestHeaderFooter.ViewModel(title: "H3")
                ])
            .bind(headerTitles: [.second: "wrong", .third: "wrong"])
            .bind(footerType: TestHeaderFooter.self, viewModels: [
                .second: TestHeaderFooter.ViewModel(title: "F2"),
                .third: TestHeaderFooter.ViewModel(title: "F3")
                ])
            .bind(footerTitles: [.second: "wrong", .third: "wrong"])
            .bind(cellType: TestCell.self, models: [.second: [], .third: []])
        
        self.binder.onAllOtherSections()
            .bind(headerType: TestHeaderFooter.self, viewModels: [.fourth: TestHeaderFooter.ViewModel(title: "H4")])
            .bind(headerTitles: [.fourth: "wrong"])
            .bind(footerType: TestHeaderFooter.self, viewModels: [.fourth: TestHeaderFooter.ViewModel(title: "F4")])
            .bind(footerTitles: [.fourth: "wrong"])
            .bind(cellType: TestCell.self, models: [.fourth: []])
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))

        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(equal("H2"))
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(equal("H4"))
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(equal("F1"))
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(equal("F3"))
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(equal("F4"))
    }
    
    // MARK: -
    
    func testClosureTitles() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var firstHeader: String? = "H1"
        var firstFooter: String? = "F1"
        
        var secondThirdHeaders: [Section: String?] = [.second: "H2", .third: "H3"]
        var secondThirdFooters: [Section: String?] = [.second: "F2", .third: "F3"]
        
        var fourthHeaders: [Section: String?] = [.fourth: "H4"]
        var fourthFooters: [Section: String?] = [.fourth: "F4"]
        
        
        self.binder.onSection(.first)
            .bind(headerTitle: { firstHeader })
            .bind(footerTitle: { firstFooter })
            .bind(cellType: TestCell.self, models: [])
        
        self.binder.onSections(.second, .third)
            .bind(headerTitles: { secondThirdHeaders })
            .bind(footerTitles: { secondThirdFooters })
            .bind(cellType: TestCell.self, models: [.second: [], .third: []])
        
        self.binder.onAllOtherSections()
            .bind(headerTitles: { fourthHeaders })
            .bind(footerTitles: { fourthFooters })
            .bind(cellType: TestCell.self, models: [.fourth: []])
        
        self.binder.onAnySection()
            .cellHeight { _, _ in 2 }
            .headerHeight { _ in 1 }
            .footerHeight { _ in 1 }
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(equal("H2"))
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(equal("H4"))
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(equal("F1"))
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(equal("F3"))
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(equal("F4"))
        
        // update the headers/footers
        firstHeader = "H1*"
        firstFooter = nil
        
        secondThirdHeaders = [.second: nil, .third: "H3"]
        secondThirdFooters = [.second: "F2*", .third: nil]
        
        fourthHeaders = [:]
        fourthFooters = [:]
        self.binder.refresh()
        
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1*"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2*"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
    }
    
    func testClosureViewModels() {
        self.tableView.register(TestHeaderFooter.self)
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        var firstHeader: TestHeaderFooter.ViewModel? = TestHeaderFooter.ViewModel(title: "H1")
        var firstFooter: TestHeaderFooter.ViewModel? = TestHeaderFooter.ViewModel(title: "F1")
        
        var secondThirdHeaders: [Section: TestHeaderFooter.ViewModel?] = [
            .second: TestHeaderFooter.ViewModel(title: "H2"),
            .third: TestHeaderFooter.ViewModel(title: "H3")]
        var secondThirdFooters: [Section: TestHeaderFooter.ViewModel?] = [
            .second: TestHeaderFooter.ViewModel(title: "F2"),
            .third: TestHeaderFooter.ViewModel(title: "F3")]
        
        var fourthHeaders: [Section: TestHeaderFooter.ViewModel?] = [.fourth: TestHeaderFooter.ViewModel(title: "H4")]
        var fourthFooters: [Section: TestHeaderFooter.ViewModel?] = [.fourth: TestHeaderFooter.ViewModel(title: "F4")]
        
        self.binder.onSection(.first)
            .bind(headerType: TestHeaderFooter.self, viewModel: { firstHeader })
            .bind(headerTitle: "wrong")
            .bind(footerType: TestHeaderFooter.self, viewModel: { firstFooter })
            .bind(footerTitle: "wrong")
            .bind(cellType: TestCell.self, models: [])
        
        self.binder.onSections(.second, .third)
            .bind(headerType: TestHeaderFooter.self, viewModels: { secondThirdHeaders })
            .bind(headerTitles: [.second: "wrong", .third: "wrong"])
            .bind(footerType: TestHeaderFooter.self, viewModels: { secondThirdFooters })
            .bind(footerTitles: [.second: "wrong", .third: "wrong"])
            .bind(cellType: TestCell.self, models: [.second: [], .third: []])
        
        self.binder.onAllOtherSections()
            .bind(headerType: TestHeaderFooter.self, viewModels: { fourthHeaders })
            .bind(headerTitles: [.fourth: "wrong"])
            .bind(footerType: TestHeaderFooter.self, viewModels: { fourthFooters })
            .bind(footerTitles: [.fourth: "wrong"])
            .bind(cellType: TestCell.self, models: [.fourth: []])
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        var allHeaderFooters = self.tableView.subviews
            .filter { $0 is UITableViewHeaderFooterView && $0.isHidden == false } as! [UITableViewHeaderFooterView]
        allHeaderFooters.sort { $0.frame.origin.y < $1.frame.origin.y }
        
        let headers = allHeaderFooters.filter { $0.textLabel?.text?.contains("H") == true }
        let footers = allHeaderFooters.filter { $0.textLabel?.text?.contains("F") == true }
        
        for (header, footer) in zip(headers, footers) {
            expect(header.textLabel?.text?.last).to(equal(footer.textLabel?.text?.last))
            expect(header.frame.minY).to(beLessThan(footer.frame.minY))
        }
        
        expect(headers.count).to(equal(4))
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(equal("H2"))
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(equal("H4"))
        
        expect(footers.count).to(equal(4))
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(equal("F1"))
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(equal("F3"))
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(equal("F4"))
        
        // update the headers/footers
        firstHeader = TestHeaderFooter.ViewModel(title: "H1*")
        firstFooter = nil
        
        secondThirdHeaders = [.second: nil, .third: TestHeaderFooter.ViewModel(title: "H3")]
        secondThirdFooters = [.second: TestHeaderFooter.ViewModel(title: "F2*"), .third: nil]
        
        fourthHeaders = [:]
        fourthFooters = [:]
        self.binder.refresh()
        
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1*"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2*"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
    }
    
    // MARK: -
    
    func testRxTitles() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        let firstHeader: BehaviorSubject<String?> = BehaviorSubject(value: "H1")
        let firstFooter: BehaviorSubject<String?> = BehaviorSubject(value: "F1")
        
        let secondThirdHeaders: BehaviorSubject<[Section: String?]>
            = BehaviorSubject(value: [.second: "H2", .third: "H3"])
        let secondThirdFooters: BehaviorSubject<[Section: String?]>
            = BehaviorSubject(value: [.second: "F2", .third: "F3"])
        
        let fourthHeaders: BehaviorSubject<[Section: String?]> = BehaviorSubject(value: [.fourth: "H4"])
        let fourthFooters: BehaviorSubject<[Section: String?]> = BehaviorSubject(value: [.fourth: "F4"])
        
        self.binder.onSection(.first)
            .rx.bind(headerTitle: firstHeader)
            .rx.bind(footerTitle: firstFooter)
            .bind(cellType: TestCell.self, models: [])
        
        self.binder.onSections(.second, .third)
            .rx.bind(headerTitles: secondThirdHeaders)
            .rx.bind(footerTitles: secondThirdFooters)
            .bind(cellType: TestCell.self, models: [.second: [], .third: []])
        
        self.binder.onAllOtherSections()
            .rx.bind(headerTitles: fourthHeaders)
            .rx.bind(footerTitles: fourthFooters)
            .bind(cellType: TestCell.self, models: [.fourth: []])
        
        self.binder.onAnySection()
            .cellHeight { _, _ in 2 }
            .headerHeight { _ in 1 }
            .footerHeight { _ in 1 }
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(equal("H2"))
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(equal("H4"))
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(equal("F1"))
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(equal("F3"))
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(equal("F4"))
        
        // update the headers/footers
        firstHeader.on(.next("H1*"))
        firstFooter.on(.next(nil))
        
        secondThirdHeaders.on(.next([.second: nil, .third: "H3"]))
        secondThirdFooters.on(.next([.second: "F2*", .third: nil]))
        
        fourthHeaders.on(.next([:]))
        fourthFooters.on(.next([:]))
        
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1*"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2*"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
    }
    
    func testRxViewModels() {
        self.tableView.register(TestHeaderFooter.self)
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        let firstHeader: BehaviorSubject<TestHeaderFooter.ViewModel?>
            = BehaviorSubject(value: TestHeaderFooter.ViewModel(title: "H1"))
        let firstFooter: BehaviorSubject<TestHeaderFooter.ViewModel?>
            = BehaviorSubject(value: TestHeaderFooter.ViewModel(title: "F1"))
        
        let secondThirdHeaders: BehaviorSubject<[Section: TestHeaderFooter.ViewModel?]> = BehaviorSubject(value: [
            .second: TestHeaderFooter.ViewModel(title: "H2"),
            .third: TestHeaderFooter.ViewModel(title: "H3")])
        let secondThirdFooters: BehaviorSubject<[Section: TestHeaderFooter.ViewModel?]> = BehaviorSubject(value: [
            .second: TestHeaderFooter.ViewModel(title: "F2"),
            .third: TestHeaderFooter.ViewModel(title: "F3")])
        
        let fourthHeaders: BehaviorSubject<[Section: TestHeaderFooter.ViewModel?]>
            = BehaviorSubject(value: [.fourth: TestHeaderFooter.ViewModel(title: "H4")])
        let fourthFooters: BehaviorSubject<[Section: TestHeaderFooter.ViewModel?]>
            = BehaviorSubject(value: [.fourth: TestHeaderFooter.ViewModel(title: "F4")])
        
        self.binder.onSection(.first)
            .rx.bind(headerType: TestHeaderFooter.self, viewModel: firstHeader)
            .bind(headerTitle: "wrong")
            .rx.bind(footerType: TestHeaderFooter.self, viewModel: firstFooter)
            .bind(footerTitle: "wrong")
            .bind(cellType: TestCell.self, models: [])
        
        self.binder.onSections(.second, .third)
            .rx.bind(headerType: TestHeaderFooter.self, viewModels: secondThirdHeaders)
            .bind(headerTitles: [.second: "wrong", .third: "wrong"])
            .rx.bind(footerType: TestHeaderFooter.self, viewModels: secondThirdFooters)
            .bind(footerTitles: [.second: "wrong", .third: "wrong"])
            .bind(cellType: TestCell.self, models: [.second: [], .third: []])
        
        self.binder.onAllOtherSections()
            .rx.bind(headerType: TestHeaderFooter.self, viewModels: fourthHeaders)
            .bind(headerTitles: [.fourth: "wrong"])
            .rx.bind(footerType: TestHeaderFooter.self, viewModels: fourthFooters)
            .bind(footerTitles: [.fourth: "wrong"])
            .bind(cellType: TestCell.self, models: [.fourth: []])
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        var allHeaderFooters = self.tableView.subviews
            .filter { $0 is UITableViewHeaderFooterView && $0.isHidden == false } as! [UITableViewHeaderFooterView]
        allHeaderFooters.sort { $0.frame.origin.y < $1.frame.origin.y }
        
        let headers = allHeaderFooters.filter { $0.textLabel?.text?.contains("H") == true }
        let footers = allHeaderFooters.filter { $0.textLabel?.text?.contains("F") == true }
        
        for (header, footer) in zip(headers, footers) {
            expect(header.textLabel?.text?.last).to(equal(footer.textLabel?.text?.last))
            expect(header.frame.minY).to(beLessThan(footer.frame.minY))
        }
        
        expect(headers.count).to(equal(4))
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(equal("H2"))
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(equal("H4"))
        
        expect(footers.count).to(equal(4))
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(equal("F1"))
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(equal("F3"))
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(equal("F4"))
        
        // update the headers/footers
        firstHeader.on(.next(TestHeaderFooter.ViewModel(title: "H1*")))
        firstFooter.on(.next(nil))
        
        secondThirdHeaders.on(.next([.second: nil, .third: TestHeaderFooter.ViewModel(title: "H3")]))
        secondThirdFooters.on(.next([.second: TestHeaderFooter.ViewModel(title: "F2*"), .third: nil]))
        
        fourthHeaders.on(.next([:]))
        fourthFooters.on(.next([:]))
        self.binder.refresh()
        
        expect(self.tableView.headerView(forSection: 0)?.textLabel?.text).toEventually(equal("H1*"))
        expect(self.tableView.headerView(forSection: 1)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.headerView(forSection: 2)?.textLabel?.text).toEventually(equal("H3"))
        expect(self.tableView.headerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
        
        expect(self.tableView.footerView(forSection: 0)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 1)?.textLabel?.text).toEventually(equal("F2*"))
        expect(self.tableView.footerView(forSection: 2)?.textLabel?.text).toEventually(beNil())
        expect(self.tableView.footerView(forSection: 3)?.textLabel?.text).toEventually(beNil())
    }
}
