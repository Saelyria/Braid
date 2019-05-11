![Braid](braid.jpg)

<p align="center">
<a href="https://travis-ci.com/Saelyria/Braid"><img src="https://travis-ci.com/Saelyria/Braid.svg?branch=master&style=flat-square" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat-square" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift5-compatible-4BC51D.svg?style=flat-square" alt="Swift 5 compatible" /></a>
<a href="https://cocoapods.org/pods/Braid"><img src="https://img.shields.io/cocoapods/v/Braid.svg?style=flat-square" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/Saelyria/Braid/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License: MIT" /></a>
</p>

Braid is a feature-packed library for making your table view setup routine smaller, more declarative, more type safe, and simply more fun. It 
includes support for automatically diffing and animating data on your tables, ability for cells to emit custom events, and support for RxSwift.

## A quick intro

With Braid, you 'bind' information and functionality like data, cell types (or closures that provide cells), and event handlers to your table on a 
per-section basis (or just to the whole table if your table isn't sectioned). 

For a sectioned table, we start by declaring an enum (or struct) that defines your sections and create a 'binder' object:

```swift
enum Section: TableViewSection {
    case first
    case second
    case third
    case fourth
}

let binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
```

Then, we start 'binding chains' to one or multiple sections, kind of like in a switch statement. Binding chains are how we bind data (cell type,
model type, event handlers, etc) to our table. Here, we'll make three 'binding chains' to demonstrate how to bind one (or multiple!) cell and
model type(s) to our sections, along with how to add header titles and cell heights.

```swift
var myModels: [MyModel] = ...

binder.onSection(.first)
    .bind(headerTitle: "FIRST")
    .bind(cellType: MyCustomTableViewCell.self, models: { myModels })
    .onDequeue { (row: Int, cell: MyCustomTableViewCell, model: MyModel) in
        // setup the dequeued 'cell' with the 'model'
    }
    .onTapped { (row, cell, model: MyModel) in
        // e.g. go to a detail view controller with the 'model'
    }

binder.onSections(.second, .third)
    .bind(headerTitles: [.second: "SECOND", .third: "THIRD"])
    .bind(cellProvider: { (tableView, section, row, model: Any) -> UITableViewCell in 
        if let model = model as? Int {
            return tableView.dequeue(MyOtherTableViewCell.self)
        } else if let model = model as? String {
            return tableView.dequeue(MyCustomTableViewCell.self)
        }
        ...
    }, models: { () -> [Section: [Any]]
        return [.second: [1, "hello", 67, 42], .third: [81, 7, "world"]
    })
    ...
    
binder.onAllOtherSections()
    .bind(cellType: MyOtherOtherTableViewCell.self, viewModels: { ... })
    ...
    
binder.finish()
```

Cells are automatically dequeued for given 'model' arrays, and bound model and cell types are remembered and passed to other handlers on
the binding chain. You also don't need to do any bookkeeping to remember which section refers to which integer - you can dynamically
remove or rearrange the displayed sections of a binder, and it'll internally keep track of where named sections moved on the table. 

Table views are also very easy to update - just call `refresh` on the binder when the data we give to `models` closures changes and it'll diff
and animate the changes.

## Custom cell events

Figuring out how to pass events like when a button is pressed or text is entered on a cell back up to your view controller is always a hassle, 
usually involving conformance to a bunch of different delegate protocols. To solve this, Braid also gives you the ability for your cells to 
declare custom event enums that can be observed on your binding chains. This is done by conforming your cell to the `ViewEventEmitting` 
protocol and giving it a `ViewEvent` enum, like this:

```swift
class MyCustomTableViewCell: UITableViewCell, ViewEventEmitting {
    enum ViewEvent {
        case switchToggled(state: Bool)
        case buttonPressed
        case textEntered(text: String)
    }
    
    @objc func onSwitchToggled(switch: UISwitch) {
        self.emit(event: .switchToggled(state: switch.isOn)
    }
}
```

You can then observe for when cells emit events on a binding chain like this:

```swift
binder.onSection(.first)
    .bind(cellType: MyCustomTableViewCell.self, models: { myModels })
    .onEvent(from: MyCustomTableViewCell.self) { (row, cell, event, model: MyModel) in
        switch event {
        case .switchToggled(let state):
            // update something in the model
        case .buttonPressed:
            // perform some action
        case .textEntered(let text):
            // update something in the model
        }
    }
```

## Diffing and animation

Braid supports deep diffing and automatic animation of your table when its data changes. Without doing anything special to your models,
Braid can already determine when (and which) sections update and run a basic count on the changes to apply 'reload', 'insert', and 'delete'
animations on sections. 

However, if you want it, the library also gives you more powerful and more fine-grained control over diffing by taking into account conformance
to `Equatable` and `CollectionIdentifiable` on the models you bind to provide more precise 'reload', 'insert', and 'delete' animations, as 
well as for tracking moves.  This 'tiered diffing' is done on a section-by-section basis, so if the models on one section conform to these 
protocols but the models for another don't, Braid can still do more advanced diffing just for the former section.

## Advanced features

You're a good developer, though - you look at these samples and think of all the limitations and edge cases you can run into with that (more
than one cell or model type per section, custom header/footer view type, section data not known at compile time, infinite scroll...). Luckily, 
Braid supports many more advanced features that cover cases like these and scales well with the complexity of your table, so you should 
never be so limited by the library that you find yourself resorting to the regular UIKit 'data source/delegate' routine.

