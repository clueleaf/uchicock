//
//  RecipeEditNameTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeEditNameTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var recipeName: UITextField!
    
    var recipe: Recipe = Recipe(){
        didSet{
            recipeName.text = recipe.recipeName
            recipeName.delegate = self
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
        recipeName.resignFirstResponder()
        return true
    }

}
