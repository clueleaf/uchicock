//
//  CircularCheckbox.swift
//  CircularCheckbox

import UIKit

/// A customizable checkbox control for iOS.
@IBDesignable
open class CircularCheckbox: UIControl {
    
    private var hasMovedWhilePressing = false
    
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
    
    /// The manager that manages display and animations of the checkbox.
    /// The default animation is a stroke.
    fileprivate var controller: CircularCheckboxController = CircularCheckboxExpandController()
    
    // MARK: - Initalization
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
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CircularCheckbox.handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Values
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
    
    // MARK: - State
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
            controller.animate(checkState, toState: newState)
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
        case .unchecked:
            setCheckState(.checked, animated: animated)
        case .mixed:
            setCheckState(.unchecked, animated: animated)
        }
    }
    
    // MARK: - Animations
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
            newManager.pathGenerator = controller.pathGenerator
            newManager.animationGenerator.animationDuration = controller.animationGenerator.animationDuration
            newManager.state = controller.state
            
            // Set up the inital state.
            for aLayer in newManager.layersToDisplay {
                layer.addSublayer(aLayer)
            }
            
            // Layout and reset
            newManager.resetLayersForState(checkState)
            controller = newManager
        }
    }
    
    // MARK: - UIControl
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.hasMovedWhilePressing = false
            isSelected = true
        } else if sender.state == .changed{
//            self.hasMovedWhilePressing = true
            isSelected = true
        } else {
            isSelected = false
            if sender.state == .ended && hasMovedWhilePressing == false {
                toggleCheckState(true)
                sendActions(for: .valueChanged)
            }
        }
    }

    // MARK: - Appearance
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
    
    // MARK: - Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Update size
        controller.pathGenerator.size = min(frame.size.width, frame.size.height)
        // Layout
        controller.layoutLayers()
    }
}

extension CircularCheckbox: UIGestureRecognizerDelegate{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UILongPressGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
    }
}
