#  Deleting, inserting, and moving cells

Braid has a succinct API for supporting moving, inserting, and deleting cells via editing controls. It is done with a combination of enabling
editing on a binding chain, then adding handlers to the binding chain when editing occurs. 

## Editing cells

We'll jump right into a sample of the API, then explain it step by step, starting with deleting cells using the native table view 'editing mode' with
the red circle buttons with a '-'.

### Deleting cells

Here's what deleting cells looks like with a single-section table:

```swift
let binder = TableViewBinder(tableView: ...)
var models: [Model] = ...

binder.onTable()
    .bind(cellType: SomeCellType.self, models: { [unowned self] in self.models })
    .onDequeue { row, cell, model in
        ...
    }
    .allowEditing(style: .delete)
    .onDelete { [unowned self] row, _, model in
        self.models.remove(at: row)
    }
```

There are only two binding chain elements required - the first is a line declaring that editing is allowed in the binding scope (in this example, the
'binding scope' being on the whole table), and also declaring the allowed editing type (in this case (and probably in most cases), 'delete'). 

The other element is an `onDelete` handler that is called when a cell was deleted from the binding scope. This handler is passed in the row, 
the model instance that the deleted cell was associated with (if, of course, your `bind(cellType:..)` method gave model type information). 
The omitted value is a 'reason' value. We'll explain this 'reason' value when we get to moving cells. The only thing we really need to do in this 
handler is delete the model from the data source (i.e. from the array it came from).

Deleting cells from multiple sections looks basically the same, other than the `onDelete` handler is also given a 'section' argument.

### Inserting cells

Inserting cells looks basically the same:

```swift
binder.onTable()
    .bind(cellType: SomeCellType.self, models: { [unowned self] in self.models })
    .onDequeue { row, cell, model in
        ...
    }
    .allowEditing(style: .insert)
    .onInsert { [unowned self] row, _, _ in
        let newModel = Model(...)
        self.models.insert(newModel, at: row)
    }
```

Again, we declare that editing is allowed in this scope, and the editing style is 'inserting' (i.e. the green circle button with a '+'). When that insert
button is pressed, the `onInsert` handler is called, passing in the same arguments - here, we've omitted the 'reason' and 'model' arguments,
since they're only really used with moving cells.

### Applying more fine-grained editing styles

If you want to be able to make only certain cells in your binding chain editable, the editing style can change, or (for whatever reason) want to 
mix-and-match 'insert' and 'delete' controls, you can do that like this:

```swift
binder.onTable()
    ...
    .allowEditing(styleForRow: { section, row in
        if ... {
            return .delete
        } else {
            return .none
        }
    })
```

This way of declaring editability on a section is basically the same API as the native `UITableViewDelegate` method.

## Moving cells

Adding the ability to move cells around between rows and/or sections on your table follows a similar pattern of first enabling moving, then
providing handlers for when cells are moved out of or moved into the sections of the binding chain. For this sample, we'll setup a table that 
has two sections, where we're able to move cells between either of the sections.

```swift
var firstSectionModels: [Model] = ...
var secondSectionModels: [Model] = ...

binder.onSections(.first, .second)
    ...
    .allowMoving(.toAnySection)
    .onDelete { [unowned self] section, row, reason, model in
        if section == .first {
            self.firstSectionModels.remove(at: row)
        } else {
            self.secondSectionModels.remove(at: row)
        }
    }
    .onInsert { [unowned self] section, row, reason, model in
        if section == .first {
            self.firstSectionModels.insert(model!, at: row)
        } else {
            self.secondSectionModels.insert(model!, at: row)
        }
    }
```

To start, we declare that moving cells is allowed on the sections being bound, and that movement is allowed from these sections to any other
sections on the table. Besides `toAnySection`, there are two other 'movement policy' options we can provide here that we'll talk about later.

Moving cells uses the same handlers as editing controls - when cells are moved out of a section, the `onDelete` handler is called, with cells
moved into a section causing the `onInsert` method to be called. In case your table uses both editing controls _and_ movement controls, 
you can use the `reason` value passed into these handlers to determine which method caused a deletion/insertion. `reason` is an enum value
that indicates either `editing` or `moved(_, _)`, with the latter being passed in the 'from' or 'to' index paths, depending on which handler it
was given to. 

Here, we also accept the `model` argument to the `onInsert` handler. This value is the model instance for the inserted cell _if it came from
another section_. This is why, in the last example, we ignored this value - it would have been nil (since the binder doesn't know how to make
new instances of models). Since cells can only be inserted in a section when they've been moved from another one (and since Braid won't
pass a nil value in this case), we just force-unwrap the model for simplicity.

> Note that Braid assumes that you're not allowing movement between sections that have different declared model types - this will be a
runtime crash. This can still be supported if you don't give the fourth 'model' argument to the closure, however.

> Braid will always call the `onDelete` handler before the `onInsert` handler and will properly bookkeep section and row values for you, so
you can always safely use the given 'section' and 'row' values with your model arrays - no need to increment or decrement the value to account
for deletions from the same section as an insertion. After a call to `onDelete` or `onInsert`, it will perform a data refresh and check to make 
sure that a model was deleted or inserted, performing a debug assertion failure if they did not.

> 'Sample 6 - Editable Attendees' uses a table view that uses both editing controls and movement - check it out for a more in-depth sample.
