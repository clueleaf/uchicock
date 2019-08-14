//
//  CircularCheckbox.swift
//  CircularCheckbox
//
//  Created by McQuilkin, Brandon on 2/23/16.
//  Copyright © 2016 Brandon McQuilkin. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

/// A customizable checkbox control for iOS.
@IBDesignable
open class CircularCheckbox: UIControl {
    
    //----------------------------
    // MARK: - Constants
    //----------------------------
    public enum CheckState: String {
        /// No check is shown.
        case unchecked = "Unchecked"
        /// A checkmark is shown.
        case checked = "Checked"
        /// A dash is shown.
        case mixed = "Mixed"
    }
    
    /**
     The possible animations for switching to and from the unchecked state.
     */
    public enum Animation: RawRepresentable, Hashable {
        /// Animates the checkmark and fills the box with a bouncy effect.
        case expand
        /// Fades checkmark in or out. (opacity).
        case fade
        
        public init?(rawValue: String) {
            // Map the integer values to the animation types.
            // This is only for interface builder support. I would like this to be removed eventually.
            switch rawValue {
            case "Expand": self = .expand
            case "Fade": self = .fade
            default: return nil
            }
        }
        
        public var rawValue: String {
            // Map the animation types to integer values.
            // This is only for interface builder support. I would like this to be removed eventually.
            switch self {
            case .expand: return "Expand"
            case .fade: return "Fade"
            }
        }
        
        /// The manager for the specific animation type.
        fileprivate var manager: CircularCheckboxController {
            switch self {
            case .expand:
                return CircularCheckboxExpandController()
            case .fade:
                return CircularCheckboxFadeController()
            }
        }
        
        public var hashValue: Int {
            return self.rawValue.hashValue
        }
    }
    
    //----------------------------
    // MARK: - Properties
    //----------------------------
    
    /// The manager that manages display and animations of the checkbox.
    /// The default animation is a stroke.
    fileprivate var controller: CircularCheckboxController = CircularCheckboxExpandController()
    
