//
//  MessageHUD.swift
//  LayoutPractice
//
//  Created by kou on 2019/10/21.
//  Copyright © 2019 kaigi. All rights reserved.
//

import UIKit

public enum MessageHUDStyle : Int {
    case light
    case dark
}

public class MessageHUD : UIView {
    
    private let MessageHUDVerticalSpacing: CGFloat = 12.0
    private let MessageHUDHorizontalSpacing: CGFloat = 12.0
    private let MessageHUDTopSpacing: CGFloat = 5.0
    private let MessageHUDImageSpacing: CGFloat = 4.0
    private var imageViewSize = CGSize(width: 22, height: 22)
    private var imageUsed: Bool = false

    private var defaultStyle = MessageHUDStyle.light
    private var fadeOutTimer: Timer?
    private var controlView: UIControl?
    private var backgroundView: UIView?
    private var hudView: UIVisualEffectView?
    private var statusLabel: UILabel?
    private var imageView: UIImageView?

    private override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        getImageView().alpha = 0.0
        getBackGroundView().alpha = 0.0
        getStatusLabel().alpha = 1.0
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private static let sharedView : MessageHUD = {
        var localInstance : MessageHUD?
        if Thread.current.isMainThread {
            if let window = UIApplication.shared.keyWindow {
                localInstance = MessageHUD.init(frame: window.bounds)
            }else{
                localInstance = MessageHUD()
            }
        }else{
            DispatchQueue.main.sync {
                if let window = UIApplication.shared.keyWindow {
                    localInstance = MessageHUD.init(frame: window.bounds)
                }else{
                    localInstance = MessageHUD()
                }
            }
        }
        return localInstance!
    }()
    
    // MARK :- Setters
    private func fadeIn(with duration: TimeInterval?, isCenter: Bool) {
        updateHUDFrame()
        positionHUD(isCenter: isCenter)
        getControlView().isUserInteractionEnabled = false

        if getBackGroundView().alpha != 1.0 {
            let animationsBlock : () -> Void = {
                self.getHudView().transform = CGAffineTransform.identity
                let blurStyle = self.defaultStyle == .dark ? UIBlurEffect.Style.dark : UIBlurEffect.Style.light
                let blurEffect = UIBlurEffect.init(style: blurStyle)
                self.getHudView().effect = blurEffect
                self.getHudView().backgroundColor = self.backgroundColorForStyle()
                self.getBackGroundView().alpha = 1.0
                self.getImageView().alpha = 1.0
                self.getStatusLabel().alpha = 1.0
            }
            
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseIn, .beginFromCurrentState], animations: animationsBlock, completion: { _ in
                if let convertedDuration = duration {
                    let timer = Timer.init(timeInterval: convertedDuration, target: self, selector: #selector(self.dismiss), userInfo: nil, repeats: false)
                    self.setFadeOut(timer: timer)
                    RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
                }
            })
            self.setNeedsDisplay()
        }else{
            if let convertedDuration = duration {
                let timer = Timer.init(timeInterval: convertedDuration, target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
                self.setFadeOut(timer: timer)
                RunLoop.main.add(self.fadeOutTimer!, forMode: .common)
            }
        }
    }
    
    private func updateHUDFrame() {
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
        var hudWidth = CGFloat(MessageHUDHorizontalSpacing + labelWidth + MessageHUDHorizontalSpacing)
        if imageUsed{
            hudWidth = CGFloat(MessageHUDHorizontalSpacing + imageViewSize.width + MessageHUDImageSpacing + labelWidth + MessageHUDHorizontalSpacing)
        }
        let hudHeight = CGFloat(MessageHUDVerticalSpacing + labelHeight + MessageHUDVerticalSpacing)
        
        // Update values on subviews
        getHudView().bounds = CGRect(x: 0.0, y: 0.0, width: hudWidth, height: hudHeight)
        if imageUsed{
            getImageView().center = CGPoint(x: MessageHUDHorizontalSpacing + imageViewSize.width / 2, y: getHudView().bounds.midY)
            getStatusLabel().frame = labelRect
            getStatusLabel().center = CGPoint(x: (imageViewSize.width + MessageHUDImageSpacing) / 2 + getHudView().bounds.midX , y: getHudView().bounds.midY)
        }else{
            getStatusLabel().frame = labelRect
            getStatusLabel().center = CGPoint(x: getHudView().bounds.midX , y: getHudView().bounds.midY)
        }
    }
    
    private func positionHUD(isCenter: Bool) {
        if let window = UIApplication.shared.keyWindow {
            self.frame = window.bounds
        }

        let labelRect = getStatusLabel().text?.boundingRect(with: CGSize.zero, options: [.usesFontLeading, .truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: getStatusLabel().font as Any], context: nil) ?? CGRect.zero
        let labelHeight = CGFloat(ceilf(Float(labelRect.height)))
        let safeAreaTop = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.origin.y ?? 0
        let safeAreaLeft = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.origin.x ?? 0
        let posY = MessageHUDVerticalSpacing + labelHeight / 2.0 + safeAreaTop + MessageHUDTopSpacing
                
        var newCenter = CGPoint.init(x: self.bounds.midX, y: posY)
        if isCenter == false{
            newCenter = CGPoint.init(x: safeAreaLeft + 120.0, y: posY)
        }
        move(to: newCenter)
    }
    
