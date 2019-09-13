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
    @IBOutlet weak var subInfoLabel: UILabel!
    @IBOutlet weak var shortage: UILabel!
    
    var hightlightRecipeNameOnlyAvailable = false
    var subInfoType = 0
    
    var recipe: Recipe = Recipe(){
        didSet{
            if let image = ImageUtil.load(imageFileName: recipe.imageFileName, useCache: true){
                self.photo.image = image
            }else{
                if Style.isDark{
                    photo.image = UIImage(named: "no-photo-dark")
                }else{
                    photo.image = UIImage(named: "no-photo")
                }
            }
            
            recipeName.text = recipe.recipeName
            if hightlightRecipeNameOnlyAvailable {
                if recipe.shortageNum == 0{
                    recipeName.textColor = Style.labelTextColor
                }else{
                    recipeName.textColor = Style.labelTextColorLight
                }
            }else{
                recipeName.textColor = Style.labelTextColor
            }

            switch subInfoType{
            case 0: // お気に入り
                switch recipe.favorites{
                case 0:
                    subInfoLabel.text = ""
                case 1:
                    subInfoLabel.text = "★"
                case 2:
                    subInfoLabel.text = "★★"
                case 3:
                    subInfoLabel.text = "★★★"
                default:
                    subInfoLabel.text = ""
                }
                subInfoLabel.textColor = Style.secondaryColor
            case 1: // 作った回数
                subInfoLabel.text = String(recipe.madeNum) + "回"
                if recipe.madeNum < 1{
                    subInfoLabel.textColor = Style.labelTextColorLight
                }else{
                    subInfoLabel.textColor = Style.secondaryColor
                }
            case 2: // 最近見た
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd"
                subInfoLabel.text = recipe.lastViewDate == nil ? "--" : formatter.string(from: recipe.lastViewDate!)
                subInfoLabel.textColor = Style.labelTextColorLight
            default: // お気に入り
                switch recipe.favorites{
                case 0:
                    subInfoLabel.text = ""
                case 1:
                    subInfoLabel.text = "★"
                case 2:
                    subInfoLabel.text = "★★"
                case 3:
                    subInfoLabel.text = "★★★"
                default:
                    subInfoLabel.text = ""
                }
                subInfoLabel.textColor = Style.secondaryColor
            }

            subInfoLabel.textAlignment = .right
            subInfoLabel.backgroundColor = Style.basicBackgroundColor
            
            switch recipe.shortageNum {
            case 0:
                shortage.text = "すぐ作れる！"
                shortage.textColor = Style.secondaryColor
                shortage.font = UIFont.boldSystemFont(ofSize: CGFloat(14))
            case 1:
                var shortageName = ""
                for recipeIngredient in recipe.recipeIngredients{
                    if recipeIngredient.mustFlag && recipeIngredient.ingredient.stockFlag == false {
                        shortageName = recipeIngredient.ingredient.ingredientName
                        break
                    }
                }
                shortage.text = shortageName + "が足りません"
                shortage.textColor = Style.labelTextColorLight
                shortage.font = UIFont.systemFont(ofSize: CGFloat(14))
            default:
                shortage.text = "材料が" + String(recipe.shortageNum) + "個足りません"
                shortage.textColor = Style.labelTextColorLight
                shortage.font = UIFont.systemFont(ofSize: CGFloat(14))
            }
            
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
