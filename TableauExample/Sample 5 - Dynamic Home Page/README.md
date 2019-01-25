#  Sample 5 - Dynamic Home Page

## Overview

This sample demonstrates how to use a struct instead of an enum to support dynamically-created section data. The view in this sample is a
'home page' for a shopping app. What we show on our home page is given to us in a mock server response (from our mock `HomeService`).
We can be told by the 'server' to show sections containing cells showing either `Product`s or `Store`s. These sections could be things like 
'Recommended for you', 'Stores nearby', or 'Recently purchased'. We also have one static section that's always on our table - just a marketing
banner at the top of the page. 

Dynamic section data like this could be a common requirement for a large commercial application where exactly what gets shown is very
customer-dependant. And, since it's not known at compile time, we can't use an enum for our sections - instead, we'll use a `Section` struct.
To further help demonstrate this use case, this sample also includes a JSON mock of what this 'home page' response could look like.

> Before reading through this, it's also recommended that you take a quick look through these tutorials:
- [Getting started](../../Documentation/1-GettingStarted.md)
- [Updating data](../../Documentation/2-UpdatingData.md)
- [Other data binding methods](../../Documentation/3-DataBindingMethods.md)
- [Hiding, showing, and ordering sections automatically](../../Documentation/5-SectionDisplayBehaviour.md)
- [Binding chain scopes](../../Documentation/6-AdvancedBindingChains.md)

## Walkthrough

1. To start, we'll take a quick look through our models, starting with the `Product.swift` and `Store.swift` files. These are pretty much 
what we'd expect - products have stuff like a name and price that we'll translate into cell view models for our table, and stores just have a
location name and distance from the user.

2. Next, take a look under `HomeService.swift`, especially at the `HomePageSectionContent` model object at the top of the file. Instances 
of this struct will act as the 'response' we get from the server. They contain information like the title and footer of the section to put on the 
table (along with a 'footer route', which we added for completeness - just details somewhere that tapping the footer should take the user). The
other more interesting part of this object is the `models` property, which is an enum containing either an array of `Product`s or an array of 
`Store`s that the section should show.

3. Now flip to `HomeViewController`. Right at the top, we've defined a `Section` struct that will act as the section model we start binding 
chains with. Most of the time, we'll be mapping the `HomePageSectionContent` objects into these for our table; we create this one so that 
we can support our static 'banner' section. A fun trick with Swift is that static instances on a type that are or return the same type can be
accessed with the same dot-syntax-without-the-type-name as enums (like how `UIColor` instances can be quickly accessed like `.white` or
`.black` without needing to write in `UIColor`). Since our banner section will always be there, we'll make a static `banner` property so that
we can setup one binding chain for this section just like we would for an enum section model.

4. Here we'll create the 'section content' subject that we'll observe new responses from the server through, along with other convenience
properties that map/reduce these 'section content' objects into other more useful pieces of information for our table - the view models for 
each section, the array of sections to show, the header titles for each section, and the footers for each section.

5. Here we set the animation to use for 'undiffable sections'. To understand what this does, take a look again at our model objects - none of 
them are `CollectionIdentifiable` or `Equatable`. However, our table view can still be animated. Binders will still be able to animate in
when new sections are added or when new items are added to these sections - it'll just add or delete items from the end of the section.
Sections whose items don't conform to these protocols are called 'undiffable sections'; the value of this 
`undiffableSectionUpdateAnimation` is thus understood to mean 'the animation to use for cell updates in sections whose data wasn't
diffable'. The default is `.fade`, but for our purposes, the `.left` animation looks a little better.

6. For convenience, Tableau provides a `displayedSections` binding sink so you can bind an observer to it.

7. Here we use that `banner` static property to bind a single 'center label' cell to the section. It'll behave as you'd expect with an enum binding
chain.

8. Next, we'll set up a binding chain that'll be used for the data and handlers for all other sections that get added to the chain. When using
dynamic sections with structs like we are, we'll inevitably need to use either this `onAllOtherSections` or the `onAllSections()` method
to setup the sections for our struct (you can actually use either - the two methods have the same implementation; the different naming is just
to allow you to make your binding chains read better). Here, we bind a 'cell provider' closure that will return a cell appropriate to the section
(near the bottom of the file there's a function that maps the 'model type' on our `HomePageSectionContent` response array into an array of
view models of the appropriate cell for the section - this 'cell provider' uses that function to do its work).

9. Then, once all our binding is done, we'll make our mock request to get the home page response. At the bottom of the file are a couple other
mapping functions to glue everything together.
