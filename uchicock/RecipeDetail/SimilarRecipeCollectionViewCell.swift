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
    
    var recipeName : String = String(){
        didSet{
            recipeNameLabel.text = recipeName
            backgroundContainer.layer.cornerRadius = 15
            recipeImageView.clipsToBounds = true
            recipeImageView.layer.cornerRadius = 35
            // テンプレートのnoImage画像の大きさ調整がうまくいかない問題へのワークアラウンド
            noImageImageView.tintColor = UchicockStyle.noPhotoColor

        }
    }    
}
