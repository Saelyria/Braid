#  Advanced binding chains

There are a few different methods you can use to start a binding chain. We've already seen two in the 'getting started' tutorial:
- `onSection(_:)` - begins a binding chain that affects a single named section
- `onSections(_:)` - begins a binding chain that affects multiple named sections

However, Tableau also provides a couple others that, while a little trickier to grasp, are very powerful. These methods are:
- `onAllSections()` / `onAllOtherSections()` - begins a binding chain for all sections not uniquely bound by name with one of the 
    previously mentioned methods or for sections whose 'names' are not necessarily known at compile time.
- `onAnySection()` - begins a binding chain for any section on the table. Binding chains started with this method are more limited in what
    they can do (primarily, they can't bind data like cell or header/footer data) and are used to provide any common handlers, especially 
    'dimension' binding.
    
## 'On all (other) sections'

First off, both of these methods (`onAllSections` and `onAllOtherSections`) actually share an implementation - the different naming allows
you a bit more flexibility in setting up your binding code so it's more legible (don't worry, you'll hopefully get why in a minute, bear with us!).

As previously mentioned, binding chains started with these methods are used to bind data and handlers to *all sections that were not uniquely
bound by name using the `onSection` or `onSections` methods*. Think of them like the `default` case in a switch statement. To 
demonstrate this, we'll start off with a sample using a section enum:

```swift
enum Section: TableViewSection {
    case first
    case second
    case third
    case fourth
    case fifth
}

binder.onSection(.first)
    .bind(cellType: FirstCellType.self, models: ...)
    ...
    
binder.onSections(.second, .third)
    .bind(cellType: SecondCellType.self, models: ...)
    ...
    
binder.onAllOtherSections()
    .bind(cellType: ThirdCellType.self, models: ...)
    ...
```

As you might expect, `ThirdCellType` is used for the `fourth` and `fifth` sections. If all your sections used the same cell type, you could 
use `onAllSections()` to bind them all at once, like this:

```swift
enum Section: TableViewSection {
    case first
    case second
    case third
}

binder.onAllSections()
    .bind(cellType: MyCellType.self, models: ...)
```

> Just like with a switch statement, it's generally recommended that you favour covering all your cases by name (i.e. using the `onSection` or 
`onSections` methods) instead of using this the `onAllOtherSections` method as it's more explicit and generally less error-prone.

> Note the choice of using `onAllSections` rather than `onAllOtherSections`. Either of these methods in either of the last two examples
would have the same effect - we just chose to, in the first example, use `onAllOtherSections` to make our binding setup more clear in the
context of having used the more specific `onSection` method.

This binding chain method is particularly useful when used with a `struct` section model type for dynamic sections. This could be used to
solve a use case like a home or product page where their content is pre-sectioned in a network response. In this case, we don't know what the
sections are at compile time (maybe the titles/what data/what type of view is used is given to us in the network response).

> The second ('Artists & Songs') and third (Home Page) examples in the 'TableauExample' included in this workspace are both full, working 
implementations of using dynamic sections using a `struct` instead of an `enum` in case you prefer to learn by example.

## 'On any section'

Handlers and data provided on a binding chain started with `onAnySection` are applied to *any section on the table, including those setup
on other binding chains*. Core data binding (cell type and models, header/footer models or titles) cannot be done on 'any 
section' binding chains - it's assumed that data is comprehensively bound by a combination of `onSection`, `onSections`, and/or
`onAllSections` chains. Instead, 'any section' binding chains are for binding supplementary handlers or dimensions only, and are generally 
overridden if provided by a more specific binding chain. They're kind of like a 'fallback'.

These are a lot of rules, so we'll go over a couple examples to show what this is used for.

### Binding dimensions

First off, it's used most commonly as the 'fallback' for providing dimensions for your binding chain. Consider this example:

```swift
binder.onSection(.first)
    ...
    .dimensions(
        .cellHeight { _ in return 120 },
        .headerHeight { return 80 })
        
binder.onSections(.second, .third)
    ...
    .dimensions(
        .cellHeight { section, _ in 
            switch section {
            case .second: return 90
            case .third: return 70
            }
        })
        
binder.onAnySection()
    .dimensions(
        .cellHeight { _, _ in return 200 }
        .headerHeight { _ in return 50 },
        .footerHeight { _ in return 50 })
```

In this example, the binder would ultimately end up using the following dimensions for each section:

- `first`
    - cell height: 120
    - header height: 80
    - footer height: 50
- `second`
    - cell height: 90
    - header height: 50
    - footer height: 50
- `third`
    - cell height: 70
    - header height: 50
    - footer height: 50
    
As you can see, any values provided for dimensions in more specific chains (any other chain type, including `onAllSections`) will be used
before values provided from `onAnySection`.

> Note that this previous example is fairly contrived to demonstrate this 'fallback' behaviour, so the dimension binding logic is a little all over the
place. Tableau gives you the flexibility to describe binding in many ways (whatever ends up being the most legible to you), so you could do
the same work by, for example, putting all your 'dimension' binding code under `onAnySection` and switching on the passed-in `section`. 
Whatever works for you!

### Binding supplementary handlers

The other main usage for the `onAnySection` method is for binding 'supplementary' handlers, especially for `onCellTapped`. Handlers like
`onCellTapped` that are added on an `onAnySection` chain are called *in addition to handlers on more specific chains* instead of as a 
fallback. So, in this example:

```swift
binder.onSection(.first)
    .onCellTapped { _, _ in
        // go to a new view controller, etc
    }
    
binder.onAnySection()
    .onCellTapped { _, _, _ in
        // do work for any cell being tapped (maybe log analytics?)
    }
```

Both handlers would be called if a cell is tapped in the `first` section. This allows you to put section-specific code in handlers for specific
sections, and put more generic code (logging analytics, hiding a spinner, whatever other shared behaviour) in the `onAnySection` chain to
reduce copy-pasta.

And that's pretty much the gist of using `onAllSections` and `onAnySection`! There are a couple edge-case things you might run into that
we'll talk about in the [tips, tricks, and FAQ](TipsTricksFAQ.md) page, but they're pretty rare. For now, we'd recommend playing around with
these different binding chain methods (again, there are full implementations using them in the included example project!) and see how you can 
describe your binding with them - they'll make a lot more sense once you've seen them in action.
