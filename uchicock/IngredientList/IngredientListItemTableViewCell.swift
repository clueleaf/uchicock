//
//  IngredientListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import M13Checkbox

class IngredientListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeNum: UILabel!
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var stock: M13Checkbox!
    
    var stockState = 0
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            if ingredient.recipeIngredients.count == 0{
                recipeNum.text = String(ingredient.recipeIngredients.count)
                recipeNum.backgroundColor = Style.badgeDisableBackgroundColor
                recipeNum.textColor = Style.labelTextColor
            }else if ingredient.recipeIngredients.count > 0 && ingredient.recipeIngredients.count < 100 {
                recipeNum.text = String(ingredient.recipeIngredients.count)
                recipeNum.backgroundColor = Style.secondaryColor
                recipeNum.textColor = Style.labelTextColorOnBadge
            }else{
                recipeNum.text = "99+"
                recipeNum.backgroundColor = Style.secondaryColor
                recipeNum.textColor = Style.labelTextColorOnBadge
            }
            recipeNum.layer.cornerRadius = 10
            recipeNum.clipsToBounds = true
            recipeNum.textAlignment = NSTextAlignment.center

            ingredientName.text = ingredient.ingredientName
            ingredientName.textColor = Style.labelTextColor
            stockLabel.textColor = Style.labelTextColorLight
            
            stock.backgroundColor = UIColor.clear
            stock.tintColor = Style.secondaryColor
            stock.secondaryTintColor = Style.checkboxSecondaryTintColor
            stock.boxLineWidth = 1.0
            stock.markType = .checkmark
            stock.boxType = .circle
            stock.animationDuration = 0.3
            if stockState == 0{
                stock.stateChangeAnimation = .expand(.fill)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
