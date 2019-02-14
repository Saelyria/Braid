#  Sample 3 - 'Add Event' Form

## Overview

The view controller in this sample is roughly based on the 'Add Event' view found in the native iOS Calendar app. It doesn't do *everything* the
iOS one does, but it gets the broader strokes. The cells on this table have controls in them whose events are delegated back to the view 
controller through the binding chain. The form itself updates and animates as the controls on its cells change. 

There are a number of ways you could set up this table - for this one, we chose to have four different cell types (one with a switch, a few that 
use text fields for text entry or for showing picker view results, a couple date picker cells, and two text view cells for entered notes/a URL).

> Before reading through this, it's also recommended that you take a quick look through these tutorials:
- [Getting started](../../Documentation/1-GettingStarted.md)
- [Updating data](../../Documentation/2-UpdatingData.md)
- [Custom cell events](../../Documentation/4-CustomCellEvents.md)
- [Advanced binding chains](../../Documentation/6-AdvancedBindingChains.md)

## Walkthrough

1. To start, we'll take a look at one of the table view cells. Most of their implementations are roughly the same, so one will suffice. Open up
`TextFieldTableViewCell.swift` and take a look. This cell conforms to `ViewEventEmitting`, and declares its associated `ViewEvent`
type to be an enum with three events - when text entry starts, text is entered, and when it ends. When text is entered, we pass along an 
associated `text` string with the event. The only other thing we do out of the ordinary here is call the `emit(event:)` method of 
`ViewEventEmitting` and pass in the appropriate case of our enum when events happen.

2. Next, flip over to `FormItem.swift`. Here we've defined two objects - first, the `FormData` object (an object that stores all the data entered
into the form - in a production app, this could be decodable into JSON that we send to a server or something like that). Our view controller 
will have an instance of this held to store data before we 'send' it.

3. Next, the `FormItem` enum. The cases on this enum each represent one cell of the whole form. These cases will be the 'model' type in our
binding chains so that we can have them passed into the various handlers in the chain so we can easily identify which cell in the form is 
emitting events. We also make sure to add conformance to `CollectionIdentifiable` and `Equatable` so that our binder can
automatically diff and animate it our cells.

4. Flip back over to `FormViewController`. Here, we define our section - mostly the same as our other sections from other samples. We 
make its raw value `Int` and make it `Comparable` so that we can have our binder automatically manage ordering and hiding sections.

5. This is where we'll store which form item the user is currently interacting with, especially for the date picking cells. The
`determineFormItems(from:activeItem:)` method takes this variable into account to determine whether or not to insert date pickers.

6. Since we're using a 'cell provider' closure to create our cells instead of giving cell types to the binder, we need to manually register our
cells. Braid gives us two convenience methods for our cells to register them - if the cells conform to `UINibInitable`, they'll automatically be
registered using their nibs; otherwise, they are registered by class.

7. Here we bind a 'cell provider' (a closure that is called with the table view, section, row, and model to dequeue a cell for) along with a closure
that will return our `displayedFormItems` model. The compiler will figure out that the model type being bound is `FormItem`, so our 'cell
provider' closure will get passed in this item. We have a function a little further down called `dequeueCell(forFormItem:tableView:)` that
will switch over the form item and return an appropriate cell - call that here then we're good. The models that our cells are dequeued for are
returns from our `determineFormItems(from:activeItem)` method, which will, given the form data we've collected so far and the form
item that is currently active (i.e. being interacted with), return a dictionary of which form items should currently be shown for each section.

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

11. Here we'll listen for taps from title-details cells (i.e. our 'date', 'start time', and 'end time' cells) for the section. When these cells are
tapped, we want date picker cells to appear below them and have the picked dates reflected back on the cells. As mentioned previously (and
as we'll explain more in depth when we get to the method), we use the `activeFormItem` property in our form item calculation method as one
of the inputs, so we just need to set that then tell the binder to refresh from its bound data.

12. In the next chain handler, we do basically the same thing as in the 'title and location' section chain - listen for date changes from any date
picker cells we have in the section, switch on the passed-in event and form item, and put the entered date into the correct value on our
form data object.

13. Same story here with the 'notes' section.

The rest of the implementation is just the cell dequeueing method that will return cells appropriate to given form items, the method used to
return the form items that should be shown for the given form data, and some date formatter objects that we use to turn our picked dates into
strings for our cells.
