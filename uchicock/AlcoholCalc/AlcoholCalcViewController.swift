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
        
        calcAlcoholStrength()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backgroundView.backgroundColor = Style.basicBackgroundColor
        
        self.ingredientTableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.ingredientTableView.backgroundColor = Style.basicBackgroundColor
        self.ingredientTableView.separatorColor = Style.labelTextColorLight

    }
    
    private func calcAlcoholStrength(){
        var totalAmount: Int = 0
        var alcoholAmount: Double = 0.0
        var alcoholPercentage: Double = 0.0
        
        guard calcIngredientList != nil else{
            return
        }
        
        for ing in calcIngredientList!{
            if ing.valid{
                totalAmount += ing.amount
                alcoholAmount = alcoholAmount + Double(ing.amount) * Double(ing.degree) / 100.0
            }
        }
        
        totalAmountLabel.text = String(totalAmount)
        
        if Int(ceil(alcoholAmount)) == 1{
            alcoholAmount = 1.0
        }
        alcoholAmountLabel.text = String(Int(floor(alcoholAmount)))
        
        if totalAmount == 0{
            alcoholPercentage = 0.0
        }else{
            alcoholPercentage = alcoholAmount / Double(totalAmount) * 100.0
        }
        
        if Int(ceil(alcoholPercentage)) == 1{
            alcoholPercentage = 1.0
        }
        
        alcoholPercentageLabel.text = String(Int(floor(alcoholPercentage)))
        if Int(floor(alcoholPercentage)) == 0{
            alcoholStrengthLabel.text = "ノンアルコール"
        }else if Int(floor(alcoholPercentage)) < 10 {
            alcoholStrengthLabel.text = "弱い"
        }else if Int(floor(alcoholPercentage)) < 25 {
            alcoholStrengthLabel.text = "やや強い"
        }else{
            alcoholStrengthLabel.text = "強い"
        }
    }
    
    // MARK: - Cell Target Action
    @objc func cellValidCheckboxTapped(_ sender: CircularCheckbox){
        var view = sender.superview
        while (view! is AlcoholCalcIngredientTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! AlcoholCalcIngredientTableViewCell
        let touchIndex = self.ingredientTableView.indexPath(for: cell)
        
        if let index = touchIndex {
            let realm = try! Realm()
            let calcIngredient = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: calcIngredientList![index.row].id)!
            if calcIngredient.valid {
                try! realm.write {
                    calcIngredient.valid = false
                }
                cell.validLabel.textColor = Style.labelTextColorLight
                cell.strengthLabel.textColor = Style.labelTextColorLight
                cell.strengthSlider.isEnabled = false
                cell.amountLabel.textColor = Style.labelTextColorLight
                cell.amountSlider.isEnabled = false
            }else{
                try! realm.write {
                    calcIngredient.valid = true
                }
                cell.validLabel.textColor = Style.labelTextColor
                cell.strengthLabel.textColor = Style.labelTextColor
                cell.strengthSlider.isEnabled = true
                cell.amountLabel.textColor = Style.labelTextColor
                cell.amountSlider.isEnabled = true
            }
            
            calcAlcoholStrength()
        }
    }
    
    @objc func cellStrengthSliderTapped(sender: CustomSlider, event: UIEvent){
        var view = sender.superview
        while (view! is AlcoholCalcIngredientTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! AlcoholCalcIngredientTableViewCell
        let touchIndex = self.ingredientTableView.indexPath(for: cell)
        
        if let index = touchIndex {
            cell.strengthLabel.text = "度数 " + String(Int(floor(sender.value))) + "%"
            
            if let touchEvent = event.allTouches?.first {
                if touchEvent.phase == .ended{
                    let realm = try! Realm()
                    let calcIngredient = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: calcIngredientList![index.row].id)!
                    try! realm.write {
                        calcIngredient.degree = Int(floor(sender.value))
                    }
                    calcAlcoholStrength()
                }
            }
        }
    }

    @objc func cellAmountSliderTapped(sender: CustomSlider, event: UIEvent){
        var view = sender.superview
        while (view! is AlcoholCalcIngredientTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! AlcoholCalcIngredientTableViewCell
        let touchIndex = self.ingredientTableView.indexPath(for: cell)
            
        if let index = touchIndex {
            cell.amountLabel.text = "分量 " + String(Int(floor(sender.value) * 5)) + "ml"

            if let touchEvent = event.allTouches?.first {
                if touchEvent.phase == .ended{
                    let realm = try! Realm()
                    let calcIngredient = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: calcIngredientList![index.row].id)!
                    try! realm.write {
                        calcIngredient.amount = Int(floor(sender.value) * 5)
                    }
                    calcAlcoholStrength()
                }
            }
        }
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
        cell.amountSlider.value = Float(calcIngredient.amount / 5)
        
        cell.validCheckbox.addTarget(self, action: #selector(AlcoholCalcViewController.cellValidCheckboxTapped(_:)), for: UIControl.Event.valueChanged)
        cell.strengthSlider.addTarget(self, action: #selector(AlcoholCalcViewController.cellStrengthSliderTapped(sender:event:)), for: UIControl.Event.valueChanged)
        cell.amountSlider.addTarget(self, action: #selector(AlcoholCalcViewController.cellAmountSliderTapped(sender:event:)), for: UIControl.Event.valueChanged)

        cell.backgroundColor = Style.basicBackgroundColor
        return cell
    }
    



}
