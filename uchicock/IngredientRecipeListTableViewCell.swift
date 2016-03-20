//
//  IngredientRecipeListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientRecipeListTableViewCell: UITableViewCell {

    @IBOutlet weak var option: UILabel!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    var recipeIngredient: RecipeIngredientLink = RecipeIngredientLink(){
        didSet{
            recipeName.text = recipeIngredient.recipe.recipeName
            amount.text = recipeIngredient.amount
            if recipeIngredient.mustFlag{
                option.text = ""
                option.backgroundColor = UIColor.clearColor()
            }else{
                option.text = "オプション"
                option.backgroundColor = UIColor.grayColor()
            }
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
