//
//  RecoverAllTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverAllTableViewCell: UITableViewCell {

    @IBOutlet weak var recoverAll: UILabel!
    
    var recoverableRecipeNum : Int = Int() {
        didSet{
            recoverAll.text = "復元できる" + String(recoverableRecipeNum) + "レシピを全て復元"
            if recoverableRecipeNum == 0{
                recoverAll.textColor = UchicockStyle.labelTextColorLight
            }else{
                recoverAll.textColor = UchicockStyle.primaryColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
