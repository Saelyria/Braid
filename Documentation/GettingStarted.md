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

Easy. Table views are used to display arrays of data - for this example, lets make a custom 'person' type and an array of people we want the 
table to show:

```swift
struct Person {
    let name: String
    let age: Int
}

let people = [
    Person(name: "John", age: 32),
    Person(name: "Mary", age: 45)
]
```

Perfect. On our table, we want to display users with a custom cell type - here, we'll define a `MyCustomTableViewCell` cell type to use.  

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

Here, we'll want to add an 'on cell dequeue' handler to this chain be called whenever the binder dequeues a cell so we can set it up. This 
handler will be passed in the cell and 'person' object the cell was dequeued for so we can set it up:

```swift
binder.onTable()
    .bind(cellType: MyCustomTableViewCell.self, models: people)
    .onCellDequeue { (row: Int, cell: MyCustomTableViewCell, person: Person) in
        cell.titleLabel.text = person.name
    }
```
Cool. However, we also want to do some work (maybe show a 'person details' view controller) whenever a cell in our table is tapped. To do 
that, we'd just add an 'on tapped' handler like this:

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
    Person(name: "Asif", age: 27),
    Person(name: "Joanne", age: 31)
]
let enemies = [
    Person(name: "Joseph", age: 22), // doesn't like chocolate
    Person(name: "Sue", age: 42) // thinks 'Attack of the Clones' is the best SW movie
]
let undecided = [
    Person(name: "Madeleine", age: 54),
    Person(name: "Jorge", age: 19)
]
```

Perfect. Now, we have two different cells we want to use - a normal cell for 'friends' and 'undecided', and a special cell type for cells in our 
'enemy' section that draws a red 'X' over it. (we'll assume that these cell classes have been defined somewhere else and conform to
`ReuseIdentifiable`). To do this, we'll bind sections specially, like this:

```swift
binder.onSection(.enemies)
    .bind(cellType: EnemyTableViewCell.self, models: enemies)
    .onCellDequeue { (row: Int, cell: EnemyTableViewCell, person: Person) in
        // setup cell
    }
    .onTapped { (row: Int, cell: EnemyTableViewCell, person: Person in
        // go to a detail VC
    }
    
binder.onSections([.friends, .undecided])
    .bind(cellType: MyTableViewCell.self, models: [
        .friends: friends,
        .undecided: undecided
    ])
    .onCellDequeue { (section: Section, row: Int, cell: MyCustomTableViewCell, person: Person) in
        // setup cell
    }
    .onTapped { (section: Section, row: Int, cell: EnemyTableViewCell, person: Person in
        // go to a detail VC
    }
    
binder.finish()
```

As you can see, when we deal with a sectioned binder, we start binding chains on a section (or sections together). Each binding chain applies
the handlers and data bound to it only to the sections it was started with. So, in the first binding chain, the `EnemyTableViewCell` is only
used in the 'enemies' section, and the associated `onCellDequeue` and `onTapped` handlers are only called when cells are dequeued or
tapped in this section. Likewise, with the next binding chain, the `MyTableViewCell` type is only used in the 'friends' and 'undecided' 
sections, with its associated handlers only being called for cells in those sections. Neat, huh?

With that, you should be pretty much up to speed to start playing around with Tableau. Other tutorials are available on the repo to get you 
started with other features of Tableau, like updating data on your bound table views, setting up your models so it can be animated for changes,
using dynamic sections, and others. If you'd prefer topoke around some working examples, there are working samples in the
`TableauExample` Xcode project you can run to see the end result.

Thanks for stopping by!
