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
    @IBOutlet weak var ingredientNameTextView: CustomTextView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var ingredientId: String? = nil
    var isDuplicated = false

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
                    stockLabel.textColor = UchicockStyle.labelTextColorOnBadge
                    stockLabel.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                    stockLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
                    ingredientNameTextView.textColor = UchicockStyle.labelTextColor
                    amountLabel.textColor = UchicockStyle.labelTextColor
                }else{
                    stockLabel.isHidden = false
                    stockLabel.text = "在庫なし"
                    stockLabel.textColor = UchicockStyle.primaryColor
                    stockLabel.layer.backgroundColor = UIColor.clear.cgColor
                    stockLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
                    ingredientNameTextView.textColor = UchicockStyle.labelTextColorLight
                    amountLabel.textColor = UchicockStyle.labelTextColorLight
                }
            }else{
                stockLabel.isHidden = true
                if isDuplicated {
                    ingredientNameTextView.textColor = UchicockStyle.deleteColor
                }else{
                    ingredientNameTextView.textColor = UchicockStyle.labelTextColor
                }
                amountLabel.textColor = UchicockStyle.labelTextColor
            }
        }
    }

    var category = Int(){
        didSet{
            alcoholIconImage.tintColor = UchicockStyle.primaryColor
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
            if isDuplicated {
                ingredientNameTextView.text = "[重複]" + ingredientName
            }else{
                ingredientNameTextView.text = ingredientName
            }
            ingredientNameTextView.backgroundColor = UIColor.clear
            ingredientNameTextView.clipsToBounds = true
            ingredientNameTextView.isScrollEnabled = false
            ingredientNameTextView.textContainerInset = .zero
            ingredientNameTextView.textContainer.lineFragmentPadding = 0
            ingredientNameTextView.font = UIFont.systemFont(ofSize: 15.0)
            ingredientNameTextView.textContainer.maximumNumberOfLines = 1
            ingredientNameTextView.textContainer.lineBreakMode = .byTruncatingTail
        }
    }
    
    var isOption = Bool(){
        didSet{
            optionLabel.backgroundColor = UIColor.clear
            optionLabel.textColor = UchicockStyle.primaryColor
            optionLabel.layer.cornerRadius = 10.5
            optionLabel.clipsToBounds = true
            optionLabel.textAlignment = NSTextAlignment.center
            optionLabel.layer.borderWidth = 1
            if isOption{
                optionLabel.text = "オプション"
                optionLabel.layer.backgroundColor = UIColor.clear.cgColor
                optionLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
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
