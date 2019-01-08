import XCTest
@testable import Tableau
import Nimble

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
        expect(headers[safe: 0]?.textLabel?.text).to(equal("H1"))
        expect(headers[safe: 1]?.textLabel?.text).to(equal("H2"))
        expect(headers[safe: 2]?.textLabel?.text).to(equal("H3"))
        expect(headers[safe: 3]?.textLabel?.text).to(equal("H4"))
        
        expect(footers.count).to(equal(4))
        expect(footers[safe: 0]?.textLabel?.text).to(equal("F1"))
        expect(footers[safe: 1]?.textLabel?.text).to(equal("F2"))
        expect(footers[safe: 2]?.textLabel?.text).to(equal("F3"))
        expect(footers[safe: 3]?.textLabel?.text).to(equal("F4"))
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
        expect(headers[safe: 0]?.textLabel?.text).to(equal("H1"))
        expect(headers[safe: 1]?.textLabel?.text).to(equal("H2"))
        expect(headers[safe: 2]?.textLabel?.text).to(equal("H3"))
        expect(headers[safe: 3]?.textLabel?.text).to(equal("H4"))
        
        expect(footers.count).to(equal(4))
        expect(footers[safe: 0]?.textLabel?.text).to(equal("F1"))
        expect(footers[safe: 1]?.textLabel?.text).to(equal("F2"))
        expect(footers[safe: 2]?.textLabel?.text).to(equal("F3"))
        expect(footers[safe: 3]?.textLabel?.text).to(equal("F4"))
    }
}
