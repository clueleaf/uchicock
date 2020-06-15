//
//  CircularCheckboxExpandController.swift
//  uchicock

import UIKit

internal class CircularCheckboxExpandController: CircularCheckboxController {
    
    override func animate(_ fromState: CircularCheckbox.CheckState?, toState: CircularCheckbox.CheckState?, completion: (() -> Void)?) {
        super.animate(fromState, toState: toState)
        
        if pathGenerator.pathForMark(toState) == nil && pathGenerator.pathForMark(fromState) != nil {
            let amplitude: CGFloat = 0.35
            let wiggleAnimation = animationGenerator.fillAnimation(1, amplitude: amplitude, reverse: true)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                self.resetLayersForState(self.state)
                completion?()
            })
            
            selectedBoxLayer.add(wiggleAnimation, forKey: "transform")
            markLayer.add(wiggleAnimation, forKey: "transform")
            
            CATransaction.commit()
        }else if pathGenerator.pathForMark(toState) != nil && pathGenerator.pathForMark(fromState) == nil {
            markLayer.path = pathGenerator.pathForMark(toState)?.cgPath
            
            let amplitude: CGFloat = 0.35
            let wiggleAnimation = animationGenerator.fillAnimation(1, amplitude: amplitude, reverse: false)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                self.resetLayersForState(self.state)
                completion?()
            })
            
            selectedBoxLayer.add(wiggleAnimation, forKey: "transform")
            markLayer.add(wiggleAnimation, forKey: "transform")
            
            CATransaction.commit()
        }else{
            let fromPath = pathGenerator.pathForMark(fromState)
            let toPath = pathGenerator.pathForMark(toState)
            
            let morphAnimation = animationGenerator.morphAnimation(fromPath, toPath: toPath)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({ [weak self] () -> Void in
                self?.resetLayersForState(self?.state)
                completion?()
                })
            
            markLayer.add(morphAnimation, forKey: "path")
            
            CATransaction.commit()
        }
    }
    
    override func resetLayersForState(_ state: CircularCheckbox.CheckState?) {
        super.resetLayersForState(state)
        // Remove all remnant animations. They will interfere with each other if they are not removed before a new round of animations start.
        unselectedBoxLayer.removeAllAnimations()
        selectedBoxLayer.removeAllAnimations()
        markLayer.removeAllAnimations()

        // Set the properties for the final states of each necessary property of each layer.
        unselectedBoxLayer.strokeColor = secondaryTintColor?.cgColor
        unselectedBoxLayer.lineWidth = pathGenerator.boxLineWidth

        selectedBoxLayer.strokeColor = tintColor.cgColor
        selectedBoxLayer.lineWidth = pathGenerator.boxLineWidth

        selectedBoxLayer.fillColor = tintColor.cgColor
        markLayer.strokeColor = secondaryCheckmarkTintColor?.cgColor

        markLayer.lineWidth = pathGenerator.checkmarkLineWidth

        if pathGenerator.pathForMark(state) != nil{
            markLayer.transform = CATransform3DIdentity
            selectedBoxLayer.transform = CATransform3DIdentity
        }else{
            markLayer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            selectedBoxLayer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        }

        // Paths
        unselectedBoxLayer.path = pathGenerator.pathForBox()?.cgPath
        selectedBoxLayer.path = pathGenerator.pathForBox()?.cgPath
        markLayer.path = pathGenerator.pathForMark(state)?.cgPath
    }
}
