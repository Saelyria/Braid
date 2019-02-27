import Braid

struct TestModel: CollectionIdentifiable, Equatable {
    let collectionId: String
    let value: String
    
    init(_ id: Int, _ value: String) {
        self.collectionId = String(id)
        self.value = value
    }
}

