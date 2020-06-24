//
//  IngredientListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeNumLabel: UILabel!
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var ingredientNameLabel: CustomLabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var stockCheckbox: CircularCheckbox!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var shouldAnimate = false
    
    var ingredient: IngredientBasic? = nil{
        didSet{
            guard ingredient != nil else { return }
            
            stockCheckbox.stateChangeAnimation = .fade
            stockCheckbox.animationDuration = 0
            stockCheckbox.checkState = ingredient!.stockFlag ? .checked : .unchecked

            recipeNumLabel.backgroundColor = UIColor.clear
            recipeNumLabel.layer.borderWidth = 1
            if ingredient!.usingRecipeNum == 0{
                recipeNumLabel.text = String(ingredient!.usingRecipeNum)
                recipeNumLabel.layer.backgroundColor = UIColor.clear.cgColor
                recipeNumLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNumLabel.textColor = UchicockStyle.primaryColor
            }else if ingredient!.usingRecipeNum > 0 && ingredient!.usingRecipeNum < 1000 {
                recipeNumLabel.text = String(ingredient!.usingRecipeNum)
                recipeNumLabel.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                recipeNumLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNumLabel.textColor = UchicockStyle.labelTextColorOnBadge
            }else{
                recipeNumLabel.text = "999"
                recipeNumLabel.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                recipeNumLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNumLabel.textColor = UchicockStyle.labelTextColorOnBadge
            }
            recipeNumLabel.layer.cornerRadius = 10
            recipeNumLabel.clipsToBounds = true

            alcoholIconImage.tintColor = UchicockStyle.primaryColor
            alcoholIconImage.isHidden = ingredient!.category != 0
            alcoholIconImageWidthConstraint.constant = ingredient!.category == 0 ? 15 : 0

            ingredientNameLabel.text = ingredient!.name
            
            stockLabel.textColor = UchicockStyle.labelTextColorLight
            stockLabel.clipsToBounds = true
            
            stockCheckbox.secondaryTintColor = UchicockStyle.primaryColor
            stockCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
            stockCheckbox.animationDuration = 0.3
            if shouldAnimate { stockCheckbox.stateChangeAnimation = .expand }
        }
    }
    
}
