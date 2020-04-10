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

    var userRecipeNameList = Array<String>()
    var recoverableSampleRecipeList = Array<SampleRecipeBasic>()
    var unrecoverableSampleRecipeList = Array<SampleRecipeBasic>()
    var isRecovering = false
    let selectedCellBackgroundView = UIView()
    
    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserRecipe()
        
        var config = Realm.Configuration(schemaVersion: GlobalConstants.RealmSchemaVersion)
        config.fileURL = Bundle.main.url(forResource: "default", withExtension: "realm")
        config.readOnly = true
        Realm.Configuration.defaultConfiguration = config

        loadSampleRecipe()
        setNavigationTitle()
        isRecovering = false
        
        tableView.separatorColor = UchicockStyle.labelTextColorLight
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
    }
    
    private func cellDeselectAnimation(){
        if let index = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
    }
    
    func changeToUserDb(){
        var config = Realm.Configuration(schemaVersion: GlobalConstants.RealmSchemaVersion)
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
    }

    func loadUserRecipe(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for ur in recipeList{
            userRecipeNameList.append(ur.recipeName)
        }
    }
    
    func loadSampleRecipe(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for sr in recipeList{
            var isRecoverable = true
            for ur in userRecipeNameList{
                if sr.recipeName == ur{
                    isRecoverable = false
                    break
                }
            }

            let srb = SampleRecipeBasic(name: sr.recipeName, recoverable: isRecoverable, recoverTarget: false)
            if isRecoverable{
                recoverableSampleRecipeList.append(srb)
            }else{
                unrecoverableSampleRecipeList.append(srb)
            }
        }
        recoverableSampleRecipeList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
        unrecoverableSampleRecipeList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
    
    func setNavigationTitle(){
        var recoverCount = 0
        for rr in recoverableSampleRecipeList{
            if rr.recoverTarget{
                recoverCount += 1
            }
        }
        self.navigationItem.title = "レシピ復元(" + String(recoverCount) + ")"
    }
    
    @objc func isTargetTapped(_ sender: CircularCheckbox){
        if isRecovering == false {
            var view = sender.superview
            while (view! is RecoverTargetTableViewCell) == false{
                view = view!.superview
            }
            let cell = view as! RecoverTargetTableViewCell
            let touchIndex = self.tableView.indexPath(for: cell)
            
            if let index = touchIndex{
                if index.row - 1 < recoverableSampleRecipeList.count{
                    if sender.checkState == .checked{
                        recoverableSampleRecipeList[index.row - 1].recoverTarget = true
                    }else if sender.checkState == .unchecked{
                        recoverableSampleRecipeList[index.row - 1].recoverTarget = false
                    }
                    setNavigationTitle()
                }
            }
        }
    }
    
    func recover(){
        var recoverRecipeList = Array<RecoverRecipe>()
        for rr in recoverableSampleRecipeList{
            if rr.recoverTarget{
                let realm = try! Realm()
                let recipe = realm.objects(Recipe.self).filter("recipeName == %@", rr.name).first!
                
                var recoverRecipe = RecoverRecipe(name: recipe.recipeName,style: recipe.style, method: recipe.method, strength: recipe.strength, ingredientList: [])
                for ri in recipe.recipeIngredients{
                    recoverRecipe.ingredientList.append(RecipeIngredientBasic(recipeIngredientId: "", ingredientId: "", ingredientName: ri.ingredient.ingredientName, amount: ri.amount, mustFlag: ri.mustFlag, category: ri.ingredient.category, displayOrder: ri.displayOrder, stockFlag: false))
                }
                recoverRecipeList.append(recoverRecipe)
            }
        }
        
        changeToUserDb()
        
        for recoverRecipe in recoverRecipeList{
            let realm = try! Realm()
            let rec = realm.objects(Recipe.self).filter("recipeName == %@",recoverRecipe.name)
            if rec.count < 1 {
                try! realm.write {
                    for recoverIngredient in recoverRecipe.ingredientList{
                        addIngredient(ingredientName: recoverIngredient.ingredientName, stockFlag: false, memo: "", category: recoverIngredient.category)
                    }
                    addRecipe(recipeName: recoverRecipe.name, favorites: 0, memo: "", style: recoverRecipe.style, method: recoverRecipe.method, strength: recoverRecipe.strength)
                    
                    for recoverIngredient in recoverRecipe.ingredientList{
                        addRecipeToIngredientLink(recipeName: recoverRecipe.name, ingredientName: recoverIngredient.ingredientName, amount: recoverIngredient.amount, mustFlag: recoverIngredient.mustFlag, displayOrder: recoverIngredient.displayOrder)
                    }
                    updateRecipeShortageNum(recipeName: recoverRecipe.name)
                }
            }
        }
    }
    
    func addRecipe(recipeName:String, favorites:Int, memo:String, style:Int, method:Int, strength:Int){
        let realm = try! Realm()
        let rec = realm.objects(Recipe.self).filter("recipeName == %@",recipeName)
        if rec.count < 1 {
            let recipe = Recipe()
            recipe.recipeName = recipeName
            recipe.katakanaLowercasedNameForSearch = recipeName.katakanaLowercasedForSearch()
            recipe.favorites = favorites
            recipe.memo = memo
            recipe.style = style
            recipe.method = method
            recipe.strength = strength
            realm.add(recipe)
        }
    }
    
    func addIngredient(ingredientName: String, stockFlag: Bool, memo: String, category: Int){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientName)
        if ing.count < 1 {
            let ingredient = Ingredient()
            ingredient.ingredientName = ingredientName
            ingredient.katakanaLowercasedNameForSearch = ingredientName.katakanaLowercasedForSearch()
            ingredient.stockFlag = stockFlag
            ingredient.memo = memo
            ingredient.category = category
            realm.add(ingredient)
        }
    }
    
    func addRecipeToIngredientLink(recipeName:String, ingredientName:String, amount:String, mustFlag:Bool, displayOrder:Int){
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
    
    func updateRecipeShortageNum(recipeName: String){
        let realm = try! Realm()
        let rec = realm.objects(Recipe.self).filter("recipeName == %@",recipeName)
        if rec.count > 0 {
            let recipe = realm.objects(Recipe.self).filter("recipeName == %@",recipeName).first!
            recipe.updateShortageNum()
        }

    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }else{
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
                if isRecovering == false {
                    if recoverableSampleRecipeList.count == 0{
                        let alertView = CustomAlertController(title: nil, message: "復元できるレシピはありません", preferredStyle: .alert)
                        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                        }))
                        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                        alertView.modalPresentationCapturesStatusBarAppearance = true
                        self.present(alertView, animated: true, completion: nil)
                    }else{
                        let alertView = CustomAlertController(title: nil, message: String(recoverableSampleRecipeList.count) + "個のサンプルレシピを\n復元します", preferredStyle: .alert)
                        alertView.addAction(UIAlertAction(title: "復元", style: .default, handler: {action in
                            self.isRecovering = true
                            MessageHUD.show("復元中...", for: nil, withCheckmark: false, isCenter: true)
                            DispatchQueue.global(qos: .userInitiated).async {
                                for i in 0..<self.recoverableSampleRecipeList.count {
                                    self.recoverableSampleRecipeList[i].recoverTarget = true
                                }
                                self.recover()
                                DispatchQueue.main.async{
                                    MessageHUD.show("復元が完了しました", for: 2.0, withCheckmark: true, isCenter: true)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }))
                        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                        alertView.modalPresentationCapturesStatusBarAppearance = true
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            }else{
                if isRecovering == false {
                    let storyboard = UIStoryboard(name: "Recover", bundle: nil)
                    let nvc = storyboard.instantiateViewController(withIdentifier: "RecoverPreviewNavigationController") as! BasicNavigationController
                    let vc = nvc.visibleViewController as! RecoverPreviewTableViewController
                    let realm = try! Realm()
                    if indexPath.row - 1 < recoverableSampleRecipeList.count{
                        let recipe = realm.objects(Recipe.self).filter("recipeName == %@", recoverableSampleRecipeList[indexPath.row - 1].name).first!
                        vc.recipe = recipe
                    }else{
                        let recipe = realm.objects(Recipe.self).filter("recipeName == %@", unrecoverableSampleRecipeList[indexPath.row - 1 - recoverableSampleRecipeList.count].name).first!
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
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.tableViewHeaderBackgroundColor
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.tableViewHeaderTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = section == 1 ? "復元したいレシピを選んでください" : ""
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return recoverableSampleRecipeList.count + unrecoverableSampleRecipeList.count + 1
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecoverDescription") as! RecoverDescriptionTableViewCell
            cell.recoverableRecipeNum = recoverableSampleRecipeList.count
            cell.sampleRecipeNum = recoverableSampleRecipeList.count + unrecoverableSampleRecipeList.count
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            return cell
        case 1:
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecoverAll") as! RecoverAllTableViewCell
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecoverTarget") as! RecoverTargetTableViewCell
                
                let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")
                let accesoryImageView = UIImageView(image: disclosureIndicator)
                accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
                accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                cell.accessoryView = accesoryImageView

                cell.isTarget.stateChangeAnimation = .fade
                cell.isTarget.animationDuration = 0.0
                cell.isTarget.backgroundColor = UIColor.clear
                cell.isTarget.boxLineWidth = 1.0
                cell.isTarget.secondaryTintColor = UchicockStyle.primaryColor
                cell.isTarget.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

                if indexPath.row - 1 < recoverableSampleRecipeList.count{
                    cell.recipeName.text = recoverableSampleRecipeList[indexPath.row - 1].name
                    cell.isTarget.isEnabled = true
                    cell.isTarget.tintColor = UchicockStyle.primaryColor
                    if recoverableSampleRecipeList[indexPath.row - 1].recoverTarget{
                        cell.isTarget.setCheckState(.checked, animated: true)
                    }else{
                        cell.isTarget.setCheckState(.unchecked, animated: true)
                    }
                    cell.isRecoverable = true
                    cell.isTarget.addTarget(self, action: #selector(RecoverTableViewController.isTargetTapped(_:)), for: UIControl.Event.valueChanged)
                }else{
                    cell.recipeName.text = unrecoverableSampleRecipeList[indexPath.row - 1 - recoverableSampleRecipeList.count].name
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
            }
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
    
    @IBAction func recoverButtonTapped(_ sender: UIBarButtonItem) {
        if isRecovering == false{
            var recoverCount = 0
            for rr in recoverableSampleRecipeList{
                if rr.recoverTarget{
                    recoverCount += 1
                }
            }
            
            if recoverCount == 0{
                changeToUserDb()
                self.dismiss(animated: true, completion: nil)
            }else{
                let alertView = CustomAlertController(title: nil, message: String(recoverCount) + "個のサンプルレシピを\n復元します", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "復元", style: .default, handler: {action in
                    self.isRecovering = true
                    MessageHUD.show("復元中...", for: nil, withCheckmark: false, isCenter: true)
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.recover()
                        DispatchQueue.main.async{
                            MessageHUD.show("復元が完了しました", for: 2.0, withCheckmark: true, isCenter: true)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }))
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        return pc
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissModalAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }

}
