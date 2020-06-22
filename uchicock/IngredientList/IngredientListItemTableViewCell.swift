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
    
    var shouldAnimate = false
    
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
            if ingredient!.usingRecipeNum == 0{
                recipeNum.text = String(ingredient!.usingRecipeNum)
                recipeNum.layer.backgroundColor = UIColor.clear.cgColor
                recipeNum.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNum.textColor = UchicockStyle.primaryColor
            }else if ingredient!.usingRecipeNum > 0 && ingredient!.usingRecipeNum < 1000 {
                recipeNum.text = String(ingredient!.usingRecipeNum)
                recipeNum.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                recipeNum.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNum.textColor = UchicockStyle.labelTextColorOnBadge
            }else{
                recipeNum.text = "999"
                recipeNum.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                recipeNum.layer.borderColor = UchicockStyle.primaryColor.cgColor
                recipeNum.textColor = UchicockStyle.labelTextColorOnBadge
            }
            recipeNum.layer.cornerRadius = 10
            recipeNum.clipsToBounds = true

            alcoholIconImage.tintColor = UchicockStyle.primaryColor
            alcoholIconImage.isHidden = ingredient!.category != 0
            alcoholIconImageWidthConstraint.constant = ingredient!.category == 0 ? 15 : 0

            ingredientName.text = ingredient!.name
            
            stockLabel.textColor = UchicockStyle.labelTextColorLight
            stockLabel.clipsToBounds = true
            
            stock.secondaryTintColor = UchicockStyle.primaryColor
            stock.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
            stock.boxLineWidth = 1.0
            stock.animationDuration = 0.3
            if shouldAnimate{
                stock.stateChangeAnimation = .expand
            }
        }
    }
    
}
