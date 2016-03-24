//
//  RecipeEditIngredientListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeEditIngredientTableViewCell: UITableViewCell {

    var ingredientName = UILabel()
    var option = UILabel()
    var amount = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        //First Call Super
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ingredientName = UILabel(frame: CGRectMake(10, 10, 300, 21))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFontOfSize(17)
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRectMake(10, 40, 70, 20))
        option.text = ""
        option.font = UIFont.systemFontOfSize(14)
        option.textColor = UIColor.grayColor()
        self.addSubview(option)

        amount = UILabel(frame: CGRectMake(100, 40, 200, 21))
        amount.text = ""
        amount.font = UIFont.systemFontOfSize(17)
        self.addSubview(amount)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
