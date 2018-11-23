import UIKit
import Tableau
import RxCocoa
import RxSwift

class SomeCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel {
        let text: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.text
        }
    }
}

class TestViewController: UIViewController {
    enum Section: Int, TableViewSection, Comparable {
        case first
        case second
    }
    
    private var tableView: UITableView!
    private var binder: SectionedTableViewBinder<Section>!
    private let disposeBag = DisposeBag()
    
    private let firstTitle = BehaviorRelay<String?>(value: "F")
    private let firstSectionVMs = BehaviorRelay<[SomeCell.ViewModel]>(value: [])
    private let secondSectionVMs = BehaviorRelay<[TitleDetailTableViewCell.ViewModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Accounts"
        
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView.register(TitleDetailTableViewCell.self)
        self.tableView.register(SomeCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.frame
        
        self.binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
        self.binder.sectionDisplayBehavior = .hidesSectionsWithNoCellData
        
        self.binder.onSection(.first)
//            .rx.bind(cellType: SomeCell.self, viewModels: self.firstSectionVMs.asObservable())
            .bind(cellType: SomeCell.self, viewModels: firstVMs)
//            .bind(headerTitle: "FIRST")
            .rx.bind(headerTitle: self.firstTitle.asObservable())
        
        self.binder.onSection(.second)
            .rx.bind(cellType: TitleDetailTableViewCell.self, viewModels: self.secondSectionVMs.asObservable())
            .bind(headerTitle: "SECOND")

        self.binder.finish()
        
        self.setupOtherViews()
    }
    
    private func setupOtherViews() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.rx.tap
            .map { _ -> (String?, [SomeCell.ViewModel], [TitleDetailTableViewCell.ViewModel]) in
                return (self._title, self.firstVMs, self.secondVMs)
            }
            .subscribe(onNext: { (title, first, second) in
                self.firstTitle.accept(title)
                self.firstSectionVMs.accept(first)
                self.secondSectionVMs.accept(second)
            })
            .disposed(by: self.disposeBag)
    }
    
    private var k: Bool = false
    private var _title: String? {
        k.toggle()
        if k {
            return "FIRST"
        } else {
            return "TITLE"
        }
    }
    
    private var j: Bool = false
    private var firstVMs: [SomeCell.ViewModel] {
        j.toggle()
        if j {
            return [SomeCell.ViewModel(text: "1")]
        } else {
            return [SomeCell.ViewModel(text: "2")]
        }
    }

    private var i: Bool = false
    private var secondVMs: [TitleDetailTableViewCell.ViewModel] {
        i.toggle()
        if i {
            return [
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
        } else {
            return [
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
        }
    }
}
