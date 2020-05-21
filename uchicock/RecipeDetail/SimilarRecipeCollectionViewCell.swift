//
//  SimilarRecipeCollectionViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class SimilarRecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var recipeNameLabel: UILabel!
    
    var recipeName : String = String(){
        didSet{
            recipeNameLabel.text = recipeName
            recipeNameLabel.layer.cornerRadius = recipeNameLabel.frame.size.height / 2
            recipeNameLabel.clipsToBounds = true
        }
    }    
}
