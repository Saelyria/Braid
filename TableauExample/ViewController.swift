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
        case other
    }

    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!

    private let savingsAccounts = Variable<[Account]>([])
    private let checkingAccounts = Variable<[Account]>([])
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.tableFooterView = UIView()
        self.tableView.register(SectionHeaderView.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [.checking, .savings, .other])
        
        self.binder.onSections([.checking, .savings])
            .rx.bind(cellType: TitleDetailTableViewCell.self, models: [
                .checking: self.savingsAccounts.asObservable(),
                .savings: self.checkingAccounts.asObservable()
            ], mapToViewModelsWith: { (account: Account) in
                return TitleDetailTableViewCell.ViewModel(
                    title: account.accountName, subtitle: account.accountNumber, detail: "\(account.balance)")
            })
            .bind(headerType: SectionHeaderView.self, viewModels: [
                .checking: "CHECKING",
                .savings: "SAVINGS"
            ])
        
        self.binder.onSection(.other)
            .rx.bind(cellType: TitleDetailTableViewCell.self, models: self.checkingAccounts.asObservable(), mapToViewModelsWith: { account in
                return TitleDetailTableViewCell.ViewModel(
                    title: account.accountName, subtitle: account.accountNumber, detail: "\(account.balance)")
            })
            .bind(headerType: SectionHeaderView.self, viewModel: "OTHER")
        
        self.getAccountsFromServer().subscribe(onNext: { accounts in
            self.savingsAccounts.value = accounts
            self.checkingAccounts.value = accounts
        }).disposed(by: self.disposeBag)
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
