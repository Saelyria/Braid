import UIKit

public extension UITableView {
    /**
     Registers the given cell type's nib on this table view, using the properties of the cell's `ReuseIdentifiable`
     and `UINibInitable` implementations. The cell can then be dequeued using its type's `reuseIdentifier` property.
     
     - parameter cellType: The cell to register to the table view.
    */
    public func register<T:UITableViewCell & UINibInitable>(_ cellType: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    /**
     Registers the given cell type on this table view, using the properties of the cell's `ReuseIdentifiable`
     implementation. The cell can then be dequeued using its type's `reuseIdentifier` property.
     
     - parameter cellType: The cell to register to the table view.
    */
    public func register<T: UITableViewCell>(_ cellType: T.Type) {
        self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    /**
     Registers the given header/footer view type's nib on this table view, using the properties of the view's
     `ReuseIdentifiable` and `UINibInitable` implementations. The view can then be dequeued using its type's
     `reuseIdentifier` property.
     
     - parameter headerFooterType: The header/footer view type to register to the table view.
    */
    public func register<T>(_ headerFooterType: T.Type)
        where T: UITableViewHeaderFooterView & UINibInitable
    {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    /**
     Registers the given header/footer view type on this table view, using the properties of the view's
     `ReuseIdentifiable` implementation. The view can then be dequeued using its type's `reuseIdentifier` property.
     
     - parameter headerFooterType: The header/footer view type to register to the table view.
    */
    public func register<T: UITableViewHeaderFooterView>(_ headerFooterType: T.Type) {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    /**
     Dequeues an instance of the given cell type for the table view. The cell is dequeued using the reuse identifier
     given from its `ReuseIdentifiable` conformance.
     
     - parameter cellType: The cell type to dequeue an instance of.
     
     - returns: A dequeued instance of the cell type.
    */
    public func dequeue<T: UITableViewCell>(_ cellType: T.Type) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("'\(String(describing: cellType))' was not registered to the table view with the reuse identifier '\(cellType.reuseIdentifier)'.")
        }
        return cell
    }
    
    /**
     Dequeues an instance of the given header/footer view type for the table view. The view is dequeued using the reuse
     identifier given from its `ReuseIdentifiable` conformance.
     
     - parameter headerFooterType: The header/footer view type to dequeue an instance of.
     
     - returns: A dequeued instance of the header/footer view type.
    */
    public func dequeue<T: UITableViewHeaderFooterView>(_ headerFooterType: T.Type) -> T {
        guard let cell = self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("'\(String(describing: headerFooterType))' was not registered to the table view with the reuse identifier '\(headerFooterType.reuseIdentifier)'.")
        }
        return cell
    }
}