    private func setFadeOut(timer: Timer?) {
        if fadeOutTimer != nil {
            fadeOutTimer?.invalidate()
            fadeOutTimer = nil
        }
        if timer != nil {
            fadeOutTimer = timer
        }
    }
    
    private func updateViewHierarchy() {
        // Add the overlay to the application window if necessary
        if getControlView().superview == nil {
            getFrontWindow()?.addSubview(getControlView())
        }else{
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
    
    private func show(status: String?, for duration: TimeInterval?, withCheckmark: Bool, isCenter: Bool) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
            
            // Stop timer
            strongSelf.setFadeOut(timer: nil)
            
            // Update / Check view hierarchy to ensure the HUD is visible
            strongSelf.updateViewHierarchy()
            
            if withCheckmark{
                strongSelf.imageUsed = true
                strongSelf.getImageView().image = UIImage(named: "accesory-checkmark")
                strongSelf.getImageView().tintColor = strongSelf.foreGroundColorForStyle()
                strongSelf.getImageView().isHidden = false
            }else{
                strongSelf.imageUsed = false
                strongSelf.getImageView().isHidden = true
            }

            // Update text and set progress to the given value
            strongSelf.getStatusLabel().isHidden = status == nil || status?.count == 0
            strongSelf.getStatusLabel().text = status
            
            // Fade in delayed if a grace time is set
            strongSelf.fadeIn(with: duration, isCenter: isCenter)
        })
    }
    
    private func dismissWithCompletion(completion: (() -> Void)?) {
        OperationQueue.main.addOperation({ [weak self] in
            guard let strongSelf = self else { return }
            
            // .beginFromCurrentState AND a delay doesn't always work as expected
            // When .beginFromCurrentState is set, withDuration: evaluates the current
            // values to check if an animation is necessary. The evaluation happens at function call time and not
            // after the delay => the animation is sometimes skipped. Therefore we delay using asyncAfter.
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
                    // Fade out all effects (colors, blur, etc.)
                    strongSelf.getHudView().effect = nil
                    strongSelf.getHudView().backgroundColor = .clear
                    strongSelf.getBackGroundView().alpha = 0.0
                    strongSelf.getImageView().alpha = 0.0
                    strongSelf.getStatusLabel().alpha = 0.0
                }) { finished in
                    // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                    // and the change of these values has not been cancelled in between e.g. due to a new show
                    if strongSelf.getBackGroundView().alpha == 0.0 {
                        // Clean up view hierarchy (overlays)
                        strongSelf.getControlView().removeFromSuperview()
                        strongSelf.getBackGroundView().removeFromSuperview()
                        strongSelf.getHudView().removeFromSuperview()
                        strongSelf.removeFromSuperview()
                        
                        // Tell the rootViewController to update the StatusBar appearance
                        let rootController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
                        rootController?.setNeedsStatusBarAppearanceUpdate()
                        completion?()
                    }
                }
            })
            
            // Inform iOS to redraw the view hierarchy
            strongSelf.setNeedsDisplay()
        })
    }
    
    @objc private func dismiss() {
        dismissWithCompletion(completion: nil)
    }
    
    private func move(to newCenter: CGPoint) {
        getHudView().center = CGPoint(x: newCenter.x, y: newCenter.y)
    }

    // MARK: - Public Method
    public class func set(defaultStyle style: MessageHUDStyle) {
        sharedView.defaultStyle = style
    }
    
    public class func show(_ status: String?, for duration: TimeInterval?, withCheckmark: Bool, isCenter: Bool) {
        sharedView.show(status: status, for: duration, withCheckmark: withCheckmark, isCenter: isCenter)
    }

    public class func dismissWithCompletion(_ completion: (() -> Void)?) {
        sharedView.dismissWithCompletion(completion: completion)
    }

    //MARK: - Getter Methods
    private func backgroundColorForStyle() -> UIColor {
        switch defaultStyle{
        case .light:
            return UIColor.white.withAlphaComponent(0.6)
        case .dark:
            return UIColor.black.withAlphaComponent(0.6)
        }
    }
    
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
        
        hudView?.layer.cornerRadius = hudView == nil ? 14.0 : hudView!.frame.size.height / 2
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
            backgroundView?.frame = self.bounds
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
        if let windowBounds : CGRect = UIApplication.shared.keyWindow?.bounds {
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
            let windowLevelSupported = win.windowLevel == UIWindow.Level.normal
            let windowKeyWindow = win.isKeyWindow
            
            if windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow {
                return win
            }
        }
        return nil
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
        statusLabel?.font = UIFont.systemFont(ofSize: 15.0)
        statusLabel?.alpha = 1.0
        statusLabel?.isHidden = false
        return statusLabel!
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

}
