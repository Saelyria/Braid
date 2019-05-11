#  Custom cell events

Cells on table views often have controls whose interaction we want to be delegated to the cell's view controller. These interactions could be
things like button presses, text entry in a text field, toggling of a switch, picking of a date on a date picker, or anything else. Delegation of these
events from the cell back up to the table view is often not very elegant, usually involving multiple delegate protocols or by holding a reference 
to specific cells. Code like this runs into problems when cells get reused on your table and generally involves a lot of index path bookkeeping.

To help solve this problem, Braid gives cells the ability to declare a custom `ViewEvent` enum whose cases it can emit up to its view
controller through handlers on a binding chain.

## Setting up the cell

To start, we'll define a custom table cell type. This cell will be initialized from a Nib file and will have a text field to the right of the cell and a 
'title' label to the left. We'll add IB actions for when text entry starts, changes, and ends on the text field too.

```swift
class TextFieldTableViewCell: UITableViewCell, UINibInitable {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func textEntryStarted() {
    
    }
    
    @IBAction func textEntered() {
    
    }
    
    @IBAction func textEntryEnded() {
    
    }
}
```
We'll assume that our Nib file is created elsewhere, matches the requirements for `UINibInitable`, and is hooked up to the IB outlets and
actions.

To make our cell able to emit view events up to its view controller, it needs to conform to the `ViewEventEmitting` protocol. The only
requirement for this protocol is a `ViewEvent` [associated type](https://docs.swift.org/swift-book/LanguageGuide/Generics.html#ID189). This
type is generally an enum whose cases are all the events that your cell can relay to its controller.

We'll add conformance to `ViewEventEmitting` and define our cell's `ViewEvent` enum like this at the top of the class declaration:

```swift
class TextFieldTableViewCell: UITableViewCell, UINibInitable, ViewEventEmitting {
    enum ViewEvent {
        case textEntryStarted
        case textEntered(text: String)
        case textEntryEnded
    }
    
    ...
}
```

Our `ViewEvent` enum isn't restricted by any requirements like `Hashable`, so we can have associated values (like with our 
`textEntered(text: String)` case) so we can pass type-safe arguments back to our controller too.

Once we have our event enum defined, the only thing left to do in our cell is to, when an event happens, call the `emit(event:)` method. This
method is available to types conforming to `ViewEventEmitting`, and simply takes as an argument an instance of the type's `ViewEvent`
associated type. For our cell, we just need to call this method in our IB action functions like this:

```swift
    @IBAction func textEntryStarted() {
        self.emit(event: .textEntryStarted)
    }

    @IBAction func textEntered() {
        let text = self.textField.text
        self.emit(event: .textEntered(text: text)
    }

    @IBAction func textEntryEnded() {
        self.emit(event: .textEntryEnded)
    }
```

## Listening for cell events in the view controller

Once our cell is setup, we just go back to our view controller and add a call to `onEvent(from:_:)` on the binding chain we want to observe
it on. With this method, we add a handler that is called whenever an event is emitted on a cell of the given type on the section(s) involved with
the binding chain. This handler is passed in the row, cell, and event that was emitted. It will generally look something like this:

```swift
binder.onSection(.first)
    .bind(cellType: TextFieldTableViewCell.self, viewModels: { ... })
    .onEvent(from: TextFieldTableViewCell.self) { row, cell, event in
        switch event {
        case .textEntryStarted:
            // do something when text entry started on the cell
        case .textEntered(let text):
            // do something when text is entered on the cell, like update another cell or write to a model
        case .textEntryEnded:
            // you get the idea
        }
    }
```

If you use a cell binding type that includes a model, a safely-cast model object can also be passed into this handler, just like with `onTapped`
or `onDequeue`. You just need to include a fourth argument to the closure you give.

## Use with multi-cell type sections

This method is particularly useful for sections that have multiple possible cell types for uses like form building. Let's pretend we have to build
a sign-up form for a user. We need a username cell, a password cell, an email cell, and a toggle cell indicating whether they would like to 
receive a bunch of marketing emails (which we're told has to be on by default).

We'll assume that we have `TextFieldTableViewCell` and `ToggleTableViewCell` cells defined somewhere, setup similarly to our 
previous text field cell with `ViewEvent` enums that'll let us know when text is entered or a toggle gets toggled. 

To make our lives easier, instead of counting indexes, we'll define a `FormItem` enum on our view controller whose cases represent one part of
the form, like this:

```swift
enum FormItem {
    case username
    case password
    case email
    case sendMeStuff
}
```

That way, we can use this `FormItem` type as a binding chain's model type and have it passed into our cell creation closure. Then, we'll set up
our binding chain like this:

```swift
var displayedFormItems: [FormItem] = [.username, .password, .email, .sendMeStuff]

binder.onSection(.someSection)
    .bind(
        cellProvider: { tableView, row, formItem in
            switch formItem {
            case .username, .password, .email:
                return tableView.dequeue(TextFieldTableViewCell.self)
            case .sendMeStuff:
                return tableView.dequeue(ToggleTableViewCell.self)
            }
        }, models: {
            return displayedFormItems 
        })
```

Now we can listen for changes to both the cell types by adding these, and switch on the passed-in form item model to find out which cell
exactly sent the event.

```swift
var displayedFormItems: [FormItem] = [.username, .password, .email, .sendMeStuff]

binder.onSection(.someSection)
    .bind(
        cellProvider: { tableView, row, formItem in
            switch formItem {
            case .username, .password, .email:
                return tableView.dequeue(TextFieldTableViewCell.self)
            case .sendMeStuff:
                return tableView.dequeue(ToggleTableViewCell.self)
            }
        }, models: {
            return displayedFormItems 
        })
    .onEvent(from: TextFieldTableViewCell.self) { row, cell, event, formItem in
        switch (event, formItem) {
        case (.textEntered(let text), .username):
            // save the username somewhere
        case (.textEntered(let text), .password):
            // save the password somewhere
        case (.textEntered(let text), .email):
            // save the email somewhere
        }
    }
    .onEvent(from: ToggleTableViewCell.self) { row, cell, event in
        switch event {
        case .switchToggled(let state):
            // save the toggle state somewhere
        }
    }
```

Neat, huh? This ends up being considerably shorter, less error-prone, and much faster than having done the same thing with more traditional
methods. What's more, if we wanted to be able to dynamically insert, rearrange, or change form items based on the value of other form items,
we can use Braid's powerful diffing to do the heavy lifting for us. All we have to do is just add `Int` as a raw value of our `FormItem` and 
make it conform to `CollectionIdentifiable` (which will provide a default `collectionId` property for diffing since `FormItem` will 
automatically conform to `Hashable`) like this:

```swift
enum FormItem: Int, CollectionIdentifable {
    case ...
}
```

We can then change around our `displayedFormItems` array, call `refresh()` on our binder, and it'll automatically diff and animate our table
view form. The sample project includes a working example (Sample 3 - Form) that demonstrates how you could build the 'Add Event' model 
from the iOS Calendar app, including animations like this where form items change and animate.

- [Getting Started](1-GettingStarted.md)
- [Updating data](2-UpdatingData.md)
- [Other data binding methods](3-DataBindingMethods.md)
- **Custom cell events**
- [Hiding, showing, and ordering sections automatically](5-SectionDisplayBehaviour.md)
- [Binding chain scopes](6-AdvancedBindingChains.md)
- [Providing dimensions](7-ProvidingDimensions.md)
- [Tips, tricks, and FAQ](9-TipsTricksFAQ.md)
- [How Braid works](10-HowItWorks.md)
