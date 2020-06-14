//
//  AlcoholCalcViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2/17/20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class AlcoholCalcViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var totalAmountLabel: CustomLabel!
    @IBOutlet weak var alcoholAmountLabel: CustomLabel!
    @IBOutlet weak var alcoholPercentageLabel: CustomLabel!
    @IBOutlet weak var alcoholStrengthLabel: CustomLabel!
    @IBOutlet weak var alcoholAmountTipButton: ExpandedButton!
    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var fakeTableHeaderView: UIView!
    @IBOutlet weak var validNumLabel: UILabel!
    @IBOutlet weak var clearAllButton: UIButton!
    
    let selectedCellBackgroundView = UIView()
    var hiddenLabel = UILabel()
    var calcIngredientList: Results<CalculatorIngredient>?
    var alcoholAmountBackup = 0
    
    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.maxAllowedInitialDistanceToLeftEdge = 60.0

        alcoholAmountTipButton.minimumHitWidth = 50
        alcoholAmountTipButton.minimumHitHeight = 44

        self.navigationItem.title = "度数計算機"
        ingredientTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        hiddenLabel.font = UIFont.systemFont(ofSize: 14.0)
        hiddenLabel.text = "お酒は楽しくほどほどに！"
        hiddenLabel.frame = CGRect(x: 0, y: -90, width: 0, height: 20)
        hiddenLabel.textAlignment = .center
        ingredientTableView.addSubview(hiddenLabel)
        
        let realm = try! Realm()
        calcIngredientList = realm.objects(CalculatorIngredient.self).sorted(byKeyPath: "id")
        if calcIngredientList == nil || calcIngredientList!.count == 0{
            addSampleCalcIngredient()
        }

        backgroundView.backgroundColor = UchicockStyle.basicBackgroundColor
        
        let tipImage = UIImage(named: "button-tip")
        alcoholAmountTipButton.setImage(tipImage, for: .normal)
        alcoholAmountTipButton.tintColor = UchicockStyle.primaryColor

        fakeTableHeaderView.backgroundColor = UchicockStyle.basicBackgroundColorLight
        validNumLabel.textColor = UchicockStyle.labelTextColor
        updateValidNumLabel()
        clearAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        clearAllButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        clearAllButton.layer.borderWidth = 1.0
        clearAllButton.layer.cornerRadius = clearAllButton.frame.size.height / 2
        clearAllButton.backgroundColor = UchicockStyle.basicBackgroundColor

        hiddenLabel.textColor = UchicockStyle.labelTextColorLight
        
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor

        self.ingredientTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        self.ingredientTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        self.ingredientTableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        
        calcAlcoholStrength()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hiddenLabel.frame = CGRect(x: 0, y: -90, width: ingredientTableView.frame.width, height: 20)
    }
    
    // MARK: - Calc
    private func addSampleCalcIngredient(){
        addCalcIngredient(id: "0", degree: 40, amount: 45, valid: true)
        addCalcIngredient(id: "1", degree: 0, amount: 90, valid: true)
        addCalcIngredient(id: "2", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "3", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "4", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "5", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "6", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "7", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "8", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "9", degree: 0, amount: 0, valid: false)
    }
    
    private func addCalcIngredient(id: String, degree: Int, amount: Int, valid: Bool){
        let realm = try! Realm()
        let ing = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: id)
        if ing == nil {
            let ingredient = CalculatorIngredient()
            ingredient.id = id
            ingredient.degree = degree
            ingredient.amount = amount
            ingredient.valid = valid
            try! realm.write{
                realm.add(ingredient)
            }
        }
    }
    
    private func updateValidNumLabel(){
        var validNum = 0
        for ing in calcIngredientList! where ing.valid{
            validNum += 1
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
        
        for ing in calcIngredientList! where ing.valid{
            totalAmount += ing.amount
            hundredTimesAlcoholAmount += ing.amount * ing.degree
        }

        if totalAmount == 0{
            alcoholPercentage = 0.0
        }else{
            alcoholPercentage = Double(hundredTimesAlcoholAmount) / Double(totalAmount)
        }

        totalAmountLabel.text = String(totalAmount)
        
        if hundredTimesAlcoholAmount > 0 && hundredTimesAlcoholAmount < 100{
            alcoholAmountLabel.text = "<1"
            alcoholAmountBackup = 0
        }else{
            let alcoholAmount: Double = Double(hundredTimesAlcoholAmount) / 100.0
            alcoholAmountLabel.text = String(Int(floor(alcoholAmount)))
            alcoholAmountBackup = Int(floor(alcoholAmount))
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
    private func setCellValid(cell: AlcoholCalcIngredientTableViewCell?){
        cell?.ingredientNumberLabel.textColor = UchicockStyle.labelTextColor
        cell?.validLabel.textColor = UchicockStyle.labelTextColor
        cell?.strengthLabel.textColor = UchicockStyle.labelTextColor
        cell?.strengthSlider.isEnabled = true
        cell?.amountLabel.textColor = UchicockStyle.labelTextColor
        cell?.amountSlider.isEnabled = true
    }
    
    private func setCellInvalid(cell: AlcoholCalcIngredientTableViewCell?){
        cell?.ingredientNumberLabel.textColor = UchicockStyle.labelTextColorLight
        cell?.validLabel.textColor = UchicockStyle.labelTextColorLight
        cell?.strengthLabel.textColor = UchicockStyle.labelTextColorLight
        cell?.strengthSlider.isEnabled = false
        cell?.amountLabel.textColor = UchicockStyle.labelTextColorLight
        cell?.amountSlider.isEnabled = false
    }
    
    @objc func cellValidCheckboxTapped(_ sender: CircularCheckbox){
        var view = sender.superview
        while (view! is AlcoholCalcIngredientTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! AlcoholCalcIngredientTableViewCell
        let touchIndex = self.ingredientTableView.indexPath(for: cell)
        
        guard calcIngredientList != nil else{ return }

        if let index = touchIndex {
            let realm = try! Realm()
            if calcIngredientList![index.row].valid {
                try! realm.write {
                    calcIngredientList![index.row].valid = false
                }
                setCellInvalid(cell: cell)
            }else{
                try! realm.write {
                    calcIngredientList![index.row].valid = true
                }
                setCellValid(cell: cell)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard calcIngredientList != nil else{ return }

        let realm = try! Realm()
        let cell = tableView.cellForRow(at: indexPath) as! AlcoholCalcIngredientTableViewCell

        if calcIngredientList![indexPath.row].valid {
            cell.validCheckbox.setCheckState(.unchecked, animated: true)
            try! realm.write {
                calcIngredientList![indexPath.row].valid = false
            }
            setCellInvalid(cell: cell)
        }else{
            cell.validCheckbox.setCheckState(.checked, animated: true)
            try! realm.write {
                calcIngredientList![indexPath.row].valid = true
            }
            setCellValid(cell: cell)
        }
        calcAlcoholStrength()
        updateValidNumLabel()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as! AlcoholCalcIngredientTableViewCell
        cell.ingredientNumberLabel.text = "材料" + String(indexPath.row + 1)
        let calcIngredient = calcIngredientList![indexPath.row]
        
        cell.validCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        cell.validCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        cell.validCheckbox.boxLineWidth = 1.5
        cell.validCheckbox.animationDuration = 0.3

        if calcIngredient.valid{
            cell.validCheckbox.checkState = .checked
            setCellValid(cell: cell)
        }else{
            cell.validCheckbox.checkState = .unchecked
            setCellInvalid(cell: cell)
        }
        
        cell.strengthLabel.text = "度数 " + String(calcIngredient.degree) + "%"
        cell.strengthSlider.value = Float(calcIngredient.degree)
        
        cell.amountLabel.text = "分量 " + String(calcIngredient.amount) + "ml"
        cell.amountSlider.value = Float(calcIngredient.amount / 5)
        
        cell.validCheckbox.addTarget(self, action: #selector(AlcoholCalcViewController.cellValidCheckboxTapped(_:)), for: UIControl.Event.valueChanged)
        cell.strengthSlider.addTarget(self, action: #selector(AlcoholCalcViewController.cellStrengthSliderTapped(sender:event:)), for: UIControl.Event.valueChanged)
        cell.amountSlider.addTarget(self, action: #selector(AlcoholCalcViewController.cellAmountSliderTapped(sender:event:)), for: UIControl.Event.valueChanged)

        cell.backgroundColor = UchicockStyle.basicBackgroundColor
        cell.selectedBackgroundView = selectedCellBackgroundView
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func alcoholAmountTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AlcoholCalc", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "AlcoholAmountTipNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! AlcoholAmountTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .formSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }
        vc.alcoholAmount = alcoholAmountBackup
        present(nvc, animated: true)
    }
    
    @IBAction func clearAllButtonTapped(_ sender: UIButton) {
        guard calcIngredientList != nil else{ return }
        
        let realm = try! Realm()
        try! realm.write {
            for ing in calcIngredientList!{
                ing.valid = false
            }
        }
        
        for (index, _) in calcIngredientList!.enumerated() {
            let cell = ingredientTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AlcoholCalcIngredientTableViewCell
            if cell != nil{
                cell?.validCheckbox.setCheckState(.unchecked, animated: true)
                setCellInvalid(cell: cell)
            }
        }
        
        calcAlcoholStrength()
        updateValidNumLabel()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        pc.xMargin = 60
        pc.yMargin = 160
        pc.canDismissWithOverlayViewTouch = true
        return pc
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = DismissModalAnimator()
        animator.xMargin = 60
        animator.yMargin = 160
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
