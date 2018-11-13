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

Bound tables can still be updated without RxSwift without too much hassle as well. Updating without RxSwift is done by passing a reference 
to a closure that takes the model or view model type to the `bind(cellType:...)` methods. Typically, this will be a reference to a property 
on your view controller. This reference is then set to a newly-created function that can be called to update the models or view models for the
section(s).

> If you haven't used reference pointers in Swift with `inout` arguments before, it'd be worth taking a quick pause here to read the 
'In-Out Parameters' section in the [Swift docs related to functions](https://docs.swift.org/swift-book/LanguageGuide/Functions.html).

Here's what that looks like:

```swift
var firstSectionModels: [MyModel] = ...
var secondSectionModels: [MyModel] = ...
var thirdSectionModels: [MyModel] = ...

var updateFirstSection: ([MyModel]) -> Void
var updateSecondThirdSections: ([Section: [MyModel]]) -> Void

binder.onSection(.first)
    .bind(cellType: MyCell.self, 
          models: firstSectionModels, 
          updatedBy: &updateFirstSection)
    .onCellDequeue { row, cell, model in
        ...
    }
    
binder.onSections([.second, .third])
    .bind(cellType: MyOtherCell.self, 
          models: [
            .second: secondSectionModels,
            .third: thirdSectionModels],
          updatedBy: &updateSecondThirdSections)
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
    .bind(headerTitle: "INITIAL TITLE", updatedBy: &updateFirstSectionTitle)
```

## Animating Updates

Tableau includes support for automatically creating diffs when data for cells or sections is updated as well as for automatically animating diffs 
in data with UIKit's native table view animations. Enabling this feature is voluntary, and simply requires conformance to the 
`CollectionIdentifiable` protocol on the model objects (or view models) used for cells. This protocol has only one requirement: a
`collectionId` string property. Table and collection view binders use this property to track insertion, movement, and deletion of items on the
table.

> Note that all models represented by the table must conform to `CollectionIdentifiable` for any of the sections to be animatable. So, if
you use different model or view model types for different sections, ensure that all types conform to the protocol and that you ensure that their
`collectionId` properties can't collide.

For animation updates to work as expected, it's important to understand what value to assign to this property, as it can be any string. The
`collectionId` property is meant to uniquely identify an object in a collection of similar objects, like a serial number on a product or license 
plate on a car, and should not change when the object is 'updated' (e.g. a car keeps the same license plate if its tires are changed or it is 
repainted). In other words, this id should identify an object's 'identity', not its 'equality'. Obeying this distinction allows Tableau to identify when 
a model has 'moved' in a dataset (it found its `collectionId` in a position different than where it was before when it attempts to generate a
diff) versus when a model has 'updated' (its `collectionId` is the same, just the other properties on the model have changed). This property 
is generally mapped to some kind of main 'id' property on a model object where possible.
