//
//  CustomClasses.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/02.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class CustomAlertController: UIAlertController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
}

class CustomActivityController: UIActivityViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
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
    var hasLeftIcon = false
    
    func setSearchIcon() {
        self.hasLeftIcon = true
        let searchIcon = UIImageView(image: UIImage(named: "tabbar-reverse-lookup"))
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.tintColor = UchicockStyle.labelTextColorLight
        self.leftViewMode = .always
        self.leftView = searchIcon
    }
    
    func setLeftPadding(){
        self.hasLeftIcon = false
        self.leftViewMode = .always
        self.leftView = UIView()
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.size.height = bounds.height / 2
        rect.origin.y = (bounds.height - rect.size.height) / 2
        rect.size.width = hasLeftIcon ? rect.size.height + 8 : 8
        rect.origin.x = 6
        return rect
    }

    var hasRightIcon = false

    func adjustClearButtonColor() {
        self.hasRightIcon = true
        let clearButton = ExpandedButton(type: .custom)
        clearButton.minimumHitHeight = 36
        clearButton.minimumHitWidth = 36
        clearButton.setImage(UIImage(named: "button-clear"), for: .normal)
        clearButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 6)
        clearButton.imageView?.contentMode = .scaleAspectFit
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
    
    func setRightPadding(){
        self.hasRightIcon = false
        self.rightViewMode = .always
        self.rightView = UIView()
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.size.height = min(bounds.height / 2, 16) + 6
        rect.origin.y = (bounds.height - rect.size.height) / 2
        rect.size.width = hasRightIcon ? rect.size.height + rect.origin.y : 8
        rect.origin.x = hasRightIcon ? bounds.width - rect.size.width : bounds.width - 14
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
        layer.cornerRadius = self.bounds.size.height / 2.0
        layer.borderColor = UchicockStyle.primaryColor.cgColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        clipsToBounds = true

        if #available(iOS 13.0, *) {
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

class CustomScrollView: UIScrollView{
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
          return true
        }
        return super.touchesShouldCancel(in: view)
    }    
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

class TipViewController: UIViewController, UIScrollViewDelegate{
    var interactor: Interactor?
    var onDoneBlock = {}

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock()
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let int = interactor, int.hasStarted {
            scrollView.contentOffset.y = 0.0
        }
    }
    
}
