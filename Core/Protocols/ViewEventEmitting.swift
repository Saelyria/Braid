import UIKit

/**
 A protocol describing a view type that can emit custom 'view events'.
 
 Table or collection view cells that conform to this protocol are able to declare an associated `ViewEvent` enum type
 that describes events the cell can emit to its view controller. These events could be things like text entry in a text
 field, the toggling of a switch, or the tapping of a button inside the cell.
 
 When a cell would like to emit one of its events, it calls its `emit(event:)` method. The emitted event will be relayed
 to the `onEvent(from:_:)` method if it has been added to a binding chain in the view controller.
 */
public protocol ViewEventEmitting: AnyViewEventEmitting {
    /// A type whose instances are events that the view can emit.
    associatedtype ViewEvent
}

public extension ViewEventEmitting {
    /**
     Emits the given event up to the cell's binder.
     
     This method will propagate the emitted event through the binder to any `onEvent(from:_:)` handlers in a binding
     chain in this cell's view controller. This method will do nothing if the cell is not visible.
     
     - parameter event: The event to emit to the cell's view controller.
    */
    func emit(event: ViewEvent) {
        self.eventEmitHandler?(self, event)
    }
}

public protocol AnyViewEventEmitting: AnyObject { }

private var handlerAssociatedHandle: UInt8 = 0
extension AnyViewEventEmitting {
    /// Cells uses the Objective-C runtime 'associated object' feature to have an emit callback given to them when they
    /// are dequeued.
    var eventEmitHandler: ((_ sender: AnyObject, _ event: Any) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &handlerAssociatedHandle) as? (AnyObject, Any) -> Void
        }
        set {
            objc_setAssociatedObject(self, &handlerAssociatedHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
