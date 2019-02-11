#  Sample 4 - News Feed

## Overview

This sample demonstrates how to use the `prefetch(when:with:)` method of a binding chain to implement an 'infinite scroll' table view.
This sample is a mock news feed view controller that pulls mock data from the `NewsFeedService` singleton and appends it to the end of its
table. Most of the sample is done the same as previous samples, so we'll keep the walkthrough for it fairly short. 

> Before reading through this, it's also recommended that you take a quick look through these tutorials:
- [Getting started](../../Documentation/1-GettingStarted.md)
- [Updating data](../../Documentation/2-UpdatingData.md)
- [Hiding, showing, and ordering sections automatically](../../Documentation/5-SectionDisplayBehaviour.md)

## Walkthrough

1. This is the subject that we'll bind to our table that contains all the `NewsItem`. When our table view is scrolled so that it only has 1 cell from
the end, we'll make a request to fetch more news items and we'll append them to this array subject.

2. Here we set up the binding chain like pretty much everywhere else - bind a cell type, bind our observable `NewsItem` array, then map the 
items into view models for our cells.

3. Here's where we set up our prefetching behaviour. The `prefetch(when:with:)` method is called with a `PrefetchBehavior` - an enum
that we use to indicate when we want the handler we pass in to be called. Currently, the only case on this enum is `.cellsFromEnd(Int)`.
This case is created with (as you might expect) an integer of how many cells from the end of the table we want there to be before the given
handler is called. 

That's pretty much all there is to implementing an infinitely scrolling table. In the handler we supply to the `prefetch(when:with:)` method,
we just make a call to our mock service and append the new news items to our array subject. That'll trigger our table to refresh, and the new
cells will be added to the table.
