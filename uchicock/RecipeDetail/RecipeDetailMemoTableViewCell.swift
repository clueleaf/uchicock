//
//  RecipeMemoTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/21.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeDetailMemoTableViewCell: UITableViewCell {

    @IBOutlet weak var memo: UILabel!
    
    var recipeMemo: String = String(){
        didSet{
            memo.text = recipeMemo
            memo.textColor = FlatGrayDark()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
