//
//  RecoverTargetTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverTargetTableViewCell: UITableViewCell {

    @IBOutlet weak var isTarget: CircularCheckbox!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    
    var isRecoverable: Bool = Bool(){
        didSet{
            isTarget.stateChangeAnimation = .expand
            isTarget.animationDuration = 0.3
            previewLabel.textColor = Style.labelTextColorLight
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
