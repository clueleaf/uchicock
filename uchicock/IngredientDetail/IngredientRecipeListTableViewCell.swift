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

    var photo = UIImageView()
    var recipeName = UILabel()
    var favorites = UILabel()
    var shortage = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = UIScreen.mainScreen().bounds.size.width
        
        photo = UIImageView(frame: CGRectMake(0, 0, 69, 69))
        photo.contentMode = UIViewContentMode.ScaleAspectFill
        photo.image = nil
        photo.clipsToBounds = true
        self.addSubview(photo)
        
        recipeName = UILabel(frame: CGRectMake(77, 8, width - 173, 21))
        recipeName.text = ""
        recipeName.font = UIFont.systemFontOfSize(17)
        self.addSubview(recipeName)
        
        favorites = UILabel(frame: CGRectMake(width - 88, 8, 60, 21))
        favorites.text = "☆☆☆"
        favorites.font = UIFont.systemFontOfSize(20)
        favorites.textColor = FlatSkyBlue()
        self.addSubview(favorites)
        
        shortage = UILabel(frame: CGRectMake(77, 39, width - 105, 21))
        shortage.text = ""
        shortage.font = UIFont.systemFontOfSize(12)
        shortage.lineBreakMode = .ByTruncatingMiddle
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
