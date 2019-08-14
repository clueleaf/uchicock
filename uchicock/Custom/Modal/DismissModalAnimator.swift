//
//  DismissModalAnimator.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/21.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class DismissModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var topPadding: CGFloat = 0
    private var bottomPadding: CGFloat = 0
    private var leftPadding: CGFloat = 0
    private var rightPadding: CGFloat = 0
    var xMargin: CGFloat = 20.0
    var yMargin: CGFloat = 40.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from)
            else { return }
        
        let window = UIApplication.shared.keyWindow!
        topPadding = window.safeAreaInsets.top
        bottomPadding = window.safeAreaInsets.bottom
        leftPadding = window.safeAreaInsets.left
        rightPadding = window.safeAreaInsets.right
        let modalSize = CGSize(width: window.bounds.width - xMargin - leftPadding - rightPadding,
                               height: window.bounds.height - yMargin - topPadding - bottomPadding)
        let bottomLeftCorner = CGPoint(x: xMargin / 2.0 + leftPadding, y: window.bounds.height)
        
        let finalFrame = CGRect(origin: bottomLeftCorner, size: modalSize)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = finalFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
