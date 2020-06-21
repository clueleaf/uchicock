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
    
    var ingredient: IngredientSuggestBasic? = nil{
        didSet{
            guard ingredient != nil else { return }
            ingredientName.text = ingredient!.name
            alcoholIconImage.tintColor = UchicockStyle.primaryColor
            alcoholIconImage.isHidden = ingredient!.category != 0
            alcoholIconImageWidthConstraint.constant = ingredient!.category == 0 ? 13 : 0
        }
    }
}
