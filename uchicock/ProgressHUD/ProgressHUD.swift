//
//  ProgressHUD.swift
//  HUDPractice
//
//  Created by kou on 2019/06/14.
//  Copyright © 2019 kaigi. All rights reserved.
//

import UIKit

public enum ProgressHUDStyle : Int {
    case light
    case dark
}

public class ProgressHUD : UIView {
    
    private let ProgressHUDVerticalSpacing: CGFloat = 12.0
    private let ProgressHUDHorizontalSpacing: CGFloat = 12.0
    private let ProgressHUDLabelSpacing: CGFloat = 8.0
    
    private var defaultStyle = ProgressHUDStyle.light
    private var minimumSize = CGSize.init(width: 150, height: 100)
    private var imageViewSize: CGSize = CGSize.init(width: 28, height: 28)
    private var successImage: UIImage! = UIImage.init(named: "success")!
    private var minimumDismissTimeInterval: TimeInterval = 2.0
    private var maximumDismissTimeInterval: TimeInterval = TimeInterval(CGFloat.infinity)
    private var fadeOutTimer: Timer?
    private var controlView: UIControl?
    private var backgroundView: UIView?
    private var hudView: UIVisualEffectView?
    private var statusLabel: UILabel?
    private var imageView: UIImageView?
    private var indefiniteAnimatedView: IndefiniteAnimatedView?
    private var activityCount: Int = 0

    private override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        activityCount = 0
        getBackGroundView().alpha = 0.0
        getImageView().alpha = 0.0
        getStatusLabel().alpha = 1.0
        getIndefiniteAnimatedView().alpha = 0.0
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getIndefiniteAnimatedView() -> IndefiniteAnimatedView {
        if (indefiniteAnimatedView == nil) {
            indefiniteAnimatedView = IndefiniteAnimatedView.init(frame: .zero)
        }
        indefiniteAnimatedView?.setIndefinite(radius: 18.0, strokeThickness: 2.0, strokeColor: foreGroundColorForStyle())
        indefiniteAnimatedView?.sizeToFit()
        return indefiniteAnimatedView!
    }
    
    private static let sharedView : ProgressHUD = {
        var localInstance : ProgressHUD?
        if Thread.current.isMainThread {
            if let window = UIApplication.shared.delegate?.window {
                localInstance = ProgressHUD.init(frame: window?.bounds ?? CGRect.zero)
            } else {
                localInstance = ProgressHUD()
            }
        } else {
            DispatchQueue.main.sync {
                if let window = UIApplication.shared.delegate?.window {
                    localInstance = ProgressHUD.init(frame: window?.bounds ?? CGRect.zero)
                } else {
                    localInstance = ProgressHUD()
                }
            }
        }
        return localInstance!
    }()
    
    // MARK :- Setters
    
    private func showProgress(status: String?) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.fadeOutTimer != nil {
                strongSelf.activityCount = 0
            }
            
            // Stop timer
            strongSelf.setFadeOut(timer: nil)
            
            // Update / Check view hierarchy to ensure the HUD is visible
            strongSelf.updateViewHierarchy()
            
            // Reset imageView and fadeout timer if an image is currently displayed
            strongSelf.getImageView().isHidden = true
            strongSelf.getImageView().image = nil
            
            // Update text and set progress to the given value
            strongSelf.getStatusLabel().isHidden = (status?.count ?? 0) == 0
            strongSelf.getStatusLabel().text = status
            
            // Add indefiniteAnimatedView to HUD
            strongSelf.getHudView().contentView.addSubview(strongSelf.getIndefiniteAnimatedView())
            
            // Update the activity count
            strongSelf.activityCount += 1

