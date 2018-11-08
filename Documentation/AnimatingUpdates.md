#  Animating Updates

Tableau includes support for automatically creating diffs when data for cells or sections is updated as well as for automatically animating diffs 
in data with UIKit's table view animations. Enabling this feature is voluntary, and simply requires conformance to the 
`CollectionIdentifiable` protocol on the model objects (or view models) used for cells. This protocol has only one requirement: a
`collectionId` string property. Table and collection view binders use this property to track insertion, movement, and deletion of items on the
table.

For animation updates to work as expected, it's important to understand what value to assign to this property, as it can be any string. The
`collectionId` property is meant to uniquely identify an object in a collection of similar objects, like a serial number on a product or license 
plate on a car, and should not change when the object is 'updated' (e.g. a car keeps the same license plate if its tires are changed or it is 
repainted). In other words, this id should identify an object's 'identity', not its 'equity'. Obeying this distinction allows Tableau to identify when 
a model has 'moved' in a dataset (it found its `collectionId` in a position different than where it was before when it attempts to generate a
diff) versus when a model has 'updated' (its `collectionId` is the same, just the other properties on the model have changed).

This property is generally mapped to some kind of main 'id' property on a model object.
