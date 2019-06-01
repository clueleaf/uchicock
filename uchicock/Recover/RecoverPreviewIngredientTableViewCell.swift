//
//  RecoverPreviewIngredientTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverPreviewIngredientTableViewCell: UITableViewCell {

    var ingredientName = UILabel()
    var option = UILabel()
    var amount = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = UIScreen.main.bounds.size.width
        
        ingredientName = UILabel(frame: CGRect(x: 8, y: 8, width: width - 43, height: 21))
        ingredientName.text = ""
        ingredientName.font = UIFont.systemFont(ofSize: 15)
        ingredientName.textColor = Style.labelTextColor
        self.addSubview(ingredientName)
        
        option = UILabel(frame: CGRect(x: 5, y: 35, width: 50, height: 21))
        option.text = ""
        option.font = UIFont.systemFont(ofSize: 10)
        option.textColor = Style.labelTextColorOnDisableBadge
        self.addSubview(option)
        
        amount = UILabel(frame: CGRect(x: 60, y: 35, width: width - 100, height: 21))
        amount.text = ""
        amount.font = UIFont.systemFont(ofSize: 12)
        amount.textColor = Style.labelTextColor
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
