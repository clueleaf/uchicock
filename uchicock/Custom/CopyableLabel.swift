//
//  CopyableLabel.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/10/07.
//  Copyright © 2017年 Kou. All rights reserved.
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

