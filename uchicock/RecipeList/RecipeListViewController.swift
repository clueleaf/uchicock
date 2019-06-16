//
//  RecipeListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import M13Checkbox

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

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
        return Style.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getTextFieldFromView(view: searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        let defaults = UserDefaults.standard
        let dic = ["firstLaunch": true]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "firstLaunch") {
            performSegue(withIdentifier: "usage", sender: nil)
            defaults.set(false, forKey: "firstLaunch")
        }
        
        initM13CheckboxStyle(buildCheckbox)
        initM13CheckboxStyle(stirCheckbox)
        initM13CheckboxStyle(shakeCheckbox)
        initM13CheckboxStyle(blendCheckbox)
        initM13CheckboxStyle(othersCheckbox)
        
        buildFilterButton.contentHorizontalAlignment = .left
        stirFilterButton.contentHorizontalAlignment = .left
        shakeFilterButton.contentHorizontalAlignment = .left
        blendFilterButton.contentHorizontalAlignment = .left
        othersFilterButton.contentHorizontalAlignment = .left
        
        let realm = try! Realm()
        recipeList = realm.objects(Recipe.self)
        try! realm.write {
            for recipe in recipeList!{
                recipe.updateShortageNum()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControlContainer.backgroundColor = Style.filterContainerBackgroundColor
        self.tableView.backgroundColor = Style.basicBackgroundColor
        searchBar.backgroundImage = UIImage()
        let attribute = [NSAttributedString.Key.foregroundColor:Style.secondaryColor]
        favoriteSelect.setTitleTextAttributes(attribute, for: .normal)
        order.setTitleTextAttributes(attribute, for: .normal)
        updateMethodFilterColorOf(buildCheckbox, and: buildFilterButton)
        updateMethodFilterColorOf(stirCheckbox, and: stirFilterButton)
        updateMethodFilterColorOf(shakeCheckbox, and: shakeFilterButton)
        updateMethodFilterColorOf(blendCheckbox, and: blendFilterButton)
        updateMethodFilterColorOf(othersCheckbox, and: othersFilterButton)

        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    let textField: UITextField = subview as! UITextField
                    textField.layer.borderColor = Style.memoBorderColor.cgColor
                    textField.layer.borderWidth = 1.0
                    textField.layer.cornerRadius = 5.0
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
    
    // MARK: - Set Color
    private func initM13CheckboxStyle(_ checkbox: M13Checkbox){
        checkbox.boxLineWidth = 1.0
        checkbox.markType = .checkmark
        checkbox.boxType = .circle
        checkbox.stateChangeAnimation = .fade(.fill)
        checkbox.animationDuration = 0
        checkbox.setCheckState(.checked, animated: true)
        checkbox.animationDuration = 0.3
        checkbox.stateChangeAnimation = .expand(.fill)
    }
    
    private func updateMethodFilterColorOf(_ checkbox: M13Checkbox, and button: UIButton){
        checkbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        if checkbox.checkState == .checked{
            button.tintColor = Style.secondaryColor
            if Style.no == "6" {
                button.tintColor = Style.labelTextColor
            }
        }else if checkbox.checkState == .unchecked{
            button.tintColor = Style.labelTextColorLight
            if Style.no == "6" {
                button.tintColor = FlatColor.white
            }
        }
    }
    
    private func updateMethodFilterColorWhenButtonTappedOf(_ checkbox: M13Checkbox, and button: UIButton){
        if checkbox.checkState == .checked{
            checkbox.setCheckState(.unchecked, animated: true)
            button.tintColor = Style.labelTextColorLight
            if Style.no == "6" {
                button.tintColor = FlatColor.white
            }
        }else if checkbox.checkState == .unchecked{
            checkbox.setCheckState(.checked, animated: true)
            button.tintColor = Style.secondaryColor
            if Style.no == "6" {
                button.tintColor = Style.labelTextColor
            }
        }
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
        reloadRecipeBasicList()
    }
    
    func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        for recipe in recipeList!{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method))
        }
        
        if searchBarTextWithoutSpace() != ""{
            recipeBasicList.removeAll{ !$0.name.katakana().lowercased().withoutMiddleDot().contains(searchBarTextWithoutSpace().katakana().lowercased().withoutMiddleDot()) }
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
            recipeBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
        }else if order.selectedSegmentIndex == 1{
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.name.localizedStandardCompare(b.name) == .orderedAscending
                } else {
                    return a.shortageNum < b.shortageNum
                }
            })
        }else if order.selectedSegmentIndex == 2{
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.lastViewDate == nil{
                    if b.lastViewDate == nil{
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
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
                    return a.name.localizedStandardCompare(b.name) == .orderedAscending
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
        
        setTableBackgroundView()
    }
    
    func setTableBackgroundView(){
        if recipeBasicList.count == 0{
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: self.tableView.bounds.size.height / 4, width: self.tableView.bounds.size.width, height: 20))
            noDataLabel.text = "条件にあてはまるレシピはありません"
            noDataLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            noDataLabel.textAlignment = .center
            self.tableView.backgroundView = UIView()
            self.tableView.backgroundView?.addSubview(noDataLabel)
            self.tableView.isScrollEnabled = false
        }else{
            self.tableView.backgroundView = nil
            self.tableView.isScrollEnabled = true
        }
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
            let alertView = CustomAlertController(title: nil, message: "本当に削除しますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                self.deleteRecipe(id: self.recipeBasicList[indexPath.row].id)
                self.recipeBasicList.remove(at: indexPath.row)
                self.setTableBackgroundView()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if let allRecipeNum = self.recipeList?.count{
                    self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + "/" + String(allRecipeNum) + ")"
                }else{
                    self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + ")"
                }
            }))
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
            alertView.alertStatusBarStyle = Style.statusBarStyle
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
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
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
        updateMethodFilterColorOf(buildCheckbox, and: buildFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func stirCheckboxTapped(_ sender: M13Checkbox) {
        updateMethodFilterColorOf(stirCheckbox, and: stirFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func shakeCheckboxTapped(_ sender: M13Checkbox) {
        updateMethodFilterColorOf(shakeCheckbox, and: shakeFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func blendCheckboxTapped(_ sender: M13Checkbox) {
        updateMethodFilterColorOf(blendCheckbox, and: blendFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func othersCheckboxTapped(_ sender: M13Checkbox) {
        updateMethodFilterColorOf(othersCheckbox, and: othersFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func buildFilterButtonTapped(_ sender: UIButton) {
        updateMethodFilterColorWhenButtonTappedOf(buildCheckbox, and: buildFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func stirFilterButtonTapped(_ sender: UIButton) {
        updateMethodFilterColorWhenButtonTappedOf(stirCheckbox, and: stirFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func shakeFilterButtonTapped(_ sender: UIButton) {
        updateMethodFilterColorWhenButtonTappedOf(shakeCheckbox, and: shakeFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func blendFilterButtonTapped(_ sender: UIButton) {
        updateMethodFilterColorWhenButtonTappedOf(blendCheckbox, and: blendFilterButton)
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func othersFilterButtonTapped(_ sender: UIButton) {
        updateMethodFilterColorWhenButtonTappedOf(othersCheckbox, and: othersFilterButton)
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
        }else if segue.identifier == "usage" {
            let vc = segue.destination as! IntroductionPageViewController
            vc.introductions = introductions()
            vc.backgroundImage = UIImage(named:"launch-background")
        }
    }
    
    func introductions() -> [introductionInfo]{
        let info1 = introductionInfo(title: "Thank you for downloading!!",
                                    description: "ダウンロードしていただき、ありがとうございます！\n使い方を簡単に説明します。\n\n※この説明は後からでも確認できます。",
                                    image: nil)
        let info2 = introductionInfo(title: "レシピ",
                                     description: "レシピの検索や新規登録はこの画面から。\nサンプルレシピですら、編集して自前でアレンジ可能！\nカクテルをつくったらぜひ写真を登録してみよう！",
                                     image: UIImage(named:"screen-recipe"))
        let info3 = introductionInfo(title: "材料",
                                     description: "ワンタップで材料の在庫を登録できます。\n在庫を登録すると、今の手持ちで作れるレシピがわかります。",
                                     image: UIImage(named:"screen-ingredient"))
        let info4 = introductionInfo(title: "逆引き",
                                     description: "3つまで材料を指定して、それらをすべて使うレシピを逆引きできます。\n「あの材料とあの材料を使うカクテル何だっけ？」\nそんなときに活用しよう！",
                                     image: UIImage(named:"screen-reverse-lookup"))
        let info5 = introductionInfo(title: "アルバム",
                                     description: "アプリに登録されているレシピの写真だけを取り出して表示します。\n表示順をシャッフルして、気まぐれにカクテルを選んでみては？",
                                     image: UIImage(named:"screen-album"))
        
        var infos: [introductionInfo] = []
        infos.append(info1)
        infos.append(info2)
        infos.append(info3)
        infos.append(info4)
        infos.append(info5)
        return infos
    }
}
