import UIKit
import Tableau
import RxSwift
import RxCocoa

/**
 
 */
class AccountsViewController: UIViewController {
    // An enum corresponding to the section able to be shown on the table view.
    enum Section: Int, TableViewSection {
        case message
        case checking
        case savings
        case other
    }

    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!

    private let savingsAccounts = BehaviorRelay<[Account]>(value: [])
    private let checkingAccounts = BehaviorRelay<[Account]>(value: [])
    private let otherAccounts = BehaviorRelay<[Account]>(value: [])
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Accounts"
        
        self.setupTableView()
        self.setupOtherViews()
        
        // after we finish binding our table view, fetch the accounts 'from a server'
        self.spinner.startAnimating()
        AccountsService.shared.getAccounts()
            .flatMapToSectionDict()
            .subscribe(onNext: { accounts in
                self.refresh(with: accounts)
            }).disposed(by: self.disposeBag)
    }
    
    private func setupTableView() {
        // Create and setup table view. Tableau provides convenient `register()` methods for `UITableViewCell` and
        // `UITableHeaderFooterView` subclasses for registering the cells/views.
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView.register(CenterLabelTableViewCell.self)
        self.tableView.register(SectionHeaderView.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        
        // Create the table view binder, starting off with only the 'message' section shown. The other sections will be
        // shown on the table once the mock 'accounts' request completes.
        self.binder = SectionedTableViewBinder(
            tableView: self.tableView, sectionedBy: Section.self, displayedSections: [.message])
        
        self.binder.onSection(.message)
            .bind(cellType: CenterLabelTableViewCell.self, viewModels: [
                "This is a sample view controller demonstrating how to use an enum for the cases in a table view."])
        
        // Bind the 'checking' and 'savings' sections.
        self.binder.onSections([.checking, .savings, .other])
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: [
                        .checking: self.savingsAccounts.asObservable(),
                        .savings: self.checkingAccounts.asObservable(),
                        .other: self.otherAccounts.asObservable()],
                     mapToViewModelsWith: { (account: Account) in return account.asTitleDetailCellViewModel() })
            .bind(headerType: SectionHeaderView.self, viewModels: [
                .checking: "CHECKING",
                .savings: "SAVINGS",
                .other: "OTHER"])
            .footerTitles([
                .checking: "These are your checking accounts",
                .savings: "These are your savings accounts."])
        
        self.binder.finish()
    }
    
    private func setupOtherViews() {
        self.view.addSubview(self.spinner)
        self.spinner.center = self.view.center
        self.spinner.hidesWhenStopped = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.rx.tap
            .do(onNext: { [unowned self] _ in
                self.spinner.startAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            })
            .flatMap { AccountsService.shared.getAccounts() }
            .flatMapToSectionDict()
            .subscribe(onNext: { [unowned self] accounts in
                self.refresh(with: accounts)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func refresh(with accounts: [Section: [Account]]) {
        self.spinner.stopAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        var displayedSections: [Section] = [.message]
        displayedSections.append(contentsOf: Array(accounts.keys))
        self.binder.displayedSections = displayedSections.sorted(by: { $0.rawValue < $1.rawValue })
        self.savingsAccounts.accept(accounts[.savings] ?? [])
        self.checkingAccounts.accept(accounts[.checking] ?? [])
        self.otherAccounts.accept(accounts[.other] ?? [])
    }
}

fileprivate extension Observable where Element == [Account] {
    typealias Section = AccountsViewController.Section
    
    func flatMapToSectionDict() -> Observable<[Section: [Account]]> {
        return self.flatMap { (accounts: [Account]) -> Observable<[Section: [Account]]> in
            var accountsForSections: [Section: [Account]] = [:]
            for account in accounts {
                if accountsForSections[account.type.tableViewSection] == nil {
                    accountsForSections[account.type.tableViewSection] = []
                }
                accountsForSections[account.type.tableViewSection]?.append(account)
            }
            return Observable<[Section: [Account]]>.just(accountsForSections)
        }
    }
}

fileprivate extension Account.AccountType {
    var tableViewSection: AccountsViewController.Section {
        switch self {
        case .checking: return .checking
        case .savings: return .savings
        case .creditCard, .investing: return .other
        }
    }
}

fileprivate extension Account {
    func asTitleDetailCellViewModel() -> TitleDetailTableViewCell.ViewModel {
        return TitleDetailTableViewCell.ViewModel(
            title: self.accountName,
            subtitle: self.accountNumber,
            detail: "$\(self.balance)")
    }
}
