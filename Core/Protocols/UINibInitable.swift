import UIKit

/**
 A protocol describing an object that can be initialized from a `UINib`.
 */
public protocol UINibInitable {
    /// The file name of the Nib file containing this class. Defaults to the name of the conforming class.
    static var nibName: String { get }
    /// The index of the item in the Nib's hierarchy that represents an instance of the conforming class. Defaults to 0.
    static var indexInNib: Int { get }
    /// The bundle containing the Nib file. Defaults to the conforming class's bundle.
    static var bundle: Bundle { get }
    
    /// Creates an instance of the conforming class from its Nib using its `UINibInitable` properties.
    static func createFromNib(owner: Any?) -> Self
}

public extension UINibInitable where Self: UIView {
    static var nibName: String {
        return String(describing: Self.self)
    }
    
    static var indexInNib: Int {
        return 0
    }
    
    static var bundle: Bundle {
        return Bundle(for: Self.self)
    }
    
    static func createFromNib(owner: Any? = nil) -> Self {
        let nib: UINib = UINib(nibName: self.nibName, bundle: self.bundle)
        let view: Self = nib.instantiate(withOwner: nil, options: nil)[self.indexInNib] as! Self
        return view
    }
}
