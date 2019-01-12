import UIKit

public protocol ViewEventEmitting: AnyViewEventEmitting {
    associatedtype ViewEvent
}

public extension ViewEventEmitting {
    func emit(event: ViewEvent) {
        self.eventEmitHandler?(self, event)
    }
}

public protocol AnyViewEventEmitting: AnyObject { }

private var handlerAssociatedHandle: UInt8 = 0
extension AnyViewEventEmitting {
    var eventEmitHandler: ((_ sender: AnyObject, _ event: Any) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &handlerAssociatedHandle) as? (AnyObject, Any) -> Void
        }
        set {
            objc_setAssociatedObject(self, &handlerAssociatedHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
