//
//  PhotoFilterDismissalTransitioningHandler.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/08/22.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class PhotoFilterDismissalTransitioningHandler: NSObject, UIViewControllerTransitioningDelegate {
    let dismissalTransition: ImageViewerDismissalTransition
    
    init(fromImageView: UIImageView, toImageView: UIImageView) {
        self.dismissalTransition = ImageViewerDismissalTransition(fromImageView: fromImageView, toImageView: toImageView)
        super.init()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissalTransition
    }
}
