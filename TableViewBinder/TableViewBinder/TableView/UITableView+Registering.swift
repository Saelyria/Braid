import UIKit

public extension UITableView {
    /// Registers the given cell type's nib on this table view, using the properties of the cell's `ReuseIdentifiable`
    /// and `UINibInitable` implementations.
    public func register<T:UITableViewCell & UINibInitable & ReuseIdentifiable>(_ cellType: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    /// Registers the given cell type on this table view, using the properties of the cell's `ReuseIdentifiable`
    /// implementation.
    public func register<T: UITableViewCell & ReuseIdentifiable>(_ cellType: T.Type) {
        self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    /// Registers the given header/footer view type's nib on this table view, using the properties of the view's
    /// `ReuseIdentifiable` and `UINibInitable` implementations.
    public func register<T: UITableViewHeaderFooterView & UINibInitable & ReuseIdentifiable>(_ headerFooterType: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    /// Registers the given header/footer view type on this table view, using the properties of the view's
    /// `ReuseIdentifiable` implementation.
    public func register<T: UITableViewHeaderFooterView & ReuseIdentifiable>(_ headerFooterType: T.Type) {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
}
