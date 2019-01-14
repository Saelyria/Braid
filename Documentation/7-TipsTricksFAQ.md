#  Tips, Tricks, and FAQ

- [Help! My table isn't showing anything!](#no-show)
- [Assuming model type across chains](#splitting-binding)
- [Does Tableau batch data updates?](#update-batching)
- [Only one (or none) of the data types in my table view is diffable. Can I still have it animate?](#partial-diffing)
- [If I use both models and view models for my section, how is diffing done?](#viewmodel-model-diffing)

<h3 name="no-show">
Help! My table isn't showing anything!
</h3>

First, ensure you've called the `finish()` method at the end of all your binding chains. Tableau needs you to be explicit about when you
finish setting up a binder so that it can appropriately set up and assign a data source/delegate object to the table view.

Next, if you're using a sectioned table, ensure that the [section display behaviour](4-SectionDisplayBehaviour.md) you have assigned to it is 
allowing your sections to be shown. By default, this behaviour is set to `manuallyManaged`, meaning you need to assign the 
`displayedSections` property to the sections you want shown in the order you want them displayed in.

If you're using RxSwift, make sure the observables that you're having the binder observe are firing as expected - check things like replay 
behaviours if you're using any of the more obscure observable types.

Finally, as a sanity check, make sure that your arrays or observables actually have data (it happens to all of us).

<h3 name="splitting-binding">
Assuming model type across chains
</h3>

Sometimes, one binding chain can have a lot of logic on it or different chains might use the same model type but use different cell types, but 
share something like logic for the 'on tapped' handler. However, the ability for type-safe 'model' objects to be passed into handlers requires
that they be in a chain that declares that model information via a cell binding method like `bind(cellType:models:)`. This is where the 
`assuming(modelType:)` method is used.

That's a pretty dense block of text, so we'll move to an example. Consider this binding setup:

```swift
let firstSectionModels: [Model]
let secondSectionModels: [Model]

binder.onSection(.first)
    .bind(cellType: SomeCell.self, models: firstSectionModels)

binder.onSection(.second)
    .bind(cellType: OtherCell.self, models: secondSectionModels)
```

As you would expect, the 'model type' resolved for each section is `Model`, so handlers like 'on tapped' that come after the cell binding 
methods can have the `Model` instance associated with the cell passed in. However, if the 'on tapped' handler does the same thing for both
of these methods, it's duplicated code to add them on both of these chains. Instead, we'll do this:

```swift
binder.onSections(.first, .second)
    .assuming(modelType: Model.self)
    .onTapped { section, row, cell, model in
        // shared logic
    }
```

This can also be useful if you choose to break up a particularly long binding chain into multiple ones. Just make sure that when you're 
assuming the model type that you did previously setup all the sections affected by that chain with the given model type - improper assumption
of model type is programmer error that Tableau does a `fatalError` for.


<h3 name="update-batching">
Does Tableau batch data updates?
</h3>

Yes. Whenever a table or collection view binder detects that data has changed, it 'queues' a diff/update animation for the next frame of the
application. So, any data updates (whether via RxSwift observables or 'update callbacks', or both) that are fired in the same frame will be
automatically batched and applied together.

<h3 name="partial-diffing">
Only one (or none) of the data types in my table view is diffable. Can I still have it animate?
</h3>

If none of your models are 'diffable' (i.e. conform to `CollectionIdentifiable` or `Equatable`), then a binder will by default use the
`reloadSections` method of `UITableView`, using its assigned `undiffableSectionUpdateAnimation` to animate. The binder will
also perform insertion and deletion animations to the end of the section if it detects that the number of items changed.

If you don't want animations, you can always set a binder's `animateChanges` to false. However, *Tableau doesn't require that all data in the 
table be 'diffable' for some level of animation to be applied*. Tableau can generate diffs on a section-by-section basis if you use different 
model/cell types in different sections. So if, for example, we had a setup like this where the model used for one section was 'diffable' but the 
other wasn't:

```swift
struct FirstModel {
    ...
}

struct SecondModel: CollectionIdentifiable, Equatable {
    ...
}

let firstSectionModels: Observable<[FirstModel]> = ...
let secondSectionModels: Observable<[SecondModel]> = ...

binder.onSection(.first)
    .rx.bind(cellType: FirstCellType.self, models: firstSectionModels)
    ...
    
binder.onSection(.second)
    .rx.bind(cellType: SecondCellType.self, models: secondSectionModels)
    ...
```

Update animations to the `first` section will be done less precisely  (the binder will simply reload the section when it detects that its data was
changed using its assigned `undiffableSectionUpdateAnimation` and add/subtract cells from the end), while changes to the second 
section will be fully animated (more precise inserts, deletes, moves, and updates for exactly the items that changed).

> Remember, model types only *need* to conform to `CollectionIdentifiable` for inserts, deletes, and moves. They can *optionally* also
conform to `Equatable` if you'd like to animate updates as well. However, note that cells will not be automatically reloaded (even if their data
changed) if they don't conform to `Equatable`, so you generally should. Keep in mind that Swift now supports automatically providing an `==`
method for `struct`s, so it could be as easy as just declaring conformance!

<h3 name="viewmodel-model-diffing">
If I use both models and view models for my section, how is diffing done?
</h3>

If you use models mapped to view models for cells in a section using the `bind(cellType:models:mapToViewModels:)` method,
then diffing is done with whichever of the two is 'diffable'. If both are 'diffable', then Tableau favours using the view models to diff with.

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- [Other data binding methods](3-DataBindingMethods.md)
- [Hiding, showing, and ordering sections automatically](4-SectionDisplayBehaviour.md)
- [Binding chain scopes](5-AdvancedBindingChains.md)
- [Providing dimensions](6-ProvidingDimensions.md)
- **Tips, tricks, and FAQ**
- [How it works](8-HowItWorks.md)
