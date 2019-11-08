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
    @IBOutlet weak var bookmarkBackImage: UIImageView!
    @IBOutlet weak var bookmarkFrontImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var subInfoLabel: UILabel!
    @IBOutlet weak var shortage: UILabel!
    
    var hightlightRecipeNameOnlyAvailable = false
    var subInfoType = 0
    
    var recipe: Recipe = Recipe(){
        didSet{
            let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")?.withRenderingMode(.alwaysTemplate)
            let accesoryImageView = UIImageView(image: disclosureIndicator)
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            accesoryImageView.tintColor = Style.labelTextColorLight
            self.accessoryView = accesoryImageView

            if let image = ImageUtil.loadImageOf(recipeId: recipe.id, forList: true){
                self.photo.image = image
            }else{
                photo.image = UIImage(named: "tabbar-recipe")?.withAlignmentRectInsets(UIEdgeInsets(top: -13, left: -13, bottom: -13, right: -13))
                if Style.isDark{
                    photo.tintColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                }else{
                    photo.tintColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
                }
            }
            
            bookmarkBackImage.tintColor = Style.primaryColor
            bookmarkFrontImage.tintColor = Style.primaryColor
            if recipe.bookmarkDate == nil{
                bookmarkBackImage.isHidden = true
                bookmarkFrontImage.isHidden = true
            }else{
                bookmarkBackImage.isHidden = false
                bookmarkFrontImage.isHidden = false
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
                subInfoLabel.textColor = Style.primaryColor
            case 1: // 作った回数
                subInfoLabel.text = String(recipe.madeNum) + "回"
                if recipe.madeNum < 1{
                    subInfoLabel.textColor = Style.labelTextColorLight
                }else{
                    subInfoLabel.textColor = Style.primaryColor
                }
            case 2: // 最近見た
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd"
                if let lastViewDate = recipe.lastViewDate{
                    let calendar = Calendar(identifier: .gregorian)
                    if calendar.isDateInToday(lastViewDate){
                        subInfoLabel.text = "今日"
                    }else if calendar.isDateInYesterday(lastViewDate){
                        subInfoLabel.text = "昨日"
                    }else{
                        subInfoLabel.text = formatter.string(from: lastViewDate)
                    }
                }else{
                    subInfoLabel.text = "--"
                }
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
                subInfoLabel.textColor = Style.primaryColor
            }

            subInfoLabel.textAlignment = .right
            
            switch recipe.shortageNum {
            case 0:
                shortage.text = "すぐ作れる！"
                shortage.textColor = Style.primaryColor
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
    
}
