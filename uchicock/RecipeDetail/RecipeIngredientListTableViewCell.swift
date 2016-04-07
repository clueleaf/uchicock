//
//  IngredientListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/13.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeIngredientListTableViewCell: UITableViewCell {

    var ingredientName = UILabel()
    var option = UILabel()
    var stock = UILabel()
    var amount = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ingredientName = UILabel(frame: CGRectMake(10, 5, 300, 21))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFontOfSize(17)
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRectMake(10, 35, 70, 20))
        option.text = ""
        option.font = UIFont.systemFontOfSize(14)
        option.textColor = FlatGrayDark()
        self.addSubview(option)
        
        stock = UILabel(frame: CGRectMake(80, 35, 70, 20))
        stock.text = ""
        stock.font = UIFont.systemFontOfSize(14)
        stock.textColor = FlatGrayDark()
        self.addSubview(stock)
        
        amount = UILabel(frame: CGRectMake(150, 35, 200, 21))
        amount.text = ""
        amount.font = UIFont.systemFontOfSize(17)
        self.addSubview(amount)
    }
    
//    var recipeIngredient: RecipeIngredientLink = RecipeIngredientLink(){
//        didSet{
//            ingredientName.text = recipeIngredient.ingredient.ingredientName
//
//            if recipeIngredient.mustFlag{
//                option.text = ""
//                option.textColor = FlatBlack()
//                option.backgroundColor = UIColor.clearColor()
//            }else{
//                option.text = "オプション"
//                option.textColor = FlatBlack()
//                option.backgroundColor = FlatWhiteDark()
//            }
//            option.layer.cornerRadius = 4
//            option.clipsToBounds = true
//
//            if recipeIngredient.ingredient.stockFlag {
//                stock.text = "在庫あり"
//                stock.textColor = FlatWhite()
//                stock.backgroundColor = FlatSkyBlueDark()
//                ingredientName.textColor = FlatBlack()
//                amount.textColor = FlatBlack()
//            }else{
//                stock.text = "在庫なし"
//                stock.textColor = FlatBlack()
//                stock.backgroundColor = FlatWhiteDark()
//                ingredientName.textColor = FlatGrayDark()
//                amount.textColor = FlatGrayDark()
//            }
//            stock.layer.cornerRadius = 4
//            stock.clipsToBounds = true
//
//            amount.text = recipeIngredient.amount
//        }
//    }
//    
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
