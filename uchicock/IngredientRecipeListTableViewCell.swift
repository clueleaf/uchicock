//
//  IngredientRecipeListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientRecipeListTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var shortage: UILabel!

    var recipeIngredient: RecipeIngredientLink = RecipeIngredientLink(){
        didSet{
            recipeName.text = recipeIngredient.recipe.recipeName
            
            switch recipeIngredient.recipe.favorites{
            case 1:
                favorites.text = "★☆☆"
            case 2:
                favorites.text = "★★☆"
            case 3:
                favorites.text = "★★★"
            default:
                favorites.text = "★★☆"
            }
            
            var shortageNum = 0
            var shortageName = ""
            for (var i = 0; i<recipeIngredient.recipe.recipeIngredients.count; ++i){
                if recipeIngredient.recipe.recipeIngredients[i].mustFlag && recipeIngredient.recipe.recipeIngredients[i].ingredient.stockFlag == false {
                    shortageNum++
                    shortageName = recipeIngredient.recipe.recipeIngredients[i].ingredient.ingredientName
                }
            }
            if shortageNum == 0 {
                shortage.text = "すぐつくれる！"
                shortage.textColor = UIColor.blueColor()
                recipeName.textColor = UIColor.blackColor()
            }else if shortageNum == 1{
                if shortageName.characters.count > 10{
                    shortage.text = (shortageName as NSString).substringToIndex(10) + "...が足りません"
                }else{
                    shortage.text = shortageName + "が足りません"
                }
                shortage.textColor = UIColor.grayColor()
                recipeName.textColor = UIColor.grayColor()
            }else{
                shortage.text = "材料が" + String(shortageNum) + "個足りません"
                shortage.textColor = UIColor.grayColor()
                recipeName.textColor = UIColor.grayColor()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
