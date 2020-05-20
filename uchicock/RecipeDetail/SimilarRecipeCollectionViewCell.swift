//
//  SimilarRecipeCollectionViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class SimilarRecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var recipeNameButton: UIButton!
    var recipeId = ""
    
    var recipeName : String = String(){
        didSet{
            recipeNameButton.setTitle(recipeName, for: .normal)
            recipeNameButton.layer.cornerRadius = recipeNameButton.frame.size.height / 2
            recipeNameButton.clipsToBounds = true
        }
    }    
}
