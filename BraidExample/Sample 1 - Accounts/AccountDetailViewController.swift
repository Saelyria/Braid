import UIKit

class AccountDetailViewController: UIViewController {
    var account: Account? {
        didSet {
            guard let name = self.account?.accountName, let balance = self.account?.balance else { return }
            self.label.text = "This is showing details for:\n'\(name)'\n with a balance of:\n '$\(balance)'"
        }
    }
    
    private let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.account?.accountName ?? "Account Details"
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.label)
        self.label.textAlignment = .center
        self.label.numberOfLines = 0
        self.label.sizeToFit()
        self.label.center = self.view.center
    }
}
