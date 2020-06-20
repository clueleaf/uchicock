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
    
    var isDuplicated = false
    var shouldDisplayStock = true
    var isNameTextViewSelectable = false

    var recipeIngredient : RecipeIngredientBasic? {
        didSet{
            guard recipeIngredient != nil else { return }

            stockLabel.layer.cornerRadius = 10.5
            stockLabel.clipsToBounds = true
            
            if shouldDisplayStock {
                stockLabel.isHidden = false
                stockLabel.layer.borderWidth = 1
                stockLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
                if recipeIngredient!.stockFlag{
                    stockLabel.text = "在庫あり"
                    stockLabel.textColor = UchicockStyle.labelTextColorOnBadge
                    stockLabel.layer.backgroundColor = UchicockStyle.primaryColor.cgColor
                    ingredientNameTextView.textColor = UchicockStyle.labelTextColor
                    amountLabel.textColor = UchicockStyle.labelTextColor
                }else{
                    stockLabel.text = "在庫なし"
                    stockLabel.textColor = UchicockStyle.primaryColor
                    stockLabel.layer.backgroundColor = UIColor.clear.cgColor
                    ingredientNameTextView.textColor = UchicockStyle.labelTextColorLight
                    amountLabel.textColor = UchicockStyle.labelTextColorLight
                }
                ingredientNameTextView.text = recipeIngredient!.ingredientName
            }else{
                stockLabel.isHidden = true
                if isDuplicated {
                    ingredientNameTextView.textColor = UchicockStyle.alertColor
                    ingredientNameTextView.text = "[重複]" + recipeIngredient!.ingredientName
                }else{
                    ingredientNameTextView.textColor = UchicockStyle.labelTextColor
                    ingredientNameTextView.text = recipeIngredient!.ingredientName
                }
                amountLabel.textColor = UchicockStyle.labelTextColor
            }
            
            ingredientNameTextView.clipsToBounds = true
            ingredientNameTextView.isScrollEnabled = false
            ingredientNameTextView.textContainerInset = .zero
            ingredientNameTextView.textContainer.lineFragmentPadding = 0
            ingredientNameTextView.font = UIFont.systemFont(ofSize: 15.0)
            ingredientNameTextView.textContainer.maximumNumberOfLines = 1
            ingredientNameTextView.textContainer.lineBreakMode = .byTruncatingTail
            
            if isNameTextViewSelectable{
                ingredientNameTextView.isSelectable = true
                ingredientNameTextView.isUserInteractionEnabled = true
            }else{
                ingredientNameTextView.isSelectable = false
                ingredientNameTextView.isUserInteractionEnabled = false
            }

            alcoholIconImage.tintColor = UchicockStyle.primaryColor
            if recipeIngredient!.category == 0{
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 13
            }else{
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
            
            optionLabel.textColor = UchicockStyle.primaryColor
            optionLabel.layer.cornerRadius = 10.5
            optionLabel.clipsToBounds = true
            optionLabel.layer.borderWidth = 1
            optionLabel.layer.backgroundColor = UIColor.clear.cgColor
            if recipeIngredient!.mustFlag{
                optionLabel.text = ""
                optionLabel.layer.borderColor = UIColor.clear.cgColor
            }else{
                optionLabel.text = "オプション"
                optionLabel.layer.borderColor = UchicockStyle.primaryColor.cgColor
            }

            amountLabel.text = recipeIngredient!.amount
            amountLabel.clipsToBounds = true
        }
    }
}
