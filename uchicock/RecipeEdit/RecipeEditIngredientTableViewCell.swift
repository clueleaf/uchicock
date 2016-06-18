//
//  RecipeEditIngredientListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeEditIngredientTableViewCell: UITableViewCell {

    var ingredientName = UILabel()
    var option = UILabel()
    var amount = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = UIScreen.mainScreen().bounds.size.width

        ingredientName = UILabel(frame: CGRectMake(8, 8, width - 43, 21))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFontOfSize(15)
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRectMake(5, 35, 50, 21))
        option.text = ""
        option.font = UIFont.systemFontOfSize(10)
        option.textColor = FlatGrayDark()
        self.addSubview(option)

        amount = UILabel(frame: CGRectMake(60, 35, width - 95, 21))
        amount.text = ""
        amount.font = UIFont.systemFontOfSize(12)
        self.addSubview(amount)
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
