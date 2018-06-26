import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: SectionedTableViewBinderProtocol {
    var displayedSections: ControlProperty<[Base.S]> {
        guard let binder = self.base as? SectionedTableViewBinder<Base.S> else { fatalError("Base wasn't the right type") }
        
        return ControlProperty(values: binder.displayedSectionsSubject.asObservable(), valueSink: binder.displayedSectionsSubject)
    }
}
