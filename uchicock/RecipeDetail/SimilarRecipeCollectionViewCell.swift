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
    
    var id: String = String(){
        didSet{
            if let image = ImageUtil.loadImageOf(recipeId: id, forList: true){
                recipeImageView.image = image
                recipeImageView.isHidden = false
                noImageImageView.isHidden = true
            }else{
                noImageImageView.tintColor = UchicockStyle.noPhotoColor
                recipeImageView.isHidden = true
                noImageImageView.isHidden = false
            }
        }
    }
    
    var recipeName : String = String(){
        didSet{
            recipeNameLabel.text = recipeName
            backgroundContainer.layer.cornerRadius = 15
            backgroundContainer.clipsToBounds = true
            highlightView.backgroundColor = UIColor.clear
        }
    }
    
    var isBookMarked : Bool = Bool(){
        didSet{
            bookmarkBackImage.tintColor = UchicockStyle.primaryColor
            bookmarkFrontImage.tintColor = UchicockStyle.primaryColor
            bookmarkBackImage.isHidden = isBookMarked ? false : true
            bookmarkFrontImage.isHidden = isBookMarked ? false : true
        }
    }
}
