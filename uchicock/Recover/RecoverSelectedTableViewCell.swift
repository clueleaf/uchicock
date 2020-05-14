//
//  RecoverSelectedTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-14.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class RecoverSelectedTableViewCell: UITableViewCell {

    @IBOutlet weak var recoverSelectedLabel: UILabel!
    
    var selectedRecipeNum : Int = Int() {
        didSet{
            recoverSelectedLabel.text = "選択した" + String(selectedRecipeNum) + "レシピのみを復元"
            if selectedRecipeNum == 0{
                recoverSelectedLabel.textColor = UchicockStyle.labelTextColorLight
            }else{
                recoverSelectedLabel.textColor = UchicockStyle.primaryColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
