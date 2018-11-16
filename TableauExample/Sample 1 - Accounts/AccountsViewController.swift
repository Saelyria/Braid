import UIKit
import Tableau
import RxSwift
import RxCocoa

class AccountsViewController: UIViewController {
    // 1.
    enum Section: Int, TableViewSection, Comparable {
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
        
        // 6.
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoCellData
        
        // 7.
        self.binder.onSection(.message)
            .bind(cellType: CenterLabelTableViewCell.self, viewModels: [
                CenterLabelTableViewCell.ViewModel(text: "Open a new savings account today and receive 3.10% for the first three months!")
            ])
        
        // 8.
        self.binder.onSections(.checking, .savings, .other)
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.accountsForSections.asObservable(),
                     mapToViewModelsWith: { (account: Account) in return account.asTitleDetailCellViewModel() })
            // 9.
            .onTapped { [unowned self] (_, _, cell: TitleDetailTableViewCell, account: Account) in
                cell.setSelected(false, animated: true)
                let detailVC = AccountDetailViewController()
                detailVC.account = account
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            .dimensions(.cellHeight { section, row, model in 100 })
        
        // 10.
        self.binder.onSections(.checking, .savings, .other)
            .bind(headerType: SectionHeaderView.self, viewModels: [
                .checking: SectionHeaderView.ViewModel(title: "CHECKING"),
                .savings: SectionHeaderView.ViewModel(title: "SAVINGS"),
                .other: SectionHeaderView.ViewModel(title: "OTHER")])
            // 11.
            .bind(footerTitles: [
                .other: "This section includes your investing and credit card accounts."])
        
        // 12.
        self.binder.finish()
        
        self.setupOtherViews()
        
        // after we finish binding our table view, fetch the accounts 'from a server'
        self.spinner.startAnimating()
        AccountsService.shared.getAccounts()
            .do(onNext: { [unowned self] _ in
                self.spinner.stopAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            })
            .flatMapToSectionDict()
            .bind(to: self.accountsForSections)
            .disposed(by: self.disposeBag)
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
            .do(onNext: { [unowned self] _ in
                self.spinner.stopAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            })
            .flatMapToSectionDict()
            .bind(to: self.accountsForSections)
            .disposed(by: self.disposeBag)
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

private extension Account {
    func asTitleDetailCellViewModel() -> TitleDetailTableViewCell.ViewModel {
        return TitleDetailTableViewCell.ViewModel(
            collectionId: self.accountNumber,
            title: self.accountName,
            subtitle: self.accountNumber,
            detail: "$\(self.balance)",
            accessoryType: .disclosureIndicator)
    }
}
