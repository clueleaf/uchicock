//
//  ModalPresentationController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/17.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class ModalPresentationController: UIPresentationController {
    var canDismissWithOverlayViewTouch = false
    var topMargin : CGFloat = 15.0
    var bottomMargin : CGFloat = 10.0
    var leftMargin : CGFloat = 5.0
    var rightMargin : CGFloat = 5.0
    var overlayAlpha: CGFloat = 0.4
    
    var overlayView = UIView()
    private var topPadding: CGFloat = 0
    private var bottomPadding: CGFloat = 0
    private var leftPadding: CGFloat = 0
    private var rightPadding: CGFloat = 0
    
    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        overlayView.frame = containerView.bounds
        if canDismissWithOverlayViewTouch{
            overlayView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(ModalPresentationController.overlayViewDidTouch(_:)))]
        }
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)
        
        // トランジションを実行
        presentedViewController.modalPresentationCapturesStatusBarAppearance = true
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = self!.overlayAlpha
            }, completion:nil)
    }
    
    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = 0.0
            }, completion:nil)
    }
    
    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }
    
    // 子のコンテナサイズを返す
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let window = UIApplication.shared.keyWindow
        topPadding = window!.safeAreaInsets.top
        bottomPadding = window!.safeAreaInsets.bottom
        leftPadding = window!.safeAreaInsets.left
        rightPadding = window!.safeAreaInsets.right
        return CGSize(width: parentSize.width - leftMargin - rightMargin - leftPadding - rightPadding,
                      height: parentSize.height - topMargin - bottomMargin - topPadding - bottomPadding)
    }
    
    // 呼び出し先のView Controllerのframeを返す
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect()
        let containerBounds = containerView!.bounds
        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.size = childContentSize
        presentedViewFrame.origin.x = leftMargin + leftPadding
        presentedViewFrame.origin.y = topMargin + topPadding
        
        return presentedViewFrame
    }
    
    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        overlayView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 10
        presentedView?.clipsToBounds = true
    }
    
    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
    }
    
    // overlayViewをタップした時に呼ばれる
    @objc func overlayViewDidTouch(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
