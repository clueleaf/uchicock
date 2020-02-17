//
//  AlcoholCalcViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2/17/20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class AlcoholCalcViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var totalAmountLabel: CustomLabel!
    @IBOutlet weak var alcoholAmountLabel: CustomLabel!
    @IBOutlet weak var alcoholPercentageLabel: CustomLabel!
    @IBOutlet weak var alcoholStrengthLabel: CustomLabel!
    @IBOutlet weak var ingredientTableView: UITableView!
    
    var calcIngredientList: Results<CalculatorIngredient>?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "度数計算機"
        ingredientTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let realm = try! Realm()
        calcIngredientList = realm.objects(CalculatorIngredient.self).sorted(byKeyPath: "id")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backgroundView.backgroundColor = Style.basicBackgroundColor
        
        self.ingredientTableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.ingredientTableView.backgroundColor = Style.basicBackgroundColor
        self.ingredientTableView.separatorColor = Style.labelTextColorLight

    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calcIngredientList == nil ? 0 : calcIngredientList!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as! AlcoholCalcIngredientTableViewCell
        cell.ingredientNumberLabel.text = "材料" + String(indexPath.row + 1)
        let calcIngredient = calcIngredientList![indexPath.row]
        
        cell.validCheckbox.secondaryTintColor = Style.primaryColor
        cell.validCheckbox.secondaryCheckmarkTintColor = Style.labelTextColorOnBadge
        cell.validCheckbox.boxLineWidth = 1.0
        cell.validCheckbox.animationDuration = 0.3

        if calcIngredient.valid{
            cell.validCheckbox.checkState = .checked
            cell.validLabel.textColor = Style.labelTextColor
            cell.strengthLabel.textColor = Style.labelTextColor
            cell.strengthSlider.isEnabled = true
            cell.amountLabel.textColor = Style.labelTextColor
            cell.amountSlider.isEnabled = true
        }else{
            cell.validCheckbox.checkState = .unchecked
            cell.validLabel.textColor = Style.labelTextColorLight
            cell.strengthLabel.textColor = Style.labelTextColorLight
            cell.strengthSlider.isEnabled = false
            cell.amountLabel.textColor = Style.labelTextColorLight
            cell.amountSlider.isEnabled = false
        }
        
        cell.strengthLabel.text = "度数 " + String(calcIngredient.degree) + "%"
        cell.strengthSlider.value = Float(calcIngredient.degree)
        
        cell.amountLabel.text = "分量 " + String(calcIngredient.amount) + "ml"
        cell.amountSlider.value = Float(calcIngredient.amount)
        
        cell.backgroundColor = Style.basicBackgroundColor
        return cell
    }
    



}
