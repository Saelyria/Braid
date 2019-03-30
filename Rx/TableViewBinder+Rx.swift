import UIKit
import RxSwift
import RxCocoa

extension TableViewBinder: ReactiveCompatible { }
extension SectionedTableViewBinder: ReactiveCompatible { }

public extension Reactive where Base: SectionedTableViewBinderProtocol {
    /// Reactive property of the table view's displayed sections. This array can be changed or reordered at any time to
    /// dynamically update the displayed sections on the table view.
    var displayedSections: ControlProperty<[Base.S]> {
        guard let binder = self.base as? SectionedTableViewBinder<Base.S> else { fatalError("Base wasn't the right type") }
        
        let source: Observable<[Base.S]> = binder.displayedSectionsSubject.asObservable()
        
        let bindingObserver = Binder(binder) { (binder, displayedSections: [Base.S]) in
            binder.displayedSections = displayedSections
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
