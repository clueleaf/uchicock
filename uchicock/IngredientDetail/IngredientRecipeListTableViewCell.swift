//
//  IngredientRecipeListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class IngredientRecipeListTableViewCell: UITableViewCell {

    var photo = UIImageView()
    var recipeName = UILabel()
    var favorites = UILabel()
    var shortage = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = UIScreen.main.bounds.size.width
        
        photo = UIImageView(frame: CGRect(x: 0, y: 0, width: 69, height: 69))
        photo.contentMode = UIView.ContentMode.scaleAspectFill
        photo.image = nil
        photo.clipsToBounds = true
        self.addSubview(photo)
        
        recipeName = UILabel(frame: CGRect(x: 77, y: 8, width: width - 173, height: 21))
        recipeName.text = ""
        recipeName.font = UIFont.systemFont(ofSize: 17)
        recipeName.textColor = Style.labelTextColor
        recipeName.backgroundColor = Style.basicBackgroundColor
        recipeName.clipsToBounds = true
        self.addSubview(recipeName)
        
        favorites = UILabel(frame: CGRect(x: width - 88, y: 8, width: 60, height: 21))
        favorites.text = ""
        favorites.font = UIFont.systemFont(ofSize: 20)
        favorites.textColor = Style.secondaryColor
        favorites.backgroundColor = Style.basicBackgroundColor
        self.addSubview(favorites)
        
        shortage = UILabel(frame: CGRect(x: 77, y: 34, width: width - 105, height: 21))
        shortage.text = ""
        shortage.font = UIFont.systemFont(ofSize: 12)
        shortage.lineBreakMode = .byTruncatingMiddle
        shortage.textColor = Style.labelTextColor
        shortage.backgroundColor = Style.basicBackgroundColor
        shortage.clipsToBounds = true
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
