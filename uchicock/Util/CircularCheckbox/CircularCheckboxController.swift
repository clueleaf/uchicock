//
//  CircularCheckboxController.swift
//  CircularCheckbox

import UIKit

internal class CircularCheckboxController {
    
    //----------------------------
    // MARK: - Properties
    //----------------------------
    
    /// The path presets for the manager.
    var pathGenerator = CircularCheckboxCheckPathGenerator()
    
    /// The animation presets for the manager.
    var animationGenerator: CircularCheckboxAnimationGenerator = CircularCheckboxAnimationGenerator()
    
    /// The current state of the checkbox.
    var state: CircularCheckbox.CheckState = .unchecked
    
    /// The current tint color.
    /// - Note: Subclasses should override didSet to update the layers when this value changes.
    var tintColor: UIColor = UIColor.black
    
    /// The secondary tint color.
    /// - Note: Subclasses should override didSet to update the layers when this value changes.
    var secondaryTintColor: UIColor? = UIColor.lightGray
    
    /// The secondary color of the mark.
    /// - Note: Subclasses should override didSet to update the layers when this value changes.
    var secondaryCheckmarkTintColor: UIColor? = UIColor.white
    
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
    
    //----------------------------
    // MARK: - Layers
    //----------------------------
    
    /// The layers to display in the checkbox. The top layer is the last layer in the array.
    var layersToDisplay: [CALayer] {
        return []
    }
    
    //----------------------------
    // MARK: - Animations
    //----------------------------
    
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
    
    //----------------------------
    // MARK: - Layout
    //----------------------------
    
    /// Layout the layers.
    func layoutLayers() {
        
    }
    
    //----------------------------
    // MARK: - Display
    //----------------------------
    
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
