import Foundation

/**
 A protocol describing an object that can have a view model bound to it with which it can configure itself.
 
 View types that are 'view model bindable' declare a `ViewModel` associated type. This type should have properties for
 the various view data on the view - for example, a cell that is 'view model bindable' that has a title, subtitle, and
 detail labe might declare its `ViewModel` type to be this:
 ```
 struct ViewModel {
    let title: String
    let subtitle: String
    let detail: String
 }
 ```
 
 The view then declares a settable `viewModel` property of this type. Whenever this property is set with a new instance
 of its view model type, the view should then update the appropriate labels/image views/etc with the data on the view
 model.
 
 Tableau can use this associated 'view model' type to setup your 'view model bindable' cells/views for you when you use
 the `bind(cellType:viewModels:)` or `bind(cellType:models:mapToViewModelWith:)` methods.
 */
public protocol ViewModelBindable {
    /// The type that this object's view model must be.
    associatedtype ViewModel
    
    /// The view model supplied to the `ViewModelBindable` instance.
    var viewModel: ViewModel? { get set }
}
