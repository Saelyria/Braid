#  Updating Data

In most table views, we want to be able to update our data after binding. Tableau supports two ways to update data - for those using RxSwift,
binders support the use of binding an Observable along with your cell or header/footer type that the binder will subscribe to to update the
table. If you're not using RxSwift, Tableau provides the ability to create 'update' handlers at the end of your binding chains that you can call
with new data to update the table.

## RxSwift

We'll start with the RxSwift variant since it's not much different from the non-updating tables in the 'getting started' guide. We start a binding
chain in the same way, except we call the `bind` method on the reactive extension (i.e. put an `.rx` in front of the method) and instead of 
handing in just arrays or dictionaries, we pass in Observable arrays or dictionaries.

```swift
let firstSectionModels: Observable<[MyModel]> = ...
let secondThirdSectionModels: Observable<[Section: [MyModel]]> = ...

binder.onSection(.first)
    .rx.bind(cellType: MyCell.self, models: models)
    .onCellDequeue { (row, cell, model) in 
        ...
    }
    ...
    
binder.onSections([.second, .third])
    .rx.bind(cellType: MyCell.self, models: secondThirdSectionModels)
    ...
```
We can do the same thing with header or footer titles - if they change, we can hook them up to an Observable as well.

```swift
let title: Observable<String?> = ...

binder.onSection(.someSection)
    .rx.headerTitle(title)
```

The subscriptions are observed by the binder and are disposed of by an internal dispose bag on the binder. Observables are internally 
converted to `Driver` to ensure the subscriptions are always executed on the main thread.

## Without RxSwift

Bound tables can still be updated without RxSwift without too much hassle as well. Updating without RxSwift is done by adding an 
`updateCells(with:)` method to the binding chain. The handler this method is called with is passed in an 'update callback' closure that
should be saved somewhere useful (likely as a property on your view controller) that can be called anytime to update the models for the
section(s) the chain involves. Here's an example of what that might look like:

```swift
var updateFirstSection: ([MyModel]) -> Void
var updateSecondThirdSections: ([Section: [MyModel]]) -> Void

let firstSectionModels: [MyModel] = ...
let secondThirdSectionModels: [Section: [MyModel]] = ...

binder.onSection(.first)
    .rx.bind(cellType: MyCell.self, models: firstSectionModels)
    .updateCells(with: { (updateCallback: ([MyModel]) -> Void) in
        updateFirstSectionModels = updateCallback
    })
    ...
    
binder.onSections([.second, .third])
    .rx.bind(cellType: MyOtherCell.self, models: models)
    .updateCells(with: { (updateCallback: ([Section: [MyModel]]) -> Void) in
        updateSecondThirdSections = updateCallback
    })
    ...
    
...
let newFirstSectionModels: [MyModel] = ...
updateFirstSection(newFirstSectionModels)

let newSecondThirdSectionModels: [MyModel] = ...
updateSecondThirdSections(newSecondThirdSectionModels)
```

Again, it's roughly the same syntax for updating section header/footer titles.

```swift
var updateFirstSectionTitle: (String?) -> Void

binder.onSection(.first)
    .headerTitle("INITIAL TITLE")
    .updateHeaderTitle(with: { (updateCallback: (String?) -> Void) in
        updateFirstSectionTitle = updateCallback
    })
```

> Where possible, it's recommended that Tableau be used with RxSwift for apps whose table views have complex updating logic since, as you
can see, the non-RxSwift updating methods are a fair amount more verbose.
