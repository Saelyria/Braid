# How Tableau Works

Hey! Whether you're looking to contribute or just want to know how Tableau works under the hood, this file's the right place to start. I like to 
think the code is easy enough to understand on its own, but I'm sure there's a bunch of stuff there that's a little mucky. Diving into this code is 
also a dive into some pretty tricky stuff about Swift's generics system, so if you're not already familiar with stuff like the `associatedtype` 
keyword, that'd be a good place to start before continuing. It's super interesting stuff and Swift has a *very* powerful generics system, so it's 
worth taking a bit to get comfortable with it. Barring that, let's get started!

To start off, there are four main object types that perform specific roles in the table binding process:
- The 'data source/delegate'
- The 'table data model'
- The 'table binder'
- The 'section binders'

These object types don't necessarily correspond to one respective class (right now there are 8 'section binder' types, not counting their 
abstract superclasses), but rather refer to roles.

## The 'data source/delegate'

The easiest one of those three to understand is the 'data source/delegate' object. This is a relatively light object that conforms to
`UITableViewDataSource` and `UITableViewDelegate`. It gets its data and callback closures from its 'table binder' object. Its concrete 
class type is `_TableViewDataSourceDelegate`. That's pretty much it.

## The 'table data model'

This object is the collection of view models/models/title strings/etc. that represents a 'data state' of a table view. Its properties are a series of
dictionaries and arrays that stores the data the table view displays. Table data models are used with the Differ library that Tableau has as a 
CocoaPods dependency to animate changes in data on the table view. The concrete class for this object type is the  `TableViewDataModel`.

## The 'table binder'

Next is the 'table binder' object, whose concrete class is `SectionedTableViewBinder`. This is a generic class (its generic type `S` is the 
section enum type the binder was setup with) that holds a reference to the underlying table view and the 'data source/delegate' object. Most
importantly, this object has a number of dictionary objects that store references to bound models/view models/callback handlers for given 
sections. So, for example, when the `onTapped` method is called, the closure given to this method eventually makes its way into the
`sectionCellTappedCallbacks` dictionary under the section it's setup to handle. 

The table binder also keeps a reference to two 'table data model' objects - a 'current' model (with the data the table is currently displaying) 
and a 'next' model (a model that represents all the changes yet to be made to the table). Whenever the table is told to update changes (the 
binder's `displayedSections` property is changed, an observable 'models' array fires, an 'update callback' is called), the changes are 
ultimately saved into the binder's 'next' model. When the binder detects that the 'next' model has changed, it queues itself to animate the 
changes from the 'current' to 'next' data model on the app's next render frame using the Differ library.

The 'section-less' `TableViewBinder` class is also technically in this role, but it's basically a wrapper around a sectioned one that it stores as
a property. The sectioned table binder that it stores has its `S` generic type set to the `_SingleSection` enum, which just has one case: 
`.table`.

## The 'section binders'

These are the most complicated objects. In a binding chain, there are at least two of these objects created (depending on the complexity of 
the binding, and especially if you're binding multiple sections at once), with the first one being the return value of the 'table binder's 
`onSection` method and its variants. Each time you add a function call onto the binding chain, one of these objects is returned (either newly 
created or they return themselves) so you can continue the chain using one of its methods. All of the main binding methods - 
`onCellDequeue`, `onTapped`, `bind(cellType:models)`, etc. are the methods of these objects. As the binding chain is created, more type
information is given (e.g. the cell type, the model type, etc), which is 'stored' via generic types in these objects. 

This is best explained by just walking through a binding chain. To start, we call the `onSection` method of our table binder, which returns the
mouthful of a class name `TableViewInitialSingleSectionBinder`. This is read as 'a section binder for a single section for a table view 
who is first in the binding chain'. Phew. This section binder is the only one that has the various 'bind cell type' methods, which is where we
get the type information from. When a cell is bound, we return a specialized section binder that 'stores' that type information and 'forwards' it
from that point on in the chain by returning itself from its bind methods, one for each of the 'bind cell type' methods. These are:

- `TableViewModelSingleSectionBinder` - returned from the `bind(cellType:models:)` method.
- `TableViewViewModelSingleSectionBinder` - returned from the `bind(cellType:viewModel:)` method.
- `TableViewModelViewModelSingleSectionBinder` - returned from the `bind(cellType:models:mapToViewModelsWith)` method.

The two main pieces of type information - the cell type (represented by `C` or `NC` (for 'new cell')) and, if the section(s) is/are setup 
with a models array, the model type (represented by `M` or `NM`) - are stored as generic types on these section binders. Note that the 'view 
model' variant does not have an `M` generic type. These generic types are used in the signature for binding methods like `onTapped` to ensure
type safety.

Each of these 'single section' binders has a 'multi section' equivalent. These ones are used if the `onSections` method of the table binder is 
used instead of the singular `onSection`. They work in basically the same way. There is also the `AnySectionBinder`, which is largely the
same as the various mutli-section binders, but does not expose functions to bind cell types, custom header/footer view types or header/footer 
titles.

## RxSwift integration

RxSwift is added with extensions on `Reactive` in the RxSwift subspec of Tableau. It adds methods to the section binders to allow their
'bind cell type' methods to be given `Observable` model/view model arrays, and works in basically the same way as their vanilla counterparts.
Only real weird thing is that, when the Rx subspec is included in the project, there's a Swift flag named `RX_TABLEAU` that gets defined that
adds stuff like a dispose bag to the table binder to save its section binders' subscriptions.

With that, that's pretty much how everything works - you should hopefully know enough now that you can read through the source and have 
an idea of what's going on, and can maybe open a pull request with some features or (inevitably) fixes!
