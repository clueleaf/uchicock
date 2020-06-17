//
//  SimilarRecipeCollectionViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class SimilarRecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var noImageImageView: UIImageView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var bookmarkFrontImage: UIImageView!
    @IBOutlet weak var bookmarkBackImage: UIImageView!
    
    
    var recipe: SimilarRecipeBasic? = nil{
        didSet{
            if recipe != nil{
                if let image = ImageUtil.loadImageOf(recipeId: recipe!.id, imageFileName: recipe!.imageFileName, forList: true){
                    recipeImageView.image = image
                    recipeImageView.isHidden = false
                    noImageImageView.isHidden = true
                }else{
                    noImageImageView.tintColor = UchicockStyle.noPhotoColor
                    recipeImageView.isHidden = true
                    noImageImageView.isHidden = false
                }
                
                recipeNameLabel.text = recipe!.name
                backgroundContainer.layer.cornerRadius = 15
                backgroundContainer.clipsToBounds = true
                
                if recipe!.canMake{
                    recipeNameLabel.textColor = UchicockStyle.labelTextColor
                }else{
                    recipeNameLabel.textColor = UchicockStyle.labelTextColorLight
                }
                
                bookmarkBackImage.tintColor = UchicockStyle.primaryColor
                bookmarkFrontImage.tintColor = UchicockStyle.primaryColor
                bookmarkBackImage.isHidden = recipe!.isBookmarked ? false : true
                bookmarkFrontImage.isHidden = recipe!.isBookmarked ? false : true
            }
        }
    }
}
