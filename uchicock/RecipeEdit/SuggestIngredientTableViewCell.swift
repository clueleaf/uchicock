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
    
    var name: String = String(){
        didSet{
            ingredientName.text = name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
