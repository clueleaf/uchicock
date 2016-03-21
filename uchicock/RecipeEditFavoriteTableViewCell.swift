//
//  RecipeEditFavoriteTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeEditFavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    
    var recipe: Recipe = Recipe(){
        didSet{
            if recipe.recipeName == "" {
                //追加
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("☆", forState: .Normal)
                star3.setTitle("☆", forState: .Normal)
            }else{
                switch recipe.favorites{
                case 1:
                    star1.setTitle("★", forState: .Normal)
                    star2.setTitle("☆", forState: .Normal)
                    star3.setTitle("☆", forState: .Normal)
                case 2:
                    star1.setTitle("★", forState: .Normal)
                    star2.setTitle("★", forState: .Normal)
                    star3.setTitle("☆", forState: .Normal)
                case 3:
                    star1.setTitle("★", forState: .Normal)
                    star2.setTitle("★", forState: .Normal)
                    star3.setTitle("★", forState: .Normal)
                default:
                    star1.setTitle("★", forState: .Normal)
                    star2.setTitle("☆", forState: .Normal)
                    star3.setTitle("☆", forState: .Normal)
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

    @IBAction func star1Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("☆", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
    }
    
    @IBAction func star2Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
    }
    
    @IBAction func star3Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("★", forState: .Normal)
    }
    
}
