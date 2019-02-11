# How Braid Works

Hey! Whether you're looking to contribute or just want to know how Braid works under the hood, this file's the right place to start. I like to 
think the code is easy enough to understand on its own, but I'm sure there's a bunch of stuff there that's a little mucky. Diving into this code is 
also a dive into some pretty tricky stuff about Swift's generics system, so if you're not already familiar with stuff like the `associatedtype` 
keyword, that'd be a good place to start before continuing. It's super interesting stuff and Swift has a *very* powerful generics system, so it's 
worth taking a bit to get comfortable with it. Barring that, let's get started!

To start off, there are four main object types that perform specific roles in the table binding process:
- The 'data source/delegate'
- The 'table data model'
- The 'binding handlers'
- The 'table binder'
- The 'section binders'

These object types don't necessarily correspond to one respective class (right now there are 8 'section binder' types, not counting their 
abstract superclasses), but rather refer to roles.

## The 'data source/delegate'

The easiest one of those three to understand is the 'data source/delegate' object. This is a relatively light object that conforms to
`UITableViewDataSource` and `UITableViewDelegate`. It gets its data and callback closures from its 'table binder' object. Its concrete 
class type is `_TableViewDataSourceDelegate`. That's pretty much it.

This class (like most other classes in the library) is a generic class - its generic type `S` is the section enum type the binder was setup with.

## The 'table data model'

This object is the collection of view models/models/title strings/etc. that represents a 'data state' of a table view. The concrete class for this 
object type is the  `_TableViewDataModel`. Its data is further separated into section data models (`_TableViewSectionDataModel`), with 
items in each section represented by `_TableViewItemModel`. Table data models are diffable from each other.

Besides the actual data the table displays, the table data model (and its child 'section' and 'item' models) also store some meta-data like
marking sections that were 'uniquely' bound by name so that appropriate handlers are used by the data source/delegate object.

## The 'binding handlers'

This object is the collection of handlers that were bound to the table. All of its properties are dictionaries that we use to find handlers the user
bound for specific sections. So, for example, when the `onTapped` method is called, the closure given to this method eventually makes its way
into the `sectionCellTappedCallbacks` dictionary under the section it's setup to handle. This object exists mostly to help namespace
these handlers and keep the 'table binder' a little leaner.

## The 'table binder'

Next is the 'table binder' object, whose concrete class is `SectionedTableViewBinder`. This object holds a reference to the underlying table 
view, the 'data source/delegate' object, and the 'binding handlers' object. The table binder also keeps a reference to two 'table data model' 
objects - a 'current' model (with the data the table is currently displaying) and a 'next' model (a model that represents all the changes yet to be 
made to the table). Whenever the table is told to update changes (the binder's `displayedSections` property is changed, an observable 
'models' array fires, `refresh` is called), the changes are ultimately saved into the binder's 'next' model. When the binder detects that the 
'next' model has changed, it queues itself to animate the changes from the 'current' to 'next' data model on the app's next render frame.

The 'section-less' `TableViewBinder` class is also technically in this role, but it's basically a wrapper around a sectioned one that it stores as
a property. The sectioned table binder that it stores has its `S` generic type set to the `_SingleSection` enum, which just has one case: 
`.table`.

## The 'section binders'

These are the most complicated objects. In a binding chain, there are often two of these objects created (depending on the complexity of the
binding, and especially if you're binding multiple sections at once), with the first one being the return value of the 'table binder's `onSection` 
method and its variants. Each time you add a function call onto the binding chain, one of these objects is returned (either newly created or they
they return themselves) so you can continue the chain using one of its methods. All of the main binding methods - `onDequeue`, `onTapped`, 
`bind(cellType:models)`, etc. are the methods of these objects. As the binding chain is created, more type information is given (e.g. the cell
type or the model type), which is 'stored' via generic types in these objects. 

This is best explained by just walking through a binding chain. To start, we call the `onSection` method of our table binder, which returns the
mouthful of a class name `TableViewSingleSectionBinder`.  Section binders have a generic `C` type that represents the type of cell that 
was bound. When a cell type is bound, a new section binder is created whose `C` type is assigned to the newly-given cell type. If a model type
is also bound, instead of creating a `TableViewSingleSectionBinder`, we create a `TableViewModelSingleSectionBinder`, which has
a generic `M` type - this is where we store the given model type. This second 'model' section binder subclasses the former one, and overrides
its methods to include its given `M` generic type.

Each of these 'single section' binders has a 'multi section' equivalent. These ones are used if the `onSections` method of the table binder is 
used instead of the singular `onSection`. They work in basically the same way. There is also the `AnySectionBinder`, which is largely the
same as the various mutli-section binders, but does not expose functions to bind cell types, custom header/footer view types or header/footer 
titles.

## RxSwift integration

RxSwift is added with extensions on `Reactive` in the RxSwift subspec of Braid. It adds methods to the section binders to allow their
'bind cell type' methods to be given `Observable` model/view model arrays, and works in basically the same way as their vanilla counterparts.
Only real weird thing is that, when the Rx subspec is included in the project, there's a Swift flag named `RX_TABLEAU` that gets defined that
adds stuff like a dispose bag to the table binder to save its section binders' subscriptions.

With that, that's pretty much how everything works - you should hopefully know enough now that you can read through the source and have 
an idea of what's going on, and can maybe open a pull request with some features or (inevitably) fixes!

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- [Other data binding methods](3-DataBindingMethods.md)
- [Custom cell events](4-CustomCellEvents.md)
- [Hiding, showing, and ordering sections automatically](5-SectionDisplayBehaviour.md)
- [Binding chain scopes](6-AdvancedBindingChains.md)
- [Providing dimensions](7-ProvidingDimensions.md)
- [Tips, tricks, and FAQ](8-TipsTricksFAQ.md)
- **How Braid works**
