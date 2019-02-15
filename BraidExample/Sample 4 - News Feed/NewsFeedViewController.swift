import UIKit
import Braid
import RxSwift
import RxCocoa

class NewsFeedViewController: UIViewController {
    private let spinner = UIActivityIndicatorView(style: .gray)
    private var binder: TableViewBinder!
    private let tableView = UITableView()
    
    private let disposeBag = DisposeBag()
    // 1.
    private let newsItems = BehaviorRelay<[NewsItem]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"

        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        
        self.binder = TableViewBinder(tableView: self.tableView)
        
        // 2.
        self.binder.onTable()
            .rx.bind(cellType: TitleDetailTableViewCell.self,
                     models: self.newsItems.asObservable(),
                     mapToViewModels: {
                        TitleDetailTableViewCell.ViewModel(
                            collectionId: $0.title,
                            title: $0.title,
                            subtitle: $0.shortSummary,
                            detail: ($0.isAd) ? "Ad" : nil,
                            accessoryType: .none)
                    })
            // 3.
            .prefetch(when: .cellsFromEnd(1)) { [unowned self] (startingIndex) in
                self.fetchNew(startingFrom: startingIndex)
            }
        
        self.binder.finish()
        
        self.tableView.tableFooterView = self.spinner
        self.spinner.startAnimating()
        self.fetchNew(startingFrom: 0)
    }
    
    private func fetchNew(startingFrom index: Int) {
        NewsFeedService.shared.getNewsFeed(startingFrom: index, numberOfItems: 8)
            .map { new in
                var merged = self.newsItems.value
                merged.append(contentsOf: new)
                return merged
            }
            .bind(to: self.newsItems)
            .disposed(by: self.disposeBag)
    }
}
