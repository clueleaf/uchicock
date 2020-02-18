//
//  IngredientRecommendTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/22.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class IngredientRecommendTableViewCell: UITableViewCell {

    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var ingredientName: String? = String(){
        didSet{
            ingredientNameLabel.text = ingredientName
        }
    }

    var ingredientDescription: String? = String(){
        didSet{
            descriptionLabel.textColor = Style.primaryColor
            descriptionLabel.text = ingredientDescription
        }
    }
    
    var category: Int? = Int(){
        didSet{
            alcoholIconImage.tintColor = Style.primaryColor
            if category == 0 {
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 17
            }else{
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
        }
    }
    
}
