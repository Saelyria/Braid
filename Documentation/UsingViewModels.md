#  Using View Models

Tableau has built-in support for using view models with your cells to make them more reusable and makes your binding chains a bit smaller by
removing the need for the `onCellDequeue` call. The idea is to make your cells conform to `ViewModelBindable` then give them a 
`ViewModel` type and property to set. This also reduces boilerplate by removing the need to, every time you use this cell type, manually set 
each of the cell's exposed labels or image views - all that configuration logic happens in one place in your cell, like this:

```swift
// MyCell.swift

class MyCell: UITableViewCell, ViewModelBindable {
    struct ViewModel {
        let title: String
        let subtitle: String
    }

    var viewModel: ViewModel? {
        didSet {
            // setup labels, etc
        }
    }
}
```

Your binding chain can then either be passed in an array of view models like this:

```swift
let viewModels: [MyCell.ViewModel] = ...

binder.onSection(.someSection)
    .bind(cellType: MyCell.self, viewModels: viewModels)
    ...
```

Or, in the more likely scenario where your cells are based off of raw data models, you can pass a mapping function into the binding chain, like 
this:

```swift
let models: [MyModel] = ...
let modelToViewModel = { (model: MyModel) -> MyCell.ViewModel in
    // create a view model for `MyCell` from the model and return it
}

binder.onSection(.someSection)
    .bind(cellType: MyCell.self, models: models, mapToViewModelBy: modelToViewModel)
```

The binder will then take care of setting the `viewModel` property of your cells automatically - no `onCellDequeue` call required. This mapping
function is also stored by the binder to use later if the section's models are updated to map them to view models for the cells. The second
method where you bind models also allows `model` instances to be given in various handlers like `onTapped` later in the chain, so is the
more recommended of the two for cell binding for sections whose cells are used for representing data.
