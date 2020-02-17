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
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var ingredientName: CustomLabel!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            ingredientName.text = ingredient.ingredientName
            
            stockLabel.backgroundColor = UIColor.clear
            stockLabel.layer.borderWidth = 1
            if ingredient.stockFlag{
                stockLabel.text = "在庫あり"
                stockLabel.textColor = Style.labelTextColorOnBadge
                stockLabel.layer.backgroundColor = Style.primaryColor.cgColor
                stockLabel.layer.borderColor = Style.primaryColor.cgColor
            }else{
                stockLabel.text = "在庫なし"
                stockLabel.textColor = Style.primaryColor
                stockLabel.layer.backgroundColor = UIColor.clear.cgColor
                stockLabel.layer.borderColor = Style.primaryColor.cgColor
            }
            
            alcoholIconImage.tintColor = Style.primaryColor
            if ingredient.category == 0{
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 13
            }else{
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
            
            stockLabel.layer.cornerRadius = 10.5
            stockLabel.clipsToBounds = true
            stockLabel.textAlignment = NSTextAlignment.center
            
            self.separatorInset = UIEdgeInsets(top: 0, left: 66, bottom: 0, right: 0)
        }
    }

}
