# Tableau

Tableau is a library for making your table and collection view setup routine smaller, more declarative, more type safe, and simply more fun. It 
includes support for automatically diffing and animating data on your tables, ability for cells to emit custom events, and support for RxSwift.

## The basics

With Tableau, you 'bind' information and functionality like data, cell types, and event handlers to your table on a per-section basis (or just to 
the whole table if your table isn't sectioned). 

For a sectioned table, we start by declaring an enum (or struct) that defines your sections and creating a 'binder' object:

```swift
enum Section: TableViewSection {
    case first
    case second
    case third
    case fourth
}

let binder = SectionedTableViewBinder(tableView: self.tableView, sectionedBy: Section.self)
```

Then, we start 'binding chains' to one or multiple sections, kind of like in a switch statement. Here, we'll make three 'binding chains' to add
different data and handlers to the sections we just declared:

```swift
let myModels: [MyModel] = ...

binder.onSection(.first)
    .bind(headerTitle: "FIRST SECTION")
    .bind(cellType: MyCustomTableViewCell.self, models: { myModels })
    .onDequeue { (row: Int, cell: MyCustomTableViewCell, model: MyModel) in
        // setup the dequeued 'cell' with the 'model'
    }
    .onTapped { (row, cell, model: MyModel) in
        // e.g. go to a detail view controller with the 'model'
    }

binder.onSections(.second, .third)
    .bind(cellType: MyOtherTableViewCell.self, models: { ... })
    .onDequeue { (section: Section, row, cell, model) in
        // setup the dequeued 'cell' with the 'model'
    }
    ...
    
binder.onAllOtherSections()
    ...
```

By having tables setup using chains like this, you can more clearly describe how your table views work in a way that reads more like the 
requirements you receive, and you have type safety built-in by having cells and models safely cast (to types you give in the
`bind(cellType:models:)` method) and passed into the handlers added to each chain.

## Custom cell events

Figuring out how to pass events like when a button is pressed or text is entered on a cell back up to your view controller is always a hassle 
usually involving conformance to a bunch of different delegate protocols. To solve this, Tableau also gives you the ability for your cells to 
declare custom event enums on your cells that can be observed on your binding chains. This is done by conforming your cell to the
`ViewEventEmitting` protocol and giving it a `ViewEvent` enum, like this:

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

Tableau supports deep diffing and automatic animation of your table when its data changes. Without doing anything special to your models,
Tableau can already determine when (and which) sections update and run a basic count on the changes to apply 'reload', 'insert', and 'delete'
animations on sections. 

However, if you want it, the library also gives you more powerful and more fine-grained control over diffing by taking into account conformance
to `Equatable` and `CollectionIdentifiable` on the models you bind to provide more precise 'reload', 'insert', and 'delete' animations, as 
well as for tracking moves - all automatically!

## Advanced features

You're a good developer, though - you look at these samples and think of all the limitations and edge cases you can run into with that (more
than one cell or model type per section, custom header/footer view type, section data not known at compile time, infinite scroll...). Luckily, 
Tableau supports many more advanced features that cover cases like these and scales well with the complexity of your table, so you should 
never be so limited by the library that you find yourself resorting to the regular UIKit 'data source/delegate' routine.

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
