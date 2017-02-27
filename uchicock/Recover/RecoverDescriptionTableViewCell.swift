//
//  RecoverDescriptionTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework
import M13Checkbox

class RecoverDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var recoverTarget: M13Checkbox!
    @IBOutlet weak var nonRecoverTarget: M13Checkbox!
    @IBOutlet weak var unableRecover: M13Checkbox!
    @IBOutlet weak var recoverableNumberLabel: UILabel!
    
    var recoverableRecipeNum = 0
    var sampleRecipeNum: Int = Int(){
        didSet{
            recoverableNumberLabel.text = String(sampleRecipeNum) + "レシピ中" + String(recoverableRecipeNum) + "レシピを復元できます。"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        recoverTarget.stateChangeAnimation = .expand(.fill)
        recoverTarget.isEnabled = false
        recoverTarget.setCheckState(.checked, animated: true)
        recoverTarget.backgroundColor = UIColor.clear
        recoverTarget.tintColor = Style.secondaryColor
        recoverTarget.boxLineWidth = 1.0
        recoverTarget.markType = .checkmark
        recoverTarget.boxType = .circle
        
        nonRecoverTarget.stateChangeAnimation = .expand(.fill)
        nonRecoverTarget.isEnabled = false
        nonRecoverTarget.setCheckState(.unchecked, animated: true)
        nonRecoverTarget.backgroundColor = UIColor.clear
        nonRecoverTarget.tintColor = Style.secondaryColor
        nonRecoverTarget.boxLineWidth = 1.0
        nonRecoverTarget.markType = .checkmark
        nonRecoverTarget.boxType = .circle
        
        unableRecover.stateChangeAnimation = .expand(.fill)
        unableRecover.isEnabled = false
        unableRecover.setCheckState(.mixed, animated: true)
        unableRecover.backgroundColor = UIColor.clear
        unableRecover.tintColor = Style.badgeDisableBackgroundColor
        unableRecover.boxLineWidth = 1.0
        unableRecover.markType = .checkmark
        unableRecover.boxType = .circle
}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
