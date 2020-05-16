//
//  RecipeTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/16.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var bookmarkBackImage: UIImageView!
    @IBOutlet weak var bookmarkFrontImage: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var subInfoLabel: UILabel!
    @IBOutlet weak var shortageLabel: UILabel!
    
    var shouldHighlightOnlyWhenAvailable = false
    var subInfoType = 0
    
    var recipe: Recipe = Recipe(){
        didSet{
            let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")?.withRenderingMode(.alwaysTemplate)
            let accesoryImageView = UIImageView(image: disclosureIndicator)
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
            self.accessoryView = accesoryImageView

            if let image = ImageUtil.loadImageOf(recipeId: recipe.id, forList: true){
                photoImageView.image = image
            }else{
                photoImageView.image = UIImage(named: "tabbar-recipe")?.withAlignmentRectInsets(UIEdgeInsets(top: -13, left: -13, bottom: -13, right: -13))
                photoImageView.tintColor = UchicockStyle.noPhotoColor
            }
            
            bookmarkBackImage.tintColor = UchicockStyle.primaryColor
            bookmarkFrontImage.tintColor = UchicockStyle.primaryColor
            bookmarkBackImage.isHidden = recipe.bookmarkDate == nil ? true : false
            bookmarkFrontImage.isHidden = recipe.bookmarkDate == nil ? true : false

            recipeNameLabel.text = recipe.recipeName
            if shouldHighlightOnlyWhenAvailable == false ||  recipe.shortageNum == 0 {
                recipeNameLabel.textColor = UchicockStyle.labelTextColor
            }else{
                recipeNameLabel.textColor = UchicockStyle.labelTextColorLight
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
                subInfoLabel.textColor = UchicockStyle.primaryColor
            case 1: // 作った回数
                subInfoLabel.text = String(recipe.madeNum) + "回"
                if recipe.madeNum < 1{
                    subInfoLabel.textColor = UchicockStyle.labelTextColorLight
                }else{
                    subInfoLabel.textColor = UchicockStyle.primaryColor
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
                subInfoLabel.textColor = UchicockStyle.labelTextColorLight
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
                subInfoLabel.textColor = UchicockStyle.primaryColor
            }

            subInfoLabel.textAlignment = .right
            
            switch recipe.shortageNum {
            case 0:
                shortageLabel.text = "すぐ作れる！"
                shortageLabel.textColor = UchicockStyle.primaryColor
                shortageLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(14))
            case 1:
                var shortageName = ""
                for recipeIngredient in recipe.recipeIngredients{
                    if recipeIngredient.mustFlag && recipeIngredient.ingredient.stockFlag == false {
                        shortageName = recipeIngredient.ingredient.ingredientName
                        break
                    }
                }
                shortageLabel.text = shortageName + "が足りません"
                shortageLabel.textColor = UchicockStyle.labelTextColorLight
                shortageLabel.font = UIFont.systemFont(ofSize: CGFloat(14))
            default:
                shortageLabel.text = "材料が" + String(recipe.shortageNum) + "個足りません"
                shortageLabel.textColor = UchicockStyle.labelTextColorLight
                shortageLabel.font = UIFont.systemFont(ofSize: CGFloat(14))
            }
            
            self.separatorInset = UIEdgeInsets(top: 0, left: 77, bottom: 0, right: 0)
        }
    }
}
