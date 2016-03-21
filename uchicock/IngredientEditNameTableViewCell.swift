//
//  IngredientEditNameTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientEditNameTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var ingredientName: UITextField!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            ingredientName.text = ingredient.ingredientName
            ingredientName.delegate = self
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

    func textFieldShouldReturn(textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        return true
    }

}
