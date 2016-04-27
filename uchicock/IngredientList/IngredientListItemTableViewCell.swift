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
                recipeNum.backgroundColor = FlatGray()
            }else if ingredient.recipeIngredients.count > 0 && ingredient.recipeIngredients.count < 100 {
                recipeNum.text = String(ingredient.recipeIngredients.count)
                recipeNum.backgroundColor = FlatSkyBlue()
            }else{
                recipeNum.text = "99+"
                recipeNum.backgroundColor = FlatSkyBlue()
            }
            recipeNum.textColor = FlatWhite()
            recipeNum.layer.cornerRadius = 10
            recipeNum.clipsToBounds = true
            recipeNum.textAlignment = NSTextAlignment.Center

            ingredientName.text = ingredient.ingredientName
            stockLabel.textColor = FlatGrayDark()
            
            stock.backgroundColor = UIColor.clearColor()
            stock.tintColor = FlatSkyBlueDark()
            stock.secondaryTintColor = FlatGray()
            stock.boxLineWidth = 1.0
            stock.markType = .Checkmark
            stock.boxType = .Circle
            stock.animationDuration = 0.3
            if stockState == 0{
                stock.stateChangeAnimation = .Expand(.Fill)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
