#  Updating Data

In most table views, we want to be able to update our data after binding. Braid supports two ways to update data - for those using RxSwift,
binders support the use of binding an Observable along with your cell or header/footer type that the binder will subscribe to to update the
table. If you're not using RxSwift, you give the binding chain a closure it can call to retrieve data (probably from a property on your view
controller) then, when that data updates, call `refresh()` on the binder.

## Without RxSwift

Updating without RxSwift is done by passing a closure to the `bind(cellType:...)` methods that returns an array instead of just the array.

Here's what that looks like:

```swift
var firstSectionModels: [MyModel] = ...
var secondSectionModels: [MyModel] = ...
var thirdSectionModels: [MyModel] = ...

binder.onSection(.first)
    .bind(
        cellType: MyCell.self, 
        models: { firstSectionModels }, 
        updatedBy: &updateFirstSection)
    .onDequeue { row, cell, model in
        ...
    }

binder.onSections([.second, .third])
    .bind(
        cellType: MyOtherCell.self, 
        models: {
            [.second: secondSectionModels, .third: thirdSectionModels]
        },
        updatedBy: &updateSecondThirdSections)
    ...
```

Then, when we want to update the sections, we simply call the `refresh()` method on the binder, then it will call these closures again and
perform a diff in the current and previous data.

We can do the same thing with header or footer titles - however unlikely it is that they do, but if they change, we can hook them up to a closure
as well.

```swift
var headerTitle: String? = "INITIAL TITLE"

binder.onSection(.first)
    .bind(headerTitle: { headerTitle })
```

## RxSwift

When using RxSwift, we start a binding chain in the same way, except we call the `bind` method on the reactive extension (i.e. put an `.rx` in
front of the method) and instead of handing in just arrays or dictionaries, we pass in observable arrays or dictionaries.

```swift
let firstSectionModels: Observable<[MyModel]> = ...
let secondThirdSectionModels: Observable<[Section: [MyModel]]> = ...

binder.onSection(.first)
    .rx.bind(cellType: MyCell.self, models: models)
    .onDequeue { (row, cell, model) in 
        ...
    }
    ...
    
binder.onSections([.second, .third])
    .rx.bind(cellType: MyCell.self, models: secondThirdSectionModels)
    ...
```
It's roughly the same syntax for updating section header/footer titles if you ever need to.

```swift
let title: Observable<String?> = ...

binder.onSection(.someSection)
    .rx.bind(headerTitle: title)
```

The subscriptions are observed by the binder and are disposed of by an internal dispose bag on the binder. Observables are internally 
observed on the main thread, so it should be pretty much plug-and-play.

## Animating Updates

Braid includes support for automatically creating diffs when data for cells or sections is updated as well as for automatically animating diffs 
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

These roles - identity and equality - are expressed by the `CollectionIdentifiable` and `Equatable` protocols, respectively. Braid will
use the `collectionId` (like a car's license plate) you provide to track where items have moved and, if your model conforms to `Equatable`, 
will use its `==` method to see if items that didn't move were updated (thus reloading its cell).

- [Getting Started](1-GettingStarted.md)
- **Updating data**
- [Other data binding methods](3-DataBindingMethods.md)
- [Custom cell events](4-CustomCellEvents.md)
- [Hiding, showing, and ordering sections automatically](5-SectionDisplayBehaviour.md)
- [Binding chain scopes](6-AdvancedBindingChains.md)
- [Providing dimensions](7-ProvidingDimensions.md)
- [Tips, tricks, and FAQ](9-TipsTricksFAQ.md)
- [How Braid works](10-HowItWorks.md)
