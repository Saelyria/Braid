import Foundation

/**
 A protocol describing an object that can have a view model bound to it with which it can configure itself.
 
 View types that are 'view model bindable' declare a `ViewModel` associated type. This type should have properties for
 the various view data on the view - for example, a cell that is 'view model bindable' that has a title, subtitle, and
 detail label might declare its `ViewModel` type to be this:
 
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
 
 Braid can use this associated 'view model' type to setup your 'view model bindable' cells/views for you when you use
 the `bind(cellType:viewModels:)` or `bind(cellType:models:mapToViewModelWith:)` methods so that you don't have to write
 your own model binding code in an `onDequeue` handler.
 */
public protocol ViewModelBindable {
    /// The type that this object's view model must be.
    associatedtype ViewModel
    
    /**
     The view model supplied to the `ViewModelBindable` instance.
     
     Generally, a 'view model bindable' cell will add a `didSet` block to this property so that when a new view model
     instance is assigned to this property, the cell can set the values from the view model to its appropriate view
     items.
    */
    var viewModel: ViewModel? { get set }
}
