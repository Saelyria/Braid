import Foundation

/**
 A protocol describing a model or view model type that can be uniquely identified in a data set.
 
 Tableau uses this protocol to uniquely identify models or view models to track these objects as they are added,
 deleted, or moved in the collections of data given to binder objects. This information is then used to create diffs
 that Tableau can then animate on table or collection views.
 
 The `collectionId` property should uniquely identify an object, like a serial number on a product or license plate on
 a car, and should not change when the object is 'updated' (e.g. a car keeps the same license plate if its tires are
 changed or it is repainted). In other words, this id should identify an object's 'identity', not its 'equality'.
 Obeying this distinction allows Tableau to identify when a model has 'moved' in a dataset (it found its `id` in a
 position different than where it was before) versus when a model has 'updated' (its `collectionId` is the same, just
 the other properties on the model have changed).
 */
public protocol CollectionIdentifiable {
    /// A string that uniquely identifies this object among other objects in a table or collection view's data.
    var collectionId: String { get }
}
