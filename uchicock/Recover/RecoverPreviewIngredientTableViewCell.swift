//
//  RecoverPreviewIngredientTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecoverPreviewIngredientTableViewCell: UITableViewCell {

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
        
        option = UILabel(frame: CGRectMake(5, 35, 50, 21))
        option.text = ""
        option.font = UIFont.systemFont(ofSize: 10)
        option.textColor = FlatGrayDark()
        self.addSubview(option)
        
        amount = UILabel(frame: CGRectMake(60, 35, width - 100, 21))
        amount.text = ""
        amount.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(amount)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
