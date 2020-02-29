//
//  FullScreenPopGesture.swift
//  uchicock
//
//  Created by Kou Kinyo on 2/29/20.
//  Copyright © 2020 Kou Kinyo. All rights reserved.
//

import Foundation
import UIKit

class FullscreenPopGesture {
    class func configuration() {
        UINavigationController.navInitialize()
    }
}

// objc_getAssociatedObjectのkey
private struct AssociatedObjectKey {
    static var fullscreenPopGestureRecognizer
        = "popGesture.pointerKey.fullscreenPopGestureRecognizer"
    
    static var popGestureRecognizerDelegate
        = "popGesture.pointerKey.popGestureRecognizerDelegate"
}

class FullScreenPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = self.navigationController else {
            return false
        }
        
        guard navigationController.viewControllers.count > 1 else {
            return false
        }
        
        // Ignore pan gesture when the navigation controller is currently in transition.
        guard let trasition = navigationController.value(forKey: "_isTransitioning") as? Bool else {
            return false
        }

        guard trasition == false else {
            return false
        }
        
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        // Prevent calling the handler when the gesture begins in an opposite direction.
        let translation = panGesture.translation(in: gestureRecognizer.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        guard (translation.x * multiplier) > 0 else {
            return false
        }
        
        return true
    }
}

fileprivate extension DispatchQueue {
    
    private static var onceTracker = [String]()
    
     /*
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
}

extension UINavigationController {
    open class func navInitialize() {
        DispatchQueue.once(token: "com.UINavigationController.MethodSwizzling", block: {
            if let originalMethod = class_getInstanceMethod(self, #selector(pushViewController(_:animated:))),
                let swizzledMethod = class_getInstanceMethod(self, #selector(swizzledPushViewController(_:animated:))) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        })
    }
    
    // The gesture recognizer that actually handles interactive pop.
    private var popGestureRecognizerDelegate: FullScreenPopGestureRecognizerDelegate {
        guard let delegate = objc_getAssociatedObject(self, &AssociatedObjectKey.popGestureRecognizerDelegate) as? FullScreenPopGestureRecognizerDelegate else {
            let popDelegate = FullScreenPopGestureRecognizerDelegate()
            popDelegate.navigationController = self
            objc_setAssociatedObject(self, &AssociatedObjectKey.popGestureRecognizerDelegate, popDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return popDelegate
        }
        return delegate
    }
    
    private var fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        guard let pan = objc_getAssociatedObject(self, &AssociatedObjectKey.fullscreenPopGestureRecognizer) as? UIPanGestureRecognizer else {
            let panGesture = UIPanGestureRecognizer()
            panGesture.maximumNumberOfTouches = 1
            objc_setAssociatedObject(self, &AssociatedObjectKey.fullscreenPopGestureRecognizer, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return panGesture
        }
        return pan
    }
    
    // MARK: Swizzeld
    @objc private func swizzledPushViewController(_ viewController: UIViewController, animated: Bool) {
        if interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(fullscreenPopGestureRecognizer) == false {
            interactivePopGestureRecognizer?.view?.addGestureRecognizer(fullscreenPopGestureRecognizer)
            
            // Forward the gesture events to the private handler of the onboard gesture recognizer.
            let internalTargets = interactivePopGestureRecognizer?.value(forKey: "targets") as? [NSObject]
            let internalTarget = internalTargets?.first?.value(forKey: "target")
            let internalAction = NSSelectorFromString("handleNavigationTransition:")
            if let target = internalTarget {
                fullscreenPopGestureRecognizer.delegate = popGestureRecognizerDelegate
                fullscreenPopGestureRecognizer.addTarget(target, action: internalAction)
                
                // Disable the onboard gesture recognizer.
                interactivePopGestureRecognizer?.isEnabled = false
            }
        }
        
        // Forward to primary implementation.
        self.swizzledPushViewController(viewController, animated: animated)
    }
}
