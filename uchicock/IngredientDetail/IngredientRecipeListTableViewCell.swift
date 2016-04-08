//
//  IngredientRecipeListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class IngredientRecipeListTableViewCell: UITableViewCell {

    var recipeName = UILabel()
    var favorites = UILabel()
    var shortage = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = self.bounds.size.width;

        recipeName = UILabel(frame: CGRectMake(8, 8, width - 104, 21))
        recipeName.text = ""
        recipeName.font = UIFont.systemFontOfSize(17)
        self.addSubview(recipeName)
        
        favorites = UILabel(frame: CGRectMake(width - 88, 8, 60, 21))
        favorites.text = "☆☆☆"
        favorites.font = UIFont.systemFontOfSize(20)
        favorites.textColor = FlatSkyBlue()
        self.addSubview(favorites)
        
        shortage = UILabel(frame: CGRectMake(8, 39, width - 16, 21))
        shortage.text = ""
        shortage.font = UIFont.systemFontOfSize(12)
        self.addSubview(shortage)
    }

    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
