//
//  RecoverTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecoverTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var recoverTargetCheckbox: CircularCheckbox!
    @IBOutlet weak var nonRecoverTargetCheckbox: CircularCheckbox!
    @IBOutlet weak var unableRecoverCheckbox: CircularCheckbox!
    @IBOutlet weak var recoverableNumberLabel: CustomLabel!
    @IBOutlet weak var recoverAllLabel: UILabel!
    @IBOutlet weak var recoverSelectedLabel: UILabel!
    
    var userRecipeNameList = Array<String>()
    var recoverableSampleRecipeList = Array<SampleRecipeBasic>()
    var unrecoverableSampleRecipeList = Array<SampleRecipeBasic>()
    var isRecovering = false
    let selectedCellBackgroundView = UIView()
    var shouldAdd73Badge = false
    var shouldAdd80Badge = false

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserRecipe()
        
        var config = Realm.Configuration(schemaVersion: GlobalConstants.RealmSchemaVersion)
        config.fileURL = Bundle.main.url(forResource: "default", withExtension: "realm")
        config.readOnly = true
        Realm.Configuration.defaultConfiguration = config

        loadSampleRecipe()
        isRecovering = false
        
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        
        recoverTargetCheckbox.stateChangeAnimation = .expand
        recoverTargetCheckbox.isEnabled = false
        recoverTargetCheckbox.setCheckState(.checked, animated: true)
        recoverTargetCheckbox.boxLineWidth = 1.0
        recoverTargetCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        recoverTargetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        nonRecoverTargetCheckbox.stateChangeAnimation = .expand
        nonRecoverTargetCheckbox.isEnabled = false
        nonRecoverTargetCheckbox.setCheckState(.unchecked, animated: true)
        nonRecoverTargetCheckbox.boxLineWidth = 1.0
        nonRecoverTargetCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        nonRecoverTargetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        unableRecoverCheckbox.stateChangeAnimation = .expand
        unableRecoverCheckbox.isEnabled = false
        unableRecoverCheckbox.setCheckState(.mixed, animated: true)
        unableRecoverCheckbox.tintColor = UchicockStyle.labelTextColorLight
        unableRecoverCheckbox.boxLineWidth = 1.0
        unableRecoverCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        unableRecoverCheckbox.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
        
        let sampleRecipeNum = recoverableSampleRecipeList.count + unrecoverableSampleRecipeList.count
        let recoverableRecipeNum = recoverableSampleRecipeList.count
        recoverableNumberLabel.text = "全" + String(sampleRecipeNum) + "レシピの内、" + String(recoverableRecipeNum) + "レシピを復元できます。"
        
        recoverAllLabel.text = "復元できる" + String(recoverableRecipeNum) + "レシピを全て復元"
        if recoverableRecipeNum == 0{
            recoverAllLabel.textColor = UchicockStyle.labelTextColorLight
        }else{
            recoverAllLabel.textColor = UchicockStyle.primaryColor
        }
        
        var recoverCount = 0
        for rr in recoverableSampleRecipeList where rr.recoverTarget{
            recoverCount += 1
        }

        recoverSelectedLabel.text = "選択した0レシピのみを復元"
        recoverSelectedLabel.textColor = UchicockStyle.labelTextColorLight
        
        tableView.register(UINib(nibName: "RecoverTableViewCell", bundle: nil), forCellReuseIdentifier: "RecoverCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension

        let defaults = UserDefaults.standard
        shouldAdd73Badge = !defaults.bool(forKey: GlobalConstants.Version73NewRecipeViewedKey)
        shouldAdd80Badge = !defaults.bool(forKey: GlobalConstants.Version80NewRecipeViewedKey)
        defaults.set(true, forKey: GlobalConstants.Version81NewRecipeViewedKey)
    }
    
    private func cellDeselectAnimation(){
        if let index = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    // MARK: - Manage Data
    private func changeToUserDb(){
        var config = Realm.Configuration(schemaVersion: GlobalConstants.RealmSchemaVersion)
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
    }

    private func loadUserRecipe(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for ur in recipeList{
            userRecipeNameList.append(ur.recipeName)
        }
    }
    
    private func loadSampleRecipe(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for sr in recipeList{
            var isRecoverable = true
            for ur in userRecipeNameList where sr.recipeName == ur{
                isRecoverable = false
                break
            }

            let srb = SampleRecipeBasic(
                name: sr.recipeName,
                nameYomi: sr.recipeNameYomi,
                katakanaLowercasedNameForSearch: sr.katakanaLowercasedNameForSearch,
                recoverable: isRecoverable,
                recoverTarget: false
            )
            if isRecoverable{
                recoverableSampleRecipeList.append(srb)
            }else{
                unrecoverableSampleRecipeList.append(srb)
            }
        }
        recoverableSampleRecipeList.sort { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending }
        unrecoverableSampleRecipeList.sort { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending }
    }
    
    @objc func isTargetTapped(_ sender: CircularCheckbox){
        guard isRecovering == false else { return }

        var view = sender.superview
        while (view! is RecoverTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! RecoverTableViewCell
        let touchIndex = self.tableView.indexPath(for: cell)
        
        if let index = touchIndex{
            if index.row < recoverableSampleRecipeList.count{
                if sender.checkState == .checked{
                    recoverableSampleRecipeList[index.row].recoverTarget = true
                }else if sender.checkState == .unchecked{
                    recoverableSampleRecipeList[index.row].recoverTarget = false
                }
                
                var recoverCount = 0
                for rr in recoverableSampleRecipeList where rr.recoverTarget{
                    recoverCount += 1
                }
                recoverSelectedLabel.text = "選択した" + String(recoverCount) + "レシピのみを復元"
                if recoverCount == 0{
                    recoverSelectedLabel.textColor = UchicockStyle.labelTextColorLight
                }else{
                    recoverSelectedLabel.textColor = UchicockStyle.primaryColor
                }
            }
        }
    }
    
    private func recover(){
        var recoverRecipeList = Array<RecoverRecipe>()
        let realm1 = try! Realm()
        for rr in recoverableSampleRecipeList where rr.recoverTarget{
            let recipe = realm1.objects(Recipe.self).filter("recipeName == %@", rr.name).first!
            
            var recoverRecipe = RecoverRecipe(
                name: recipe.recipeName,
                nameYomi: recipe.recipeNameYomi,
                katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch,
                style: recipe.style,
                method: recipe.method,
                strength: recipe.strength,
                ingredientList: []
            )
            for ri in recipe.recipeIngredients{
                recoverRecipe.ingredientList.append(RecipeIngredientBasic(
                    ingredientId: "",
                    ingredientName: ri.ingredient.ingredientName,
                    ingredientNameYomi: ri.ingredient.ingredientNameYomi,
                    katakanaLowercasedNameForSearch: ri.ingredient.katakanaLowercasedNameForSearch,
                    amount: ri.amount,
                    mustFlag: ri.mustFlag,
                    category: ri.ingredient.category,
                    displayOrder: ri.displayOrder,
                    stockFlag: false
                ))
            }
            recoverRecipeList.append(recoverRecipe)
        }
        
        changeToUserDb()
        
        let realm2 = try! Realm()
        for recoverRecipe in recoverRecipeList{
            let rec = realm2.objects(Recipe.self).filter("recipeName == %@",recoverRecipe.name)
            if rec.count < 1 {
                try! realm2.write {
                    for recoverIngredient in recoverRecipe.ingredientList{
                        addIngredient(ingredientName: recoverIngredient.ingredientName, ingredientNameYomi: recoverIngredient.ingredientNameYomi, katakanaLowercasedForSearch: recoverIngredient.katakanaLowercasedNameForSearch, stockFlag: false, memo: "", category: recoverIngredient.category)
                    }
                    addRecipe(recipeName: recoverRecipe.name, recipeNameYomi: recoverRecipe.nameYomi, katakanaLowercasedForSearch: recoverRecipe.katakanaLowercasedNameForSearch, favorites: 0, memo: "", style: recoverRecipe.style, method: recoverRecipe.method, strength: recoverRecipe.strength)
                    
                    for recoverIngredient in recoverRecipe.ingredientList{
                        addRecipeToIngredientLink(recipeName: recoverRecipe.name, ingredientName: recoverIngredient.ingredientName, amount: recoverIngredient.amount, mustFlag: recoverIngredient.mustFlag, displayOrder: recoverIngredient.displayOrder)
                    }
                    updateRecipeShortageNum(recipeName: recoverRecipe.name)
                }
            }
        }
    }
    
    private func addRecipe(recipeName:String, recipeNameYomi: String, katakanaLowercasedForSearch: String, favorites:Int, memo:String, style:Int, method:Int, strength:Int){
        let realm = try! Realm()
        let rec = realm.objects(Recipe.self).filter("recipeName == %@",recipeName)
        if rec.count < 1 {
            let recipe = Recipe()
            recipe.recipeName = recipeName
            recipe.recipeNameYomi = recipeNameYomi
            recipe.katakanaLowercasedNameForSearch = katakanaLowercasedForSearch
            recipe.favorites = favorites
            recipe.memo = memo
            recipe.style = style
            recipe.method = method
            recipe.strength = strength
            realm.add(recipe)
        }
    }
    
    private func addIngredient(ingredientName: String, ingredientNameYomi: String, katakanaLowercasedForSearch: String, stockFlag: Bool, memo: String, category: Int){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientName)
        if ing.count < 1 {
            let ingredient = Ingredient()
            ingredient.ingredientName = ingredientName
            ingredient.ingredientNameYomi = ingredientNameYomi
            ingredient.katakanaLowercasedNameForSearch = katakanaLowercasedForSearch
            ingredient.stockFlag = stockFlag
            ingredient.memo = memo
            ingredient.category = category
            realm.add(ingredient)
        }
    }
    
    private func addRecipeToIngredientLink(recipeName:String, ingredientName:String, amount:String, mustFlag:Bool, displayOrder:Int){
        let realm = try! Realm()
        let recipeIngredientLink = RecipeIngredientLink()
        recipeIngredientLink.amount = amount
        recipeIngredientLink.mustFlag = mustFlag
        recipeIngredientLink.displayOrder = displayOrder
        realm.add(recipeIngredientLink)
        
        let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientName).first!
        ingredient.recipeIngredients.append(recipeIngredientLink)
        
        let recipe = realm.objects(Recipe.self).filter("recipeName == %@",recipeName).first!
        recipe.recipeIngredients.append(recipeIngredientLink)
    }
    
    private func updateRecipeShortageNum(recipeName: String){
        let realm = try! Realm()
        let rec = realm.objects(Recipe.self).filter("recipeName == %@",recipeName)
        if rec.count > 0 {
            let recipe = realm.objects(Recipe.self).filter("recipeName == %@",recipeName).first!
            recipe.updateShortageNum()
        }
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 30 : 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                return UITableView.automaticDimension
            }else{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }else{
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isRecovering == false else { return }

        if indexPath.section == 0{
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 1{
                if recoverableSampleRecipeList.count == 0{
                    let alertView = CustomAlertController(title: nil, message: "復元できるレシピはありません", preferredStyle: .alert)
                    if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                        alertView.overrideUserInterfaceStyle = .dark
                    }
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    if #available(iOS 13.0, *){ action.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                    alertView.addAction(action)
                    alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    self.present(alertView, animated: true, completion: nil)
                }else{
                    let recipeNum = recoverableSampleRecipeList.count
                    let alertView = CustomAlertController(title: nil, message: "復元できる" + String(recipeNum) + "レシピを全て復元します", preferredStyle: .alert)
                    if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                        alertView.overrideUserInterfaceStyle = .dark
                    }
                    let recoverAction = UIAlertAction(title: "復元", style: .default){action in
                        self.isRecovering = true
                        MessageHUD.show("復元中...", for: nil, withCheckmark: false, isCenter: true)
                        DispatchQueue.global(qos: .userInitiated).async {
                            for i in 0..<self.recoverableSampleRecipeList.count {
                                self.recoverableSampleRecipeList[i].recoverTarget = true
                            }
                            self.recover()
                            DispatchQueue.main.async{
                                MessageHUD.show(String(recipeNum) + "レシピを復元しました", for: 2.0, withCheckmark: true, isCenter: true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    if #available(iOS 13.0, *){ recoverAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                    alertView.addAction(recoverAction)
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                    if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                    alertView.addAction(cancelAction)
                    alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    self.present(alertView, animated: true, completion: nil)
                }
            }else if indexPath.row == 2{
                var recoverCount = 0
                for rr in recoverableSampleRecipeList where rr.recoverTarget{
                    recoverCount += 1
                }
                    
                if recoverCount > 0{
                    let alertView = CustomAlertController(title: nil, message: "選択した" + String(recoverCount) + "レシピを復元します", preferredStyle: .alert)
                    if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                        alertView.overrideUserInterfaceStyle = .dark
                    }
                    let recoverAction = UIAlertAction(title: "復元", style: .default){action in
                        self.isRecovering = true
                        MessageHUD.show("復元中...", for: nil, withCheckmark: false, isCenter: true)
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.recover()
                            DispatchQueue.main.async{
                                MessageHUD.show(String(recoverCount) + "レシピを復元しました", for: 2.0, withCheckmark: true, isCenter: true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    if #available(iOS 13.0, *){ recoverAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                    alertView.addAction(recoverAction)
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                    if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                    alertView.addAction(cancelAction)
                    alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    self.present(alertView, animated: true, completion: nil)
                }
            }
        }else if indexPath.section == 1{
            let storyboard = UIStoryboard(name: "Recover", bundle: nil)
            let nvc = storyboard.instantiateViewController(withIdentifier: "RecoverPreviewNavigationController") as! BasicNavigationController
            let vc = nvc.visibleViewController as! RecoverPreviewTableViewController
            let realm = try! Realm()
            if indexPath.row < recoverableSampleRecipeList.count{
                let recipe = realm.objects(Recipe.self).filter("recipeName == %@", recoverableSampleRecipeList[indexPath.row].name).first!
                vc.recipe = recipe
            }else{
                let recipe = realm.objects(Recipe.self).filter("recipeName == %@", unrecoverableSampleRecipeList[indexPath.row - recoverableSampleRecipeList.count].name).first!
                vc.recipe = recipe
            }
            vc.onDoneBlock = {
                self.cellDeselectAnimation()
            }
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
                nvc.modalPresentationStyle = .pageSheet
            }else{
                nvc.modalPresentationStyle = .custom
                nvc.transitioningDelegate = self
                vc.interactor = interactor
            }

            present(nvc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = section == 1 ? "復元したいレシピを選んでください" : ""
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else if section == 1{
            return recoverableSampleRecipeList.count + unrecoverableSampleRecipeList.count
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecoverCell") as! RecoverTableViewCell
            
            let accesoryImageView = UIImageView(image: UIImage(named: "accesory-disclosure-indicator"))
            accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            cell.accessoryView = accesoryImageView

            
            cell.shouldAdd73Badge = self.shouldAdd73Badge
            cell.shouldAdd80Badge = self.shouldAdd80Badge
            cell.isTarget.stateChangeAnimation = .fade
            cell.isTarget.animationDuration = 0.0
            cell.isTarget.backgroundColor = UIColor.clear
            cell.isTarget.boxLineWidth = 1.0
            cell.isTarget.secondaryTintColor = UchicockStyle.primaryColor
            cell.isTarget.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

            if indexPath.row < recoverableSampleRecipeList.count{
                cell.recipeName = recoverableSampleRecipeList[indexPath.row].name
                cell.isTarget.isEnabled = true
                cell.isTarget.tintColor = UchicockStyle.primaryColor
                if recoverableSampleRecipeList[indexPath.row].recoverTarget{
                    cell.isTarget.setCheckState(.checked, animated: true)
                }else{
                    cell.isTarget.setCheckState(.unchecked, animated: true)
                }
                cell.isRecoverable = true
                cell.isTarget.addTarget(self, action: #selector(RecoverTableViewController.isTargetTapped(_:)), for: UIControl.Event.valueChanged)
            }else{
                cell.recipeName = unrecoverableSampleRecipeList[indexPath.row - recoverableSampleRecipeList.count].name
                cell.isTarget.isEnabled = false
                cell.isTarget.tintColor = UchicockStyle.labelTextColorLight
                cell.isTarget.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
                cell.isTarget.setCheckState(.mixed, animated: true)
                cell.isRecoverable = false
            }
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if isRecovering == false {
            changeToUserDb()
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        pc.leftMargin = 10
        pc.rightMargin = 10
        pc.topMargin = 20
        pc.bottomMargin = 20
        pc.canDismissWithOverlayViewTouch = false
        return pc
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = DismissModalAnimator()
        animator.leftMargin = 10
        animator.rightMargin = 10
        animator.topMargin = 20
        animator.bottomMargin = 20
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
