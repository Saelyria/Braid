import Braid
import RxCocoa
import RxSwift

class HomeViewController: UIViewController {
    // 3.
    struct Section: TableViewSection, CollectionIdentifiable {
        let collectionId: String
        let title: String?
        let footer: String?
        
        static let banner = Section(collectionId: "banner", title: nil, footer: nil)
    }
    
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!
    
    private let disposeBag = DisposeBag()
    
    // 4.
    private let sectionContent = BehaviorRelay<[HomePageSectionContent]>(value: [])
    private var sectionCellViewModels: Observable<[Section: [Any]]> {
        return self.sectionContent.map { $0.reduceToSectionCellViewModels() }
    }
    private var sections: Observable<[Section]> {
        return self.sectionCellViewModels.map {
            var sections = Array($0.keys)
            sections.insert(.banner, at: 0)
            return sections
        }
    }
    private var sectionHeaderTitles: Observable<[Section: String?]> {
        return self.sections.map { $0.reduce(into: [:], { (dict, section) in
            dict[section] = section.title
        }) }
    }
    private var footerViewModels: Observable<[Section: SectionHeaderView.ViewModel?]> {
        return self.sections.map { $0.reduce(into: [:], { (dict, section) in
            if let title = section.footer {
                dict[section] = SectionHeaderView.ViewModel(title: title)
            }
        }) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.view.addSubview(self.tableView)
        self.tableView.allowsSelection = false
        self.tableView.register(CenterLabelTableViewCell.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.tableView.register(ImageTitleSubtitleTableViewCell.self)
        self.tableView.register(SectionHeaderView.self)
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        // 5.
        self.binder.undiffableSectionUpdateAnimation = .left
        
        // 6.
        self.sections
            .bind(to: self.binder.rx.displayedSections)
            .disposed(by: self.disposeBag)
        
        // 7.
        self.binder.onSection(.banner)
            .bind(cellType: CenterLabelTableViewCell.self, viewModels: {
                [CenterLabelTableViewCell.ViewModel(text: "<Brand Name>. Shopping made easy.")]
            })
        
        // 8.
        self.binder.onAllOtherSections()
            .rx.bind(
                cellProvider: { (tableView, section: Section, row: Int, viewModel: Any) in
                    if let viewModel = viewModel as? TitleDetailTableViewCell.ViewModel {
                        let cell = tableView.dequeue(TitleDetailTableViewCell.self)
                        cell.viewModel = viewModel
                        return cell
                    } else if let viewModel = viewModel as? ImageTitleSubtitleTableViewCell.ViewModel {
                        let cell = tableView.dequeue(ImageTitleSubtitleTableViewCell.self)
                        cell.viewModel = viewModel
                        return cell
                    }
                    return UITableViewCell()
                }, models: self.sectionCellViewModels)
            .rx.bind(headerTitles: self.sectionHeaderTitles)
            .rx.bind(footerType: SectionHeaderView.self, viewModels: self.footerViewModels)
        
        self.binder.finish()
        
        // 4.
        HomeService.shared.getHomePage()
            .bind(to: self.sectionContent)
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Helper extensions

private extension Array where Element == HomePageSectionContent {
    /// Reduces an array of 'home page section content' objects into a dictionary of home view sections and cell view
    /// models for those sections.
    func reduceToSectionCellViewModels() -> [HomeViewController.Section: [Any]] {
        return self.reduce(into: [:], { (dict, sectionContent) in
            let section = HomeViewController.Section(
                collectionId: sectionContent.title,
                title: sectionContent.title,
                footer: sectionContent.footer)
            dict[section] = sectionContent.models.mapToCellModels()
        })
    }
}

private extension HomePageSectionContent.Models {
    static let priceFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        return nf
    }()
    
    /// Maps the 'store' and 'product' models in a 'home page section content' into cell view models.
    func mapToCellModels() -> [Any] {
        switch self {
        case .stores(let stores):
            let titleDetailVMs = stores.map { (store: Store) in
                return TitleDetailTableViewCell.ViewModel(
                    collectionId: store.location, title: store.location, subtitle: nil, detail: store.distance, accessoryType: .disclosureIndicator)
            }
            return titleDetailVMs
        case .products(let products):
            let imageTitleViewModels = products.map { (product: Product) in
                return ImageTitleSubtitleTableViewCell.ViewModel(
                    collectionId: product.title,
                    title: product.title,
                    subtitle: HomePageSectionContent.Models.priceFormatter.string(from: NSNumber(value: product.price)),
                    image: UIImage(named: "placeholder")!)
            }
            return imageTitleViewModels
        }
    }
}
