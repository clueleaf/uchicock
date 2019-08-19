//
//  ImageViewerDismissalInteractor.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class ImageViewerDismissalInteractor: NSObject, UIViewControllerInteractiveTransitioning {
    let transition: ImageViewerDismissalTransition
    
    init(transition: ImageViewerDismissalTransition) {
        self.transition = transition
        super.init()
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        transition.start(transitionContext)
    }
    
    func update(transform: CGAffineTransform) {
        transition.update(transform: transform)
    }
    
    func update(percentage: CGFloat) {
        transition.update(percentage: percentage)
    }
    
    func cancel() {
        transition.cancel()
    }
    
    func finish() {
        transition.finish()
    }
}
