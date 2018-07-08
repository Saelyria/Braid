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

    private let tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
    private var binder: SectionedTableViewBinder<Section>!

    private let savingsAccounts = Variable<[Account]>([])
    private let checkingAccounts = Variable<[Account]>([])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [])
        
        self.binder.onSections([.checking, .savings])
            .rx.bind(cellType: TitleDetailTableViewCell.self, models: [
                Section.checking: Observable.just([1, 2, 3]),
                Section.savings: Observable.just([3, 2, 1])
            ])
//        self.binder.onSection(.checking)
//            .rx.bind(cellType: TitleDetailTableViewCell.self, viewModels: Observable.just([
//                TitleDetailTableViewCell.ViewModel(title: "1", subtitle: "", detail: ""),
//                TitleDetailTableViewCell.ViewModel(title: "2", subtitle: "", detail: ""),
//                TitleDetailTableViewCell.ViewModel(title: "3", subtitle: "", detail: "")
//            ]))
//
//        let accounts = self.getAccountsFromServer().share()
//        accounts.filter({ accounts in
//            accounts.filter({ $0.type == .checking })
//        })
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
