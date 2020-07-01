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
    var calcBasicList = Array<CalcBasic>()
    var alcoholAmountBackup = 0
    var totalAmount = ""
    var alcoholAmount = ""
    var alcoholPercentage = ""
    
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
        
        hiddenLabel.font = UIFont.systemFont(ofSize: 14.0)
        hiddenLabel.numberOfLines = 1
        hiddenLabel.text = "お酒は楽しくほどほどに！"
        hiddenLabel.frame = CGRect(x: 0, y: -90, width: 0, height: 20)
        hiddenLabel.textAlignment = .center
        hiddenLabel.textColor = UchicockStyle.labelTextColorLight
        ingredientTableView.addSubview(hiddenLabel)
        hiddenLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerXConstraint = NSLayoutConstraint(item: hiddenLabel, attribute: .centerX, relatedBy: .equal, toItem: ingredientTableView, attribute: .centerX, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: hiddenLabel, attribute: .bottom, relatedBy: .equal, toItem: ingredientTableView, attribute: .top, multiplier: 1, constant: -90)
        let heightConstraint = NSLayoutConstraint(item: hiddenLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        NSLayoutConstraint.activate([centerXConstraint, topConstraint, heightConstraint])
        
        let realm = try! Realm()
        let calcCount = realm.objects(CalculatorIngredient.self).sorted(byKeyPath: "id").count
        if calcCount == 0{
            addSampleCalcIngredient()
        }
        let calcList = realm.objects(CalculatorIngredient.self).sorted(byKeyPath: "id")
        for calc in calcList{
            calcBasicList.append(CalcBasic(id: calc.id, degree: calc.degree, amount: calc.amount, valid: calc.valid))
        }

        backgroundView.backgroundColor = UchicockStyle.basicBackgroundColor
        alcoholAmountTipButton.tintColor = UchicockStyle.primaryColor
        fakeTableHeaderView.backgroundColor = UchicockStyle.basicBackgroundColorLight
        validNumLabel.textColor = UchicockStyle.labelTextColor
        updateValidNumLabel()
        clearAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        clearAllButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        clearAllButton.layer.borderWidth = 1.0
        clearAllButton.layer.cornerRadius = clearAllButton.frame.size.height / 2
        clearAllButton.backgroundColor = UchicockStyle.basicBackgroundColor

        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor

        ingredientTableView.tableFooterView = UIView(frame: CGRect.zero)
        ingredientTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        ingredientTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        ingredientTableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        
        calcAlcoholStrength()
        totalAmount = totalAmountLabel.text!
        alcoholAmount = alcoholAmountLabel.text!
        alcoholPercentage = alcoholPercentageLabel.text!
    }
    
    // MARK: - Logic functions
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
        for ing in calcBasicList where ing.valid{
            validNum += 1
        }
        validNumLabel.text = "有効な材料" + String(validNum) + "個"
    }
    
    private func calcAlcoholStrength(){
        var totalAmount: Int = 0
        var hundredTimesAlcoholAmount: Int = 0
        var alcoholPercentage: Float = 0.0
        
        for ing in calcBasicList where ing.valid{
            totalAmount += ing.amount
            hundredTimesAlcoholAmount += ing.amount * ing.degree
        }

        totalAmountLabel.text = String(totalAmount)
        alcoholPercentage = totalAmount == 0 ? 0.0 : Float(hundredTimesAlcoholAmount) / Float(totalAmount)

        if hundredTimesAlcoholAmount > 0 && hundredTimesAlcoholAmount < 100{
            alcoholAmountLabel.text = "<1"
            alcoholAmountBackup = 0
        }else{
            let alcoholAmount: Float = Float(hundredTimesAlcoholAmount) / 100.0
            alcoholAmountLabel.text = String(Int(floor(alcoholAmount)))
            alcoholAmountBackup = Int(floor(alcoholAmount))
        }
        
        if ceil(alcoholPercentage) == 0{
            alcoholPercentageLabel.text = "0"
            alcoholStrengthLabel.text = RecipeStrengthType.nonAlcohol.rawValue
        }else if alcoholPercentage < 1.0{
            alcoholPercentageLabel.text = "<1"
            alcoholStrengthLabel.text = RecipeStrengthType.nonAlcohol.rawValue
        }else{
            let flooredAlcoholPercentage = Int(floor(alcoholPercentage))
            alcoholPercentageLabel.text = String(flooredAlcoholPercentage)
            if flooredAlcoholPercentage < 10 {
                alcoholStrengthLabel.text = RecipeStrengthType.weak.rawValue
            }else if flooredAlcoholPercentage < 25 {
                alcoholStrengthLabel.text = RecipeStrengthType.medium.rawValue
            }else{
                alcoholStrengthLabel.text = RecipeStrengthType.strong.rawValue
            }
        }
    }
    
    private func animateLabelsIfNeeded(){
        if totalAmount != totalAmountLabel.text! {
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                self.totalAmountLabel.transform = .init(scaleX: 1.2, y: 1.2)
            }) { (finished: Bool) -> Void in
                UIView.animate(withDuration: 0.10, animations: { () -> Void in
                    self.totalAmountLabel.transform = .identity
                })
            }
        }
        if alcoholAmount != alcoholAmountLabel.text! {
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                self.alcoholAmountLabel.transform = .init(scaleX: 1.2, y: 1.2)
            }) { (finished: Bool) -> Void in
                UIView.animate(withDuration: 0.10, animations: { () -> Void in
                    self.alcoholAmountLabel.transform = .identity
                })
            }
        }
        if alcoholPercentage != alcoholPercentageLabel.text! {
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                self.alcoholPercentageLabel.transform = .init(scaleX: 1.2, y: 1.2)
            }) { (finished: Bool) -> Void in
                UIView.animate(withDuration: 0.10, animations: { () -> Void in
                    self.alcoholPercentageLabel.transform = .identity
                })
            }
        }
        totalAmount = totalAmountLabel.text!
        alcoholAmount = alcoholAmountLabel.text!
        alcoholPercentage = alcoholPercentageLabel.text!
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
        
        guard let index = touchIndex else { return }

        calcBasicList[index.row].valid = !calcBasicList[index.row].valid
        if calcBasicList[index.row].valid {
            setCellValid(cell: cell)
        }else{
            setCellInvalid(cell: cell)
        }
        calcAlcoholStrength()
        animateLabelsIfNeeded()
        updateValidNumLabel()

        let realm = try! Realm()
        let ing = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: calcBasicList[index.row].id)!
        try! realm.write {
            ing.valid = calcBasicList[index.row].valid
        }
    }
    
    @objc func cellStrengthSliderTapped(sender: CustomSlider, event: UIEvent){
        var view = sender.superview
        while (view! is AlcoholCalcIngredientTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! AlcoholCalcIngredientTableViewCell
        let touchIndex = self.ingredientTableView.indexPath(for: cell)
        
        guard let index = touchIndex else { return }
        guard let touchEvent = event.allTouches?.first else { return }
        guard touchEvent.phase == .moved || touchEvent.phase == .ended else { return }

        calcBasicList[index.row].degree = Int(floor(sender.value))
        cell.strengthLabel.text = "度数 " + String(calcBasicList[index.row].degree) + "%"
        calcAlcoholStrength()
        
        guard touchEvent.phase == .ended else { return }

        animateLabelsIfNeeded()
        let realm = try! Realm()
        let ing = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: calcBasicList[index.row].id)!
        try! realm.write {
            ing.degree = calcBasicList[index.row].degree
        }
    }

    @objc func cellAmountSliderTapped(sender: CustomSlider, event: UIEvent){
        var view = sender.superview
        while (view! is AlcoholCalcIngredientTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! AlcoholCalcIngredientTableViewCell
        let touchIndex = self.ingredientTableView.indexPath(for: cell)
            
        guard let index = touchIndex else { return }
        guard let touchEvent = event.allTouches?.first else { return }
        guard touchEvent.phase == .moved || touchEvent.phase == .ended else { return }

        calcBasicList[index.row].amount = Int(floor(sender.value) * 5)
        cell.amountLabel.text = "分量 " + String(calcBasicList[index.row].amount) + "ml"
        calcAlcoholStrength()

        guard touchEvent.phase == .ended else { return }

        animateLabelsIfNeeded()
        let realm = try! Realm()
        let ing = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: calcBasicList[index.row].id)!
        try! realm.write {
            ing.amount = calcBasicList[index.row].amount
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
        return calcBasicList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath) as! AlcoholCalcIngredientTableViewCell

        calcBasicList[indexPath.row].valid = !calcBasicList[indexPath.row].valid
        if calcBasicList[indexPath.row].valid {
            cell.validCheckbox.setCheckState(.checked, animated: true)
            setCellValid(cell: cell)
        }else{
            cell.validCheckbox.setCheckState(.unchecked, animated: true)
            setCellInvalid(cell: cell)
        }
        calcAlcoholStrength()
        animateLabelsIfNeeded()
        updateValidNumLabel()
        
        let realm = try! Realm()
        let ing = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: calcBasicList[indexPath.row].id)!
        try! realm.write {
            ing.valid = calcBasicList[indexPath.row].valid
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as! AlcoholCalcIngredientTableViewCell
        cell.ingredientNumberLabel.text = "材料" + String(indexPath.row + 1)
        let calcIngredient = calcBasicList[indexPath.row]
        
        cell.validCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        cell.validCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        cell.validCheckbox.boxLineWidth = 1.5

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
        for i in 0..<calcBasicList.count {
            calcBasicList[i].valid = false
        }

        let realm = try! Realm()
        let calcList = realm.objects(CalculatorIngredient.self).sorted(byKeyPath: "id")
        try! realm.write {
            for ing in calcList {
                ing.valid = false
            }
        }
        
        for (index, _) in calcBasicList.enumerated() {
            let cell = ingredientTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AlcoholCalcIngredientTableViewCell
            if cell != nil{
                cell?.validCheckbox.setCheckState(.unchecked, animated: true)
                setCellInvalid(cell: cell)
            }
        }
        
        calcAlcoholStrength()
        animateLabelsIfNeeded()
        updateValidNumLabel()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        pc.leftMargin = 30
        pc.rightMargin = 30
        pc.topMargin = 80
        pc.bottomMargin = 80
        pc.canDismissWithOverlayViewTouch = true
        return pc
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = DismissModalAnimator()
        animator.leftMargin = 30
        animator.rightMargin = 30
        animator.topMargin = 80
        animator.bottomMargin = 80
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
