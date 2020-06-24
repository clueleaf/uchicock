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

    var recipeName = String(){
        didSet{
            recipeNameLabel.text = recipeName
            
            var shouldAddNewBadge = false
            if shouldAdd73Badge && shouldAdd80Badge && NewRecipe.v73.contains(recipeName){
                shouldAddNewBadge = true
            }else if shouldAdd80Badge && NewRecipe.v80.contains(recipeName){
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
