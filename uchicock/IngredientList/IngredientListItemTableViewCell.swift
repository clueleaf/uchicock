//
//  IngredientListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class IngredientListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var stock: UISwitch!
    @IBOutlet weak var stockLabel: UILabel!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            ingredientName.text = ingredient.ingredientName
            stock.on = ingredient.stockFlag
            stockLabel.textColor = FlatGrayDark()
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

    @IBAction func stockSwitchTapped(sender: UISwitch) {
        if sender.on{
            let realm = try! Realm()
            try! realm.write {
                ingredient.stockFlag = true
            }
        }else{
            let realm = try! Realm()
            try! realm.write {
                ingredient.stockFlag = false
            }
        }
    }
}
