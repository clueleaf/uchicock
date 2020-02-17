//
//  IngredientListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeNum: UILabel!
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var ingredientName: CustomLabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var stock: CircularCheckbox!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var stockState = 0
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            recipeNum.backgroundColor = UIColor.clear
            recipeNum.layer.borderWidth = 1
            if ingredient.recipeIngredients.count == 0{
                recipeNum.text = String(ingredient.recipeIngredients.count)
                recipeNum.layer.backgroundColor = UIColor.clear.cgColor
                recipeNum.layer.borderColor = Style.primaryColor.cgColor
                recipeNum.textColor = Style.primaryColor
            }else if ingredient.recipeIngredients.count > 0 && ingredient.recipeIngredients.count < 100 {
                recipeNum.text = String(ingredient.recipeIngredients.count)
                recipeNum.layer.backgroundColor = Style.primaryColor.cgColor
                recipeNum.layer.borderColor = Style.primaryColor.cgColor
                recipeNum.textColor = Style.labelTextColorOnBadge
            }else{
                recipeNum.text = "99+"
                recipeNum.layer.backgroundColor = Style.primaryColor.cgColor
                recipeNum.layer.borderColor = Style.primaryColor.cgColor
                recipeNum.textColor = Style.labelTextColorOnBadge
            }
            
            alcoholIconImage.tintColor = Style.primaryColor
            if ingredient.category == 0{
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 15
            }else{
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
            recipeNum.layer.cornerRadius = 10
            recipeNum.clipsToBounds = true
            recipeNum.textAlignment = NSTextAlignment.center

            ingredientName.text = ingredient.ingredientName
            stockLabel.textColor = Style.labelTextColorLight
            stockLabel.clipsToBounds = true
            
            stock.secondaryTintColor = Style.primaryColor
            stock.secondaryCheckmarkTintColor = Style.labelTextColorOnBadge
            stock.boxLineWidth = 1.0
            stock.animationDuration = 0.3
            if stockState == 0{
                stock.stateChangeAnimation = .expand
            }
        }
    }

}
