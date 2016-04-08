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
        let width = self.bounds.size.width;

        ingredientName = UILabel(frame: CGRectMake(10, 5, width - 40, 21))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFontOfSize(17)
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRectMake(10, 35, 70, 20))
        option.text = ""
        option.font = UIFont.systemFontOfSize(14)
        option.textColor = FlatGrayDark()
        self.addSubview(option)

        amount = UILabel(frame: CGRectMake(80, 35, width - 115, 21))
        amount.text = ""
        amount.font = UIFont.systemFontOfSize(17)
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
