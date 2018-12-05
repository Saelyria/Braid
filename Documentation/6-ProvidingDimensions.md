#  Providing dimensions (cell height, header height, etc.)

Tableau has very concise syntax for supplying dimensions like header, footer, or cell height. Dimensions are added by providing a 
`dimensions` item to a binding chain, which is then given all the dimensions you want to supply, like this:

```swift
binder.onSections(.first, .second)
    .dimensions(
        .cellHeight { section, row in UITableViewAutomaticDimension },
        .estimatedCellHeight { section, row in 120 },
        .headerHeight { section in 50 })
```

The dimensions you provide are the returned objects from the various functions on either `SingleSectionDimension` or 
`MultiSectionDimension`. These static functions are called with handlers that are passed in the section and row, returning the `CGFloat` 
values for the dimension. The handlers are called whenever the table view asks for the dimensions for its subviews, just like the base table
view delegate methods.

The dimensions you can provide as arguments to `dimensions(_:)` are:

- `cellHeight`
- `estimatedCellHeight`
- `cellIndentationLevel`
- `headerHeight`
- `estimatedHeaderHeight`
- `footerHeight`
- `estimatedFooterHeight`

Depending on whether these dimensions are added to a single section or multi section binding chain, they are called with different closure
types. The closure types for each dimension when they are called on a binding chain for a single section are as follows:

- `cellHeight` - `(_ row: Int) -> CGFloat`
- `estimatedCellHeight` - `(_ row: Int) -> CGFloat`
- `cellIndentationLevel` - `(_ row: Int) -> Int`
- `headerHeight`  - `() -> CGFloat`
- `estimatedHeaderHeight`  - `() -> CGFloat`
- `footerHeight`  - `() -> CGFloat`
- `estimatedFooterHeight`  - `() -> CGFloat`

If the dimensions are called while binding for multiple sections, they are also passed in the 'section' (an instance of your custom section enum
/struct) as the first argument, like so:

- `cellHeight` - `(_ section: Section, _ row: Int) -> CGFloat`
...
- `headerHeight`  - `(_ section: Section) -> CGFloat`
...

Furthermore, in case the model object is taken into account when calculating the height of a given cell, if the `dimensions` item is called in the
binding chain after a cell binding method that includes a declared 'model' type, instances of the model can also be passed into the 
`cellHeight`,  `estimatedCellHeight`, and (in the odd event you ever use it) `cellIndentationLevel` methods if you provide a third 
argument to the closure. So, for a single-section binding chain:

- `cellHeight` - `(_ row: Int, _ model: Model) -> CGFloat`
- `estimatedCellHeight` - `(_ row: Int, _ model: Model) -> CGFloat`
- `cellIndentationLevel` - `(_ row: Int, _ model: Model) -> Int`

And for a multi-section binding chain:

- `cellHeight` - `(_ section: Section, _ row: Int, _ model: Model) -> CGFloat`
- `estimatedCellHeight` - `(_ section: Section, _ row: Int, _ model: Model) -> CGFloat`
- `cellIndentationLevel` - `(_ section: Section, _ row: Int, _ model: Model) -> Int`

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- [Other data binding methods](3-DataBindingMethods.md)
- [Hiding, showing, and ordering sections automatically](4-SectionDisplayBehaviour.md)
- [Binding chain scopes](5-AdvancedBindingChains.md)
- **Providing dimensions**
- [Tips, tricks, and FAQ](7-TipsTricksFAQ.md)
- [How it works](8-HowItWorks.md)
