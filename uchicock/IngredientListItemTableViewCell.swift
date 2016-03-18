//
//  IngredientListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var stock: UISwitch!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            ingredientName.text = ingredient.ingredientName
            stock.on = ingredient.stockFlag
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
