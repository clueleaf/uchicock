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
        let width = UIScreen.main.bounds.size.width
        
        photo = UIImageView(frame: CGRect(x: 0, y: 0, width: 69, height: 69))
        photo.contentMode = UIViewContentMode.scaleAspectFill
        photo.image = nil
        photo.clipsToBounds = true
        self.addSubview(photo)
        
        recipeName = UILabel(frame: CGRect(x: 77, y: 8, width: width - 173, height: 21))
        recipeName.text = ""
        recipeName.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(recipeName)
        
        favorites = UILabel(frame: CGRect(x: width - 88, y: 8, width: 60, height: 21))
        favorites.text = "☆☆☆"
        favorites.font = UIFont.systemFont(ofSize: 20)
        favorites.textColor = FlatSkyBlueDark()
        self.addSubview(favorites)
        
        shortage = UILabel(frame: CGRect(x: 77, y: 39, width: width - 105, height: 21))
        shortage.text = ""
        shortage.font = UIFont.systemFont(ofSize: 12)
        shortage.lineBreakMode = .byTruncatingMiddle
        self.addSubview(shortage)
    }

    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
