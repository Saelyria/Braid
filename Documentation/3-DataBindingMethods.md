#  Other data binding methods

## Cells

Braid offers a number of different methods that you can use to bind cells and data to your table view. The cell binding variants (roughly in 
order of 'granularity of control') are:

- `bind(cellType:models:)` (cell type + models)
- `bind(cellType:viewModels:)` (cell type + view models)
- `bind(cellType:models:mapToViewModels:)` (cell type + models + view model mapping)
- `bind(cellProvider:models:)` (cell provider + models)
- `bind(cellProvider:numberOfCells:)` (cell provider + number of cells)

> Each of these variants is available on the `.rx` extension to allow models, view models, or number of cells to be observable or, if you're not
using RxSwift, each variant also has an overload where you can pass in an 'update callback' closure reference.

### Cell type + models

This method declares the given `UITableViewCell` type to be used for the section(s) being bound. It also declares that cells are dequeued 
according to the given array (or dictionary) of 'model' objects; one cell for each model. The cell type and model type are passed along down 
the chain for type safety and ability to have 'model' instances given to various handlers.

Examples of this cell binding method can be found in the [getting started](GettingStarted.md) tutorial, but it generally looks like this:

```swift
class CustomTableViewCell: UITableViewCell, ReuseIdentifiable {
    ...
}

let models: [MyModel] = ...

binder.onSection(.first)
    .bind(cellType: CustomTableViewCell.self, models: models)
    ...
```

### Cell type + view models

> Using view models with cells is a little more involved, but can shorten your binding chains. However, they do assume some familiarity with
Swift protocol [associated types](https://docs.swift.org/swift-book/LanguageGuide/Generics.html#ID189), so if you haven't used them before,
now is a great time to learn them!

This method is largely the same as the previous 'model' one - it declares the given `UITableViewCell` type to be used for the section(s) being
bound. It also declares that cells are dequeued according to the given array (or dictionary) of 'view model' objecst; one cell for each view 
model.

'View models' are a little different than 'models'. To use this method, the table view cell type declared must conform to a protocol called
`ViewModelBindable`. This 'view model bindable' protocol has a view class declare an associated `ViewModel` type that it can be setup 
with. These 'view models' should describe the cell's entire view state and are automatically bound to dequeued cells, so you don't need to 
include an `onDequeue` method when using view models.

This method is most often used for relatively static content that doesn't really have a raw 'model' object that you manipulate anywhere else, 
like a 'banner' cell or cells in some kind of form. An example of its use can be found in the first sample ('Accounts') in the sample project to
implement a 'banner' cell. Most of the table view cell types in the sample project conform to `ViewModelBindable`, so you can see what an
implementation of that protocol looks like there as well. Generally, it will look something like this:

```swift
class CustomTableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel {
        let title: String
        let subtitle: String
        ...
    }
    
    var viewModel: ViewModel? {
        didSet {
            ...
        }
    }
    ...
}

let viewModels: [CustomTableViewCell.ViewModel] = ...

binder.onSection(.first)
    .bind(cellType: CustomTableViewCell.self, viewModels: viewModels)
    ...
```

### Cell type + models + view model mapping

This method involves binding a `ViewModelBindable` cell type that is dequeued according to an array of raw 'model' objects. The raw model
objects are mapped to instances of the cell's `ViewModel` type by the given mapping function then bound to dequeued cells. This method 
provides the most type information to the binding chain, allowing both models and view models to be available in handlers later in the chain.

This method is used a lot throughout the sample projects in a few different ways, so check them out for an idea of the implementation. 
Generally, it looks something like this:

```swift
class CustomTableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel {
        let title: String
        let subtitle: String
        ...
    }

    var viewModel: ViewModel? {
        didSet {
            ... 
        }
    }
    ...
}

let models: [MyModel] = ...

binder.onSection(.first)
    .bind(cellType: CustomTableViewCell.self, 
          models: models,
          mapToViewModels { (model: MyModel) in
              return CustomTableViewCell.ViewModel(...)
          }
    ...
```

### Cell provider + models

For sections or tables that use multiple cell types in a section or where cell construction is more complicated, you can call the cell binding 
method with a closure that will create the cells for an array of model objects. So if, for example, you have an array of different data types where
the different types map to different model objects, you would use this method. The 'cell provider' closure is passed in the row and model 
object (cast to the type of the array you pass in).

Generally, this cell binding method looks something like this:

```swift
let models: [Any] = ["dog", "cat", 42, "raptor"]

binder.onTable()
    .bind(cellProvider: { (tableView, row: Int, model: Any) in
        if let string = model as? String {
            return tableView.dequeue(MyFirstCellType.self)
        } else {
            return tableView.dequeue(MySecondCellType.self)
        }
    }, models: models)
```

A particularly useful way to use this method is to wrap your models in an enum with associated values, like this:

```swift
enum Model {
    case string(String)
    case integer(Int)
}

let models: [Model] = [.string("dog"), .string("cat"), .integer(42)]

binder.onTable()
    .bind(cellProvider: { (tableView, row: Int, model: Model) in
        switch model {
        case .string(let string):
            return tableView.dequeue(MyFirstCellType.self)
        case .int(let int):
            return tableView.dequeue(MySecondCellType.self)
        }
    }, models: models)
    ...
```

### Cell provider + number of cells

This method is just a thin wrapper around the default `tableView(_:numberOfRowsInSection:)` and `tableView(_:cellForRowAt:)` 
methods and gives you all the flexibility the default UIKit API gives you. It's recommended that you use one of the other methods if you can,
but if you find yourself with a particularly complicated problem, this method is always available. 

It's generally used something like this:

```swift
binder.onTable()
    .bind(cellProvider: { (tableView: UITableView, row: Int) in
        return tableView.dequeue(MyCellType.self)
    }, numberOfCells: 5)
```

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- **Other data binding methods**
- [Custom cell events](4-CustomCellEvents.md)
- [Hiding, showing, and ordering sections automatically](5-SectionDisplayBehaviour.md)
- [Binding chain scopes](6-AdvancedBindingChains.md)
- [Providing dimensions](7-ProvidingDimensions.md)
- [Tips, tricks, and FAQ](8-TipsTricksFAQ.md)
- [How Braid works](9-HowItWorks.md)
