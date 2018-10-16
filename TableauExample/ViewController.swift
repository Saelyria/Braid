import UIKit
import Tableau
import RxSwift
import RxCocoa

struct Account: Identifiable {
    enum AccountType {
        case checking
        case savings
    }
    
    let accountName: String
    let accountNumber: String
    let balance: Double
    let type: AccountType
    
    var id: String { return self.accountNumber }
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

        // create and setup table view
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView.tableFooterView = UIView()
        self.tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: CGFloat.leastNormalMagnitude)))
        self.tableView.register(SectionHeaderView.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        
        // create the table view binder
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [])
        
        // bind the 'checking' and 'savings' sections
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
            .footerTitles([
                .checking: "These are your checking accounts",
                .savings: "These are your savings accounts."
            ])
            .estimatedCellHeight { _, _ in return 44 }
        
        self.binder.onSection(.savings)
            .onTapped { (_, _) in
                self.binder.displayedSections = [.savings, .checking]
            }
        
        self.binder.onSection(.checking)
            .onTapped { (_, _) in
                self.binder.displayedSections = [.savings, .other, .checking]
            }
        
        // bind the 'other' section
        self.binder.onSection(.other)
            .rx.bind(cellType: TitleDetailTableViewCell.self, models: self.checkingAccounts.asObservable(), mapToViewModelsWith: { account in
                return TitleDetailTableViewCell.ViewModel(
                    title: account.accountName, subtitle: account.accountNumber, detail: "\(account.balance)")
            })
            .headerTitle("OTHER")
            .estimatedCellHeight { _ in return 44 }
            .onTapped { (_, _) in
                self.binder.displayedSections = [.checking, .savings, .other]
            }
        
        self.binder.finish()
        
        self.getAccountsFromServer().subscribe(onNext: { accounts in
            self.binder.displayedSections = [.checking, .savings, .other]
            self.savingsAccounts.value = accounts
            self.checkingAccounts.value = accounts
        }).disposed(by: self.disposeBag)
    }

    private func getAccountsFromServer() -> Observable<[Account]> {
        return Observable.create({ observer in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
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
