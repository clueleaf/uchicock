//
//  RecipeDeleteTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeDetailDeleteTableViewCell: UITableViewCell {

    @IBOutlet weak var delete: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        delete.textColor = FlatRed()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
