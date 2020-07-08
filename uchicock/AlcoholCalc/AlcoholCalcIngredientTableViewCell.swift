//
//  AlcoholCalcIngredientTableViewCell.swift
//  uchicock
//
//  Created by Kou Kinyo on 2/17/20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class AlcoholCalcIngredientTableViewCell: UITableViewCell {
    @IBOutlet weak var ingredientNumberLabel: CustomLabel!
    @IBOutlet weak var validCheckbox: CircularCheckbox!
    @IBOutlet weak var validLabel: CustomLabel!
    @IBOutlet weak var strengthLabel: CustomLabel!
    @IBOutlet weak var strengthSlider: CustomSlider!
    @IBOutlet weak var amountLabel: CustomLabel!
    @IBOutlet weak var amountSlider: CustomSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        strengthSlider.isExclusiveTouch = true
        amountSlider.isExclusiveTouch = true
    }
}
