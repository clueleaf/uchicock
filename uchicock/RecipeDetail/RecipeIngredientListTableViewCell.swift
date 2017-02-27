//
//  IngredientListTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/13.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeIngredientListTableViewCell: UITableViewCell {

    var ingredientName = UILabel()
    var option = UILabel()
    var stock = UILabel()
    var amount = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = UIScreen.main.bounds.size.width

        ingredientName = UILabel(frame: CGRect(x: 8, y: 8, width: width - 43, height: 21))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRect(x: 5, y: 33, width: 50, height: 21))
        option.text = ""
        option.font = UIFont.systemFont(ofSize: 10)
        option.textColor = Style.labelTextColorLight
        self.addSubview(option)
        
        stock = UILabel(frame: CGRect(x: 60, y: 33, width: 50, height: 21))
        stock.text = ""
        stock.font = UIFont.systemFont(ofSize: 10)
        stock.textColor = Style.labelTextColorLight
        self.addSubview(stock)
        
        amount = UILabel(frame: CGRect(x: 115, y: 33, width: width - 150, height: 21))
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
