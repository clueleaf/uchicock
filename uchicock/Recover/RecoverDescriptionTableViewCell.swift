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

        recoverTarget.stateChangeAnimation = .Expand(.Fill)
        recoverTarget.enabled = false
        recoverTarget.setCheckState(.Checked, animated: true)
        recoverTarget.backgroundColor = UIColor.clearColor()
        recoverTarget.tintColor = FlatSkyBlueDark()
        recoverTarget.boxLineWidth = 1.0
        recoverTarget.markType = .Checkmark
        recoverTarget.boxType = .Circle
        
        nonRecoverTarget.stateChangeAnimation = .Expand(.Fill)
        nonRecoverTarget.enabled = false
        nonRecoverTarget.setCheckState(.Unchecked, animated: true)
        nonRecoverTarget.backgroundColor = UIColor.clearColor()
        nonRecoverTarget.tintColor = FlatSkyBlueDark()
        nonRecoverTarget.boxLineWidth = 1.0
        nonRecoverTarget.markType = .Checkmark
        nonRecoverTarget.boxType = .Circle
        
        unableRecover.stateChangeAnimation = .Expand(.Fill)
        unableRecover.enabled = false
        unableRecover.setCheckState(.Mixed, animated: true)
        unableRecover.backgroundColor = UIColor.clearColor()
        unableRecover.tintColor = FlatWhiteDark()
        unableRecover.boxLineWidth = 1.0
        unableRecover.markType = .Checkmark
        unableRecover.boxType = .Circle
}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
