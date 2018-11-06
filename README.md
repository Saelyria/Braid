# Tableau

Tableau is a library for making your table and collection view setup routine smaller, more declarative, and more type safe that lets you switch 
from the tired data source / delegate routine to a cleaner function chain that reads like a sentence. Tableau also includes support for RxSwift.

Here's a sample of what a typical table view setup might look like:

```swift
// MyViewController.swift

enum Section: TableViewSection {
    case first
    case second
    case third
    case fourth
    case fifth
}

let firstSectionModels: Observable<[MyModel]> = ...
let secondThirdSectionModels: Observable<[Section: MyModel]> = ...

let binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)

binder.onSection(.first)
    .bind(cellType: MyCell.self, models: firstSectionModels)
    .onCellDequeue { (row: Int, cell: MyCell, model: MyModel) in
        // setup the 'cell' with the 'model'
    }
    .onTapped { (row: Int, cell: MyCell, model: MyModel) in
        // e.g. go to a detail view controller with the 'model'
    }

binder.onSections([.second, .third])
    .bind(cellType: MyOtherCell.self, models: secondThirdSectionModels)
    .onCellDequeue { (section: Section, row: Int, cell: MyOtherCell, model: MyModel) in
        ...
    }
    ...
    
binder.onAllOtherSections()
    .bind(cellType: MyThirdCell.self, models: ...)
    ...

binder.finish()
```

Without reading through any docs, you can probably assume most of what's going on here just by reading it. Setting up your table view is 
done in functional chains, and you declare the logic for your sections (what table view type they use, what models the cells are dequeued for,
what's done when a cell is tapped, etc.) directly on the sections. Everything is type safe and you don't need to map rows to model array 
indices. 

Tableau scales easily with complexity, though, and supports more complex use cases that can't be described as easily as this example by
allowing you to do things like use a struct instead of an enum for more dynamic section logic, ability to bind handlers to any section (known or
unknown), and also allows much more manual control by allowing you to call cell binding with closures to dequeue cells yourself if needed, so 
you should never be so limited by the library that you find yourself resorting to the regular UIKit 'data source / delegate' routine. 

Tableau has a number of other features:
- Easily hot swap by changing the binder's `displayedSections` property
- Easier cell registration and dequeuing using  `UINibInitable` and `ReuseIdentifiable` protocols
- Type safe updating of cells in a section via callback closures created during binding
- Automatic diffing and animation between updates to the table's underlying models
- Support for binding with or without RxSwift
- `UICollectionView` support (coming soon!)

Tableau is fully documented, including tutorials and working code samples (with documented walkthroughs!) in the 'TableauExample' Xcode 
project in the repository. The place to get started with learning how to use it is [right here](Documentation/GettingStarted.md).

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

Tableau uses Tony Arnold's super-awesome [Differ](https://github.com/tonyarnold/Differ) library to do its diffing work. If you like Tableau, make
sure to give that repo a star as well!

## License

Tableau is available under the MIT license, so do pretty much anything you want with it. As always, see the LICENSE file for more info.
