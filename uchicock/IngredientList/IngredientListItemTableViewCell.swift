//
//  IngredientListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeNum: UILabel!
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var ingredientName: CustomLabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var stock: CircularCheckbox!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var stockState = 0
    
    var ingredient: IngredientBasic? = nil{
        didSet{
            guard ingredient != nil else { return }
            
            stock.stateChangeAnimation = .fade
            stock.animationDuration = 0
            if ingredient!.stockFlag{
                stock.setCheckState(.checked, animated: true)
            }else{
                stock.setCheckState(.unchecked, animated: true)
            }

            recipeNum.backgroundColor = UIColor.clear
            recipeNum.layer.borderWidth = 1
            if ingredient!.usedRecipeNum == 0{
                recipeNum.text = String(ingredient!.usedRecipeNum)
                recipeNum.layer.backgroundColor = UIColor.clear.cgColor
                recipeNum.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNum.textColor = UchicockStyle.primaryColor
            }else if ingredient!.usedRecipeNum > 0 && ingredient!.usedRecipeNum < 1000 {
                recipeNum.text = String(ingredient!.usedRecipeNum)
                recipeNum.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                recipeNum.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNum.textColor = UchicockStyle.labelTextColorOnBadge
            }else{
                recipeNum.text = "999"
                recipeNum.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                recipeNum.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNum.textColor = UchicockStyle.labelTextColorOnBadge
            }
            
            alcoholIconImage.tintColor = UchicockStyle.primaryColor
            if ingredient!.category == 0{
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 15
            }else{
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
            recipeNum.layer.cornerRadius = 10
            recipeNum.clipsToBounds = true
            recipeNum.textAlignment = NSTextAlignment.center

            ingredientName.text = ingredient!.name
            stockLabel.textColor = UchicockStyle.labelTextColorLight
            stockLabel.clipsToBounds = true
            
            stock.secondaryTintColor = UchicockStyle.primaryColor
            stock.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
            stock.animationDuration = 0.3
            if stockState == 0{
                stock.stateChangeAnimation = .expand
            }
        }
    }
    
}
