import UIKit
import Tableau
import RxSwift
import RxCocoa

class AccountsViewController: UIViewController {
    // 1.
    enum Section: Int, TableViewSection {
        case message
        case checking
        case savings
        case other
    }

    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var tableView: UITableView!
    // 2.
    private var binder: SectionedTableViewBinder<Section>!
    
    // 3.
    private let accountsForSections = BehaviorRelay<[Section: [Account]]>(value: [:])
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Accounts"
        
        // 4.
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView.register(CenterLabelTableViewCell.self)
        self.tableView.register(SectionHeaderView.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        
        // 5.
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.binder.displayedSections = [.message]
        
        // 6.
        self.binder.onSection(.message)
            .bind(cellType: CenterLabelTableViewCell.self, viewModels: [
                CenterLabelTableViewCell.ViewModel(text: "Open a new savings account today and receive 3.10% for the first three months!")
                ])
        
        // 7.
        self.binder.onSections([.checking, .savings, .other])
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.accountsForSections.asObservable(),
                     mapToViewModelsWith: { (account: Account) in return account.asTitleDetailCellViewModel() })
            // 8.
            .onTapped { [unowned self] (_, _, _, account: Account) in
                let detailVC = UIViewController()
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        
        // 9.
        self.binder.onSections([.checking, .savings, .other])
            .bind(headerType: SectionHeaderView.self, viewModels: [
                .checking: SectionHeaderView.ViewModel(title: "CHECKING"),
                .savings: SectionHeaderView.ViewModel(title: "SAVINGS"),
                .other: SectionHeaderView.ViewModel(title: "OTHER")])
            // 10.
            .footerTitles([
                .other: "This section includes your investing and credit card accounts."])
        
        // 11.
        self.binder.finish()
        
        self.setupOtherViews()
        
        // after we finish binding our table view, fetch the accounts 'from a server'
        self.spinner.startAnimating()
        AccountsService.shared.getAccounts()
            .flatMapToSectionDict()
            .subscribe(onNext: { [unowned self] accounts in
                self.refresh(with: accounts)
            }).disposed(by: self.disposeBag)
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
        
        // With the dictionary returned, set the binder's `displayedSections` property and update the relay objects
        // the binder was setup with for the sections' models arrays. The binder will batch all of these updates,
        // calculate the diff, and animate the changes automatically.
        var displayedSections: [Section] = [.message]
        displayedSections.append(contentsOf: Array(accounts.keys))
        self.binder.displayedSections = displayedSections.sorted(by: { $0.rawValue < $1.rawValue })
        self.accountsForSections.accept(accounts)
    }
}

private extension Observable where Element == [Account] {
    typealias Section = AccountsViewController.Section
    
    func flatMapToSectionDict() -> Observable<[Section: [Account]]> {
        return self.flatMap { (accounts: [Account]) -> Observable<[Section: [Account]]> in
            var accountsForSections: [Section: [Account]] = [:]
            for account in accounts {
                if accountsForSections[account.type.correspondingTableSection] == nil {
                    accountsForSections[account.type.correspondingTableSection] = []
                }
                accountsForSections[account.type.correspondingTableSection]?.append(account)
            }
            return Observable<[Section: [Account]]>.just(accountsForSections)
        }
    }
}

private extension Account.AccountType {
    var correspondingTableSection: AccountsViewController.Section {
        switch self {
        case .checking: return .checking
        case .savings: return .savings
        case .creditCard, .investing: return .other
        }
    }
}

extension Account: CollectionIdentifiable {
    var collectionId: String { return self.accountNumber }
    
    func asTitleDetailCellViewModel() -> TitleDetailTableViewCell.ViewModel {
        return TitleDetailTableViewCell.ViewModel(
            collectionId: self.accountNumber,
            title: self.accountName,
            subtitle: self.accountNumber,
            detail: "$\(self.balance)",
            accessoryType: .disclosureIndicator)
    }
}
