//
//  SimilarRecipeCollectionViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class SimilarRecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var recipeNameLabel: CustomLabel!
    var recipeId = ""
    
    var recipeName : String = String(){
        didSet{
            recipeNameLabel.backgroundColor = UchicockStyle.basicBackgroundColorLight
            recipeNameLabel.layer.cornerRadius = 10
            recipeNameLabel.clipsToBounds = true
            recipeNameLabel.text = recipeName
            recipeNameLabel.layer.backgroundColor = UchicockStyle.basicBackgroundColorLight.cgColor
        }
    }    
}