            // Fade in delayed if a grace time is set
            strongSelf.fadeIn(with: nil)
        })
    }
    
    private func fadeIn(with duration: TimeInterval?) {
        updateHUDFrame()
        positionHUD()
        getControlView().isUserInteractionEnabled = false

        if getBackGroundView().alpha != 1.0 {
//            getHudView().transform = CGAffineTransform.init(scaleX: 1/1.5, y: 1/1.5)
            let animationsBlock : () -> Void = {
                // Zoom HUD a little to make a nice appear / pop up animation
                self.getHudView().transform = CGAffineTransform.identity
                
                // Fade in all effects (colors, blur, etc.)
                let blurStyle = self.defaultStyle == .dark ? UIBlurEffect.Style.dark : UIBlurEffect.Style.light
                let blurEffect = UIBlurEffect.init(style: blurStyle)
                self.getHudView().effect = blurEffect
                self.getHudView().backgroundColor = self.backgroundColorForStyle()
                self.getBackGroundView().alpha = 1.0
                self.getImageView().alpha = 1.0
                self.getStatusLabel().alpha = 1.0
                self.getIndefiniteAnimatedView().alpha = 1.0
            }
            
            let completionBlock : () -> Void = {
                if self.getBackGroundView().alpha == 1.0 {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.positionHUD(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
                }
                
                if let cd = duration {
                    let timer = Timer.init(timeInterval: cd, target: self, selector: #selector(self.dismiss), userInfo: nil, repeats: false)
                    self.setFadeOut(timer: timer)
                    RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
                }
            }
            
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseIn, .beginFromCurrentState], animations: animationsBlock, completion: {
                finished in
                completionBlock()
            })
            self.setNeedsDisplay()
        } else {
            if let convertedDuration = duration {
                let timer = Timer.init(timeInterval: convertedDuration, target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
                setFadeOut(timer: timer)
                RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
            }
        }
    }
    
    private func setFadeOut(timer: Timer?) {
        if (fadeOutTimer != nil) {
            fadeOutTimer?.invalidate()
            fadeOutTimer = nil
        }
        if timer != nil {
            fadeOutTimer = timer
        }
    }
    
    @objc private func positionHUD(_ notification: Notification? = nil) {
        var keyboardHeight: CGFloat = 0.0
        var animationDuration: Double = 0.0
        
        var statusBarFrame = CGRect.zero
        
        if let appDelegate = UIApplication.shared.delegate,
            let window : UIWindow = appDelegate.window! {
            frame = window.bounds
        }
        var orientation = UIApplication.shared.statusBarOrientation
        
        if frame.width > frame.height {
            orientation = .landscapeLeft
        } else {
            orientation = .portrait
        }
        if let notificationData = notification {
            let keyboardInfo = notificationData.userInfo
            if let keyboardFrame: NSValue = keyboardInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame: CGRect = keyboardFrame.cgRectValue
                if (notification?.name.rawValue == UIResponder.keyboardWillShowNotification.rawValue || notification?.name.rawValue == UIResponder.keyboardDidShowNotification.rawValue) {
                    keyboardHeight = keyboardFrame.width
                    if orientation.isPortrait {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            if let aDuration: Double = keyboardInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                animationDuration = aDuration
            }
        } else {
            keyboardHeight = getVisibleKeyboardHeight()
        }
        statusBarFrame = UIApplication.shared.statusBarFrame

        let orientationFrame = bounds
        
        var activeHeight = orientationFrame.height
        
        if keyboardHeight > 0 {
            activeHeight += statusBarFrame.height * 2
        }
        activeHeight -= keyboardHeight
        
        let posX = orientationFrame.midX
        let posY = CGFloat(floor(activeHeight * 0.45))
        
        let rotateAngle : CGFloat = 0.0
        let newCenter = CGPoint.init(x: posX, y: posY)
        
        if notification != nil {
            // Animate update if notification was present
            UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.move(to: newCenter, rotateAngle: rotateAngle)
                self.getHudView().setNeedsDisplay()
            })
        } else {
            move(to: newCenter, rotateAngle: rotateAngle)
        }
    }
    
    private func updateViewHierarchy() {
        // Add the overlay to the application window if necessary
        if getControlView().superview == nil {
            getFrontWindow()?.addSubview(getControlView())
        } else {
            // The HUD is already on screen, but maybe not in front. Therefore
            // ensure that overlay will be on top of rootViewController (which may
            // be changed during runtime).
            getControlView().superview?.bringSubviewToFront(getControlView())
        }
        
        // Add self to the overlay view
        if superview == nil {
            getControlView().addSubview(self)
        }
    }
    
    private func show(image: UIImage, status: String?, duration: TimeInterval) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.setFadeOut(timer: nil)
            strongSelf.updateViewHierarchy()
            
            strongSelf.indefiniteAnimatedView?.stopActivityIndicator()
            strongSelf.indefiniteAnimatedView?.removeFromSuperview()

            if image.renderingMode != UIImage.RenderingMode.alwaysTemplate {
                strongSelf.getImageView().image = image.withRenderingMode(.alwaysTemplate)
                strongSelf.getImageView().tintColor = strongSelf.foreGroundColorForStyle()
            } else {
                strongSelf.getImageView().image = image
            }
            strongSelf.getImageView().isHidden = false
            
            strongSelf.getStatusLabel().isHidden = status == nil || status?.count == 0
            if let stts = status {
                strongSelf.getStatusLabel().text = stts
            }
            strongSelf.fadeIn(with: duration)
        })
    }
    // shows a image + status, use white PNGs with the imageViewSize (default is 28x28 pt)
    
    private func dismissWithCompletion(completion: (() -> Void)?) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
            // Reset activity count
            strongSelf.activityCount = 0
            
            let animationsBlock: () -> Void = {
                // Shrink HUD a little to make a nice disappear animation
//                strongSelf.getHudView().transform = strongSelf.getHudView().transform.scaledBy(x: 1/1.3, y: 1/1.3)
                
                // Fade out all effects (colors, blur, etc.)
                strongSelf.getHudView().effect = nil
                strongSelf.getHudView().backgroundColor = .clear
                strongSelf.getBackGroundView().alpha = 0.0
                strongSelf.getImageView().alpha = 0.0
                strongSelf.getStatusLabel().alpha = 0.0
                strongSelf.getIndefiniteAnimatedView().alpha = 0.0
            }
            
            let completionBlock: (() -> Void) = {
                // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between e.g. due to a new show
                if strongSelf.getBackGroundView().alpha == 0.0 {
                    // Clean up view hierarchy (overlays)
                    strongSelf.getControlView().removeFromSuperview()
                    strongSelf.getBackGroundView().removeFromSuperview()
                    strongSelf.getHudView().removeFromSuperview()
                    strongSelf.removeFromSuperview()
                    
                    // Reset progress and cancel any running animation
                    strongSelf.indefiniteAnimatedView?.stopActivityIndicator()
                    strongSelf.indefiniteAnimatedView?.removeFromSuperview()

                    // Remove observer <=> we do not have to handle orientation changes etc.
                    NotificationCenter.default.removeObserver(strongSelf)
                    
                    // Tell the rootViewController to update the StatusBar appearance
                    let rootController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
                    rootController?.setNeedsStatusBarAppearanceUpdate()
                    if completion != nil {
                        completion!()
                    }
                }
            }
            
            // UIViewAnimationOptionBeginFromCurrentState AND a delay doesn't always work as expected
            // When UIViewAnimationOptionBeginFromCurrentState is set, animateWithDuration: evaluates the current
            // values to check if an animation is necessary. The evaluation happens at function call time and not
            // after the delay => the animation is sometimes skipped. Therefore we delay using dispatch_after.
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
                    animationsBlock()
                }) { finished in
                    completionBlock()
                }
            })
            
            // Inform iOS to redraw the view hierarchy
            strongSelf.setNeedsDisplay()
            }
        )
    }
    
    @objc private func dismiss() {
        dismissWithCompletion(completion: nil)
    }
    
    private func updateHUDFrame() {
        // Check if an image or progress ring is displayed
        let imageUsed: Bool = (getImageView().image) != nil && !((getImageView().isHidden) )
        let progressUsed: Bool = getImageView().isHidden
        
        // Calculate size of string
        var labelRect : CGRect = CGRect.zero
        var labelHeight: CGFloat = 0.0
        var labelWidth: CGFloat = 0.0
        
        if getStatusLabel().text != nil {
            let constraintSize = CGSize(width: 200.0, height: 300.0)
            labelRect = getStatusLabel().text?.boundingRect(with: constraintSize, options: [.usesFontLeading, .truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: getStatusLabel().font as Any], context: nil) ?? CGRect.zero
            labelHeight = CGFloat(ceilf(Float(labelRect.height )))
            labelWidth = CGFloat(ceilf(Float(labelRect.width )))
        }
        
        // Calculate hud size based on content
        // For the beginning use default values, these
        // might get update if string is too large etc.
        var hudWidth: CGFloat
        var hudHeight: CGFloat
        
        var contentWidth: CGFloat = 0.0
        var contentHeight: CGFloat = 0.0
        
        if (imageUsed || progressUsed) {
            if imageUsed {
                contentWidth = getImageView().frame.width
                contentHeight = getImageView().frame.height
            } else {
                contentWidth = getIndefiniteAnimatedView().frame.width
                contentHeight = getIndefiniteAnimatedView().frame.height
            }
        }
        // |-spacing-content-spacing-|
        hudWidth = CGFloat(ProgressHUDHorizontalSpacing + max(labelWidth, contentWidth) + ProgressHUDHorizontalSpacing)
        
        // |-spacing-content-(labelSpacing-label-)spacing-|
        hudHeight = CGFloat(ProgressHUDVerticalSpacing) + labelHeight + contentHeight + CGFloat(ProgressHUDVerticalSpacing)
        if ((getStatusLabel().text != nil) && (imageUsed || progressUsed )) {
            // Add spacing if both content and label are used
            hudHeight += CGFloat(ProgressHUDLabelSpacing)//8 [80]
        }
        
        // Update values on subviews
        getHudView().bounds = CGRect(x: 0.0, y: 0.0, width: max(minimumSize.width, hudWidth), height: max(minimumSize.height, hudHeight))
        
        // Animate value update
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Spinner and image view
        var centerY: CGFloat
        if getStatusLabel().text != nil {
            let yOffset = max(ProgressHUDVerticalSpacing, (minimumSize.height - contentHeight - CGFloat(ProgressHUDLabelSpacing) - labelHeight) / 2.0)//12
            centerY = yOffset + contentHeight / 2.0 //26
        } else {
            centerY = getHudView().bounds.midY
        }
        getIndefiniteAnimatedView().center = CGPoint(x: getHudView().bounds.midX, y: centerY)
        getImageView().center = CGPoint(x: getHudView().bounds.midX , y: centerY)
        // Label
        if imageUsed || progressUsed {
            if imageUsed {
                centerY = getImageView().frame.maxY + ProgressHUDLabelSpacing + labelHeight / 2.0
            } else {
                centerY = getIndefiniteAnimatedView().frame.maxY + ProgressHUDLabelSpacing + labelHeight / 2.0
            }
        } else {
            centerY = getHudView().bounds.midY
        }
        getStatusLabel().frame = labelRect
        getStatusLabel().center = CGPoint(x: getHudView().bounds.midX , y: centerY)
        CATransaction.commit()
    }
    
    private func backgroundColorForStyle() -> UIColor {
        switch defaultStyle{
        case .light:
            return UIColor.white.withAlphaComponent(0.6)
        case .dark:
            return UIColor.black.withAlphaComponent(0.6)
        }
    }
    
    private func getVisibleKeyboardHeight() -> CGFloat {
        var keyboardWindow : UIWindow? = nil
        for testWindow in UIApplication.shared.windows {
            if !testWindow.self.isEqual(UIWindow.self) {
                keyboardWindow = testWindow
                break
            }
        }
        for possibleKeyboard in keyboardWindow?.subviews ?? [] {
            var viewName = String.init(describing: possibleKeyboard.self)
            if viewName.hasPrefix("UI") {
                if viewName.hasSuffix("PeripheralHostView") || viewName.hasSuffix("Keyboard") {
                    return possibleKeyboard.bounds.height
                } else if viewName.hasSuffix("InputSetContainerView") {
                    for possibleKeyboardSubview: UIView? in possibleKeyboard.subviews {
                        viewName = String.init(describing: possibleKeyboardSubview.self)
                        if viewName.hasPrefix("UI") && viewName.hasSuffix("InputSetHostView") {
                            let convertedRect = possibleKeyboard.convert(possibleKeyboardSubview?.frame ?? CGRect.zero, to: self)
                            let intersectedRect: CGRect = convertedRect.intersection(bounds)
                            if !intersectedRect.isNull {
                                return intersectedRect.height
                            }
                        }
                    }
                }
            }
        }
        return 0
    }
    
    private func move(to newCenter: CGPoint, rotateAngle angle: CGFloat) {
        getHudView().transform = CGAffineTransform(rotationAngle: angle)
        getHudView().center = CGPoint(x: newCenter.x, y: newCenter.y)
    }
}

