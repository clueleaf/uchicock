//
//  IngredientStockTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientDetailStockTableViewCell: UITableViewCell {

    @IBOutlet weak var stock: UISwitch!
    
    var ingredientStock: Bool = Bool(){
        didSet{
            stock.on = ingredientStock
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
