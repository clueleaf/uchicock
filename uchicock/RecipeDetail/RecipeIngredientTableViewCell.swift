//
//  RecipeIngredientTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/20.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class RecipeIngredientTableViewCell: UITableViewCell {

    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var ingredientId: String? = nil
    
    var stock: Bool? = Bool(){
        didSet{
            stockLabel.backgroundColor = UIColor.clear
            stockLabel.layer.cornerRadius = 4
            stockLabel.clipsToBounds = true
            stockLabel.textAlignment = NSTextAlignment.center
            if let stock = stock{
                if stock{
                    stockLabel.isHidden = false
                    stockLabel.text = "在庫あり"
                    stockLabel.textColor = Style.labelTextColorOnBadge
                    stockLabel.layer.backgroundColor = Style.secondaryColor.cgColor
                    ingredientNameLabel.textColor = Style.labelTextColor
                    amountLabel.textColor = Style.labelTextColor
                }else{
                    stockLabel.isHidden = false
                    stockLabel.text = "在庫なし"
                    stockLabel.textColor = Style.labelTextColorOnDisableBadge
                    stockLabel.layer.backgroundColor = Style.badgeDisableBackgroundColor.cgColor
                    ingredientNameLabel.textColor = Style.labelTextColorLight
                    amountLabel.textColor = Style.labelTextColorLight
                }
            }else{
                stockLabel.isHidden = true
                ingredientNameLabel.textColor = Style.labelTextColor
                amountLabel.textColor = Style.labelTextColor
            }
        }
    }
    
    var ingredientName = String(){
        didSet{
            ingredientNameLabel.text = ingredientName
            ingredientNameLabel.backgroundColor = Style.basicBackgroundColor
            ingredientNameLabel.clipsToBounds = true
        }
    }
    
    var isOption = Bool(){
        didSet{
            optionLabel.backgroundColor = UIColor.clear
            optionLabel.textColor = Style.labelTextColorOnDisableBadge
            optionLabel.layer.cornerRadius = 4
            optionLabel.clipsToBounds = true
            optionLabel.textAlignment = NSTextAlignment.center
            if isOption{
                optionLabel.text = "オプション"
                optionLabel.layer.backgroundColor = Style.badgeDisableBackgroundColor.cgColor
            }else{
                optionLabel.text = ""
                optionLabel.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
    }
    
    var amountText = String(){
        didSet{
            amountLabel.text = amountText
            amountLabel.backgroundColor = Style.basicBackgroundColor
            amountLabel.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
