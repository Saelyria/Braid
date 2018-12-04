#  Data binding methods

## Cells

Tableau offers a number of different methods that you can use to bind cells and data to your table view. The cell binding variants (roughly in 
order of 'granularity of control') are:

- `bind(cellType:models:)`
- `bind(cellType:viewModels:)`
- `bind(cellType:models:mapToViewModels:)`
- `bind(cellProvider:models:)`
- `bind(cellProvider:numberOfCells:)`

> Each of these variants is available on the `.rx` extension to allow models, view models, or number of cells to be observable or, if you're not
using RxSwift, each variant also has an overload where you can pass in an 'update callback' closure reference.

### Cell type + models (`bind(cellType:models:)`)

This method declares the given `UITableViewCell` type (that also conforms to `ReuseIdentifiable`) to be used for the section(s) being
bound. It also declares that cells are dequeued according to the given array (or dictionary) of 'model' objects; one cell for each model. The
cell type and model type are passed along down the chain for type safety and ability to have 'model' instances given to various handlers.

### Cell type + view models (`bind(cellType:viewModels:)`)

This method is largely the same as the previous 'model' one - it declares the given `UITableViewCell` type to be used for the section(s) being
bound. It also declares that cells are dequeued according to the given array (or dictionary) of 'view model' objecst; one cell for each view 
model.

'View models' are a little different than 'models'. To use this method, the table view cell type declared must conform to a protocol called
`ViewModelBindable` (along with `ReuseIdentifiable`, like the previous method). This 'view model bindable' protocol has a view class
declare an associated 'view model' type that it can be setup with. These 'view models' should describe the cell's entire view state and are
automatically bound to dequeued cells, so you don't need to include an `onCellDequeue` method when using view models.

This method is most often used for relatively static content that doesn't really have a 'model' object that you manipulate anywhere else, like
a banner cell.

More information on using view models can be found in the [using view models](UsingViewModels.md) tutorial.
