//
//  RecoverDescriptionTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var recoverTarget: CircularCheckbox!
    @IBOutlet weak var nonRecoverTarget: CircularCheckbox!
    @IBOutlet weak var unableRecover: CircularCheckbox!
    @IBOutlet weak var recoverableNumberLabel: CustomLabel!
    
    var recoverableRecipeNum = 0
    var sampleRecipeNum: Int = Int(){
        didSet{
            recoverableNumberLabel.text = String(sampleRecipeNum) + "レシピ中" + String(recoverableRecipeNum) + "レシピを復元できます。"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recoverTarget.stateChangeAnimation = .expand
        recoverTarget.isEnabled = false
        recoverTarget.setCheckState(.checked, animated: true)
        recoverTarget.boxLineWidth = 1.0
        recoverTarget.secondaryTintColor = UchicockStyle.primaryColor
        recoverTarget.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        nonRecoverTarget.stateChangeAnimation = .expand
        nonRecoverTarget.isEnabled = false
        nonRecoverTarget.setCheckState(.unchecked, animated: true)
        nonRecoverTarget.boxLineWidth = 1.0
        nonRecoverTarget.secondaryTintColor = UchicockStyle.primaryColor
        nonRecoverTarget.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        unableRecover.stateChangeAnimation = .expand
        unableRecover.isEnabled = false
        unableRecover.setCheckState(.mixed, animated: true)
        unableRecover.tintColor = UchicockStyle.labelTextColorLight
        unableRecover.boxLineWidth = 1.0
        unableRecover.secondaryTintColor = UchicockStyle.primaryColor
        unableRecover.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
    }
}
