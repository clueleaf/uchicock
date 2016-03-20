//
//  IngredientListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/13.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeIngredientListTableViewCell: UITableViewCell {

    @IBOutlet weak var option: UILabel!
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    var recipeIngredient: RecipeIngredientLink = RecipeIngredientLink(){
        didSet{
            ingredientName.text = recipeIngredient.ingredient.ingredientName
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
