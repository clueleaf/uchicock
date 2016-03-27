//
//  RecipeMethodTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeDetailMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var method: UISegmentedControl!
    
    var recipeMethod: Int = Int(){
        didSet{
            if recipeMethod >= 0 && recipeMethod < 5 {
                method.selectedSegmentIndex = recipeMethod
            } else {
                method.selectedSegmentIndex = 4
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
