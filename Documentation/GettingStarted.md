# Getting Started

If you're just discovering Tableau, this is the place to start. Here, we're going to walk you through setting a table view - first a section-less one,
then one that uses sections.

## A simple, section-less table view

To start, we'll get familiar with a few of the main concepts when using Tableau - the *binder* and the *binding chain*.

First, we'll make a new table view and a 'table view binder'. This 'binder' object will act as an intermediary between your table view and 
your controller. The idea is to describe sections, cells, and model types (and where to find these models) to the binder, then it performs the 
work of dequeueing cells from this data while giving you the ability to bind various handlers for key events. Binders for a section-less table
are made just by initializing one with a reference to the table view they will bind, like this:

```swift
import Tableau

// in 'viewDidLoad'
let tableView = UITableView()
let binder = TableViewBinder(tableView: tableView)
```

Easy. Table views are generally used to display arrays of data - for this example, lets make a custom 'person' type and an array of people we
want the table to show:

```swift
struct Person {
    let name: String
    let age: Int
}

let people = [
    Person(name: "John", age: 32),
    Person(name: "Mary", age: 45),
    Person(name: "Mohammed", age: 16)
]
```

Perfect. On our table, we want to display people with a custom cell type - here, we'll define a `MyCustomTableViewCell` cell type to use.  

```swift
class MyCustomTableViewCell: UITableViewCell, ReuseIdentifiable {
    let titleLabel = UILabel()
}
```

For demo purposes, we won't implement much on it - just pretend that we've setup the `titleLabel` in an `awakeFromNib` or in the `init`. 
One key thing here is that we've made our cell conform to the protocol `ReuseIdentifiable`. This is a Tableau protocol with one 
requirement: a static `reuseIdentifier` property that returns what reuse identifier to use for dequeueing instances of this cell. If we don't 
explicitly provide this property, a default string of the class name is used. That's fine for our purposes.

Now we have our models and the cell type we want to represent them - the role of the binder now is to make a connection between them. We 
do this by declaring that 'on the table, bind my custom cell type using these given models', like this:

```swift
binder.onTable()
    .bind(cellType: MyCustomTableViewCell.self, models: people)
```

This is the start of what's called a 'binding chain' in Tableau. Binding chains are chained function calls where we add behaviour to the binder. 
This includes binding handlers for various events (e.g. when a cell is tapped or dequeued) as well as binding cell heights or headers or footers 
to the table. New handlers are added to the chain by simply including them after the last item in the chain.

Typically, we want to start our binding chains with one of the cell binding methods. Here, we've used the 'model' binding method, which takes
as arguments the cell type we want to use and an array of 'model' objects (of any type we specify) that cells will be dequeued for. The main
reason we prefer to call the cell binding method early in the chain is that this type information - the cell type and the 'model' type - are passed
along the binding chain, and allow us to have cell and model instances safely cast to these types later, as we'll see in the next step.

Next, we'll want to add an 'on cell dequeue' handler to this chain be called whenever the binder dequeues a cell so we can set it up. This 
handler will be passed in the cell and 'person' object the cell was dequeued for.

```swift
binder.onTable()
    .bind(cellType: MyCustomTableViewCell.self, models: people)
    .onCellDequeue { (row: Int, cell: MyCustomTableViewCell, person: Person) in
        cell.titleLabel.text = person.name
    }
```
Notice how the passed in `cell` and `person` objects are the type that we specified in the cell binding method. If we had added the
`onCellDequeue` method to the chain before the `bind(cellType:models)` method, this type information wouldn't have been available,
and the passed-in cell would have just been a `UITableViewCell` and we wouldn't have been able to have the `person` object passed in at
all.

Next, we also want to do some work (maybe show a 'person details' view controller) whenever a cell in our table is tapped. To do that, we'd 
just add an 'on tapped' handler like this:

```swift
binder.onTable()
    .bind(cellType: MyCustomTableViewCell.self, models: people)
    .onCellDequeue { (row: Int, cell: MyCustomTableViewCell, person: Person) in
        cell.titleLabel.text = person.name
    }
    .onTapped { (row: Int, cell: MyCustomTableViewCell, person: Person) in
        // show a 'details' VC with the given 'person' object
    }
```
Same deal here with the `onTapped` handler - because it came after the cell binding method, it gets the same type safety allowance. There are
a number of handers we can bind that can, when they're bound in a chain after the cell binding methods, be passed in model objects or have
additional type safety that they wouldn't have when called earlier in the chain.

As previously mentioned, there are a number of other handlers we can bind to add more information to our table, all of which are simply added
to this function chain.

After we've finished binding handlers, we just call the `finish` method on the binder, then it'll update the table with the data we've provided.

```swift
binder.finish()
```

And that's pretty much it - the binder will then create two cells and populate them with the two `Person` objects.

## Sectioned table views

