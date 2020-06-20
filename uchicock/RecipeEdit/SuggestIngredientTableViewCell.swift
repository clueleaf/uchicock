//
//  SuggestIngredientTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/24.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class SuggestIngredientTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientName: CustomLabel!
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var name: String = String(){
        didSet{
            ingredientName.text = name
        }
    }
    
    var category: Int = Int(){
        didSet{
            alcoholIconImage.tintColor = UchicockStyle.primaryColor
            alcoholIconImage.isHidden = category != 0
            alcoholIconImageWidthConstraint.constant = category == 0 ? 13 : 0
        }
    }
}
