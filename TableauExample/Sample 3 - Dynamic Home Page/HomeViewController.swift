import Tableau
import RxCocoa

class HomeViewController: UIViewController {
    struct Section: TableViewSection, CollectionIdentifiable {
        let collectionId: String
        let title: String?
        let footer: String?
    }
    
    enum CellModels {
        case centeredLabel([CenterLabelTableViewCell.ViewModel])
        case imageTitleSubtitle([ImageTitleSubtitleTableViewCell.ViewModel])
        case titleDetail([TitleDetailTableViewCell.ViewModel])
    }
    
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!
    
    private let sectionCellModels = BehaviorRelay<[Section: [CollectionIdentifiable]]>(value: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
    }
    
    private func setupTableView() {
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.view.addSubview(self.tableView)
        self.tableView.register(CenterLabelTableViewCell.self)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.tableView.register(ImageTitleSubtitleTableViewCell.self)
        
        let banner = Section(collectionId: "banner", title: nil, footer: nil)
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self, displayedSections: [banner])
        
        self.binder.onSection(banner)
            .bind(cellType: CenterLabelTableViewCell.self, viewModels: [
                CenterLabelTableViewCell.ViewModel(text: "<Brand Name>. Shopping made easier.")
            ])
        
//        self.binder.onAllOtherSections()
//            .rx.bind(cellProvider: { [unowned self] (section: Section, row: Int, model: CollectionIdentifiable) in
//                if let viewModel = model as? TitleDetailTableViewCell.ViewModel {
//                    let cell = self.tableView.dequeue(TitleDetailTableViewCell.self)
//                    cell.viewModel = viewModel
//                    return cell
//                } else if let viewModel = model as? ImageTitleSubtitleTableViewCell.ViewModel {
//                    let cell = self.tableView.dequeue(ImageTitleSubtitleTableViewCell.self)
//                    cell.viewModel = viewModel
//                    return cell
//                }
//                return UITableViewCell()
//            }, models: self.sectionCellModels.asObservable())
    }
}

private extension HomePageSection {
    func asSectionModel() -> (HomeViewController.Section, [CollectionIdentifiable]) {
        let section = HomeViewController.Section(
            collectionId: self.title,
            title: self.title,
            footer: self.footer)
        return (section, self.modelType.asCellModels())
    }
}

private extension HomePageSection.ModelType {
    func asCellModels() -> [CollectionIdentifiable] {
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
                    collectionId: product.title)
            }
            return imageTitleViewModels
        }
    }
}