// MARK: - Public Method
extension ProgressHUD {
    public class func set(defaultStyle style: ProgressHUDStyle) {
        sharedView.defaultStyle = style
    }
    
    public class func show(with status: String?) {
        sharedView.showProgress(status: status)
    }
    
    public class func showSuccess(with status: String?, duration: TimeInterval) {
        sharedView.show(image: sharedView.successImage, status: status, duration: duration)
    }

    public class func dismissWithCompletion(_ completion: (() -> Void)?) {
        sharedView.dismissWithCompletion(completion: completion)
    }
}

//MARK: - Getter Methods
extension ProgressHUD {
    private func foreGroundColorForStyle() -> UIColor {
        switch defaultStyle{
        case .light:
            return .black
        case .dark:
            return .white
        }
    }
    
    private func getHudView() -> UIVisualEffectView {
        if hudView == nil {
            let tmphudView = UIVisualEffectView()
            tmphudView.layer.masksToBounds = true
            tmphudView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin]
            hudView = tmphudView
        }
        
        if hudView?.superview == nil {
            self.addSubview(hudView!)
        }
        
        hudView?.layer.cornerRadius = 14.0
        return hudView!
    }
    
    private func getBackGroundView() -> UIView {
        if backgroundView == nil {
            backgroundView = UIView()
            backgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        if backgroundView?.superview == nil {
            insertSubview(self.backgroundView!, belowSubview: getHudView())
        }
        backgroundView?.backgroundColor = UIColor.clear

        // Update frame
        if backgroundView != nil {
            backgroundView?.frame = bounds
        }
        return backgroundView!
    }
    
    private func getControlView() -> UIControl {
        if controlView == nil {
            controlView = UIControl.init()
            controlView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            controlView?.backgroundColor = .clear
            controlView?.isUserInteractionEnabled = true
        }
        if let windowBounds : CGRect = UIApplication.shared.delegate?.window??.bounds {
            controlView?.frame = windowBounds
        }
        return controlView!
    }
    
    private func getFrontWindow() -> UIWindow? {
        let frontToBackWindows: NSEnumerator = (UIApplication.shared.windows as NSArray).reverseObjectEnumerator()
        for window in frontToBackWindows {
            guard let win : UIWindow = window as? UIWindow else {return nil}
            let windowOnMainScreen: Bool = win.screen == UIScreen.main
            let windowIsVisible: Bool = !win.isHidden && (win.alpha > 0)
            var windowLevelSupported = false
            windowLevelSupported = win.windowLevel == UIWindow.Level.normal
            
            let windowKeyWindow = win.isKeyWindow
            
            if windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow {
                return win
            }
        }
        return nil
    }
    
    private func getImageView() -> UIImageView {
        if imageView != nil && imageView?.bounds.size != imageViewSize {
            imageView?.removeFromSuperview()
            imageView = nil
        }
        
        if imageView == nil {
            imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height))
        }
        if imageView?.superview == nil {
            getHudView().contentView.addSubview(imageView!)
        }
        
        return imageView!
    }
    
    private func getStatusLabel() -> UILabel {
        if statusLabel == nil {
            statusLabel = UILabel.init(frame: .zero)
            statusLabel?.backgroundColor = .clear
            statusLabel?.adjustsFontSizeToFitWidth = true
            statusLabel?.textAlignment = .center
            statusLabel?.baselineAdjustment = .alignCenters
            statusLabel?.numberOfLines = 0
        }
        if statusLabel?.superview == nil && statusLabel != nil {
            getHudView().contentView.addSubview(statusLabel!)
        }
        statusLabel?.textColor = foreGroundColorForStyle()
        statusLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        statusLabel?.alpha = 1.0
        statusLabel?.isHidden = false
        return statusLabel!
    }
}
