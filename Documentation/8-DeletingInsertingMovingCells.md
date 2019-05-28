#  Deleting, inserting, and moving cells

Braid has a succinct API for supporting moving, inserting, and deleting cells via editing controls. It is done with a combination of enabling
editing on a binding chain, then adding handlers to the binding chain when editing occurs. We'll jump right into a sample of the API, then 
explain it step by step, starting with moving cells around.

First, a simple sample. We'll make a two-section table that allows cells to be moved around between the two sections

```swift
var firstSectionModels: [Model] = ...
var secondSectionModels: [Model] = ...

self.binder.onSection(.first)
    .bind(cellType: ...)
    .allowMoving(.toSectionsIn([.first, .second]))
    .onDelete { row, source, model in
        self.firstSectionModels.remove(at: row)
    }
    .onInsert { row, _, person in
        self.peopleAttending.insert(person!, at: row)
    }
```
