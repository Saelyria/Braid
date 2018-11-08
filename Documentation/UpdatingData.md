#  Updating Data

In most table views, we want to be able to update our data after binding. Tableau supports two ways to update data - for those using RxSwift,
binders support the use of binding an Observable along with your cell or header/footer type that the binder will subscribe to to update the
table. If you're not using RxSwift, Tableau provides the ability to create 'update' handlers at in your binding chains that you can store and call 
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
We can do the same thing with header or footer titles - however unlikely it is that they do, but if they change, we can hook them up to an 
Observable as well.

```swift
let title: Observable<String?> = ...

binder.onSection(.someSection)
    .rx.bind(headerTitle: title)
```

The subscriptions are observed by the binder and are disposed of by an internal dispose bag on the binder. Observables are internally 
converted to `Driver` to ensure the subscriptions are always executed on the main thread.

## Without RxSwift

Bound tables can still be updated without RxSwift without too much hassle as well. Updating without RxSwift is done by passing in an
additional closure to the `bind(cellType:)` method. This closure is passed in an 'update callback' closure that should be saved somewhere 
useful (likely as a property on your view controller) that can be called anytime to update the models for the section(s) the chain involves. Here's
an example of what that might look like:

```swift
var updateFirstSection: ([MyModel]) -> Void
var updateSecondThirdSections: ([Section: [MyModel]]) -> Void

let firstSectionModels: [MyModel] = ...
let secondSectionModels: [MyModel] = ...
let thirdSectionModels: [MyModel] = ...

binder.onSection(.first)
    .bind(cellType: MyCell.self, 
          models: firstSectionModels, 
          updatedWith: { [weak self] updateCallback in
              self?.updateFirstSectionModels = updateCallback
          })
    .onCellDequeue { row, cell, model in
        ...
    }
    
binder.onSections([.second, .third])
    .bind(cellType: MyOtherCell.self, 
          models: [
            .second: secondSectionModels,
            .third: thirdSectionModels],
          updatedWith: { [weak self] updateCallback in
              self?.updateSecondThirdSections = updateCallback
          })
    ...
```
Then, when we want to update the sections, we simply call these closures with new models. The end result ends up reading a lot like a normal
function call on the view controller:

```swift
let newFirstSectionModels: [MyModel] = ...
updateFirstSection(newFirstSectionModels)

let newSecondSectionModels: [MyModel] = ...
let newThirdSectionModels: [MyModel] = ...
updateSecondThirdSections([.second: newSecondSectionModels, .third: newThirdSectionModels])
```

It's roughly the same syntax for updating section header/footer titles if you ever need to.

```swift
var updateFirstSectionTitle: (String?) -> Void

binder.onSection(.first)
    .bind(headerTitle: "INITIAL TITLE",
          updatedWith: { [weak self] updateCallback in
              self?.updateFirstSectionTitle = updateCallback
          })
```

Where possible, for projects with table views that have complex updating logic and many sections, use of RxSwift is recommended as it tends
to be less error prone and is much less verbose/imperative than the non-RxSwift updating variant. The learning curve to get into reactive 
programming is steep, but definitely worth it once requirements become more complex. 
