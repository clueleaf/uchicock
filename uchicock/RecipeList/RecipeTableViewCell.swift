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
    var sortOrder = RecipeSortType.name
    
    var recipe: RecipeBasic? = nil{
        didSet{
            guard recipe != nil else { return }

            let accesoryImageView = UIImageView(image: UIImage(named: "accesory-disclosure-indicator"))
            accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            self.accessoryView = accesoryImageView

            if let image = ImageUtil.loadImageForList(recipeId: recipe!.id, imageFileName: recipe!.imageFileName){
                photoImageView.image = image
            }else{
                photoImageView.image = UIImage(named: "tabbar-recipe")?.withAlignmentRectInsets(UIEdgeInsets(top: -11, left: -11, bottom: -11, right: -11))
                photoImageView.tintColor = UchicockStyle.noPhotoColor
            }
            photoImageView.layer.cornerRadius = 8
            
            bookmarkBackImage.tintColor = UchicockStyle.primaryColor
            bookmarkFrontImage.tintColor = UchicockStyle.primaryColor
            bookmarkBackImage.isHidden = recipe!.bookmarkDate == nil ? true : false
            bookmarkFrontImage.isHidden = recipe!.bookmarkDate == nil ? true : false

            recipeNameLabel.text = recipe!.name
            if shouldHighlightOnlyWhenAvailable == false || recipe!.shortageNum == 0 {
                recipeNameLabel.textColor = UchicockStyle.labelTextColor
            }else{
                recipeNameLabel.textColor = UchicockStyle.labelTextColorLight
            }

            switch sortOrder{
            case .makeableMadenumName, .madenumName, .madenumMakeableName, .madenumFavoriteName, .madenumViewedName:
                subInfoLabel.text = String(recipe!.madeNum) + "回"
                if recipe!.madeNum < 1{
                    subInfoLabel.textColor = UchicockStyle.labelTextColorLight
                }else{
                    subInfoLabel.textColor = UchicockStyle.primaryColor
                }
            case .makeableViewdName, .viewedName:
                if let lastViewDate = recipe!.lastViewDate{
                    let calendar = Calendar(identifier: .gregorian)
                    if calendar.isDateInToday(lastViewDate){
                        subInfoLabel.text = "今日"
                    }else if calendar.isDateInYesterday(lastViewDate){
                        subInfoLabel.text = "昨日"
                    }else{
                        let formatter: DateFormatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd"
                        subInfoLabel.text = formatter.string(from: lastViewDate)
                    }
                }else{
                    subInfoLabel.text = "--"
                }
                subInfoLabel.textColor = UchicockStyle.labelTextColorLight
            default:
                switch recipe!.favorites{
                case 0: subInfoLabel.text = ""
                case 1: subInfoLabel.text = "★"
                case 2: subInfoLabel.text = "★★"
                case 3: subInfoLabel.text = "★★★"
                default: subInfoLabel.text = ""
                }
                subInfoLabel.textColor = UchicockStyle.primaryColor
            }

            switch recipe!.shortageNum {
            case 0:
                shortageLabel.text = "すぐ作れる！"
                shortageLabel.textColor = UchicockStyle.primaryColor
                shortageLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            case 1:
                if let iname = recipe!.shortageIngredientName{
                    shortageLabel.text = iname + "が足りません"
                }else{
                    shortageLabel.text = "材料が" + String(recipe!.shortageNum) + "個足りません"
                }
                shortageLabel.textColor = UchicockStyle.labelTextColorLight
                shortageLabel.font = UIFont.systemFont(ofSize: 14.0)
            default:
                shortageLabel.text = "材料が" + String(recipe!.shortageNum) + "個足りません"
                shortageLabel.textColor = UchicockStyle.labelTextColorLight
                shortageLabel.font = UIFont.systemFont(ofSize: 14.0)
            }
            
            self.separatorInset = UIEdgeInsets(top: 0, left: 78, bottom: 0, right: 0)
        }
    }
    
}