    //----------------------------
    // MARK: - Initalization
    //----------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedSetup()
    }
    
    /// The setup shared between initalizers.
    fileprivate func sharedSetup() {
        // Set up the inital state.
        for aLayer in controller.layersToDisplay {
            layer.addSublayer(aLayer)
        }
        controller.tintColor = tintColor
        controller.resetLayersForState(.unchecked)
        
        let longPressGesture = CircularCheckboxGestureRecognizer(target: self, action: #selector(CircularCheckbox.handleLongPress(_:)))
        addGestureRecognizer(longPressGesture)
    }
    
    //----------------------------
    // MARK: - Values
    //----------------------------
    
    /// The object to return from `value` when the checkbox is checked.
    open var checkedValue: Any?
    
    /// The object to return from `value` when the checkbox is unchecked.
    open var uncheckedValue: Any?
    
    /// The object to return from `value` when the checkbox is mixed.
    open var mixedValue: Any?
    
    /**
     Returns one of the three "value" properties depending on the checkbox state.
     - returns: The value coresponding to the checkbox state.
     - note: This is a convenience method so that if one has a large group of checkboxes, it is not necessary to write: if (someCheckbox == thatCheckbox) { if (someCheckbox.checkState == ...
     */
    open var value: Any? {
        switch checkState {
        case .unchecked:
            return uncheckedValue
        case .checked:
            return checkedValue
        case .mixed:
            return mixedValue
        }
    }
    
    //----------------------------
    // MARK: - State
    //----------------------------
    
    /// The current state of the checkbox.
    open var checkState: CheckState {
        get {
            return controller.state
        }
        set {
            setCheckState(newValue, animated: false)
        }
    }
    
    /**
     Change the check state.
     - parameter checkState: The new state of the checkbox.
     - parameter animated: Whether or not to animate the change.
     */
    open func setCheckState(_ newState: CheckState, animated: Bool) {
        if checkState == newState {
            return
        }
        
        if animated {
            if enableMorphing {
                controller.animate(checkState, toState: newState)
            } else {
                controller.animate(checkState, toState: nil, completion: { [weak self] in
                    self?.controller.resetLayersForState(newState)
                    self?.controller.animate(nil, toState: newState)
                    })
            }
        } else {
            controller.resetLayersForState(newState)
        }
    }
    
    /**
     Toggle the check state between unchecked and checked.
     - parameter animated: Whether or not to animate the change. Defaults to false.
     - note: If the checkbox is mixed, it will return to the unchecked state.
     */
    open func toggleCheckState(_ animated: Bool = false) {
        switch checkState {
        case .checked:
            setCheckState(.unchecked, animated: animated)
            break
        case .unchecked:
            setCheckState(.checked, animated: animated)
            break
        case .mixed:
            setCheckState(.unchecked, animated: animated)
            break
        }
    }
    
    //----------------------------
    // MARK: - Animations
    //----------------------------
    
    /// The duration of the animation that occurs when the checkbox switches states. The default is 0.3 seconds.
    @IBInspectable open var animationDuration: TimeInterval {
        get {
            return controller.animationGenerator.animationDuration
        }
        set {
            controller.animationGenerator.animationDuration = newValue
        }
    }
    
    /// The type of animation to preform when changing from the unchecked state to any other state.
    open var stateChangeAnimation: Animation = .expand {
        didSet {
            
            // Remove the sublayers
            if let layers = layer.sublayers {
                for sublayer in layers {
                    sublayer.removeAllAnimations()
                    sublayer.removeFromSuperlayer()
                }
            }
            
            // Set the manager
            let newManager = stateChangeAnimation.manager
            
            newManager.tintColor = tintColor
            newManager.secondaryTintColor = secondaryTintColor
            newManager.secondaryCheckmarkTintColor = secondaryCheckmarkTintColor
            newManager.hideBox = hideBox
            newManager.pathGenerator = controller.pathGenerator
            newManager.animationGenerator.animationDuration = controller.animationGenerator.animationDuration
            newManager.state = controller.state
            newManager.enableMorphing = controller.enableMorphing
            
            // Set up the inital state.
            for aLayer in newManager.layersToDisplay {
                layer.addSublayer(aLayer)
            }
            
            // Layout and reset
            newManager.resetLayersForState(checkState)
            controller = newManager

        }
    }
    
    /// Whether or not to enable morphing between states.
    @IBInspectable open var enableMorphing: Bool {
        get {
            return controller.enableMorphing
        }
        set {
            controller.enableMorphing = newValue
        }
    }
    
    //----------------------------
    // MARK: - UIControl
    //----------------------------
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            isSelected = true
        } else {
            isSelected = false
            if sender.state == .ended {
                toggleCheckState(true)
                sendActions(for: .valueChanged)
            }
        }
    }
    
    //----------------------------
    // MARK: - Appearance
    //----------------------------
    
    /// The color of the checkbox's tint color when not in the unselected state. The tint color is is the main color used when not in the unselected state.
    @IBInspectable open var secondaryTintColor: UIColor? {
        get {
            return controller.secondaryTintColor
        }
        set {
            controller.secondaryTintColor = newValue
        }
    }
    
    /// The color of the checkmark when it is displayed against a filled background.
    @IBInspectable open var secondaryCheckmarkTintColor: UIColor? {
        get {
            return controller.secondaryCheckmarkTintColor
        }
        set {
            controller.secondaryCheckmarkTintColor = newValue
        }
    }
    
    /// The stroke width of the checkmark.
    @IBInspectable open var checkmarkLineWidth: CGFloat {
        get {
            return controller.pathGenerator.checkmarkLineWidth
        }
        set {
            controller.pathGenerator.checkmarkLineWidth = newValue
            controller.resetLayersForState(checkState)
        }
    }
    
    /// The stroke width of the box.
    @IBInspectable open var boxLineWidth: CGFloat {
        get {
            return controller.pathGenerator.boxLineWidth
        }
        set {
            controller.pathGenerator.boxLineWidth = newValue
            controller.resetLayersForState(checkState)
        }
    }
    
    /// The corner radius of the box if the box type is square.
    @IBInspectable open var cornerRadius: CGFloat {
        get {
            return controller.pathGenerator.cornerRadius
        }
        set {
            controller.pathGenerator.cornerRadius = newValue
            setNeedsLayout()
        }
    }
    
    /// Wether or not to hide the checkbox.
    @IBInspectable open var hideBox: Bool {
        get {
            return controller.hideBox
        }
        set {
            controller.hideBox = newValue
        }
    }
    
    /// A proxy to set the box type compatible with interface builder.
    @IBInspectable var _IBStateChangeAnimation: String {
        get {
            return stateChangeAnimation.rawValue
        }
        set {
            if let type = Animation(rawValue: newValue) {
                stateChangeAnimation = type
            } else {
                stateChangeAnimation = .expand
            }
        }
    }
    
    /// A proxy to set the check state compatible with interface builder.
    @IBInspectable var _IBCheckState: String {
        get {
            return checkState.rawValue
        }
        set {
            if let temp = CheckState(rawValue: newValue) {
                checkState = temp
            } else {
                checkState = .checked
            }
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        controller.tintColor = tintColor
    }
    
    //----------------------------
    // MARK: - Layout
    //----------------------------
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Update size
        controller.pathGenerator.size = min(frame.size.width, frame.size.height)
        // Layout
        controller.layoutLayers()
    }
}