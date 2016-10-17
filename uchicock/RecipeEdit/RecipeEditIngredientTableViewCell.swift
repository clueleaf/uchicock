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
        let width = UIScreen.main.bounds.size.width

        ingredientName = UILabel(frame: CGRectMake(8, 8, width - 43, 21))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRectMake(5, 33, 50, 21))
        option.text = ""
        option.font = UIFont.systemFont(ofSize: 10)
        option.textColor = FlatGrayDark()
        self.addSubview(option)

        amount = UILabel(frame: CGRectMake(60, 33, width - 95, 21))
        amount.text = ""
        amount.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(amount)
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
