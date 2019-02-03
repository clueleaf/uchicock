//
//  RecipeListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import DZNEmptyDataSet
import MYBlurIntroductionView
import M13Checkbox

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MYIntroductionDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var favoriteSelect: UISegmentedControl!
    @IBOutlet weak var order: UISegmentedControl!
    @IBOutlet weak var buildCheckbox: M13Checkbox!
    @IBOutlet weak var stirCheckbox: M13Checkbox!
    @IBOutlet weak var shakeCheckbox: M13Checkbox!
    @IBOutlet weak var blendCheckbox: M13Checkbox!
    @IBOutlet weak var othersCheckbox: M13Checkbox!
    @IBOutlet weak var buildFilterButton: UIButton!
    @IBOutlet weak var stirFilterButton: UIButton!
    @IBOutlet weak var shakeFilterButton: UIButton!
    @IBOutlet weak var blendFilterButton: UIButton!
    @IBOutlet weak var othersFilterButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var recipeList: Results<Recipe>?
    var recipeBasicList = Array<RecipeBasic>()
    var scrollBeginingYPoint: CGFloat = 0.0
    let selectedCellBackgroundView = UIView()
    var selectedRecipeId: String? = nil
    var selectedIndexPath: IndexPath? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if Style.isStatusBarLight{
            return .lightContent
        }else{
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getTextFieldFromView(view: searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        let defaults = UserDefaults.standard
        let dic = ["firstLaunch": true]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "firstLaunch") {
            showIntroduction()
            defaults.set(false, forKey: "firstLaunch")
        }
        
        buildCheckbox.boxLineWidth = 1.0
        buildCheckbox.markType = .checkmark
        buildCheckbox.boxType = .circle
        stirCheckbox.boxLineWidth = 1.0
        stirCheckbox.markType = .checkmark
        stirCheckbox.boxType = .circle
        shakeCheckbox.boxLineWidth = 1.0
        shakeCheckbox.markType = .checkmark
        shakeCheckbox.boxType = .circle
        blendCheckbox.boxLineWidth = 1.0
        blendCheckbox.markType = .checkmark
        blendCheckbox.boxType = .circle
        othersCheckbox.boxLineWidth = 1.0
        othersCheckbox.markType = .checkmark
        othersCheckbox.boxType = .circle

        buildCheckbox.stateChangeAnimation = .fade(.fill)
        buildCheckbox.animationDuration = 0
        buildCheckbox.setCheckState(.checked, animated: true)
        buildCheckbox.animationDuration = 0.3
        buildCheckbox.stateChangeAnimation = .expand(.fill)
        stirCheckbox.stateChangeAnimation = .fade(.fill)
        stirCheckbox.animationDuration = 0
        stirCheckbox.setCheckState(.checked, animated: true)
        stirCheckbox.animationDuration = 0.3
        stirCheckbox.stateChangeAnimation = .expand(.fill)
        shakeCheckbox.stateChangeAnimation = .fade(.fill)
        shakeCheckbox.animationDuration = 0
        shakeCheckbox.setCheckState(.checked, animated: true)
        shakeCheckbox.animationDuration = 0.3
        shakeCheckbox.stateChangeAnimation = .expand(.fill)
        blendCheckbox.stateChangeAnimation = .fade(.fill)
        blendCheckbox.animationDuration = 0
        blendCheckbox.setCheckState(.checked, animated: true)
        blendCheckbox.animationDuration = 0.3
        blendCheckbox.stateChangeAnimation = .expand(.fill)
        othersCheckbox.stateChangeAnimation = .fade(.fill)
        othersCheckbox.animationDuration = 0
        othersCheckbox.setCheckState(.checked, animated: true)
        othersCheckbox.animationDuration = 0.3
        othersCheckbox.stateChangeAnimation = .expand(.fill)
        
        buildFilterButton.contentHorizontalAlignment = .left
        stirFilterButton.contentHorizontalAlignment = .left
        shakeFilterButton.contentHorizontalAlignment = .left
        blendFilterButton.contentHorizontalAlignment = .left
        othersFilterButton.contentHorizontalAlignment = .left
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControlContainer.backgroundColor = Style.filterContainerBackgroundColor
        self.tableView.backgroundColor = Style.basicBackgroundColor
        searchBar.backgroundColor = Style.filterContainerBackgroundColor
        searchBar.tintColor = Style.labelTextColor
        favoriteSelect.backgroundColor = Style.basicBackgroundColor
        favoriteSelect.tintColor = Style.secondaryColor
        order.backgroundColor = Style.basicBackgroundColor
        order.tintColor = Style.secondaryColor
        let attribute = [NSAttributedString.Key.foregroundColor:Style.secondaryColor]
        favoriteSelect.setTitleTextAttributes(attribute, for: .normal)
        order.setTitleTextAttributes(attribute, for: .normal)
        buildCheckbox.backgroundColor = UIColor.clear
        buildCheckbox.tintColor = Style.secondaryColor
        buildCheckbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        stirCheckbox.backgroundColor = UIColor.clear
        stirCheckbox.tintColor = Style.secondaryColor
        stirCheckbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        shakeCheckbox.backgroundColor = UIColor.clear
        shakeCheckbox.tintColor = Style.secondaryColor
        shakeCheckbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        blendCheckbox.backgroundColor = UIColor.clear
        blendCheckbox.tintColor = Style.secondaryColor
        blendCheckbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        othersCheckbox.backgroundColor = UIColor.clear
        othersCheckbox.tintColor = Style.secondaryColor
        othersCheckbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        if buildCheckbox.checkState == .checked{
            buildFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                buildFilterButton.tintColor = Style.labelTextColor
            }
        }else if buildCheckbox.checkState == .unchecked{
            buildFilterButton.tintColor = Style.labelTextColorLight
        }
        if stirCheckbox.checkState == .checked{
            stirFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                stirFilterButton.tintColor = Style.labelTextColor
            }
        }else if stirCheckbox.checkState == .unchecked{
            stirFilterButton.tintColor = Style.labelTextColorLight
        }
        if shakeCheckbox.checkState == .checked{
            shakeFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                shakeFilterButton.tintColor = Style.labelTextColor
            }
        }else if shakeCheckbox.checkState == .unchecked{
            shakeFilterButton.tintColor = Style.labelTextColorLight
        }
        if blendCheckbox.checkState == .checked{
            blendFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                blendFilterButton.tintColor = Style.labelTextColor
            }
        }else if blendCheckbox.checkState == .unchecked{
            blendFilterButton.tintColor = Style.labelTextColorLight
        }
        if othersCheckbox.checkState == .checked{
            othersFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                othersFilterButton.tintColor = Style.labelTextColor
            }
        }else if othersCheckbox.checkState == .unchecked{
            othersFilterButton.tintColor = Style.labelTextColorLight
        }

        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    let textField: UITextField = subview as! UITextField
                    textField.backgroundColor = Style.textFieldBackgroundColor
                    textField.textColor = Style.labelTextColor
                    textField.layer.borderColor = Style.memoBorderColor.cgColor
                    textField.layer.borderWidth = 1.0
                    textField.layer.cornerRadius = 5.0
                    if Style.isDark{
                        textField.keyboardAppearance = .dark
                    }else{
                        textField.keyboardAppearance = .default
                    }
                    for subsubview in subview.subviews{
                        if subsubview is UILabel{
                            let placeholderLabel = subsubview as! UILabel
                            placeholderLabel.textColor = Style.labelTextColor
                        }
                    }
                }
            }
        }

        reloadRecipeList()
        tableView.reloadData()
        
        if let path = selectedIndexPath {
            if tableView.numberOfRows(inSection: 0) > path.row{
                let nowRecipeId = (tableView.cellForRow(at: path) as? RecipeListItemTableViewCell)?.recipe.id
                if nowRecipeId != nil && selectedRecipeId != nil{
                    if nowRecipeId! == selectedRecipeId!{
                        tableView.selectRow(at: path, animated: false, scrollPosition: .none)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.tableView.deselectRow(at: path, animated: true)
                        }
                    }
                }
            }
        }
        selectedRecipeId = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    for subsubview in subview.subviews{
                        if subsubview is UILabel{
                            let placeholderLabel = subsubview as! UILabel
                            placeholderLabel.textColor = Style.labelTextColor
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTextFieldFromView(view: UIView) -> UITextField?{
        for subview in view.subviews{
            if subview is UITextField{
                return subview as? UITextField
            }else{
                let textField = self.getTextFieldFromView(view: subview)
                if textField != nil{
                    return textField
                }
            }
        }
        return nil
    }
    
    func deleteRecipe(id: String) {
        let realm = try! Realm()
        let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: id)!
        
        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
        for ri in recipe.recipeIngredients{
            let recipeIngredient = realm.object(ofType: RecipeIngredientLink.self, forPrimaryKey: ri.id)!
            deletingRecipeIngredientList.append(recipeIngredient)
        }
        
        try! realm.write{
            for ri in deletingRecipeIngredientList{
                let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                for i in 0 ..< ingredient.recipeIngredients.count where i < ingredient.recipeIngredients.count{
                    if ingredient.recipeIngredients[i].id == ri.id{
                        ingredient.recipeIngredients.remove(at: i)
                    }
                }
            }
            for ri in deletingRecipeIngredientList{
                realm.delete(ri)
            }
            realm.delete(recipe)
        }
    }
    
    func searchBarTextWithoutSpace() -> String {
        return searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func reloadRecipeList(){
        let realm = try! Realm()
        recipeList = realm.objects(Recipe.self)
        if order.selectedSegmentIndex == 1{
            try! realm.write {
                for recipe in recipeList!{
                    recipe.updateShortageNum()
                }
            }
        }
        reloadRecipeBasicList()
    }
    
    func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        for recipe in recipeList!{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method))
        }
        
        if searchBarTextWithoutSpace() != ""{
            recipeBasicList.removeAll{ !$0.kanaName.contains(searchBarTextWithoutSpace().katakana().lowercased()) }
        }
        
        recipeBasicList.removeAll{ $0.favorites < favoriteSelect.selectedSegmentIndex }
        
        if buildCheckbox.checkState == .unchecked{
            recipeBasicList.removeAll{
                $0.method == 0
            }
        }
        if stirCheckbox.checkState == .unchecked{
            recipeBasicList.removeAll{
                $0.method == 1
            }
        }
        if shakeCheckbox.checkState == .unchecked{
            recipeBasicList.removeAll{
                $0.method == 2
            }
        }
        if blendCheckbox.checkState == .unchecked{
            recipeBasicList.removeAll{
                $0.method == 3
            }
        }
        if othersCheckbox.checkState == .unchecked{
            recipeBasicList.removeAll{
                $0.method == 4
            }
        }

        if order.selectedSegmentIndex == 0{
            recipeBasicList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })
        }else if order.selectedSegmentIndex == 1{
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.japaneseDictionaryOrder.lowercased() < b.japaneseDictionaryOrder.lowercased()
                } else {
                    return a.shortageNum < b.shortageNum
                }
            })
        }else if order.selectedSegmentIndex == 2{
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.lastViewDate == nil{
                    if b.lastViewDate == nil{
                        return a.japaneseDictionaryOrder.lowercased() < b.japaneseDictionaryOrder.lowercased()
                    }else{
                        return false
                    }
                }else{
                    if b.lastViewDate == nil{
                        return true
                    }else{
                        return a.lastViewDate! > b.lastViewDate!
                    }
                }
            })
        }else if order.selectedSegmentIndex == 3{
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    return a.japaneseDictionaryOrder.lowercased() < b.japaneseDictionaryOrder.lowercased()
                } else {
                    return a.madeNum > b.madeNum
                }
            })
        }
        
        if let allRecipeNum = recipeList?.count{
            self.navigationItem.title = "レシピ(" + String(recipeBasicList.count) + "/" + String(allRecipeNum) + ")"
        }else{
            self.navigationItem.title = "レシピ(" + String(recipeBasicList.count) + ")"
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまるレシピはありません"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -self.tableView.frame.size.height/4.0
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: false)
    }
    
    func showIntroduction(){
        let desc0 = "ダウンロードしていただき、ありがとうございます！\n使い方を簡単に説明します。\n\n※この説明は後からでも確認できます。"
        let introductionPanel0 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "Thank you for downloading!!", description: desc0)
        
        let desc1 = "レシピの検索や新規登録はこの画面から。\nサンプルレシピですら、編集して自前でアレンジ可能！\nカクテルをつくったらぜひ写真を登録してみよう！"
        let introductionPanel1 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "レシピ", description: desc1, image: UIImage(named: "screen-recipe"))
        introductionPanel1!.panelImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        let desc2 = "ワンタップで材料の在庫を登録できます。\n在庫を登録すると、今の手持ちで作れるレシピがわかります。"
        let introductionPanel2 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "材料", description: desc2, image: UIImage(named: "screen-ingredient"))
        introductionPanel2!.panelImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        let desc3 = "3つまで材料を指定して、それらをすべて使うレシピを逆引きできます。\n「あの材料とあの材料を使うカクテル何だっけ？」\nそんなときに活用しよう！"
        let introductionPanel3 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "逆引き", description: desc3, image: UIImage(named: "screen-reverse-lookup"))
        introductionPanel3!.panelImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        let desc4 = "アプリに登録されているレシピの写真だけを取り出して表示します。\n表示順をシャッフルして、気まぐれにカクテルを選んでみては？"
        let introductionPanel4 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "アルバム", description: desc4, image: UIImage(named: "screen-album"))
        introductionPanel4!.panelImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        let introductionView = MYBlurIntroductionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        introductionView.backgroundImageView.image = UIImage(named: "launch-background")
        introductionView.rightSkipButton.backgroundColor = UIColor.clear
        introductionView.pageControl.currentPageIndicatorTintColor = FlatYellow()
        introductionView.pageControl.pageIndicatorTintColor = FlatOrange()
        introductionView.delegate = self
        introductionView.buildIntroduction(withPanels: [introductionPanel0!,introductionPanel1!,introductionPanel2!,introductionPanel3!, introductionPanel4!])
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(introductionView)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0{
            scrollBeginingYPoint = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50{
            searchBar.becomeFirstResponder()
        }else if scrollBeginingYPoint < scrollView.contentOffset.y {
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.reloadRecipeBasicList()
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.reloadRecipeBasicList()
            self.tableView.reloadData()
        }
        return true
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            if recipeList == nil{
                reloadRecipeList()
            }
            return recipeBasicList.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "編集") {
            (action, indexPath) in
            if let editNavi = UIStoryboard(name: "RecipeEdit", bundle: nil).instantiateViewController(withIdentifier: "RecipeEditNavigation") as? UINavigationController{
                guard var history = self.navigationController?.viewControllers,
                    let editVC = editNavi.visibleViewController as? RecipeEditTableViewController,
                    let detailVC = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as? RecipeDetailTableViewController else{
                        return
                }
                let realm = try! Realm()
                let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: self.recipeBasicList[indexPath.row].id)!
                self.selectedRecipeId = self.recipeBasicList[indexPath.row].id
                self.selectedIndexPath = indexPath
                editVC.recipe = recipe
                
                history.append(detailVC)
                editVC.detailVC = detailVC
                self.present(editNavi, animated: true, completion: {
                    self.navigationController?.setViewControllers(history, animated: false)
                })
            }
        }
        edit.backgroundColor = Style.tableViewCellEditBackgroundColor
        
        let del = UITableViewRowAction(style: .default, title: "削除") {
            (action, indexPath) in
            let alertView = UIAlertController(title: nil, message: "本当に削除しますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                self.deleteRecipe(id: self.recipeBasicList[indexPath.row].id)
                self.recipeBasicList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if let allRecipeNum = self.recipeList?.count{
                    self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + "/" + String(allRecipeNum) + ")"
                }else{
                    self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + ")"
                }
            }))
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
            if Style.isStatusBarLight{
                alertView.setStatusBarStyle(.lightContent)
            }else{
                alertView.setStatusBarStyle(.default)
            }
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        }
        del.backgroundColor = Style.deleteColor
        
        return [del, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeListItem") as! RecipeListItemTableViewCell
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!
            cell.recipe = recipe
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func favoriteStateTapped(_ sender: UISegmentedControl) {
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func orderTapped(_ sender: UISegmentedControl) {
        if order.selectedSegmentIndex == 1{
            let realm = try! Realm()
            try! realm.write {
                for recipe in recipeList!{
                    recipe.updateShortageNum()
                }
            }
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if let editNavi = UIStoryboard(name: "RecipeEdit", bundle: nil).instantiateViewController(withIdentifier: "RecipeEditNavigation") as? UINavigationController{
            guard var history = self.navigationController?.viewControllers,
                let editVC = editNavi.visibleViewController as? RecipeEditTableViewController,
                let detailVC = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as? RecipeDetailTableViewController else{
                    return
            }
            
            history.append(detailVC)
            editVC.detailVC = detailVC
            self.present(editNavi, animated: true, completion: {
                self.navigationController?.setViewControllers(history, animated: false)
            })
        }
    }
    
    @IBAction func buildCheckboxTapped(_ sender: M13Checkbox) {
        if buildCheckbox.checkState == .checked{
            buildFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                buildFilterButton.tintColor = Style.labelTextColor
            }
        }else if buildCheckbox.checkState == .unchecked{
            buildFilterButton.tintColor = Style.labelTextColorLight
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func stirCheckboxTapped(_ sender: M13Checkbox) {
        if stirCheckbox.checkState == .checked{
            stirFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                stirFilterButton.tintColor = Style.labelTextColor
            }
        }else if stirCheckbox.checkState == .unchecked{
            stirFilterButton.tintColor = Style.labelTextColorLight
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func shakeCheckboxTapped(_ sender: M13Checkbox) {
        if shakeCheckbox.checkState == .checked{
            shakeFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                shakeFilterButton.tintColor = Style.labelTextColor
            }
        }else if shakeCheckbox.checkState == .unchecked{
            shakeFilterButton.tintColor = Style.labelTextColorLight
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func blendCheckboxTapped(_ sender: M13Checkbox) {
        if blendCheckbox.checkState == .checked{
            blendFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                blendFilterButton.tintColor = Style.labelTextColor
            }
        }else if blendCheckbox.checkState == .unchecked{
            blendFilterButton.tintColor = Style.labelTextColorLight
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func othersCheckboxTapped(_ sender: M13Checkbox) {
        if othersCheckbox.checkState == .checked{
            othersFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                othersFilterButton.tintColor = Style.labelTextColor
            }
        }else if othersCheckbox.checkState == .unchecked{
            othersFilterButton.tintColor = Style.labelTextColorLight
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func buildFilterButtonTapped(_ sender: UIButton) {
        if buildCheckbox.checkState == .checked{
            buildCheckbox.setCheckState(.unchecked, animated: true)
            buildFilterButton.tintColor = Style.labelTextColorLight
        }else if buildCheckbox.checkState == .unchecked{
            buildCheckbox.setCheckState(.checked, animated: true)
            buildFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                buildFilterButton.tintColor = Style.labelTextColor
            }
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func stirFilterButtonTapped(_ sender: UIButton) {
        if stirCheckbox.checkState == .checked{
            stirCheckbox.setCheckState(.unchecked, animated: true)
            stirFilterButton.tintColor = Style.labelTextColorLight
        }else if stirCheckbox.checkState == .unchecked{
            stirCheckbox.setCheckState(.checked, animated: true)
            stirFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                stirFilterButton.tintColor = Style.labelTextColor
            }
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func shakeFilterButtonTapped(_ sender: UIButton) {
        if shakeCheckbox.checkState == .checked{
            shakeCheckbox.setCheckState(.unchecked, animated: true)
            shakeFilterButton.tintColor = Style.labelTextColorLight
        }else if shakeCheckbox.checkState == .unchecked{
            shakeCheckbox.setCheckState(.checked, animated: true)
            shakeFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                shakeFilterButton.tintColor = Style.labelTextColor
            }
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func blendFilterButtonTapped(_ sender: UIButton) {
        if blendCheckbox.checkState == .checked{
            blendCheckbox.setCheckState(.unchecked, animated: true)
            blendFilterButton.tintColor = Style.labelTextColorLight
        }else if blendCheckbox.checkState == .unchecked{
            blendCheckbox.setCheckState(.checked, animated: true)
            blendFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                blendFilterButton.tintColor = Style.labelTextColor
            }
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func othersFilterButtonTapped(_ sender: UIButton) {
        if othersCheckbox.checkState == .checked{
            othersCheckbox.setCheckState(.unchecked, animated: true)
            othersFilterButton.tintColor = Style.labelTextColorLight
        }else if othersCheckbox.checkState == .unchecked{
            othersCheckbox.setCheckState(.checked, animated: true)
            othersFilterButton.tintColor = Style.secondaryColor
            if Style.no == "6" {
                othersFilterButton.tintColor = Style.labelTextColor
            }
        }
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedRecipeId = recipeBasicList[indexPath.row].id
                selectedIndexPath = indexPath
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        }
    }
}
