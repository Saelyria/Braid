import UIKit

/**
 Defines an object that is instantiated or dequeued with a reuse identifier. This is most likely to be implemented by
 view classes like `UITableViewCell` or `UICollectionViewCell`.
 */
public protocol ReuseIdentifiable {
    /// The reuse identifier that instances of this class should be dequeued with.
    static var reuseIdentifier: String { get }
}

public extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