Many of the table views we work with use sections. When using Tableau, sections can be defined either with an enum or a struct that 
conforms to `TableViewSection`. Let's say we're building a table that has three sections of `Person` objects - one section for friends, one
section for enemies, and one section for people you aren't sure of yet. To start, we'll define our 'section model' enum like so:

```swift
enum Section: TableViewSection {
    case friends
    case enemies
    case undecided
}
```

For sectioned table views, we use the `SectionedTableViewBinder` instead of just the `TableViewBinder`. We initialize it with the 'section
model' type (our enum) like this:

```swift
let binder = SectionedTableViewBinder(tableView: tableView, sectionedBy: Section.self)
```

Then we'll setup our data to give the binder. For this demo, we'll just make three different arrays.

```swift
let friends = [
    Person(name: "Asif", age: 27), // brings delicious cupcakes to work
    Person(name: "Joanne", age: 31) // gives me good deals at Bulk Barn
]
let enemies = [
    Person(name: "Joseph", age: 22), // doesn't like dark chocolate
    Person(name: "Sue", age: 42) // thinks 'Attack of the Clones' is the best Star Wars movie
]
let undecided = [
    Person(name: "Madeleine", age: 54), // is kind of passive-aggressive, but has a cute dog
    Person(name: "Jorge", age: 19) // loves daytime television, but does like dark chocolate
]
```

Perfect. Now, we have two different cells we want to use - a normal cell for 'friends' and 'undecided', and a special cell type for cells in our 
'enemy' section that draws a red 'X' over it. (we'll assume that these cell classes have been defined somewhere else and conform to
`ReuseIdentifiable`). We'll setup the 'enemies' section first.

```swift
binder.onSection(.enemies)
    .bind(cellType: EnemyTableViewCell.self, models: enemies)
    .headerTitle("ENEMIES")
    .onCellDequeue { (row: Int, cell: EnemyTableViewCell, person: Person) in
        // setup cell
    }
    .onTapped { (row: Int, cell: EnemyTableViewCell, person: Person in
        // go to a detail VC
    }
```

As you can see, when we deal with a sectioned binder, we don't have an `onTable` method to start binding chains - we start binding chains
by passing in the section (in this case, a case of our `Section` enum) we want to bind the following information to. After that, it's basically the
same story as with the section-less binding chain - bind a cell type, on 'on dequeue', and an 'on tapped'. Here, we've also added the title for
this section.

Next, we'll setup the 'friends' and 'undecided' sections. They use a lot of the same logic and the same cell type, so we'll bind them together
in one binding chain to spare a few lines.

```swift    
binder.onSections([.friends, .undecided])
    .bind(cellType: MyTableViewCell.self, models: [
        .friends: friends,
        .undecided: undecided
    ])
    .headerTitles([
        .friends: "FRIENDS",
        .undecided: "NOT SURE YET"
    ])
    .onCellDequeue { (section: Section, row: Int, cell: MyTableViewCell, person: Person) in
        // setup cell
    }
    .onTapped { (section: Section, row: Int, cell: MyTableViewCell, person: Person) in
        // go to a detail VC
    }    
```

As you can see, binding two sections at once is basically the same - the only difference is that for cell models, we pass in a dictionary where
the key is a section and the value is an array of the models for that section. Each binding chain applies the handlers and data bound to it only 
to the sections it was started with. So, in the first binding chain, the `EnemyTableViewCell` is only used in the 'enemies' section, and the
associated `onCellDequeue` and `onTapped` handlers are only called when cells are dequeued or tapped in this section. Likewise, with the 
next binding chain, the `MyTableViewCell` type is only used in the 'friends' and 'undecided' sections, with its associated handlers only being 
called for cells in those sections. Neat, huh?

The last thing we do with our sectioned binder is set a 'behaviour' for how it hides and orders sections. For simplicity (and because our data
isn't dynamic), we'll just leave the default behaviour - 'manually managed'. This means in order to control which sections are displayed (and in 
what order), we just set the `displayedSections` property on the binder. We want all our sections displayed, so we'll just do this:

```swift
binder.displayedSections = [.friends, .enemies, .undecided]
```

When we get into dynamic data in other tutorials, we'll introduce the other 'section display behaviours' that let the binder hide sections for us
automatically when they're empty. For now, we'll leave this, call the binder's `finish()` method, and we're good to go!

With that, you should be pretty much up to speed to start playing around with Tableau. Other tutorials are available on the repo to get you 
started with other features of Tableau, like updating data on your bound table views, setting up your models so it can be animated for changes,
using dynamic sections, and others. 
- [Updating data](UpdatingData.md)
- [Hiding, showing, and ordering sections automatically](SectionDisplayBehaviour.md)
- [Providing dimensions](ProvidingDimensions.md)
- [Advanced binding chains](AdvancedBindingChains.md)
- [Using view models](UsingViewModels.md)
- [Tips, tricks, and FAQ](TipsTricksFAQ.md)
- [How it works](HowItWorks.md)

If you'd prefer to poke around some working examples, there are working samples in the `TableauExample` Xcode project you can run to see 
the end result.
