//
//  RecoverTargetTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework
import M13Checkbox

class RecoverTargetTableViewCell: UITableViewCell {

    @IBOutlet weak var isTarget: M13Checkbox!
    
    var isRecoverable = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isTarget.stateChangeAnimation = .Expand(.Fill)
        isTarget.backgroundColor = UIColor.clearColor()
        isTarget.boxLineWidth = 1.0
        isTarget.markType = .Checkmark
        isTarget.boxType = .Circle
        if isRecoverable {
            isTarget.enabled = true
            isTarget.setCheckState(.Unchecked, animated: true)
            isTarget.tintColor = FlatSkyBlueDark()
        }else{
            isTarget.enabled = false
            isTarget.setCheckState(.Mixed, animated: true)
            isTarget.tintColor = FlatWhiteDark()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
