//
//  IngredientMemoTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientMemoTableViewCell: UITableViewCell {

    @IBOutlet weak var memo: UILabel!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            memo.text = ingredient.memo
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
