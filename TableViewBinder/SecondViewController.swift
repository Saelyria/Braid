import UIKit
import RxSwift

class SecondViewController: UIViewController {
    enum Section: TableViewSection {
        case section1
        case section2
        case section3
        case section4

        static let allSections: [Section] = [.section1, .section2, .section3, .section4]
    }

    @IBOutlet private weak var tableView: UITableView!
    private var tableViewBinder: SectionedTableViewBinder<Section>!
    
    let section1Models = Variable<[(Int, Int)]>([(1, 1), (2, 2)])
    let section2Models = Variable<[(Int, Int)]>([(3, 3), (4, 4)])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Second VC loaded")
        
        let sectionModels: [Section: Observable<[(Int, Int)]>] = [
            .section1: self.section1Models.asObservable(),
            .section2: self.section2Models.asObservable()
        ]
        
        self.tableViewBinder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.tableViewBinder
            .onSections([.section1, .section2])
            .bind(cellType: SecondTableViewCell.self, models: sectionModels, mapToViewModelsWith: { (m1, m2) in
                return SecondTableViewCell.ViewModel(title: String(m1), subtitle: String(m2))
            })
            .onTapped { [weak self] (_, _, _, model) in
                print(model)
                self?.dismiss(animated: true, completion: nil)
            }
        
        for _ in 0...10 {
            self.section1Models.value.append(contentsOf: self.section1Models.value)
        }
    }

    deinit {
        print("no retain cycles!")
    }
}

class SecondTableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
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

