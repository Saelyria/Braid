# Sample 2 - Artists & Songs

## Overview

This view controller demonstrates how to use a struct instead of an enum as the section model for more dynamic section binding. The view
controller is a mock 'artists' view controller (`ArtistsViewController`) - basically the same as the one in the default iOS Music app.

The data shown by the table are instances of the `Artist` model object, which are 'fetched from the server' by the `MusicLibraryService`.
The songs are organized alphabetically, divided into sections where each section is the letter the artists in it start with, just like the iOS Music
app. It uses the `TitleDetailTableViewCell` for all cells in the table, and just uses the default table view headers created when we provide
titles. Just like the previous sample, tapping the 'Refresh' button starts a new 'fetch' and fills the table with new data, animating just like 
the 'accounts' sample. Similarly, this view controller uses RxSwift to do much of its work, so familiarity with this framework is highly 
recommended before continuing.

## Walkthrough

1. Here, instead of using an enum to define our sections, we use a struct object. While enums provide better code legibility for more static 
    table views (the main legibility being that we can see all sections possible in the table by just looking up the enum), using a struct has many 
    advantages as well. In this example, we decide to use a struct instead of an enum with 26 cases (more if you want to organize by symbol)
    for brevity of code. It also allows us to bind other data to the section model - most notably, the 'title' for the section. Just like the enum in 
    the previous example, here, we make the `Section` conform to `TableViewSection`, then `Comparable` for ordering.
    
2. An observable 'data source'-type object that we will later bind to the table view with the binder. Events on this object will, as in the previous
    example, trigger updates on the table view once it is bound.
    
3. Creating the binder and setting up the table view is done in the same way as the previous example - we'll once again pass in 
    `hidesSectionsWithNoCellData` as the section display behaviour.
    
4. Our binding chain is where we start doing something different. Here, we use the `onAllSections()` method on the binder instead of the
    `onSection(_:)` or `onSections(_:)` methods. When we use this method to start a binding chain, the cell type/models/handlers/etc. that
    we bind are used to dequeue cells for all sections on the table*, including those that are added later that the binder is not aware of at
    compile-time.
    
    We continue this binding chain by binding the `TitleDetailTableViewCell` to all sections, which are dequeued based on the `Artist`
    objects given from the `artistsForSections` observable dictionary. When we use the `onAllSections` binding method, sections are
    added or removed based on which sections in the dictionary have data, as you would expect. We don't have to manage the deletion of 
    sections either since we assigned the section display behaviour to be `hidesSectionsWithNoCellData`.
