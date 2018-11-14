#  Providing dimensions

Tableau has very concise syntax for supplying dimensions like header, footer, or cell height. Dimensions are added by providing a 
`dimensions` item to a binding chain, which is then given all the dimensions you want to supply, like this:

```swift
binder.onSections(.first, .second)
    .dimensions(
        .cellHeight { UITableViewAutomaticDimension },
        .estimatedCellHeight { 120 },
        .headerHeight { 50 })
```

The dimensions you provide are the returned objects from the various functions on either `SingleSectionDimension` or 
`MultiSectionDimension`. These static functions are called with handlers that are passed in the section and row, returning the `CGFloat` 
values for the dimension. There are overloads for each of these dimension functions to allow you to ignore the section/row if you always return
the same value regardless of the section row like in the previous given example. The previous example with full type annotation using the 
available row/section info would look like this:

```swift
binder.onSection(.first, .second)
    .dimensions(
        .cellHeight { (section: MySection, row: Int) in return UITableViewAutomaticDimension },
        .estimatedCellHeight { (section: MySection, row: Int) in return 120 },
        .headerHeight { (section: MySection) in return 50 })
```

The dimensions you can provide are:
- `cellHeight` - Provides the height for cells in the bound section(s).

    If this is called while binding a single section, it can be given one of two handler types:
    -  `(Int) -> CGFloat` (e.g. `cellHeight { row in ... }`), where it is passed in the row to provide the height for
    - `() -> CGFloat` (e.g. `cellHeight { ... }`) if it's the same height for all rows of the section. 
    
    If this is called while binding multiple sections, it can be given one of two handler types:
    - `(<Section>, Int) -> CGFloat` (e.g. `cellHeight { section, row in ... }`)  where it is passed in the section (an instance of 
        your section enum/struct) and the row to provide the height for
    - `() -> CGFloat` (e.g. `cellHeight { ... }`) if it's the same height for all rows of all the bound sections.
