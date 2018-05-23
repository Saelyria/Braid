import UIKit
import RxSwift

class ViewController: UIViewController {
    enum Section: TableViewSection {
        case section1
        case section2
        case section3
        case section4

        static let allSections: [Section] = [.section1, .section2, .section3, .section4]
    }

    @IBOutlet private weak var tableView: UITableView!
    private var tableViewBinder: SectionedTableViewBinder<Section>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("First VC loaded")
        
        let sectionViewModels: [Section: Observable<[TableViewCell.ViewModel]>] = [
            .section1: Observable<[TableViewCell.ViewModel]>.just([
                TableViewCell.ViewModel(title: "Title", subtitle: "Subtitle")
            ]),
            .section2: Observable<[TableViewCell.ViewModel]>.just([
                TableViewCell.ViewModel(title: "Title", subtitle: "Subtitle"),
                TableViewCell.ViewModel(title: "Title", subtitle: "Subtitle")
            ])
        ]

        self.tableViewBinder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.tableViewBinder
            .onSections([.section1, .section2])
            .bind(cellType: TableViewCell.self, viewModels: sectionViewModels)
            .onTapped { [weak self] _, _, _ in
                let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController")
                self?.present(secondVC, animated: true, completion: nil)
            }
    }
}

class TableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel {
        let title: String
        let subtitle: String
    }

    let viewModel = Variable<ViewModel?>(nil)

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewModel.asObservable().subscribe(onNext: { model in
            self.titleLabel.text = model?.title
            self.subtitleLabel.text = model?.subtitle
        }).disposed(by: self.disposeBag)
    }
}
