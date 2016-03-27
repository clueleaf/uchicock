//
//  IngredientListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/13.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeIngredientListTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var option: UILabel!
    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    var recipeIngredient: RecipeIngredientLink = RecipeIngredientLink(){
        didSet{
            ingredientName.text = recipeIngredient.ingredient.ingredientName

            if recipeIngredient.mustFlag{
                option.text = ""
                option.textColor = FlatBlack()
                option.backgroundColor = UIColor.clearColor()
            }else{
                option.text = "オプション"
                option.textColor = FlatBlack()
                option.backgroundColor = FlatWhiteDark()
            }
            option.layer.cornerRadius = 4
            option.clipsToBounds = true

            if recipeIngredient.ingredient.stockFlag {
                stock.text = "在庫あり"
                stock.textColor = FlatWhite()
                stock.backgroundColor = FlatSkyBlueDark()
                ingredientName.textColor = FlatBlack()
                amount.textColor = FlatBlack()
            }else{
                stock.text = "在庫なし"
                stock.textColor = FlatBlack()
                stock.backgroundColor = FlatWhiteDark()
                ingredientName.textColor = FlatGrayDark()
                amount.textColor = FlatGrayDark()
            }
            stock.layer.cornerRadius = 4
            stock.clipsToBounds = true

            amount.text = recipeIngredient.amount
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
