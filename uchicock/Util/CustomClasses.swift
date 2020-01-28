//
//  CustomClasses.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/02.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class CopyableLabel: CustomLabel {
    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if menu.isMenuVisible {
            menu.setMenuVisible(false, animated: true)
        }else{
            let rect: CGRect = textRect(forBounds: self.bounds, limitedToNumberOfLines: self.numberOfLines)
            menu.setTargetRect(rect, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
}

class CustomAlertController: UIAlertController {
    var alertStatusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return alertStatusBarStyle
    }
}

class CustomActivityController: UIActivityViewController{
    var activityStatusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return activityStatusBarStyle
    }
}

class BasicNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
}

class CustomTextView: UITextView{
}

class CustomTextField: UITextField{
    func adjustClearButtonColor(with edgeInset: CGFloat) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(named: "clear"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        clearButton.imageEdgeInsets = UIEdgeInsets(top: edgeInset, left: 0, bottom: edgeInset, right: edgeInset * 2)
        clearButton.contentMode = .scaleAspectFit
        clearButton.tintColor = Style.labelTextColorLight
        clearButton.addTarget(self, action: #selector(CustomTextField.clear(sender:) ), for: .touchUpInside)
        if self.text == nil || self.text == ""{
            self.rightViewMode = .never
        }else{
            self.rightViewMode = .always
        }
        self.rightView = clearButton
    }

    @objc func clear(sender : AnyObject) {
        self.text = ""
        NotificationCenter.default.post(name: .textFieldClearButtonTappedNotification, object: self)        
    }
}

class CustomSearchBar: UISearchBar{
}

class CustomNavigationBar: UINavigationBar{
}

class CustomSlider: UISlider{
}

class CustomTabBar: UITabBar{
}

class CustomSegmentedControl: UISegmentedControl{
}

class CustomLabel: UILabel{
}

class CustomCAGradientLayer: CAGradientLayer{
}
