//
//  CircularCheckboxController.swift
//  uchicock

import UIKit

internal class CircularCheckboxController {
    
    /// The path presets for the manager.
    var pathGenerator = CircularCheckboxCheckPathGenerator()
    
    /// The animation presets for the manager.
    var animationGenerator: CircularCheckboxAnimationGenerator = CircularCheckboxAnimationGenerator()
    
    /// The current state of the checkbox.
    var state: CircularCheckbox.CheckState = .unchecked
    
    /// The current tint color.
    /// - Note: Subclasses should override didSet to update the layers when this value changes.
    var tintColor: UIColor = UIColor.black{
        didSet {
            selectedBoxLayer.strokeColor = tintColor.cgColor
            selectedBoxLayer.fillColor = tintColor.cgColor
        }
    }
    
    /// The secondary tint color.
    /// - Note: Subclasses should override didSet to update the layers when this value changes.
    var secondaryTintColor: UIColor? = UIColor.lightGray{
        didSet {
            unselectedBoxLayer.strokeColor = secondaryTintColor?.cgColor
        }
    }
    
    /// The secondary color of the mark.
    /// - Note: Subclasses should override didSet to update the layers when this value changes.
    var secondaryCheckmarkTintColor: UIColor? = UIColor.white{
        didSet {
            markLayer.strokeColor = secondaryCheckmarkTintColor?.cgColor
        }
    }
    
    init() {
        sharedSetup()
    }
    
    fileprivate func sharedSetup() {
        // Disable som implicit animations.
        let newActions = [
            "opacity": NSNull(),
            "transform": NSNull(),
            "path": NSNull(),
        ]
        
        // Setup the unselected box layer
        unselectedBoxLayer.lineCap = .round
        unselectedBoxLayer.rasterizationScale = UIScreen.main.scale
        unselectedBoxLayer.shouldRasterize = true
        unselectedBoxLayer.actions = newActions
        
        unselectedBoxLayer.opacity = 1.0
        unselectedBoxLayer.strokeEnd = 1.0
        unselectedBoxLayer.transform = CATransform3DIdentity
        unselectedBoxLayer.fillColor = nil

        // Setup the selected box layer.
        selectedBoxLayer.lineCap = .round
        selectedBoxLayer.rasterizationScale = UIScreen.main.scale
        selectedBoxLayer.shouldRasterize = true
        selectedBoxLayer.actions = newActions
        
        selectedBoxLayer.fillColor = nil
        selectedBoxLayer.transform = CATransform3DIdentity
        
        // Setup the checkmark layer.
        markLayer.lineCap = .round
        markLayer.lineJoin = .round
        markLayer.rasterizationScale = UIScreen.main.scale
        markLayer.shouldRasterize = true
        markLayer.actions = newActions
        
        markLayer.transform = CATransform3DIdentity
        markLayer.fillColor = nil
    }
    
    private func _setMarkType(animated: Bool) {
        let newPathGenerator = CircularCheckboxCheckPathGenerator()
        newPathGenerator.boxLineWidth = pathGenerator.boxLineWidth
        newPathGenerator.checkmarkLineWidth = pathGenerator.checkmarkLineWidth
        
        // Animate the change.
        if pathGenerator.pathForMark(state) != nil && animated {
            let previousState = state
            animate(state, toState: nil, completion: { [weak self] in
                self?.pathGenerator = newPathGenerator
                self?.resetLayersForState(previousState)
                if self?.pathGenerator.pathForMark(previousState) != nil {
                    self?.animate(nil, toState: previousState)
                }
            })
        } else if newPathGenerator.pathForMark(state) != nil && animated {
            let previousState = state
            pathGenerator = newPathGenerator
            resetLayersForState(nil)
            animate(nil, toState: previousState)
        } else {
            pathGenerator = newPathGenerator
            resetLayersForState(state)
        }
    }
    
    // MARK: - Layers
    let markLayer = CAShapeLayer()
    let selectedBoxLayer = CAShapeLayer()
    let unselectedBoxLayer = CAShapeLayer()

    /// The layers to display in the checkbox. The top layer is the last layer in the array.
    var layersToDisplay: [CALayer] {
        return [unselectedBoxLayer, selectedBoxLayer, markLayer]
    }
    
    // MARK: - Animations
    /**
     Animates the layers between the two states.
     - parameter fromState: The previous state of the checkbox.
     - parameter toState: The new state of the checkbox.
     */
    func animate(_ fromState: CircularCheckbox.CheckState?, toState: CircularCheckbox.CheckState?, completion: (() -> Void)? = nil) {
        if let toState = toState {
            state = toState
        }
    }
    
    // MARK: - Layout
    /// Layout the layers.
    func layoutLayers() {
        // Frames
        unselectedBoxLayer.frame = CGRect(x: 0.0, y: 0.0, width: pathGenerator.size, height: pathGenerator.size)
        selectedBoxLayer.frame = CGRect(x: 0.0, y: 0.0, width: pathGenerator.size, height: pathGenerator.size)
        markLayer.frame = CGRect(x: 0.0, y: 0.0, width: pathGenerator.size, height: pathGenerator.size)
        // Paths
        unselectedBoxLayer.path = pathGenerator.pathForBox()?.cgPath
        selectedBoxLayer.path = pathGenerator.pathForBox()?.cgPath
        markLayer.path = pathGenerator.pathForMark(state)?.cgPath
    }

    // MARK: - Display
    /**
     Reset the layers to be in the given state.
     - parameter state: The new state of the checkbox.
     */
    func resetLayersForState(_ state: CircularCheckbox.CheckState?) {
        if let state = state {
            self.state = state
        }
        layoutLayers()
    }
    
}
