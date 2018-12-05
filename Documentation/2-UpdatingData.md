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
observed on the main thread, so it should be pretty much plug-and-play.

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
in data with UIKit's native table view animations. Enabling this feature is voluntary, and simply requires conformance to a couple protocols on
the data you want to be diffable. At a minimum, your data type must conform to the `CollectionIdentifiable` protocol to track moves, 
inserts, and deletes. The `CollectionIdentifiable` protocol has only one requirement: a `collectionId` string property, which should
uniquely identify an instance of the model in the collection of data bound to the table. Your data can then additionally conform to the
`Equatable` protocol to enable 'reload' animations.

### Example

For animation updates to work as expected, it's important to understand how each of these conformances plays in diffing and what value to
use for the `collectionId` property. The distinction between the protocols is the difference between 'identity' and 'equality', and can be 
explained with a row of cars.

In a row of cars, each car has a license plate that uniquely identifies which car it is. When cars are re-ordered in their parking lot, we can check
which cars moved where by checking their license plates - this maps to insertions, deletions, and moves in a diff. The license plates must be
unique for this diff to work properly - it marks the 'identity' of the car. However, cars have a number of other properties that might change (paint
colour, wheels, audio system) that, when changed, would reflect an 'update'. By comparing these properties to their previous values, we can 
determine the 'equality' of the car.

These roles - identity and equality - are expressed by the `CollectionIdentifiable` and `Equatable` protocols, respectively. Tableau will
use the `collectionId` (like a car's license plate) you provide to track where items have moved and, if your model conforms to `Equatable`, 
will use its `==` method to see if items that didn't move were updated (thus reloading its cell).

- [Getting Started](1-GettingStarted.md)
- **Updating data**
- [Other data binding methods](3-DataBindingMethods.md)
- [Hiding, showing, and ordering sections automatically](4-SectionDisplayBehaviour.md)
- [Binding chain scopes](5-AdvancedBindingChains.md)
- [Providing dimensions](6-ProvidingDimensions.md)
- [Tips, tricks, and FAQ](7-TipsTricksFAQ.md)
- [How it works](8-HowItWorks.md)
