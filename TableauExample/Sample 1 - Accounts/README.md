# Sample 1 - Account

## Overview

This sample demonstrates how to use a `TableViewSection` enum to bind a section table view. The view controller 
(`AccountsViewController`) is a mock 'accounts' view controller like you might find in a banking app, where sections on the table view are 
different types of accounts - checking, savings, etc.

The data shown by the table are instances of the `Account` model object, which are 'fetched from the server' by the `AccountsService` 
object. It uses the `CenterLabelTableViewCell`, `TitleDetailTableViewCell`, and `SectionHeaderView` views classes to display its 
data. Whenever the 'Refresh' button is tapped in the view's nav bar, it starts a new 'fetch' and fills the table with the new data, 
demonstrating Tableau's ability to auto-animate changes. This view controller uses RxSwift to do much of its work.

## Walkthrough

1. This is the enum whose cases describe the sections in the table view. This enum must conform to the `TableViewSection` protocol.
2. A reference to the 'table view binder' object must be kept for the lifecycle of the view controller. This object keeps the RxSwift subscriptions
    live, and holds references to the data displayed on the table view. Generally, this should just be a property on your view controller.
3. The observable object that we will bind to the binder in various ways that it will pull its cell data from.
