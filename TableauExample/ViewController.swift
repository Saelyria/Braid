import UIKit
import Tableau
import RxSwift
import RxCocoa

struct Account {
    enum AccountType {
        case checking
        case savings
    }
    
    let accountName: String
    let accountNumber: String
    let balance: Double
    let type: AccountType
}

class ViewController: UIViewController {
    enum Section: TableViewSection {
        case checking
        case savings
    }

    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!

    private let savingsAccounts = Variable<[Account]>([])
    private let checkingAccounts = Variable<[Account]>([])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.tableFooterView = UIView()
        self.tableView.register(TitleDetailTableViewCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [.checking, .savings])
        
        self.binder.onSections([.checking, .savings])
            .rx.bind(cellType: TitleDetailTableViewCell.self, models: [
                .checking: Observable.just([1, 2, 3]),
                .savings: Observable.just([3, 2, 1])
            ])
            .headerTitles([
                .checking: "CHECKING",
                .savings: "SAVINGS"
            ])
    }

    private func getAccountsFromServer() -> Observable<[Account]> {
        return Observable.create({ observer in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                observer.onNext([
                    Account(accountName: "Every Day Checking", accountNumber: "123***123", balance: 2305.82, type: .checking),
                    Account(accountName: "US Checking", accountNumber: "321***123", balance: 2305.82, type: .checking),
                    Account(accountName: "High-Interest Savings", accountNumber: "465***958", balance: 2305.82, type: .savings)
                ])
                observer.onCompleted()
            }

            return Disposables.create()
        })
    }
}
