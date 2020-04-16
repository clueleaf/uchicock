//
//  RecoverTargetTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverTargetTableViewCell: UITableViewCell {

    @IBOutlet weak var isTarget: CircularCheckbox!
    @IBOutlet weak var recipeNameLabel: CustomLabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var newRecipeLabel: UILabel!
    @IBOutlet weak var newRecipeLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var newRecipeLabelWidthConstraint: NSLayoutConstraint!
    
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
            if recipeName.isNewRecipe(){
                newRecipeLabel.isHidden = false
                newRecipeLabelWidthConstraint.constant = 28
                newRecipeLabelTrailingConstraint.constant = 2
                newRecipeLabel.backgroundColor = UIColor.clear
                newRecipeLabel.textColor = UchicockStyle.alertColor
            }else{
                newRecipeLabel.isHidden = true
                newRecipeLabelWidthConstraint.constant = 0
                newRecipeLabelTrailingConstraint.constant = 0
            }
        }
    }
}
