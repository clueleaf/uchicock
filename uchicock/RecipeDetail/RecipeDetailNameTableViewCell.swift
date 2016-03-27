//
//  RecipeNameTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeDetailNameTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    
    var recipe: Recipe = Recipe(){
        didSet{
            if recipe.imageData != nil{
                photo.image = UIImage(data: recipe.imageData!)
                //レシピ削除のバグに対するワークアラウンド
                if photo.image == nil{
                    photo.image = UIImage(named: "no-photo")
                }
            }else{
                photo.image = UIImage(named: "no-photo")
            }

            recipeName.text = recipe.recipeName
            
            self.selectionStyle = .None
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
