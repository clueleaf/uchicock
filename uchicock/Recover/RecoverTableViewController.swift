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
    let leastWaitTime = 0.15
    let selectedCellBackgroundView = UIView()
    
    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserRecipe()
        
        var config = Realm.Configuration(schemaVersion: 8)
        config.fileURL = Bundle.main.url(forResource: "default", withExtension: "realm")
        config.readOnly = true
        Realm.Configuration.defaultConfiguration = config

        loadSampleRecipe()
        setNavigationTitle()
        isRecovering = false
        
        var safeAreaBottom: CGFloat = 0.0
        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)

        tableView.backgroundColor = Style.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
    }
    
    private func cellDeselectAnimation(){
        if let index = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.backgroundColor = Style.basicBackgroundColor
    }
    
    func changeToUserDb(){
        var config = Realm.Configuration(schemaVersion: 8)
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
        self.navigationItem.title = "サンプルレシピ復元(" + String(recoverCount) + ")"
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
                
                var recoverRecipe = RecoverRecipe(name: recipe.recipeName,style: recipe.style, method: recipe.method, ingredientList: [])
                for ri in recipe.recipeIngredients{
                    recoverRecipe.ingredientList.append(RecipeIngredientBasic(id: "", ingredientName: ri.ingredient.ingredientName, amount: ri.amount, mustFlag: ri.mustFlag, category: ri.ingredient.category))
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
                    addRecipe(recipeName: recoverRecipe.name, favorites: 0, memo: "", style: recoverRecipe.style, method: recoverRecipe.method)
                    
                    for recoverIngredient in recoverRecipe.ingredientList{
                        addRecipeToIngredientLink(recipeName: recoverRecipe.name, ingredientName: recoverIngredient.ingredientName, amount: recoverIngredient.amount, mustFlag: recoverIngredient.mustFlag)
                    }
                    updateRecipeShortageNum(recipeName: recoverRecipe.name)
                }
            }
        }
    }
    
    func addRecipe(recipeName:String, favorites:Int, memo:String, style:Int, method:Int){
        let realm = try! Realm()
        let rec = realm.objects(Recipe.self).filter("recipeName == %@",recipeName)
        if rec.count < 1 {
            let recipe = Recipe()
            recipe.recipeName = recipeName
            recipe.favorites = favorites
            recipe.memo = memo
            recipe.style = style
            recipe.method = method
            realm.add(recipe)
        }
    }
    
    func addIngredient(ingredientName: String, stockFlag: Bool, memo: String, category: Int){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientName)
        if ing.count < 1 {
            let ingredient = Ingredient()
            ingredient.ingredientName = ingredientName
            ingredient.stockFlag = stockFlag
            ingredient.memo = memo
            ingredient.category = category
            realm.add(ingredient)
        }
    }
    
    func addRecipeToIngredientLink(recipeName:String, ingredientName:String, amount:String, mustFlag:Bool){
        let realm = try! Realm()
        let recipeIngredientLink = RecipeIngredientLink()
        recipeIngredientLink.amount = amount
        recipeIngredientLink.mustFlag = mustFlag
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
    
    func waitAtLeast(_ time : TimeInterval, _ block: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent()
        let wait = max(0.0, time - (end - start))
        if wait > 0.0 {
            Thread.sleep(forTimeInterval: wait)
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
                        alertView.alertStatusBarStyle = Style.statusBarStyle
                        alertView.modalPresentationCapturesStatusBarAppearance = true
                        self.present(alertView, animated: true, completion: nil)
                    }else{
                        let alertView = CustomAlertController(title: nil, message: String(recoverableSampleRecipeList.count) + "個のサンプルレシピを\n復元します", preferredStyle: .alert)
                        alertView.addAction(UIAlertAction(title: "復元", style: .default, handler: {action in
                            self.isRecovering = true
                            ProgressHUD.show(with: "復元中...")
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.waitAtLeast(self.leastWaitTime) {
                                    for i in 0..<self.recoverableSampleRecipeList.count {
                                        self.recoverableSampleRecipeList[i].recoverTarget = true
                                    }
                                    self.recover()
                                }
                                DispatchQueue.main.async{
                                    ProgressHUD.showSuccess(with: "復元が完了しました", duration: 1.5)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }))
                        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                        alertView.alertStatusBarStyle = Style.statusBarStyle
                        alertView.modalPresentationCapturesStatusBarAppearance = true
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            }else{
                if isRecovering == false {
                    let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                    let nvc = storyboard.instantiateViewController(withIdentifier: "RecoverPreviewNavigationController") as! BasicNavigationController
                    nvc.modalPresentationStyle = .custom
                    nvc.transitioningDelegate = self
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
                    vc.interactor = interactor
                    present(nvc, animated: true)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if section == 1 {
            label.text = "  復元したいレシピを選んでください"
        }else{
            label.text = nil
        }
        return label
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
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        case 1:
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecoverAll") as! RecoverAllTableViewCell
                cell.backgroundColor = Style.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecoverTarget") as! RecoverTargetTableViewCell
                cell.isTarget.stateChangeAnimation = .fade
                cell.isTarget.animationDuration = 0.0
                cell.isTarget.backgroundColor = UIColor.clear
                cell.isTarget.boxLineWidth = 1.0
                cell.isTarget.secondaryTintColor = Style.checkboxSecondaryTintColor
                
                if indexPath.row - 1 < recoverableSampleRecipeList.count{
                    cell.recipeName.text = recoverableSampleRecipeList[indexPath.row - 1].name
                    cell.isTarget.isEnabled = true
                    cell.isTarget.tintColor = Style.secondaryColor
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
                    cell.isTarget.tintColor = Style.badgeDisableBackgroundColor
                    cell.isTarget.setCheckState(.mixed, animated: true)
                    cell.isRecoverable = false
                }
                cell.backgroundColor = Style.basicBackgroundColor
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
                    ProgressHUD.show(with: "復元中...")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.waitAtLeast(self.leastWaitTime) {
                            self.recover()
                        }
                        DispatchQueue.main.async{
                            ProgressHUD.showSuccess(with: "復元が完了しました", duration: 1.5)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }))
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                alertView.alertStatusBarStyle = Style.statusBarStyle
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
