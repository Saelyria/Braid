# Tableau

Tableau is an RxSwift-compatible library for making your table and collection view setup routine smaller, more declarative, more type safe, and
simply more fun that lets you switch from the tired data source / delegate routine to a cleaner function chain that reads like a sentence.

To give you a quick idea of some of the key features of the library, here's a quick overview of how you'd setup a table view with it:

```swift
// First, define an enum (or struct!) that defines your sections...
enum Section: TableViewSection {
    case first
    case second
    case third
    case fourth
}

// ...define your data (support for observable Rx and non-Rx data!)...
let firstSectionModels: Observable<[MyModel]> = ...
let secondThirdSectionModels: Observable<[Section: [MyOtherModel]]> = ...

// ...create a 'binder' object...
let binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)

// ...then start binding logic (kind of like a switch statement). 
// You can bind logic to individual sections...
binder.onSection(.first)
    .rx.bind(cellType: MyCustomTableViewCell.self, models: firstSectionModels)
    .bind(headerTitle: "FIRST")
    .onCellDequeue { (row: Int, cell: MyCustomTableViewCell, model: MyModel) in // (such type safety!)
        // setup the 'cell' with the 'model'
    }
    .onCellTapped { (row, cell, model: MyModel) in
        // e.g. go to a detail view controller with the 'model'
    }

// ...to multiple sections...
binder.onSections(.second, .third)
    .rx.bind(cellType: MyOtherTableViewCell.self, models: secondThirdSectionModels)
    .onCellTapped { (section: Section, row: Int, cell: MyOtherTableViewCell, model: MyOtherModel) in
        ...
    }
    ...
    
// ...to all (other unbound) sections...
binder.onAllOtherSections()
    ...
    
// ...or bind shared logic for any section!
binder.onAnySection()
    .dimensions(
        .cellHeight { UITableViewAutomaticDimension },
        .estimatedCellHeight { 100 })

binder.finish()
```

This is much more legible and reads more like requirements you might get, and no more index bookkeeping for your model objects!

You're a good developer, though - you look at that sample and think of all the limitations and edge cases you can run into with that (more than
one cell or model type per section, custom header/footer view type, section data not known at compile time, infinite scroll...). Luckily, Tableau
also scales easily with complexity and supports many more advanced features that cover cases like these, so you should never be so limited 
by the library that you find yourself resorting to the regular UIKit 'data source / delegate' routine.

Tableau is fully documented, including tutorials and working code samples (with documented walkthroughs!) in the 'TableauExample' Xcode 
project in the repository. Available tutorials to get you familiar with Tableau are as follows:

- [Getting started](Documentation/1-GettingStarted.md)
- [Updating data](Documentation/2-UpdatingData.md)
- [Other data binding methods](Documentation/3-DataBindingMethods.md)
- [Hiding, showing, and ordering sections automatically](Documentation/4-SectionDisplayBehaviour.md)
- [Providing dimensions (cell height, header height, etc.)](Documentation/6-ProvidingDimensions.md)
- [Tips, tricks, and FAQ](Documentation/7-TipsTricksFAQ.md)
- [How it works](Documentation/8-HowItWorks.md)

## Installation

Tableau (will be) available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Tableau'
```

## Contributors

Aaron Bosnjak (email: aaron.bosnjak707@gmail.com, Twitter: @aaron_bosnjak)

Tableau is open to contributors! If you have a feature idea or a bug fix, feel free to open a pull request. Issues and feature ideas are tracked on
this [Trello board](https://trello.com/b/8knAHovD/tableau).

## Acknowledgement

Tableau uses a fork of Tony Arnold's super-awesome [Differ](https://github.com/tonyarnold/Differ) library to do its diffing work. If you like 
Tableau, make sure to give that repo a star as well!

## License

Tableau is available under the MIT license, so do pretty much anything you want with it. As always, see the LICENSE file for more info.
