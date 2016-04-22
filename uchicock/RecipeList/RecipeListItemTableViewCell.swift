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

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var shortage: UILabel!
    
    var recipe: Recipe = Recipe(){
        didSet{
            if recipe.imageData != nil{
                photo.image = UIImage(data: recipe.imageData!)
                //レシピ削除のバグに対するワークアラウンド
                if photo.image == nil{
                    photo.image = UIImage(named: "no-photo")
                }
            }else{
                photo.image = UIImage(named: "no-photo")
            }

            recipeName.text = recipe.recipeName
            
            switch recipe.favorites{
            case 1:
                favorites.text = "★☆☆"
            case 2:
                favorites.text = "★★☆"
            case 3:
                favorites.text = "★★★"
            default:
                favorites.text = "★☆☆"
            }
            favorites.textColor = FlatSkyBlue()
            
            var shortageNum = 0
            var shortageName = ""
            for recipeIngredient in recipe.recipeIngredients{
                if recipeIngredient.mustFlag && recipeIngredient.ingredient.stockFlag == false {
                    shortageNum += 1
                    shortageName = recipeIngredient.ingredient.ingredientName
                }
            }
            switch shortageNum {
            case 0:
                shortage.text = "すぐつくれる！"
                shortage.textColor = FlatSkyBlueDark()
                shortage.font = UIFont.boldSystemFontOfSize(CGFloat(14))
            case 1:
                if shortageName.characters.count > 10{
                    shortage.text = (shortageName as NSString).substringToIndex(10) + "...が足りません"
                }else{
                    shortage.text = shortageName + "が足りません"
                }
                shortage.textColor = FlatGrayDark()
                shortage.font = UIFont.systemFontOfSize(CGFloat(14))
            default:
                shortage.text = "材料が" + String(shortageNum) + "個足りません"
                shortage.textColor = FlatGrayDark()
                shortage.font = UIFont.systemFontOfSize(CGFloat(14))
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
