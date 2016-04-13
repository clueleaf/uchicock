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

    @IBOutlet weak var recipeNum: UILabel!
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var stock: UISwitch!
    
    var ingredient: Ingredient = Ingredient(){
        didSet{
            if ingredient.recipeIngredients.count == 0{
                recipeNum.text = String(ingredient.recipeIngredients.count)
                recipeNum.backgroundColor = FlatGray()
            }else if ingredient.recipeIngredients.count > 0 && ingredient.recipeIngredients.count < 99 {
                recipeNum.text = String(ingredient.recipeIngredients.count)
                recipeNum.backgroundColor = FlatSkyBlue()
            }else{
                recipeNum.text = "99+"
                recipeNum.backgroundColor = FlatSkyBlue()
            }
            recipeNum.textColor = FlatWhite()
            recipeNum.layer.cornerRadius = 10
            recipeNum.clipsToBounds = true
            recipeNum.textAlignment = NSTextAlignment.Center

            ingredientName.text = ingredient.ingredientName
            stockLabel.textColor = FlatGrayDark()
            stock.on = ingredient.stockFlag
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - IBAction
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
