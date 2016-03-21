//
//  IngredientRecipeListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientRecipeListTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var shortage: UILabel!

    var recipeIngredient: RecipeIngredientLink = RecipeIngredientLink(){
        didSet{
            recipeName.text = recipeIngredient.recipe.recipeName
            
            switch recipeIngredient.recipe.favorites{
            case 1:
                favorites.text = "★☆☆"
            case 2:
                favorites.text = "★★☆"
            case 3:
                favorites.text = "★★★"
            default:
                favorites.text = "★★☆"
            }
            
            shortage.text = "今すぐ作れます！"
            shortage.textColor = UIColor.blueColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
