#  Tips, Tricks, and FAQ

[Only one of the data types in my table view is diffable. Can I still have it animate?](#partial-diffing)

<a name="partial-diffing">
### Only one of the data types in my table view is diffable. Can I still have it animate?
</a>

If none of your models are 'diffable' (i.e. conform to `CollectionIdentifiable` or `Equatable`), then no animation is done and the table 
view's `reloadData()` method is used to update the table view. However, *Tableau doesn't require that all data in the table be 'diffable' for 
some level of animation to be applied*. Tableau can generate diffs on a section-by-section basis if you use different model/cell types in different
sections. So if, for example, we had a setup like this where the model used for one section was 'diffable' but the other wasn't:

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
changed), while changes to the second section will be fully animated (inserts, deletes, moves, and updates).

> Remember, model types only *need* to conform to `CollectionIdentifiable` for inserts, deletes, and moves. They can *optionally* also
conform to `Equatable` if you'd like to animate updates as well. However, note that cells will not be automatically reloaded (even if their data
changed) if they don't conform to `Equatable`, so you generally should. Keep in mind that Swift now supports automatically providing an `==`
method for `struct`s, so it could be as easy as just declaring conformance!

### If I use both models and view models for my section, how is diffing done?

If you use models mapped to view models for cells in a section using the `bind(cellType:models:mappedToViewModelsWith:)` method,
then diffing is done with whichever of the two is 'diffable'. If both are 'diffable', then Tableau favours using the view models to diff with.
