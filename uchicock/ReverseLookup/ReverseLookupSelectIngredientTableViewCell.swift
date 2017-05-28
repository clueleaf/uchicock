//
//  ReverseLookupSelectIngredientTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class ReverseLookupSelectIngredientTableViewCell: UITableViewCell {

    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var ingredientName: UILabel!

    var ingredient: Ingredient = Ingredient(){
        didSet{
            ingredientName.text = ingredient.ingredientName
            ingredientName.textColor = Style.labelTextColor
            ingredientName.backgroundColor = Style.basicBackgroundColor
            ingredientName.clipsToBounds = true
            
            stockLabel.backgroundColor = UIColor.clear
            if ingredient.stockFlag{
                stockLabel.text = "在庫あり"
                stockLabel.textColor = Style.labelTextColorOnBadge
                stockLabel.layer.backgroundColor = Style.secondaryColor.cgColor
            }else{
                stockLabel.text = "在庫なし"
                stockLabel.textColor = Style.labelTextColorOnDisableBadge
                stockLabel.layer.backgroundColor = Style.badgeDisableBackgroundColor.cgColor
            }
            stockLabel.layer.cornerRadius = 4
            stockLabel.clipsToBounds = true
            stockLabel.textAlignment = NSTextAlignment.center
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
