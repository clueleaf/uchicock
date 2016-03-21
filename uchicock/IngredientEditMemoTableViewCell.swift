//
//  IngredientEditMemoTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientEditMemoTableViewCell: UITableViewCell {

    @IBOutlet weak var memo: UITextView!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            memo.text = ingredient.memo
            
            memo.layer.masksToBounds = true
            memo.layer.cornerRadius = 5.0
            memo.layer.borderWidth = 1
            memo.layer.borderColor = UIColor.grayColor().CGColor
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