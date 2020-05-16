//
//  CustomClasses.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/02.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.interactivePopEnabled = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
}

class BasicTabBarController: UITabBarController, UITabBarControllerDelegate {

    var shouldScroll = false
    var lastSelectedIndex = 0
    
    override func viewDidLoad() {
        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.shouldScroll = false
        if let navigationController: UINavigationController = viewController as? UINavigationController {
            let visibleVC = navigationController.visibleViewController!
            if let index = navigationController.viewControllers.firstIndex(of: visibleVC), index == 0 {
                shouldScroll = true
            }
        }
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)  {
        let indexCache = lastSelectedIndex
        self.lastSelectedIndex = tabBarController.selectedIndex
        guard self.shouldScroll else { return }

        if indexCache == tabBarController.selectedIndex  {
            if let navigationController: UINavigationController = viewController as? UINavigationController {
                let visibleVC = navigationController.visibleViewController!
                if let scrollableVC = visibleVC as? ScrollableToTop {
                    scrollableVC.scrollToTop()
                }
            }
        }
    }
}

protocol ScrollableToTop {
    func scrollToTop()
}

class CustomTextView: UITextView{
}

class CustomTextField: UITextField{
    func adjustClearButtonColor(with edgeInset: CGFloat) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(named: "button-clear"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        clearButton.imageEdgeInsets = UIEdgeInsets(top: edgeInset, left: 0, bottom: edgeInset, right: edgeInset * 2)
        clearButton.contentMode = .scaleAspectFit
        clearButton.tintColor = UchicockStyle.labelTextColorLight
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
    
    var hasLeftIcon = false
    
    func setSearchIcon() {
        self.hasLeftIcon = true
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "tabbar-reverse-lookup")?.withAlignmentRectInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 0))
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.tintColor = UchicockStyle.labelTextColorLight
        self.leftViewMode = .always
        self.leftView = searchIcon
    }
    
    func setLeftPadding(){
        self.hasLeftIcon = false
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 2.0))
        self.leftView = leftView
        self.leftViewMode = .always
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x = 8
        rect.origin.y = 10
        rect.size.height = self.frame.height - (rect.origin.y * 2)
        rect.size.width = hasLeftIcon ? rect.size.height : 0
        return rect
    }
}

public class BadgeBarButtonItem: UIBarButtonItem {
    @IBInspectable
    public var badgeText: String? = nil {
        didSet {
            self.updateBadge()
        }
    }
    
    private let label: UILabel
    
    required public init?(coder aDecoder: NSCoder){
        let label = UILabel()
        label.backgroundColor = UchicockStyle.badgeBackgroundColor
        label.alpha = 1.0
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.layer.zPosition = 1
        label.font = UIFont.systemFont(ofSize: 12.0)
        self.label = label
        
        super.init(coder: aDecoder)
        
        self.addObserver(self, forKeyPath: "view", options: [], context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        self.updateBadge()
    }
    
    private func updateBadge(){
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        self.label.text = badgeText
        self.label.backgroundColor = UchicockStyle.badgeBackgroundColor
        
        if self.badgeText != nil && self.label.superview == nil{
            view.addSubview(self.label)
            
            self.label.widthAnchor.constraint(equalToConstant: 18).isActive = true
            self.label.heightAnchor.constraint(equalToConstant: 18).isActive = true
            self.label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 12).isActive = true
            self.label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -9).isActive = true
        }else if self.badgeText == nil && self.label.superview != nil{
            self.label.removeFromSuperview()
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "view")
    }
}

class CustomNavigationBar: UINavigationBar{
}

class CustomSlider: UISlider{
}

class CustomTabBar: UITabBar{
}

class CustomSegmentedControl: UISegmentedControl{
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 13.0, *) {
            layer.cornerRadius = self.bounds.size.height / 2.0
            layer.borderColor = UchicockStyle.primaryColor.cgColor
            layer.borderWidth = 1.0
            layer.masksToBounds = true
            clipsToBounds = true

            for i in 0...subviews.count - 1{
                if let subview = subviews[i] as? UIImageView{
                    if i == self.selectedSegmentIndex {
                        subview.backgroundColor = UchicockStyle.primaryColor
                    }else{
                        subview.backgroundColor = .clear
                    }
                }
            }
        }
    }
}

class CustomLabel: UILabel{
}

class CustomCAGradientLayer: CAGradientLayer{
}

class ExpandedButton: UIButton {
    var minimumHitWidth : CGFloat = 44.0
    var minimumHitHeight : CGFloat = 44.0

    override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        if self.isHidden || self.isUserInteractionEnabled == false || self.alpha < 0.01 { return  false }

        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitWidth - buttonSize.width, 0)
        let heightToAdd = max(minimumHitHeight - buttonSize.height, 0)
        let area = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        return area.contains(point)
    }
}
