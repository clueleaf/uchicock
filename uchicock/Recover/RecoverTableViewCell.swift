//
//  RecoverTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-14.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class RecoverTableViewCell: UITableViewCell {

    @IBOutlet weak var targetCheckbox: CircularCheckbox!
    @IBOutlet weak var recipeNameLabel: CustomLabel!

    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var newRecipeLabel: UILabel!
    @IBOutlet weak var newRecipeLabelWidthConstraint: NSLayoutConstraint!
    
    var shouldAdd73Badge = false
    var shouldAdd80Badge = false
    var isRecoverable = false

    var recipe : SampleRecipeBasic? = nil{
        didSet{
            guard recipe != nil else { return }
            
            recipeNameLabel.text = recipe!.name

            var shouldAddNewBadge = false
            if shouldAdd73Badge && shouldAdd80Badge && NewRecipe.v73.contains(recipe!.name){
                shouldAddNewBadge = true
            }else if shouldAdd80Badge && NewRecipe.v80.contains(recipe!.name){
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
            
            targetCheckbox.secondaryTintColor = UchicockStyle.primaryColor
            
            previewLabel.textColor = UchicockStyle.labelTextColorLight

            if isRecoverable{
                targetCheckbox.isEnabled = true
                targetCheckbox.tintColor = UchicockStyle.primaryColor
                targetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
                targetCheckbox.checkState = recipe!.recoverTarget ? .checked : .unchecked
            }else{
                targetCheckbox.isEnabled = false
                targetCheckbox.tintColor = UchicockStyle.labelTextColorLight
                targetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
                targetCheckbox.checkState = .mixed
            }
        }
    }
}
