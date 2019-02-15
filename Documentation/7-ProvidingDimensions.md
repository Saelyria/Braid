#  Providing dimensions (cell height, header height, etc.)

Braid has very concise syntax for supplying dimensions like header, footer, or cell height. Dimensions are added by providing their associated
methods to a binding chain, like this:

```swift
binder.onSections(.first, .second)
    .cellHeight { section, row in UITableViewAutomaticDimension }
    .estimatedCellHeight { section, row in 120 }
    .headerHeight { section in 50 })
```

The handlers are called whenever the table view asks for the dimensions for its subviews, just like the base table view delegate methods. The 
dimensions you can provide are:

- `cellHeight`
- `estimatedCellHeight`
- `headerHeight`
- `estimatedHeaderHeight`
- `footerHeight`
- `estimatedFooterHeight`

Depending on whether these dimensions are added to a single section or multi section binding chain, they are called with different closure
types. On a binding chain that only affects one section, the cell-related methods are passed in an `Int` detailing the row of the cell to provide
the height for. On a binding chain that affects multiple secions (including 'any section'), the handler is also passed in the section (as an instance
of the `TableViewSection` type you gave to the binder).

Furthermore, in case the model object is taken into account when calculating the height of a given cell, if a dimentions method is called in the
binding chain after a cell binding method that includes a declared 'model' type, instances of the model can also be passed into the 
`cellHeight` and  `estimatedCellHeight` methods if you provide a third argument to the closure, like this:

```swift
let models: [MyModel] = ...

binder.onSections(.first, .second)
    .bind(cellType: MyCell.self, models: models)
    .cellHeight { (section, row, model: MyModel) in 
        ... 
    }
```

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- [Other data binding methods](3-DataBindingMethods.md)
- [Custom cell events](4-CustomCellEvents.md)
- [Hiding, showing, and ordering sections automatically](5-SectionDisplayBehaviour.md)
- [Binding chain scopes](6-AdvancedBindingChains.md)
- **Providing dimensions**
- [Tips, tricks, and FAQ](8-TipsTricksFAQ.md)
- [How Braid works](9-HowItWorks.md)
