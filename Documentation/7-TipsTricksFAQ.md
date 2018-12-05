#  Tips, Tricks, and FAQ

- [Does Tableau batch data updates?](#update-batching)
- [Only one of the data types in my table view is diffable. Can I still have it animate?](#partial-diffing)
- [If I use both models and view models for my section, how is diffing done?](#viewmodel-model-diffing)
- [The 'binding chains' tutorial mentioned some weird edge cases. What are they?](#binding-chain-edge-cases)

<h3 name="update-batching">
Does Tableau batch data updates?
</h3>

Yes. Whenever a table or collection view binder detects that data has changed, it 'queues' a diff/update animation for the next frame of the
application. So, any data updates (whether via RxSwift observables or 'update callbacks', or both) that are fired in the same frame will be
automatically batched and applied together.

<h3 name="partial-diffing">
Only one of the data types in my table view is diffable. Can I still have it animate?
</h3>

If none of your models are 'diffable' (i.e. conform to `CollectionIdentifiable` or `Equatable`), then a binder will by default use the
`reloadSections` method of `UITableView`, using its assigned `undiffableSectionUpdateAnimation` to animate. If you don't want 
animations, you can always set a binder's `animateChanges` to false. However, *Tableau doesn't require that all data in the table be 'diffable' 
for some level of animation to be applied*. Tableau can generate diffs on a section-by-section basis if you use different model/cell types in
different sections. So if, for example, we had a setup like this where the model used for one section was 'diffable' but the other wasn't:

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

Then updates to the `first` section will be done without animation (the binder will simply reload the section when it detects that its data was
changed using its assigned `undiffableSectionUpdateAnimation`), while changes to the second section will be fully animated (inserts, 
deletes, moves, and updates).

> Remember, model types only *need* to conform to `CollectionIdentifiable` for inserts, deletes, and moves. They can *optionally* also
conform to `Equatable` if you'd like to animate updates as well. However, note that cells will not be automatically reloaded (even if their data
changed) if they don't conform to `Equatable`, so you generally should. Keep in mind that Swift now supports automatically providing an `==`
method for `struct`s, so it could be as easy as just declaring conformance!

<h3 name="viewmodel-model-diffing">
If I use both models and view models for my section, how is diffing done?
</h3>

If you use models mapped to view models for cells in a section using the `bind(cellType:models:mapToViewModels:)` method,
then diffing is done with whichever of the two is 'diffable'. If both are 'diffable', then Tableau favours using the view models to diff with.

<h3 name="binding-chain-edge-cases">
The 'binding chains' tutorial mentioned some weird edge cases. What are they?
</h3>

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- [Other data binding methods](3-DataBindingMethods.md)
- [Hiding, showing, and ordering sections automatically](4-SectionDisplayBehaviour.md)
- [Binding chain scopes](5-AdvancedBindingChains.md)
- [Providing dimensions](6-ProvidingDimensions.md)
- **Tips, tricks, and FAQ**
- [How it works](8-HowItWorks.md)
