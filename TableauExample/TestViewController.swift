import UIKit
import Tableau
import RxCocoa
import RxSwift

class TestViewController: UIViewController {
    enum Section: Int, TableViewSection, Comparable {
        case first
        case second
    }
    
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!
    private let disposeBag = DisposeBag()
    
    private let viewModels = BehaviorRelay<[Section: [TitleDetailTableViewCell.ViewModel]]>(value: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Accounts"
        
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoCellData
        
        // 7.
        self.binder.onAllSections()
            .rx.bind(cellType: TitleDetailTableViewCell.self, viewModels: self.viewModels.asObservable())

        self.binder.finish()
        
        self.setupOtherViews()
    }
    
    private func setupOtherViews() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.rx.tap
            .map { _ in
                return self._possibleViewModels
            }
            .bind(to: self.viewModels)
            .disposed(by: self.disposeBag)
    }

    private var i: Bool = false
    private var _possibleViewModels: [Section: [TitleDetailTableViewCell.ViewModel]] {
        i.toggle()
        if i {
            return [
                .first: [
                    TitleDetailTableViewCell.ViewModel(
                        collectionId: "1",
                        title: "short",
                        subtitle: nil,
                        detail: nil,
                        accessoryType: .none),
                    TitleDetailTableViewCell.ViewModel(
                        collectionId: "2",
                        title: "short",
                        subtitle: nil,
                        detail: nil,
                        accessoryType: .none)]
            ]
        } else {
            return [
                .first: [
                    TitleDetailTableViewCell.ViewModel(
                        collectionId: "1",
                        title: "short",
                        subtitle: nil,
                        detail: nil,
                        accessoryType: .none),
                    TitleDetailTableViewCell.ViewModel(
                        collectionId: "2",
                        title: "This is a really long block of text that will hopefully go over two lines if everything works as I expect it to and should be reloaded in the diff",
                        subtitle: nil,
                        detail: nil,
                        accessoryType: .none)]
            ]
        }
    }
}
