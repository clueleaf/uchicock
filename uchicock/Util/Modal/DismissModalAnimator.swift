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
    var topMargin: CGFloat = 15.0
    var bottomMargin: CGFloat = 10.0
    var leftMargin: CGFloat = 5.0
    var rightMargin: CGFloat = 5.0

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
        let modalSize = CGSize(width: window.bounds.width - leftMargin - rightMargin - leftPadding - rightPadding,
                               height: window.bounds.height - topMargin - bottomMargin - topPadding - bottomPadding)
        let bottomLeftCorner = CGPoint(x: leftMargin + leftPadding, y: window.bounds.height)
        
        let finalFrame = CGRect(origin: bottomLeftCorner, size: modalSize)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = finalFrame
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
