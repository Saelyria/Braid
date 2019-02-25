import Braid

struct TestModel: ExpressibleByStringLiteral, CollectionIdentifiable, Equatable {
    let value: String
    var collectionId: String {
        return self.value
    }
    
    init(stringLiteral value: String) {
        self.value = value
    }
}

