import UIKit

/**
 Defines an object that is instantiated or dequeued with a reuse identifier.
 
 This is most likely to be implemented by view classes like `UITableViewCell` or `UICollectionViewCell`, and allows
 these types to declare a 'reuse identifier' that binders can use to dequeue new instances. The only requirement for
 conformance to this protocol is a static `reuseIdentifier` property. A default value is provided for this property that
 simply returns the class name of the conforming type.
 */
public protocol ReuseIdentifiable {
    /// The reuse identifier that instances of this class should be dequeued with. Defaults to the name of the
    /// conforming type if not explicitly provided.
    static var reuseIdentifier: String { get }
}

public extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
