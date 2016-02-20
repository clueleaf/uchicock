//
//  RecipeListItemTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var favoritesContainer: UIView!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var shortage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
