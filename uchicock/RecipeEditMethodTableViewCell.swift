//
//  RecipeEditMethodTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeEditMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var method: UISegmentedControl!

    var recipe: Recipe = Recipe(){
        didSet{
            if recipe.recipeName == "" {
                method.selectedSegmentIndex = 0
            }else{
                switch recipe.method{
                case 0:
                    method.selectedSegmentIndex = 0
                case 1:
                    method.selectedSegmentIndex = 1
                case 2:
                    method.selectedSegmentIndex = 2
                case 3:
                    method.selectedSegmentIndex = 3
                case 4:
                    method.selectedSegmentIndex = 4
                default:
                    method.selectedSegmentIndex = 4
                }
            }
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
