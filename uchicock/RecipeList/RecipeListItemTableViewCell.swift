//
//  RecipeListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var shortage: UILabel!
    
    var recipe: Recipe = Recipe(){
        didSet{
            recipeName.text = recipe.recipeName
            
            switch recipe.favorites{
            case 1:
                favorites.text = "★☆☆"
            case 2:
                favorites.text = "★★☆"
            case 3:
                favorites.text = "★★★"
            default:
                favorites.text = "★★☆"
            }
            favorites.textColor = FlatSkyBlue()
            
            var shortageNum = 0
            var shortageName = ""
            for (var i = 0; i<recipe.recipeIngredients.count; ++i){
                if recipe.recipeIngredients[i].mustFlag && recipe.recipeIngredients[i].ingredient.stockFlag == false {
                    shortageNum++
                    shortageName = recipe.recipeIngredients[i].ingredient.ingredientName
                }
            }
            if shortageNum == 0 {
                shortage.text = "すぐつくれる！"
                shortage.textColor = FlatSkyBlueDark()
                shortage.font = UIFont.boldSystemFontOfSize(CGFloat(14))
            }else if shortageNum == 1{
                if shortageName.characters.count > 10{
                    shortage.text = (shortageName as NSString).substringToIndex(10) + "...が足りません"
                }else{
                    shortage.text = shortageName + "が足りません"
                }
                shortage.textColor = FlatGrayDark()
                shortage.font = UIFont.systemFontOfSize(CGFloat(14))
            }else{
                shortage.text = "材料が" + String(shortageNum) + "個足りません"
                shortage.textColor = FlatGrayDark()
                shortage.font = UIFont.systemFontOfSize(CGFloat(14))
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