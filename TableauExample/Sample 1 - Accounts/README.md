# Sample 1 - Account

## Overview

This sample demonstrates how to use a `TableViewSection` enum to bind a section table view. The view controller 
(`AccountsViewController`) is a mock 'accounts' view controller like you might find in a banking app, where sections on the table view are 
different types of accounts - checking, savings, etc.

The data shown by the table are instances of the `Account` model object, which are 'fetched from the server' by the `AccountsService` 
object. It uses the `CenterLabelTableViewCell`, `TitleDetailTableViewCell`, and `SectionHeaderView` views classes to display its 
data. Whenever the 'Refresh' button is tapped in the view's nav bar, it starts a new 'fetch' and fills the table with the new data, 
demonstrating Tableau's ability to auto-animate changes. This view controller uses RxSwift to do much of its work, so a familiarity with this
framework is highly recommended before continuing.

## Walkthrough

1. This is the enum whose cases describe the sections in the table view. This enum must conform to the `TableViewSection` protocol.

2. A reference to the 'table view binder' object must be kept for the lifecycle of the view controller. This object keeps the RxSwift subscriptions
    live, and holds references to the data displayed on the table view. Generally, this should just be a property on your view controller.
    
3. The observable object that we will bind to the binder in various ways that it will pull its cell data from. Events from this behaviour relay are
    emitted whenever the 'Refresh' button is tapped and the mock network request gives us a new array of `Account` objects.

4. Here, we instantiate the actual `UITableView` object, and register the cells we're going to use with it. Tableau provides convienient 
    `register` methods on table views for cells that conform to `ReuseIdentifiable` that registers the cell with the reuse identifier given by 
    conformance to this protocol. If the cell conforms to `UINibInitable`,  then this method will register the cell's nib instead of the class.
    
5. Here we instantiate the 'binder' object. The init method is given the table view it will perform the binding on along with the enum type we 
    want the table's sections to be described by. Finally, we give an array of the sections we want the table to initially display - we will update
    the 'displayed properties' later after our mock network request finishes and we know what accounts to show.
    
6. Here, we perform our first 'binding chain'. We declare that on the 'message' section, we want its cells to be `CenterLabelTableViewCell`
    instances. `CenterLabelTableViewCell` is `ViewModelBindable`, so we choose to instantiate these cells with the array of given 'view
    models'. The table binder will create one cell for each view model in this array for this section. This method requires that the array given to
    the `viewModels` argument be an array of the cell's `ViewModel` associated type. For more information on using view models, check out 
    the documentation on  `ViewModelBindable`. We only want one cell in this section with the 'open a new account' call-to-action, so we 
    supply an array with one view model with that text.
    
    Note also that this section's cell type is not bound using the `rx` extension on the binder. This data never changes, so we don't need to use
    RxSwift to update it. The next binding chain, however, will use RxSwift, to allow us to easily update the data for its sections later.
    
7. Here, we perform the work for binding all the other sections -  'checking', 'savings', and 'other' - since their setup logic is the same. They
    all use the `TitleDetailTableViewCell` type for their cells. This cell type is also 'view model bindable', so we'd like to use view models 
    for its cells as well. However, we do something a little different than *just* using view models. The cells in these sections are meant to 
    visually display `Account` objects. Whenever cells in these sections are tapped, we want a reference to the `Account` object the cell 
    represents so we can show a view controller with details for that account. Tableau lets us do with by associating a generic 'model' type to 
    our cells using the `bind(cellType:models:mapToViewModelsWith:)` method.
    
    In this chain, we associate `Account` instances to the cells by passing an observable dictionary of `Account` objects to the `models` 
    argument. The keys on this dictionary are `Section` instances, with the values being arrays of models that the cells are dequeued for. We'd 
    still like our cells to be setup with view models so we don't need to include an `onDequeue` call on our chain, so we also supply a
    closure that will map a given account into a `TitleDetailTableViewCell.ViewModel`. Setting up the chain with this method means
    that whenever the `self.accountsForSections` observable fires, the binder will map the resulting dictionary of `Accounts` arrays into
    view models for the cells in the appropriate sections.
    
8. After we setup the cell type and the observable 'data source' for the sections, we add an `onTapped` handler to the chain. Whenever a cell
    in the 'checking', 'savings', or 'other' section is tapped, the handler  given to this method is passed in section, row, and cell that was 
    tapped. We ignore all these arguments, though, since what we're really interested in is the `Account` object that the tapped cell represented.
    This is very easy with Tableau - since we're calling this `onTapped` method after the cell binding method where we gave the cell and generic
    'model' types, we can also also have this method be passed in the instance of the generic 'model 'type (in this case, the `Account` instance) 
    that the tapped cell was representing. Much better than using the index path to look through an 'accounts' array.
    
9. Now we're going to setup the headers and footers on these three sections. We don't need to start a new binding chain with the
    `onSections` call here - we could just append the `bind(headerType:viewModels)` method to the last one after the `onTapped` 
    method - but, just for the sake of dividing up the binding into logical chunks/to show that it's possible, we'll just do it on another chain.
    Here, we're going to use a custom 'header/footer view' type - `SectionHeaderView`. This view type is `ViewModelBindable` as well, so
    we similarly pass in a dictionary of view model objects (organized by `Section`).
    
10. On the same binding chain, we set up the footers. We'll just use the default iOS footers where we just provide a string - on a binder, this is
    done with the `footerTitles` method, which gets passed in a dictionary where the keys are `Section`s and the values are strings. Only 
    the `other` section has footer text, so that's the only entry we'll put in the dictionary.
    
11. With that, our table is bound and ready to go. When we finish our binding, we need to make sure we call the `finish` method on the 
    binder. The binder uses this method to setup a standin 'data source/delegate' object for the table view with the appropriate methods added
    to it according to the data/handlers given to the binder and call the first `reloadData()` on the table view.