//
//  RecoverTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-14.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class RecoverTableViewCell: UITableViewCell {

    @IBOutlet weak var isTarget: CircularCheckbox!
    @IBOutlet weak var recipeNameLabel: CustomLabel!

    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var newRecipeLabel: UILabel!
    @IBOutlet weak var newRecipeLabelWidthConstraint: NSLayoutConstraint!
    
    var shouldAdd73Badge = false
    var shouldAdd80Badge = false

    var isRecoverable: Bool = Bool(){
        didSet{
            isTarget.stateChangeAnimation = .expand
            isTarget.animationDuration = 0.3
            previewLabel.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    var recipeName = String(){
        didSet{
            recipeNameLabel.text = recipeName
            
            var shouldAddNewBadge = false
            if shouldAdd73Badge && recipeName.isNewRecipe73(){
                shouldAddNewBadge = true
            }else if shouldAdd80Badge && recipeName.isNewRecipe80(){
                shouldAddNewBadge = true
            }

            if shouldAddNewBadge{
                newRecipeLabel.isHidden = false
                newRecipeLabelWidthConstraint.constant = 30
                newRecipeLabel.backgroundColor = UIColor.clear
                newRecipeLabel.textColor = UchicockStyle.alertColor
            }else{
                newRecipeLabel.isHidden = true
                newRecipeLabelWidthConstraint.constant = 0
            }
        }
    }
}
