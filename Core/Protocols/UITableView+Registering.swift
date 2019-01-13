import UIKit

public extension UITableView {
    /**
     Registers the given cell type's nib on this table view. The cell must conform to `UINibInitable` to use this
     method. If the cell conforms to `ReuseIdentifiable`, the cell is registered using its `reuseIdentifiable` property.
     Otherwise, it is registered using a string matching the cell's class name.
     
     - parameter cellType: The cell to register to the table view.
    */
    public func register<T:UITableViewCell & UINibInitable>(_ cellType: T.Type) {
        let reuseIdentifier = (cellType as? ReuseIdentifiable.Type)?.reuseIdentifier
            ?? cellType.classNameReuseIdentifier
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    /**
     Registers the given cell type on this table view. If the cell conforms to `ReuseIdentifiable`, the cell is
     registered using its `reuseIdentifiable` property. Otherwise, it is registered using a string matching the cell's
     class name.
     
     - parameter cellType: The cell to register to the table view.
    */
    public func register<T: UITableViewCell>(_ cellType: T.Type) {
        let reuseIdentifier = (cellType as? ReuseIdentifiable.Type)?.reuseIdentifier
            ?? cellType.classNameReuseIdentifier
        self.register(T.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    /**
     Registers the given header/footer view type's nib on this table view. The view must conform to `UINibInitable` to
     use this method. If the view conforms to `ReuseIdentifiable`, the view is registered using its `reuseIdentifiable`
     property. Otherwise, it is registered using a string matching the view's class name.
     
     - parameter headerFooterType: The header/footer view type to register to the table view.
    */
    public func register<T>(_ headerFooterType: T.Type)
        where T: UITableViewHeaderFooterView & UINibInitable
    {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        let reuseIdentifier = (headerFooterType as? ReuseIdentifiable.Type)?.reuseIdentifier
            ?? headerFooterType.classNameReuseIdentifier
        self.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
    
    /**
     Registers the given header/footer view type on this table view. If the view conforms to `ReuseIdentifiable`, the
     view is registered using its `reuseIdentifiable` property. Otherwise, it is registered using a string matching the
     view's class name.
     
     - parameter headerFooterType: The header/footer view type to register to the table view.
    */
    public func register<T: UITableViewHeaderFooterView>(_ headerFooterType: T.Type) {
        let reuseIdentifier = (headerFooterType as? ReuseIdentifiable.Type)?.reuseIdentifier
            ?? headerFooterType.classNameReuseIdentifier
        self.register(T.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
    
    /**
     Dequeues an instance of the given cell type for the table view. The cell is dequeued using the reuse identifier
     given from its `ReuseIdentifiable` conformance.
     
     - parameter cellType: The cell type to dequeue an instance of.
     
     - returns: A dequeued instance of the cell type.
    */
    public func dequeue<T: UITableViewCell>(_ cellType: T.Type) -> T {
        let reuseIdentifier = (cellType as? ReuseIdentifiable.Type)?.reuseIdentifier
            ?? cellType.classNameReuseIdentifier
        guard let cell = self.dequeueReusableCell(withIdentifier: reuseIdentifier) as? T else {
            fatalError("'\(String(describing: cellType))' was not registered to the table view with the reuse identifier '\(reuseIdentifier)'.")
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
        let reuseIdentifier = (headerFooterType as? ReuseIdentifiable.Type)?.reuseIdentifier
            ?? headerFooterType.classNameReuseIdentifier
        guard let cell = self.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? T else {
            fatalError("'\(String(describing: headerFooterType))' was not registered to the table view with the reuse identifier '\(reuseIdentifier)'.")
        }
        return cell
    }
}