Braid is fully documented, including tutorials and working code samples (with documented walkthroughs!) in the 'BraidExample' Xcode 
project in the repository. Available tutorials to get you familiar with Braid are as follows:

- [Getting started](https://github.com/Saelyria/Braid/tree/master/Documentation/1-GettingStarted.md)
- [Updating data](https://github.com/Saelyria/Braid/tree/master/Documentation/2-UpdatingData.md)
- [Other data binding methods](https://github.com/Saelyria/Braid/tree/master/Documentation/3-DataBindingMethods.md)
- [Custom cell events](https://github.com/Saelyria/Braid/tree/master/Documentation/4-CustomCellEvents)
- [Hiding, showing, and ordering sections automatically](https://github.com/Saelyria/Braid/tree/master/Documentation/5-SectionDisplayBehaviour.md)
- [Binding chain scopes](https://github.com/Saelyria/Braid/tree/master/Documentation/6-AdvancedBindingChains.md)
- [Providing dimensions (cell height, header height, etc.)](https://github.com/Saelyria/Braid/tree/master/Documentation/7-ProvidingDimensions.md)
- [Deleting, inserting, and moving cells](https://github.com/Saelyria/Braid/tree/master/Documentation/8-DeletingInsertingMovingCells)
- [Tips, tricks, and FAQ](https://github.com/Saelyria/Braid/tree/master/Documentation/9-TipsTricksFAQ.md)
- [How Braid works](https://github.com/Saelyria/Braid/tree/master/Documentation/10-HowItWorks.md)

> Collection view support and ability to bind cells by name like sections for form-style tables are on the way!

## Installation

Braid is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Braid'
```

If you are using RxSwift with Braid, you have to include the Rx subspec of Braid, like so:

```ruby
pod 'Braid/Rx'
```

## Contributors

Aaron Bosnjak (email: aaron.bosnjak707@gmail.com, Twitter: @aaron_bosnjak)

Braid is open to contributors! If you have a feature idea or a bug fix, feel free to open a pull request. Issues and feature ideas are tracked on
this [Trello board](https://trello.com/b/8knAHovD/tableau).

## Acknowledgement

Braid uses a fork of Tony Arnold's super-awesome [Differ](https://github.com/tonyarnold/Differ) library to do its diffing work. If you like 
Braid, make sure to give that repo a star as well!

## License

Braid is available under the MIT license, so do pretty much anything you want with it. As always, see the LICENSE file for more info.
