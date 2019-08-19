//
//  ImageViewerTransitioningHandler.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class ImageViewerTransitioningHandler: NSObject, UIViewControllerTransitioningDelegate {
    let presentationTransition: ImageViewerPresentationTransition
    let dismissalTransition: ImageViewerDismissalTransition
    let dismissalInteractor: ImageViewerDismissalInteractor
    
    var dismissInteractively = false
    
    init(fromImageView: UIImageView, toImageView: UIImageView) {
        self.presentationTransition = ImageViewerPresentationTransition(fromImageView: fromImageView)
        self.dismissalTransition = ImageViewerDismissalTransition(fromImageView: toImageView, toImageView: fromImageView)
        self.dismissalInteractor = ImageViewerDismissalInteractor(transition: dismissalTransition)
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissalTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractively ? dismissalInteractor : nil
    }
}
