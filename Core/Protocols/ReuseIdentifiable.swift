import UIKit

/**
 Defines an object that is instantiated or dequeued with a reuse identifier.
 
 This is most likely to be implemented by view classes like `UITableViewCell` or `UICollectionViewCell`, and allows
 these types to declare a 'reuse identifier' that binders can use to dequeue new instances. Conformance to this protocol
 is only necessary for dequeuable types if they use a reuse identifier that is not simply the name of their class - by
 default, Tableau will register and dequeue cells by the name of their class.
 */
public protocol ReuseIdentifiable {
    /// The reuse identifier that instances of this class should be dequeued with.
    static var reuseIdentifier: String { get }
}

internal protocol _ReuseIdentifiable {
    static var classNameReuseIdentifier: String { get }
}
extension _ReuseIdentifiable {
    static var classNameReuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: _ReuseIdentifiable { }
extension UITableViewHeaderFooterView: _ReuseIdentifiable { }
extension UICollectionReusableView: _ReuseIdentifiable { }
