//
//  RecipeTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/16.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var shortage: UILabel!
    
    var recipe: Recipe = Recipe(){
        didSet{
            if let image = recipe.imageData {
                photo.image = UIImage(data: image as Data)
            }else{
                if Style.isDark{
                    photo.image = UIImage(named: "no-photo-dark")
                }else{
                    photo.image = UIImage(named: "no-photo")
                }
            }
            
            recipeName.text = recipe.recipeName
            recipeName.textColor = Style.labelTextColor
            recipeName.backgroundColor = Style.basicBackgroundColor
            recipeName.clipsToBounds = true
            
            switch recipe.favorites{
            case 0:
                favorites.text = ""
            case 1:
                favorites.text = "★"
            case 2:
                favorites.text = "★★"
            case 3:
                favorites.text = "★★★"
            default:
                favorites.text = ""
            }
            favorites.textAlignment = .left
            favorites.textColor = Style.secondaryColor
            favorites.backgroundColor = Style.basicBackgroundColor
            
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
                shortage.text = "すぐ作れる！"
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
            shortage.backgroundColor = Style.basicBackgroundColor
            shortage.clipsToBounds = true
            
            self.separatorInset = UIEdgeInsets(top: 0, left: 77, bottom: 0, right: 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
