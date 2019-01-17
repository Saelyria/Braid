#  Sample 3 - 'Add Event' Form

The view controller in this sample is roughly based on the 'Add Event' view found in the native iOS Calendar app. It doesn't do *everything* the
iOS one does, but it gets the broader strokes. The cells on this table have  controls in them whose events are delegated back to the view 
controller through the binding chain. The form itself updates and animates as the controls on its cells change. 

There are a number of ways you could set up this table - for this one, we chose to have four different cell types (one with a switch, a few that 
use text fields for text entry or for showing picker view results, a couple date picker cells, and two text view cells for entered notes/a URL).

> Before reading through this, it's also recommended that you take a quick look through these tutorials:
- [Getting started](../../Documentation/1-GettingStarted.md)
- [Updating data](../../Documentation/2-UpdatingData.md)
- [Custom cell events](../../Documentation/4-CustomCellEvents.md)
- [Advanced binding chains](../../Documentation/6-AdvancedBindingChains.md)

1. To start, we'll take a look at one of the table view cells. Most of their implementations are roughly the same, so one will suffice. Open up
`TextFieldTableViewCell.swift` and take a look. This cell conforms to `ViewEventEmitting`, and declares its associated `ViewEvent`
type to be an enum with three events - when text entry starts, text is entered, and when it ends. When text is entered, we pass along an 
associated `text` string with the event. The only other thing we do out of the ordinary here is call the `emit(event:)` method of 
`ViewEventEmitting` and pass in the appropriate case of our enum when events happen.

2. Flip back over to `FormViewController`. Here, we define our section - mostly the same as our other sections from other samples. We 
make its raw value `Int` and make it `Comparable` so that we can have our binder automatically manage ordering and hiding sections.

3. This `FormItem` enum is was the model type is going to be for our binding chains. Each case on this enum represents one part of our form. 
These enum cases will be passed around as the model in our handlers to help us identify which form item a given cell is being used to 
represent. Later on, we'll map these `FormItem` cases into a `CellModel` that we can use to dequeue cells. We also make sure that it has a
hashable raw value (`String`) and conforms to `CollectionIdentifiable` so that our binder can automatically diff and animate it. We 
don't need to explicitly provide a `collectionId` string property since our enum is now `Hashable` because of its string raw value.

4. This variable is how we'll give model information to the binder. `displayedFormItems` will simply return a dictionary when we get it that
maps which form items should be displayed under each section, using a couple pieces of model information to determine which form items
are shown.

5. `FormData` is just an object where we store all the information in the form. Imagine that at the end of our form, we encode that into JSON or
something to send to a server/store somewhere/put on a calendar.

6. This is where we'll store which form item the user is currently interacting with. The `displayedFormItems` takes this variable into account
to determine whether or not to insert date pickers.

7. Here we bind a 'cell provider' (a closure that is called with the table view, section, row, and model to dequeue a cell for) along with a closure
that will return our `displayedFormItems` model. The compiler will figure out that the model type being bound is `FormItem`, so our 'cell
provider' closure will get passed in this item. We have a function a little further down called `dequeueCell(forFormItem:tableView:)` that
will switch over the form item and return an appropriate cell - call that here then we're good.

8. Now we'll start binding logic to our sections, starting with the 'title and location' section. The start the chain, we use this 
`assuming(modelType:)` method. If you've read through the documentation, you know that model information is only available for handlers
if they come *after* a cell binding method that provides it. However, we did that binding on the 'all sections' chain. To solve this, we can use
this 'assuming model type' method to tell the binder 'I'm certain that the cells on this section are using this model type, so just pass in the 
models to handlers on this chain'. We're sure that `FormItem` is the model type for all following sections, so this is fine - our app won't crash.

9. Right after that, we add our first custom event handler. These handlers work by having you declare the type of cell you want to receieve
events from (in this case, our text field cells), then passing in a handler that gets called whenever events from cells of that type on the given
section are called. Since we assumed the model type to be `FormItem`, the form items for the cells will get passed in. We can then switch
over the passed-in event and form item to store text on the appropriate property on our 'form data' variable.

10. Our binding chain for the 'time' section is largely the same as for the 'title and location' section. To start it off, when the switch in this 
section gets toggled, we set the 'is all day' flag on the 'form data' object, then reload the binder. The binder will respond by calling the closure
we gave it for `models` in the `onAllSections` chain, which will now return a new set of form items for the 'time' section. It'll do a bunch of
diffing stuff then animate away the 'start time' and 'end time' cells, or vice-versa.

11. Here we'll listen for the text field cells on the 'time' section. For simplicity, we're just using text field cells for the different date-related cells.
Their text is entered from date picker cells. We set this handler up to listen for when text entry starts or finishes to set or unset the 'active form
item' property, then refresh the table.
