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
                photo.image = UIImage(data: recipe.imageData! as Data)
            }else{
                if Style.isDark{
                    photo.image = UIImage(named: "no-photo-dark")
                }else{
                    photo.image = UIImage(named: "no-photo")
                }
            }

            recipeName.text = recipe.recipeName
            recipeName.textColor = Style.labelTextColor

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
            favorites.textColor = Style.secondaryColor
            
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
                shortage.textColor = Style.secondaryColor
                shortage.font = UIFont.boldSystemFont(ofSize: CGFloat(14))
            case 1:
                shortage.text = shortageName + "が足りません"
                shortage.textColor = Style.labelTextColorLight
                shortage.font = UIFont.systemFont(ofSize: CGFloat(14))
            default:
                shortage.text = "材料が" + String(shortageNum) + "個足りません"
                shortage.textColor = Style.labelTextColorLight
                shortage.font = UIFont.systemFont(ofSize: CGFloat(14))
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
