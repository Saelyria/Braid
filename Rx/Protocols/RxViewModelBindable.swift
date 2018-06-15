import Foundation
import RxSwift

/**
 Describes an object that can have a view model bound to it with which it can configure itself.
 
 A `ViewModelBindable` can be any object (especially a view object, like a `UITableViewCell`) that can, when given a
 view model, binds that data to itself. The object conforming to this protocol declares what its view model type is
 with its associated `ViewModel` type.
 */
public protocol RxViewModelBindable {
    /// The type that this object's view model must be.
    associatedtype ViewModel
    
    /// The view model supplied to the `ViewModelBindable` instance.
    var viewModel: Variable<ViewModel?> { get }
}
