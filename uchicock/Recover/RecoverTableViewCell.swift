//
//  RecoverTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-14.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class RecoverTableViewCell: UITableViewCell {

    @IBOutlet weak var targetCheckbox: CircularCheckbox!
    @IBOutlet weak var recipeNameLabel: CustomLabel!
    @IBOutlet weak var previewLabel: UILabel!
    
    var isRecoverable = false

    var recipe : SampleRecipeBasic? = nil{
        didSet{
            guard recipe != nil else { return }
            
            recipeNameLabel.text = recipe!.name
            targetCheckbox.secondaryTintColor = UchicockStyle.primaryColor
            previewLabel.textColor = UchicockStyle.labelTextColorLight

            if isRecoverable{
                targetCheckbox.isEnabled = true
                targetCheckbox.tintColor = UchicockStyle.primaryColor
                targetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
                targetCheckbox.checkState = recipe!.recoverTarget ? .checked : .unchecked
            }else{
                targetCheckbox.isEnabled = false
                targetCheckbox.tintColor = UchicockStyle.labelTextColorLight
                targetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
                targetCheckbox.checkState = .mixed
            }
        }
    }
}
