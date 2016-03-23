//
//  RecipeEditIngredientListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeEditIngredientTableViewCell: UITableViewCell {

    var ingredientName = UILabel()
    var option = UILabel()
    var amount = UILabel()
    
//    var recipeIngredient: RecipeIngredientLink = RecipeIngredientLink(){
//        didSet{
//            ingredientName.text = recipeIngredient.ingredient.ingredientName
//            amount.text = recipeIngredient.amount
//            if recipeIngredient.mustFlag{
//                option.text = ""
//            }else{
//                option.text = "オプション"
//            }
//        }
//    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        //First Call Super
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ingredientName = UILabel(frame: CGRectMake(10, 2, 300, 15))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFontOfSize(14)
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRectMake(10, 20, 300, 15))
        option.text = ""
        option.font = UIFont.systemFontOfSize(12)
        option.textColor = UIColor.grayColor()
        self.addSubview(option)

        amount = UILabel(frame: CGRectMake(10, 30, 300, 15))
        amount.text = ""
        amount.font = UIFont.systemFontOfSize(12)
        self.addSubview(amount)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
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
