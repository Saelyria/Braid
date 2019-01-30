import UIKit

/**
 A protocol describing an object that can be initialized from a `UINib`.
 
 Braid uses the properties of this protocol when registering cell or view types to table/collection views.
 */
public protocol UINibInitable: AnyObject {
    /// The file name of the Nib file containing this class. Defaults to the name of the conforming type if not
    /// explicitly provided by the conforming type.
    static var nibName: String { get }
    /// The index of the item in the Nib's hierarchy that represents an instance of the conforming type. Defaults to 0
    /// if not explicitly provided by the conforming type.
    static var indexInNib: Int { get }
    /// The bundle containing the Nib file. Defaults to the conforming type's bundle if not explicitly provided by the
    /// conforming type.
    static var bundle: Bundle { get }
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
    
    /**
     Creates an instance of the conforming class from its Nib using its `UINibInitable` properties.
     
     - parameter owner: The owner of the nib contents. Defaults to nil.
     
     - returns: An instance of the nib-initable view.
    */
    static func createFromNib(owner: Any? = nil) -> Self {
        let nib: UINib = UINib(nibName: self.nibName, bundle: self.bundle)
        guard let view: Self = nib.instantiate(withOwner: nil, options: nil)[self.indexInNib] as? Self else {
            fatalError("An instance of '\(String(describing: Self.self))' was not able to be instantiated using the properties described in its UINibInitable conformance. Please ensure they are correct, along with the names/properties in the expected Nib file.")
        }
        return view
    }
}
