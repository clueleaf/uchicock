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
    
    var ingredient: IngredientBasic? = nil{
        didSet{
            guard ingredient != nil else { return }
            
            ingredientName.text = ingredient!.name
            
            stockLabel.backgroundColor = UIColor.clear
            stockLabel.layer.borderWidth = 1
            if ingredient!.stockFlag{
                stockLabel.text = "在庫あり"
                stockLabel.textColor = UchicockStyle.labelTextColorOnBadge
                stockLabel.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                stockLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
            }else{
                stockLabel.text = "在庫なし"
                stockLabel.textColor = UchicockStyle.primaryColor
                stockLabel.layer.backgroundColor = UIColor.clear.cgColor
                stockLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
            }
            
            alcoholIconImage.tintColor = UchicockStyle.primaryColor
            if ingredient!.category == 0{
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 13
            }else{
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
            
            stockLabel.layer.cornerRadius = 10.5
            stockLabel.clipsToBounds = true
            stockLabel.textAlignment = NSTextAlignment.center
        }
    }
}
