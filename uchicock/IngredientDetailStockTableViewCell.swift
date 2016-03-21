//
//  IngredientStockTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientDetailStockTableViewCell: UITableViewCell {

    @IBOutlet weak var stock: UISwitch!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
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
