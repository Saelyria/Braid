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
    
    func testHeaderTitles() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: [])
            .bind(headerTitle: "H1")
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: [
                .second: [],
                .third: []
            ])
            .bind(headerTitles: [
                .second: "H2",
                .third: "H3"
            ])
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: [.fourth: []])
            .bind(headerTitles: [.fourth: "H4"])
        
        self.binder.onAnySection()
            .cellHeight { _, _ in 2 }
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        var headers = self.tableView.subviews.filter { $0 is UITableViewHeaderFooterView } as! [UITableViewHeaderFooterView]
        headers.sort { $0.frame.origin.y < $1.frame.origin.y }
        expect(headers.count).to(equal(4))
        expect(headers[0].textLabel?.text).to(equal("H1"))
        expect(headers[1].textLabel?.text).to(equal("H2"))
        expect(headers[2].textLabel?.text).to(equal("H3"))
        expect(headers[3].textLabel?.text).to(equal("H4"))
    }
    
    func testFooterTitles() {
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: [])
            .bind(footerTitle: "F1")
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: [
                .second: [],
                .third: []
                ])
            .bind(footerTitles: [
                .second: "F2",
                .third: "F3"
                ])
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: [.fourth: []])
            .bind(footerTitles: [.fourth: "F4"])

        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        var footers = self.tableView.subviews.filter { $0 is UITableViewHeaderFooterView } as! [UITableViewHeaderFooterView]
        footers.sort { $0.frame.origin.y < $1.frame.origin.y }
        expect(footers.count).to(equal(4))
        expect(footers[0].textLabel?.text).to(equal("F1"))
        expect(footers[1].textLabel?.text).to(equal("F2"))
        expect(footers[2].textLabel?.text).to(equal("F3"))
        expect(footers[3].textLabel?.text).to(equal("F4"))
    }

    func testHeaderViewModels() {
        self.tableView.register(TestHeaderFooter.self)
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: [])
            .bind(headerType: TestHeaderFooter.self, viewModel: TestHeaderFooter.ViewModel(title: "H1"))
            .bind(headerTitle: "wrong")
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: [
                .second: [],
                .third: []
            ])
            .bind(headerType: TestHeaderFooter.self, viewModels: [
                .second: TestHeaderFooter.ViewModel(title: "H2"),
                .third: TestHeaderFooter.ViewModel(title: "H3")
            ])
            .bind(headerTitles: [
                .second: "wrong",
                .third: "wrong"
            ])
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: [.fourth: []])
            .bind(headerType: TestHeaderFooter.self, viewModels: [
                .fourth: TestHeaderFooter.ViewModel(title: "H4")
            ])
            .bind(headerTitles: [.fourth: "wrong"])
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        var headers = self.tableView.subviews.filter { $0 is TestHeaderFooter } as! [TestHeaderFooter]
        headers.sort { $0.frame.origin.y < $1.frame.origin.y }
        expect(headers.count).to(equal(4))
        expect(headers[0].textLabel?.text).to(equal("H1"))
        expect(headers[1].textLabel?.text).to(equal("H2"))
        expect(headers[2].textLabel?.text).to(equal("H3"))
        expect(headers[3].textLabel?.text).to(equal("H4"))
    }
    
    func testFooterViewModels() {
        self.tableView.register(TestHeaderFooter.self)
        self.binder.displayedSections = [.first, .second, .third, .fourth]
        
        self.binder.onSection(.first)
            .bind(cellType: TestCell.self, models: [])
            .bind(footerType: TestHeaderFooter.self, viewModel: TestHeaderFooter.ViewModel(title: "F1"))
            .bind(footerTitle: "wrong")
        
        self.binder.onSections(.second, .third)
            .bind(cellType: TestCell.self, models: [
                .second: [],
                .third: []
            ])
            .bind(footerType: TestHeaderFooter.self, viewModels: [
                .second: TestHeaderFooter.ViewModel(title: "F2"),
                .third: TestHeaderFooter.ViewModel(title: "F3")
            ])
            .bind(footerTitles: [
                .second: "wrong",
                .third: "wrong"
            ])
        
        self.binder.onAllOtherSections()
            .bind(cellType: TestCell.self, models: [.fourth: []])
            .bind(footerType: TestHeaderFooter.self, viewModels: [
                .fourth: TestHeaderFooter.ViewModel(title: "F4")
            ])
            .bind(footerTitles: [.fourth: "wrong"])
        
        self.binder.finish()
        
        // test we got no cells
        expect(self.tableView.visibleCells.count).toEventually(equal(0))
        var footers = self.tableView.subviews.filter { $0 is TestHeaderFooter } as! [TestHeaderFooter]
        footers.sort { $0.frame.origin.y < $1.frame.origin.y }
        expect(footers.count).to(equal(4))
        expect(footers[0].textLabel?.text).to(equal("F1"))
        expect(footers[1].textLabel?.text).to(equal("F2"))
        expect(footers[2].textLabel?.text).to(equal("F3"))
        expect(footers[3].textLabel?.text).to(equal("F4"))
    }

}
