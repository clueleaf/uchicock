//
//  RecipeListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchConditionLabel: CustomLabel!
    @IBOutlet weak var searchConditionModifyButton: UIButton!
    @IBOutlet weak var containerSeparator: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var recipeList: Results<Recipe>?
    var recipeBasicList = Array<RecipeBasic>()
    var scrollBeginingYPoint: CGFloat = 0.0
    let selectedCellBackgroundView = UIView()
    var selectedRecipeId: String? = nil
    var selectedIndexPath: IndexPath? = nil
    
    var recipeSortPrimary = 1
    var recipeSortSecondary = 0
    var recipeFilterStar0 = true
    var recipeFilterStar1 = true
    var recipeFilterStar2 = true
    var recipeFilterStar3 = true
    var recipeFilterLong = true
    var recipeFilterShort = true
    var recipeFilterHot = true
    var recipeFilterStyleNone = true
    var recipeFilterBuild = true
    var recipeFilterStir = true
    var recipeFilterShake = true
    var recipeFilterBlend = true
    var recipeFilterOthers = true
    
    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getTextFieldFromView(view: searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.gray

        let defaults = UserDefaults.standard
        let dic = ["firstLaunch": true]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "firstLaunch") {
            performSegue(withIdentifier: "usage", sender: nil)
            defaults.set(false, forKey: "firstLaunch")
        }
        
        self.tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        
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
        setupVC()
    }
    
    private func setupVC(){
        searchContainer.backgroundColor = Style.filterContainerBackgroundColor
        searchBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.layer.borderColor = Style.memoBorderColor.cgColor
            searchBar.searchTextField.layer.borderWidth = 1.0
            searchBar.searchTextField.layer.cornerRadius = 8.0
        }else{
            for view in searchBar.subviews {
                for subview in view.subviews {
                    if subview is UITextField {
                        let textField: UITextField = subview as! UITextField
                        textField.layer.borderColor = Style.memoBorderColor.cgColor
                        textField.layer.borderWidth = 1.0
                        textField.layer.cornerRadius = 8.0
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
        
        searchConditionModifyButton.layer.borderColor = Style.secondaryColor.cgColor
        searchConditionModifyButton.layer.borderWidth = 1.5
        searchConditionModifyButton.layer.cornerRadius = 15
        searchConditionModifyButton.tintColor = Style.secondaryColor
        searchConditionModifyButton.backgroundColor = Style.basicBackgroundColor
        
        containerSeparator.backgroundColor = Style.labelTextColor

        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black

        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        
        loadSearchUserDefaults()
        setSearchConditionLabel()
        reloadRecipeList()
        tableView.reloadData()

        if let path = selectedIndexPath {
            if tableView.numberOfRows(inSection: 0) > path.row{
                let nowRecipeId = (tableView.cellForRow(at: path) as? RecipeTableViewCell)?.recipe.id
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
    
    private func loadSearchUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["recipe-sort-primary" : 1])
        defaults.register(defaults: ["recipe-sort-secondary" : 0])
        defaults.register(defaults: ["recipe-filter-star0" : true])
        defaults.register(defaults: ["recipe-filter-star1" : true])
        defaults.register(defaults: ["recipe-filter-star2" : true])
        defaults.register(defaults: ["recipe-filter-star3" : true])
        defaults.register(defaults: ["recipe-filter-long" : true])
        defaults.register(defaults: ["recipe-filter-short" : true])
        defaults.register(defaults: ["recipe-filter-hot" : true])
        defaults.register(defaults: ["recipe-filter-stylenone" : true])
        defaults.register(defaults: ["recipe-filter-build" : true])
        defaults.register(defaults: ["recipe-filter-stir" : true])
        defaults.register(defaults: ["recipe-filter-shake" : true])
        defaults.register(defaults: ["recipe-filter-blend" : true])
        defaults.register(defaults: ["recipe-filter-others" : true])

        recipeSortPrimary = defaults.integer(forKey: "recipe-sort-primary")
        recipeSortSecondary = defaults.integer(forKey: "recipe-sort-secondary")
        recipeFilterStar0 = defaults.bool(forKey: "recipe-filter-star0")
        recipeFilterStar1 = defaults.bool(forKey: "recipe-filter-star1")
        recipeFilterStar2 = defaults.bool(forKey: "recipe-filter-star2")
        recipeFilterStar3 = defaults.bool(forKey: "recipe-filter-star3")
        recipeFilterLong = defaults.bool(forKey: "recipe-filter-long")
        recipeFilterShort = defaults.bool(forKey: "recipe-filter-short")
        recipeFilterHot = defaults.bool(forKey: "recipe-filter-hot")
        recipeFilterStyleNone = defaults.bool(forKey: "recipe-filter-stylenone")
        recipeFilterBuild = defaults.bool(forKey: "recipe-filter-build")
        recipeFilterStir = defaults.bool(forKey: "recipe-filter-stir")
        recipeFilterShake = defaults.bool(forKey: "recipe-filter-shake")
        recipeFilterBlend = defaults.bool(forKey: "recipe-filter-blend")
        recipeFilterOthers = defaults.bool(forKey: "recipe-filter-others")
    }
    
    private func setSearchConditionLabel(){
        var conditionText = ""
        
        switch recipeSortPrimary{
        case 1:
            conditionText = "名前順"
        case 2:
            conditionText = "作れる順"
        case 3:
            conditionText = "作った回数順"
        case 4:
            conditionText = "お気に入り順"
        case 5:
            conditionText = "最近見た順"
        default:
            conditionText = "名前順"
        }
        
        if recipeSortPrimary > 1 && recipeSortPrimary < 5{
            switch recipeSortSecondary{
            case 1:
                conditionText += " > 名前順"
            case 2:
                conditionText += " > 作れる順"
            case 3:
                conditionText += " > 作った回数順"
            case 4:
                conditionText += " > お気に入り順"
            case 5:
                conditionText += " > 最近見た順"
            default:
                conditionText += " > 名前順"
            }
        }
        
        if recipeFilterStar0 && recipeFilterStar1 && recipeFilterStar2 && recipeFilterStar3 &&
            recipeFilterLong && recipeFilterShort && recipeFilterHot && recipeFilterStyleNone &&
            recipeFilterBuild && recipeFilterStir && recipeFilterShake && recipeFilterBlend && recipeFilterOthers {
        }else{
            conditionText += "、絞り込みあり"
        }

        searchConditionLabel.text = conditionText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTableBackgroundView() // 実行端末のサイズがStoryboardsと異なる時、EmptyDataの表示位置がずれないようにするために必要
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
        self.tableView.flashScrollIndicators()
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
    
    private func deleteRecipe(id: String) {
        let realm = try! Realm()
        let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: id)!
        
        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
        for ri in recipe.recipeIngredients{
            let recipeIngredient = realm.object(ofType: RecipeIngredientLink.self, forPrimaryKey: ri.id)!
            deletingRecipeIngredientList.append(recipeIngredient)
        }
        
        _ = ImageUtil.remove(imageFileName: recipe.imageFileName)
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
    
    private func searchBarTextWithoutSpace() -> String {
        return searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    private func reloadRecipeList(){
        let realm = try! Realm()
        recipeList = realm.objects(Recipe.self)
        reloadRecipeBasicList()
    }
    
    private func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        for recipe in recipeList!{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, imageFileName: recipe.imageFileName))
        }
        
        if searchBarTextWithoutSpace() != ""{
            recipeBasicList.removeAll{ !$0.name.katakana().lowercased().withoutMiddleDot().contains(searchBarTextWithoutSpace().katakana().lowercased().withoutMiddleDot()) }
        }
            
        if recipeFilterStar0 == false{
            recipeBasicList.removeAll{ $0.favorites == 0 }
        }
        if recipeFilterStar1 == false{
            recipeBasicList.removeAll{ $0.favorites == 1 }
        }
        if recipeFilterStar2 == false{
            recipeBasicList.removeAll{ $0.favorites == 2 }
        }
        if recipeFilterStar3 == false{
            recipeBasicList.removeAll{ $0.favorites == 3 }
        }
        if recipeFilterLong == false{
            recipeBasicList.removeAll{ $0.style == 0 }
        }
        if recipeFilterShort == false{
            recipeBasicList.removeAll{ $0.style == 1 }
        }
        if recipeFilterHot == false{
            recipeBasicList.removeAll{ $0.style == 2 }
        }
        if recipeFilterStyleNone == false{
            recipeBasicList.removeAll{ $0.style == 3 }
        }
        if recipeFilterBuild == false{
            recipeBasicList.removeAll{ $0.method == 0 }
        }
        if recipeFilterStir == false{
            recipeBasicList.removeAll{ $0.method == 1 }
        }
        if recipeFilterShake == false{
            recipeBasicList.removeAll{ $0.method == 2 }
        }
        if recipeFilterBlend == false{
            recipeBasicList.removeAll{ $0.method == 3 }
        }
        if recipeFilterOthers == false{
            recipeBasicList.removeAll{ $0.method == 4 }
        }

        switch recipeSortPrimary{
        case 1: // 名前順
            recipeBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
        case 2:
            switch recipeSortSecondary{
            case 1: // 作れる順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.shortageNum == b.shortageNum {
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
                    } else {
                        return a.shortageNum < b.shortageNum
                    }
                })
            case 3: // 作れる順 > 作った回数順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.shortageNum == b.shortageNum {
                        if a.madeNum == b.madeNum{
                            return a.name.localizedStandardCompare(b.name) == .orderedAscending
                        }else{
                            return a.madeNum > b.madeNum
                        }
                    } else {
                        return a.shortageNum < b.shortageNum
                    }
                })
            case 4: // 作れる順 > お気に入り順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.shortageNum == b.shortageNum {
                        if a.favorites == b.favorites{
                            return a.name.localizedStandardCompare(b.name) == .orderedAscending
                        }else{
                            return a.favorites > b.favorites
                        }
                    } else {
                        return a.shortageNum < b.shortageNum
                    }
                })
            case 5: // 作れる順 > 最近見た順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.shortageNum == b.shortageNum {
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
                    } else {
                        return a.shortageNum < b.shortageNum
                    }
                })
            default: // 作れる順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.shortageNum == b.shortageNum {
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
                    } else {
                        return a.shortageNum < b.shortageNum
                    }
                })
            }
        case 3:
            switch recipeSortSecondary{
            case 1: // 作った回数順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.madeNum == b.madeNum {
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
                    } else {
                        return a.madeNum > b.madeNum
                    }
                })
            case 2: // 作った回数順 > 作れる順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.madeNum == b.madeNum {
                        if a.shortageNum == b.shortageNum{
                            return a.name.localizedStandardCompare(b.name) == .orderedAscending
                        }else{
                            return a.shortageNum < b.shortageNum
                        }
                    } else {
                        return a.madeNum > b.madeNum
                    }
                })
            case 4: // 作った回数順 > お気に入り順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.madeNum == b.madeNum {
                        if a.favorites == b.favorites{
                            return a.name.localizedStandardCompare(b.name) == .orderedAscending
                        }else{
                            return a.favorites > b.favorites
                        }
                    } else {
                        return a.madeNum > b.madeNum
                    }
                })
            case 5: // 作った回数順 > 最近見た順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.madeNum == b.madeNum {
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
                    } else {
                        return a.madeNum > b.madeNum
                    }
                })
            default: // 作った回数順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.madeNum == b.madeNum {
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
                    } else {
                        return a.madeNum > b.madeNum
                    }
                })
            }
        case 4:
            switch recipeSortSecondary{
            case 1: // お気に入り順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.favorites == b.favorites {
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
                    } else {
                        return a.favorites > b.favorites
                    }
                })
            case 2: // お気に入り順 > 作れる順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.favorites == b.favorites {
                        if a.shortageNum == b.shortageNum{
                            return a.name.localizedStandardCompare(b.name) == .orderedAscending
                        }else{
                            return a.shortageNum < b.shortageNum
                        }
                    } else {
                        return a.favorites > b.favorites
                    }
                })
            case 3: // お気に入り順 > 作った回数順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.favorites == b.favorites {
                        if a.madeNum == b.madeNum {
                            return a.name.localizedStandardCompare(b.name) == .orderedAscending
                        }else{
                            return a.madeNum > b.madeNum
                        }
                    } else {
                        return a.favorites > b.favorites
                    }
                })
            case 5: // お気に入り順 > 最近見た順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.favorites == b.favorites {
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
                    } else {
                        return a.favorites > b.favorites
                    }
                })
            default: // お気に入り順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.favorites == b.favorites {
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
                    } else {
                        return a.favorites > b.favorites
                    }
                })
            }
        case 5: // 最近見た順 > 名前順
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
        default: // 名前順
            recipeBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
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
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: self.tableView.bounds.size.height / 5, width: self.tableView.bounds.size.width, height: 60))
            noDataLabel.numberOfLines = 0
            noDataLabel.text = "条件にあてはまるレシピはありません"
            if recipeFilterStar0 && recipeFilterStar1 && recipeFilterStar2 && recipeFilterStar3 &&
                recipeFilterLong && recipeFilterShort && recipeFilterHot && recipeFilterStyleNone &&
                recipeFilterBuild && recipeFilterStir && recipeFilterShake && recipeFilterBlend && recipeFilterOthers {
            }else{
                noDataLabel.text! += "\n絞り込み条件を変えると見つかるかもしれません"
            }

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
                
                editNavi.modalPresentationStyle = .fullScreen
                editNavi.modalTransitionStyle = .coverVertical
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!
            if recipeSortPrimary == 3{
                cell.subInfoType = 1
            }else if recipeSortPrimary == 5{
                cell.subInfoType = 2
            }else if recipeSortPrimary == 2{
                if recipeSortSecondary == 3{
                    cell.subInfoType = 1
                }else if recipeSortSecondary == 5{
                    cell.subInfoType = 2
                }else{
                    cell.subInfoType = 0
                }
            }else{
                cell.subInfoType = 0
            }
            cell.recipe = recipe
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if let editNavi = UIStoryboard(name: "RecipeEdit", bundle: nil).instantiateViewController(withIdentifier: "RecipeEditNavigation") as? UINavigationController{
            guard var history = self.navigationController?.viewControllers,
                let editVC = editNavi.visibleViewController as? RecipeEditTableViewController,
                let detailVC = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as? RecipeDetailTableViewController else{
                    return
            }
            
            editNavi.modalPresentationStyle = .fullScreen
            editNavi.modalTransitionStyle = .coverVertical
            history.append(detailVC)
            editVC.detailVC = detailVC
            self.present(editNavi, animated: true, completion: {
                self.navigationController?.setViewControllers(history, animated: false)
            })
        }
    }
    
    @IBAction func searchConditionModifyButtonTapped(_ sender: UIButton) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        let storyboard = UIStoryboard(name: "RecipeSearch", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeSearchModalNavigationController") as! UINavigationController
        nvc.modalPresentationStyle = .custom
        nvc.transitioningDelegate = self
        let vc = nvc.visibleViewController as! RecipeSearchViewController
        vc.onDoneBlock = {
            self.setupVC()
        }
        vc.interactor = interactor
        vc.userDefaultsPrefix = "recipe-"
        searchBar.resignFirstResponder()
        present(nvc, animated: true)
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
