import UIKit
import Tableau
import RxSwift
import RxCocoa

/**
 This view controller demonstrates how to use a `TableViewSection` enum to bind a section table view. It's a mock
 'accounts' view controller like you might find in a banking app, where sections on the table view are different types
 of accounts - checking, savings, etc.
 
 The data shown by the table are instances of the `Account` model object, which are 'fetched from the server' by the
 `AccountsService` object. It uses the `CenterLabelTableViewCell`, `TitleDetailTableViewCell`, and `SectionHeaderView`
 objects to display its data. Whenever the 'Refresh' button is tapped in the view's nav bar, it starts a new 'fetch',
 which will fill the table with different data, demonstrating Tableau's ability to auto-animate changes. This view
 controller uses RxSwift to do much of its work.
 */
class AccountsViewController: UIViewController {
    // An enum corresponding to the sections able to be shown on the table view.
    enum Section: Int, TableViewSection, CaseIterable {
        case message
        case checking
        case savings
        case other
    }

    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var tableView: UITableView!
    // A reference to binders must be kept for binding to work.
    private var binder: SectionedTableViewBinder<Section>!
    
    // This is effectively the 'data source' for the table view. This property is observed by the binder, which will
    // update the data for its sections based on the dictionary returned from this.
    private let accountsForSections = BehaviorRelay<[Section: [Account]]>(value: [:])
    
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
            .subscribe(onNext: { [unowned self] accounts in
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
        
        // Bind the static 'message' section. Because this section's content doesn't update, we don't have to use Rx
        // with it. We only need one cell in this section, so our `viewModels` array is just a single string.
        self.binder.onSection(.message)
            .bind(cellType: CenterLabelTableViewCell.self, viewModels: [
                "This is a sample view controller demonstrating how to use an enum for the cases in a table view. Tap the 'Refresh' button to cycle through different combinations."])
        
        // Bind the 'checking', 'savings', and 'other' sections. When we bind multiple sections, we provide an
        // Observable dictionary for the models/view models where the key is each section being bound and the value is
        // the models for that section. 'TitleDetailTableViewCell' is view model compatible, so we also provide a 'map
        // to view model' function that the binder uses to turn our 'Account' arrays into cell view model objects.
        self.binder.onSections([.checking, .savings, .other])
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.accountsForSections.asObservable(),
                     mapToViewModelsWith: { (account: Account) in return account.asTitleDetailCellViewModel() })
            // Next, we bind a custom header class and a dictionary of view models for it just like for cells.
            .bind(headerType: SectionHeaderView.self, viewModels: [
                .checking: SectionHeaderView.ViewModel(title: "CHECKING"),
                .savings: SectionHeaderView.ViewModel(title: "SAVINGS"),
                .other: SectionHeaderView.ViewModel(title: "OTHER")])
            // For footers, we'll just use the default footer view. Note that for the dictionaries we provide for cells,
            // headers, and footers, we only need to provide data for the sections we care about - we only want a footer
            // for the 'other' section, so we only need to include that section in the dictionary.
            .footerTitles([
                .other: "This section includes your investing and credit card accounts."])
        
        // Make sure to call the binder's 'finish' method once everything is bound.
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
        
        // With the dictionary returned, set the binder's `displayedSections` property and update the relay objects
        // the binder was setup with for the sections' models arrays. The binder will batch all of these updates,
        // calculate the diff, and animate the changes automatically.
        var displayedSections: [Section] = [.message]
        displayedSections.append(contentsOf: Array(accounts.keys))
        self.binder.displayedSections = displayedSections.sorted(by: { $0.rawValue < $1.rawValue })
        self.accountsForSections.accept(accounts)
    }
}

fileprivate extension Observable where Element == [Account] {
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

fileprivate extension Account.AccountType {
    var correspondingTableSection: AccountsViewController.Section {
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
            id: self.accountNumber,
            title: self.accountName,
            subtitle: self.accountNumber,
            detail: "$\(self.balance)",
            accessoryType: .disclosureIndicator)
    }
}
