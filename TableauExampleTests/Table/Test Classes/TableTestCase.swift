import XCTest

class TableTestCase: XCTestCase {
    var viewController: UIViewController!
    var tableView: UITableView!
    
    override func setUp() {
        super.setUp()
        
        self.viewController = UIViewController()
        self.tableView = UITableView()
        self.tableView.register(TestCell.self)
        self.tableView.register(TestViewModelCell.self)
        UIApplication.shared.keyWindow?.rootViewController = self.viewController
        self.viewController.perform(#selector(viewController.loadView), on: Thread.main, with: nil, waitUntilDone: true)
        self.viewController.view.addSubview(self.tableView)
        self.tableView.frame = self.viewController.view.frame
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.viewController = nil
        self.tableView = nil
        UIApplication.shared.keyWindow?.rootViewController = nil
    }
}
