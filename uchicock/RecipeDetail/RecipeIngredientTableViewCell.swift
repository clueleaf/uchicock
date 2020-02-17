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
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var ingredientId: String? = nil
    
    var stock: Bool? = Bool(){
        didSet{
            stockLabel.backgroundColor = UIColor.clear
            stockLabel.layer.cornerRadius = 10.5
            stockLabel.clipsToBounds = true
            stockLabel.textAlignment = NSTextAlignment.center
            if let stock = stock{
                stockLabel.layer.borderWidth = 1
                if stock{
                    stockLabel.isHidden = false
                    stockLabel.text = "在庫あり"
                    stockLabel.textColor = Style.labelTextColorOnBadge
                    stockLabel.layer.backgroundColor = Style.primaryColor.cgColor
                    stockLabel.layer.borderColor = Style.primaryColor.cgColor
                    ingredientNameLabel.textColor = Style.labelTextColor
                    amountLabel.textColor = Style.labelTextColor
                }else{
                    stockLabel.isHidden = false
                    stockLabel.text = "在庫なし"
                    stockLabel.textColor = Style.primaryColor
                    stockLabel.layer.backgroundColor = UIColor.clear.cgColor
                    stockLabel.layer.borderColor = Style.primaryColor.cgColor
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

    var category = Int(){
        didSet{
            alcoholIconImage.tintColor = Style.primaryColor
            if category == 0{
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 13
            }else{
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
        }
    }

    var ingredientName = String(){
        didSet{
            ingredientNameLabel.text = ingredientName
            ingredientNameLabel.clipsToBounds = true
        }
    }
    
    var isOption = Bool(){
        didSet{
            optionLabel.backgroundColor = UIColor.clear
            optionLabel.textColor = Style.primaryColor
            optionLabel.layer.cornerRadius = 10.5
            optionLabel.clipsToBounds = true
            optionLabel.textAlignment = NSTextAlignment.center
            optionLabel.layer.borderWidth = 1
            if isOption{
                optionLabel.text = "オプション"
                optionLabel.layer.backgroundColor = UIColor.clear.cgColor
                optionLabel.layer.borderColor = Style.primaryColor.cgColor
            }else{
                optionLabel.text = ""
                optionLabel.layer.backgroundColor = UIColor.clear.cgColor
                optionLabel.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    var amountText = String(){
        didSet{
            amountLabel.text = amountText
            amountLabel.clipsToBounds = true
        }
    }
    
}
