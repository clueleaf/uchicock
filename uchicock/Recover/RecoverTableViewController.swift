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
        
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        
        recoverTargetCheckbox.isEnabled = false
        recoverTargetCheckbox.checkState = .checked
        recoverTargetCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        recoverTargetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        nonRecoverTargetCheckbox.isEnabled = false
        nonRecoverTargetCheckbox.checkState = .unchecked
        nonRecoverTargetCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        nonRecoverTargetCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        unableRecoverCheckbox.isEnabled = false
        unableRecoverCheckbox.checkState = .mixed
        unableRecoverCheckbox.tintColor = UchicockStyle.labelTextColorLight
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
        recoverSelectedLabel.text = "選択した0レシピのみを復元"
        recoverSelectedLabel.textColor = UchicockStyle.labelTextColorLight
        
        tableView.register(UINib(nibName: "RecoverTableViewCell", bundle: nil), forCellReuseIdentifier: "RecoverCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        let defaults = UserDefaults.standard
        defaults.set(true, forKey: GlobalConstants.Version81NewRecipeViewedKey)
    }
    
    // MARK: - Logic functions
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

    private func changeToUserDb(){
        var config = Realm.Configuration(schemaVersion: GlobalConstants.RealmSchemaVersion)
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
    }
    
    @objc func isTargetTapped(_ sender: CircularCheckbox){
        guard isRecovering == false else { return }

        var view = sender.superview
        while (view! is RecoverTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! RecoverTableViewCell
        let touchIndex = self.tableView.indexPath(for: cell)
        
        guard let index = touchIndex, index.row < recoverableSampleRecipeList.count else{ return }
        recoverableSampleRecipeList[index.row].recoverTarget = sender.checkState == .checked
        
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
            let rec = realm2.objects(Recipe.self).filter("recipeName == %@", recoverRecipe.name)
            if rec.count > 0 { continue }
            try! realm2.write {
                let r = realm2.objects(Recipe.self).filter("recipeName == %@", recoverRecipe.name)
                if r.count < 1 {
                    let recipe = Recipe()
                    recipe.recipeName = recoverRecipe.name
                    recipe.recipeNameYomi = recoverRecipe.nameYomi
                    recipe.katakanaLowercasedNameForSearch = recoverRecipe.katakanaLowercasedNameForSearch
                    recipe.style = recoverRecipe.style
                    recipe.method = recoverRecipe.method
                    recipe.strength = recoverRecipe.strength
                    realm2.add(recipe)
                }

                for recoverIngredient in recoverRecipe.ingredientList{
                    let ing = realm2.objects(Ingredient.self).filter("ingredientName == %@", recoverIngredient.ingredientName)
                    if ing.count < 1 {
                        let ingredient = Ingredient()
                        ingredient.ingredientName = recoverIngredient.ingredientName
                        ingredient.ingredientNameYomi = recoverIngredient.ingredientNameYomi
                        ingredient.katakanaLowercasedNameForSearch = recoverIngredient.katakanaLowercasedNameForSearch
                        ingredient.category = recoverIngredient.category
                        realm2.add(ingredient)
                    }

                    let recipeIngredientLink = RecipeIngredientLink()
                    recipeIngredientLink.amount = recoverIngredient.amount
                    recipeIngredientLink.mustFlag = recoverIngredient.mustFlag
                    recipeIngredientLink.displayOrder = recoverIngredient.displayOrder
                    realm2.add(recipeIngredientLink)
                    
                    let ingredient = realm2.objects(Ingredient.self).filter("ingredientName == %@", recoverIngredient.ingredientName).first!
                    ingredient.recipeIngredients.append(recipeIngredientLink)
                    
                    let recipe = realm2.objects(Recipe.self).filter("recipeName == %@", recoverRecipe.name).first!
                    recipe.recipeIngredients.append(recipeIngredientLink)
                }
                
                let rec = realm2.objects(Recipe.self).filter("recipeName == %@", recoverRecipe.name)
                if rec.count > 0 { rec.first!.updateShortageNum() }
            }
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
        
        switch (indexPath.section, indexPath.row){
        case let(section, row) where section == 0 && row == 1:
            tableView.deselectRow(at: indexPath, animated: true)
            if recoverableSampleRecipeList.count == 0{
                let alertView = CustomAlertController(title: nil, message: "復元できるレシピはありません", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                if #available(iOS 13.0, *){ action.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                alertView.addAction(action)
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
            }else{
                let recipeNum = recoverableSampleRecipeList.count
                let alertView = CustomAlertController(title: nil, message: "復元できる" + String(recipeNum) + "レシピを全て復元します", preferredStyle: .alert)
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
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
            }
        case let(section, row) where section == 0 && row == 2:
            tableView.deselectRow(at: indexPath, animated: true)
            var recoverCount = 0
            for rr in recoverableSampleRecipeList where rr.recoverTarget{
                recoverCount += 1
            }
            
            if recoverCount == 0{ break }
            let alertView = CustomAlertController(title: nil, message: "選択した" + String(recoverCount) + "レシピを復元します", preferredStyle: .alert)
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
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        case let(section, _) where section == 1:
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
                if let index = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: index, animated: true)
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
                nvc.modalPresentationStyle = .pageSheet
            }else{
                nvc.modalPresentationStyle = .custom
                nvc.transitioningDelegate = self
                vc.interactor = interactor
            }
            present(nvc, animated: true)
        default: break
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

            if indexPath.row < recoverableSampleRecipeList.count{
                cell.isRecoverable = true
                cell.recipe = recoverableSampleRecipeList[indexPath.row]
                cell.targetCheckbox.addTarget(self, action: #selector(RecoverTableViewController.isTargetTapped(_:)), for: UIControl.Event.valueChanged)
            }else{
                cell.isRecoverable = false
                cell.recipe = unrecoverableSampleRecipeList[indexPath.row - recoverableSampleRecipeList.count]
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
        guard isRecovering == false else { return }
        changeToUserDb()
        self.dismiss(animated: true, completion: nil)
    }
        
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissModalAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
