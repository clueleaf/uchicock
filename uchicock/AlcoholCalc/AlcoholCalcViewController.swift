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
    @IBOutlet weak var fakeTableHeaderView: UIView!
    @IBOutlet weak var validNumLabel: UILabel!
    @IBOutlet weak var clearAllButton: UIButton!
    
    var hiddenLabel = UILabel()
    var calcIngredientList: Results<CalculatorIngredient>?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "度数計算機"
        ingredientTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        hiddenLabel.font = UIFont.systemFont(ofSize: 14.0)
        hiddenLabel.text = "お酒は楽しくほどほどに！"
        hiddenLabel.frame = CGRect(x: 0, y: -90, width: 0, height: 20)
        hiddenLabel.textAlignment = .center
        ingredientTableView.addSubview(hiddenLabel)
        
        let realm = try! Realm()
        calcIngredientList = realm.objects(CalculatorIngredient.self).sorted(byKeyPath: "id")
        
        calcAlcoholStrength()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backgroundView.backgroundColor = Style.basicBackgroundColor
        fakeTableHeaderView.backgroundColor = Style.tableViewHeaderBackgroundColor
        validNumLabel.textColor = Style.tableViewHeaderTextColor
        updateValidNumLabel()
        clearAllButton.setTitleColor(Style.primaryColor, for: .normal)
        clearAllButton.layer.borderColor = Style.primaryColor.cgColor
        clearAllButton.layer.borderWidth = 1.0
        clearAllButton.layer.cornerRadius = 12
        clearAllButton.backgroundColor = Style.basicBackgroundColor

        hiddenLabel.textColor = Style.labelTextColorLight
        
        self.ingredientTableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.ingredientTableView.backgroundColor = Style.basicBackgroundColor
        self.ingredientTableView.separatorColor = Style.labelTextColorLight
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hiddenLabel.frame = CGRect(x: 0, y: -90, width: ingredientTableView.frame.width, height: 20)
    }
    
    private func updateValidNumLabel(){
        var validNum = 0
        for ing in calcIngredientList!{
            if ing.valid{
                validNum += 1
            }
        }
        validNumLabel.text = "有効な材料" + String(validNum) + "個"
    }
    
    private func calcAlcoholStrength(){
        var totalAmount: Int = 0
        var hundredTimesAlcoholAmount: Int = 0
        var alcoholPercentage: Double = 0.0
        
        guard calcIngredientList != nil else{
            return
        }
        
        for ing in calcIngredientList!{
            if ing.valid{
                totalAmount += ing.amount
                hundredTimesAlcoholAmount += ing.amount * ing.degree
            }
        }

        if totalAmount == 0{
            alcoholPercentage = 0.0
        }else{
            alcoholPercentage = Double(hundredTimesAlcoholAmount) / Double(totalAmount)
        }

        totalAmountLabel.text = String(totalAmount)
        
        if hundredTimesAlcoholAmount > 0 && hundredTimesAlcoholAmount < 100{
            alcoholAmountLabel.text = "<1"
        }else{
            let alcoholAmount: Double = Double(hundredTimesAlcoholAmount) / 100.0
            alcoholAmountLabel.text = String(Int(floor(alcoholAmount)))
        }
        
        if ceil(alcoholPercentage) == 0{
            alcoholPercentageLabel.text = "0"
            alcoholStrengthLabel.text = "ノンアルコール"
        } else if alcoholPercentage < 1.0{
            alcoholPercentageLabel.text = "<1"
            alcoholStrengthLabel.text = "ノンアルコール"
        } else{
            let flooredAlcoholPercentage = Int(floor(alcoholPercentage))
            alcoholPercentageLabel.text = String(flooredAlcoholPercentage)
            if flooredAlcoholPercentage < 10 {
                alcoholStrengthLabel.text = "弱い"
            }else if flooredAlcoholPercentage < 25 {
                alcoholStrengthLabel.text = "やや強い"
            }else{
                alcoholStrengthLabel.text = "強い"
            }
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
                cell.ingredientNumberLabel.textColor = Style.labelTextColorLight
                cell.validLabel.textColor = Style.labelTextColorLight
                cell.strengthLabel.textColor = Style.labelTextColorLight
                cell.strengthSlider.isEnabled = false
                cell.amountLabel.textColor = Style.labelTextColorLight
                cell.amountSlider.isEnabled = false
            }else{
                try! realm.write {
                    calcIngredient.valid = true
                }
                cell.ingredientNumberLabel.textColor = Style.labelTextColor
                cell.validLabel.textColor = Style.labelTextColor
                cell.strengthLabel.textColor = Style.labelTextColor
                cell.strengthSlider.isEnabled = true
                cell.amountLabel.textColor = Style.labelTextColor
                cell.amountSlider.isEnabled = true
            }
            calcAlcoholStrength()
            updateValidNumLabel()
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calcIngredientList == nil ? 0 : calcIngredientList!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
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
        cell.validCheckbox.boxLineWidth = 1.5
        cell.validCheckbox.animationDuration = 0.3

        if calcIngredient.valid{
            cell.ingredientNumberLabel.textColor = Style.labelTextColor
            cell.validCheckbox.checkState = .checked
            cell.validLabel.textColor = Style.labelTextColor
            cell.strengthLabel.textColor = Style.labelTextColor
            cell.strengthSlider.isEnabled = true
            cell.amountLabel.textColor = Style.labelTextColor
            cell.amountSlider.isEnabled = true
        }else{
            cell.ingredientNumberLabel.textColor = Style.labelTextColorLight
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
    
    // MARK: - IBAction
    @IBAction func clearAllButtonTapped(_ sender: UIButton) {
        guard calcIngredientList != nil else{
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            for ing in calcIngredientList!{
                ing.valid = false
            }
        }
        
        for (index, _) in calcIngredientList!.enumerated() {
            let cell = ingredientTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AlcoholCalcIngredientTableViewCell
            if cell != nil{
                cell?.ingredientNumberLabel.textColor = Style.labelTextColorLight
                cell?.validCheckbox.setCheckState(.unchecked, animated: true)
                cell?.validLabel.textColor = Style.labelTextColorLight
                cell?.strengthLabel.textColor = Style.labelTextColorLight
                cell?.strengthSlider.isEnabled = false
                cell?.amountLabel.textColor = Style.labelTextColorLight
                cell?.amountSlider.isEnabled = false
            }
        }
        
        calcAlcoholStrength()
        updateValidNumLabel()
    }
}
