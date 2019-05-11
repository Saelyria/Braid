#  Hiding, showing, and ordering sections automatically

How a binder controls the visibility and order of sections given to it can be controlled via its `sectionDisplayBehavior` property. This 
property is set with one of three 'behaviours':

### 'Manually managed'

This is the default behaviour of a binder. When using this behaviour, the binder will display the sections set to its `displayedSections`
property in the order given. This `displayedSections` property can only be set if the binder's behaviour is set to 'manually managed' - an 
attempt to set the property if this is not the behaviour will simply do nothing. This is the most versatile of the three options, allowing very 
fine-grained control for complex section logic. The sections in `displayedSections` property can be removed, inserted, or rearranged at any
time, and changes will be animated if the models correctly conform to `CollectionIdentifiable`.

### 'Hides sections with no cell data' and 'Hides sections with no data'

These behaviours are very similar with one subtle difference. We'll start with the first - 'hides sections with no cell data'. If the binder has this 
behaviour set, it will automatically hide any sections that do not have any 'cell data' (models or view models). For example, if a binder were
set up like this..

```swift
let firstModels: [Int] = [1, 2, 3]
let secondModels: [Int] = []

binder.onSection(.first)
    .bind(cellType: MyCell.self, models: firstModels)
    .bind(headerTitle: "FIRST")
    
binder.onSection(.second)
    .bind(cellType: MyCell.self, models: secondModels)
    .bind(headerTitle: "SECOND")
```

.. and its 'section display behaviour was set to `hidesSectionsWithNoCellData`, then the table would only display the first section - 
despite having provided a header for the second section, it will still be hidden because it has no 'cell data'. Binders will respond to changes in 
section data; if the section was setup using an Rx observable or an 'update callback' and the data is updated from having no cell data to 
having some, then the binder will automatically display the section and vice-versa for hiding the section. If the models for the section are set 
up to handle diffing via  `CollectionIdentifiable` conformance, the binder will also animate the display of the section.

`hidesSectionsWithNoData` works in basically the same way as `hidesSectionsWithNoCellData`, with one small distinction - a section
must have absolutely no view data for it to be hidden, including headers or footers. So, if the binder's behaviour was to hide sections with no
data in the previous example, the 'second' section would still be shown because it still has a header title. As you would expect, if the header
title were setup to be updateable and it was changed to nil, the section would be hidden.

The order sections are displayed in with these two behaviours is determined either by a passed-in 'sorting' closure or via conformance to
`Comparable` by the section. If your section enum/struct conforms to `Comparable`, these behaviours can be set on your binder just like this:

```swift
enum Section: TableViewSection, Comparable {
    case first
    case second
    
    static func < (lhs: Section, rhs: Section) -> Bool {
        return ...
    }
}

binder.sectionDisplayBehaviour = .hidesSectionsWithNoCellData
```

If your enum is backed by a comparable raw value (e.g. `Int` or `String`), Braid provides a default `<` comparison function based on its
raw value as well. So, for example, a default implementation of `<` is provided that orders them based on the case order in this enum:

```swift
enum Section: Int, TableViewSection, Comparable {
    case first
    case second
}
```

If the section enum/struct does not conform to `Comparable`, the display behaviour is set like this:

```swift
binder.sectionDisplayBehaviour = .hidesSectionsWithNoCellData(orderedWith: { unorderedSections in
    return unorderedSections.sorted(by: { ... })
})
```

Where the behaviour assignment is also given a sorting function that is passed in the unordered sections that the binder has calculated are to
be shown that should be returned sorted.

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- [Other data binding methods](3-DataBindingMethods.md)
- [Custom cell events](4-CustomCellEvents.md)
- **Hiding, showing, and ordering sections automatically**
- [Binding chain scopes](6-AdvancedBindingChains.md)
- [Providing dimensions](7-ProvidingDimensions.md)
- [Tips, tricks, and FAQ](9-TipsTricksFAQ.md)
- [How Braid works](10-HowItWorks.md)
