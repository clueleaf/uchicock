//
//  ReverseLookupViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class ReverseLookupTableViewController: UITableViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var ingredientSuggestTableView: UITableView!
    @IBOutlet weak var ingredientNumberLabel1: UILabel!
    @IBOutlet weak var ingredientNumberLabel2: UILabel!
    @IBOutlet weak var ingredientNumberLabel3: UILabel!
    @IBOutlet weak var ingredientTextField1: UITextField!
    @IBOutlet weak var ingredientTextField2: UITextField!
    @IBOutlet weak var ingredientTextField3: UITextField!
    @IBOutlet weak var searchConditionLabel: UILabel!
    @IBOutlet weak var searchConditionModifyButton: UIButton!
    
    var firstIngredientName = ""
    var secondIngredientName = ""
    var thirdIngredientName = ""
    var editingTextField: Int = -1
    var selectedRecipeId: String? = nil
    var recipeBasicList = Array<RecipeBasic>()
    var ingredientList: Results<Ingredient>?
    var ingredientSuggestList = Array<IngredientBasic>()
    let selectedCellBackgroundView = UIView()
    var safeAreaHeight: CGFloat = 0
    var transitioningSection1 = false
    var shoudlHideSearchCell = false
    
    var recipeSortPrimary = 1
    var recipeSortSecondary = 0
    var recipeFilterStar0 = true
    var recipeFilterStar1 = true
    var recipeFilterStar2 = true
    var recipeFilterStar3 = true
    var recipeFilterLong = true
    var recipeFilterShort = true
    var recipeFilterBuild = true
    var recipeFilterStir = true
    var recipeFilterShake = true
    var recipeFilterBlend = true
    var recipeFilterOthers = true
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientTextField1.delegate = self
        ingredientTextField2.delegate = self
        ingredientTextField3.delegate = self
        ingredientTextField1.tag = 0
        ingredientTextField2.tag = 1
        ingredientTextField3.tag = 2
        ingredientTextField1.layer.cornerRadius = 5.0
        ingredientTextField2.layer.cornerRadius = 5.0
        ingredientTextField3.layer.cornerRadius = 5.0
        ingredientTextField1.layer.borderWidth = 1
        ingredientTextField2.layer.borderWidth = 1
        ingredientTextField3.layer.borderWidth = 1

        self.tableView.tag = 0
        recipeTableView.tag = 1
        ingredientSuggestTableView.tag = 2

        recipeTableView.tableFooterView = UIView(frame: CGRect.zero)
        ingredientSuggestTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.recipeTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")

        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
        
        clearButton.isEnabled = true
        cancelButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setVC()
    }
    
    private func setVC(){
        let window = UIApplication.shared.keyWindow
        safeAreaHeight = view.frame.size.height - window!.safeAreaInsets.top - window!.safeAreaInsets.bottom
        
        let selectedPathForRecipeTableView = recipeTableView.indexPathForSelectedRow
        
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.tableView.backgroundColor = Style.basicBackgroundColor
        recipeTableView.backgroundColor = Style.basicBackgroundColor
        ingredientSuggestTableView.backgroundColor = Style.basicBackgroundColor
        recipeTableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        ingredientSuggestTableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        ingredientNumberLabel1.textColor = Style.labelTextColorLight
        ingredientNumberLabel2.textColor = Style.labelTextColorLight
        ingredientNumberLabel3.textColor = Style.labelTextColorLight
        ingredientTextField1.layer.borderColor = Style.memoBorderColor.cgColor
        ingredientTextField2.layer.borderColor = Style.memoBorderColor.cgColor
        ingredientTextField3.layer.borderColor = Style.memoBorderColor.cgColor
        
        searchConditionLabel.textColor = Style.labelTextColor
        searchConditionModifyButton.layer.borderColor = Style.secondaryColor.cgColor
        searchConditionModifyButton.layer.borderWidth = 1.0
        searchConditionModifyButton.layer.cornerRadius = 5
        searchConditionModifyButton.tintColor = Style.secondaryColor
        searchConditionModifyButton.backgroundColor = Style.basicBackgroundColor
        
        loadIngredientsFromUserDefaults()
        loadSearchUserDefaults()
        setSearchConditionLabel()
        reloadRecipeList()
        recipeTableView.reloadData()
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange1(_:)), name: UITextField.textDidChangeNotification, object: self.ingredientTextField1)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange2(_:)), name: UITextField.textDidChangeNotification, object: self.ingredientTextField2)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange3(_:)), name: UITextField.textDidChangeNotification, object: self.ingredientTextField3)
        
        if let path = selectedPathForRecipeTableView {
            if recipeTableView.numberOfRows(inSection: 0) > path.row{
                let nowRecipeId = (recipeTableView.cellForRow(at: path) as? RecipeTableViewCell)?.recipe.id
                if nowRecipeId != nil && selectedRecipeId != nil{
                    if nowRecipeId! == selectedRecipeId!{
                        recipeTableView.selectRow(at: path, animated: false, scrollPosition: .none)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.recipeTableView.deselectRow(at: path, animated: true)
                        }
                    }
                }
            }
        }
        selectedRecipeId = nil
    }
    
    private func loadSearchUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["reverse-lookup-sort-primary" : 1])
        defaults.register(defaults: ["reverse-lookup-sort-secondary" : 0])
        defaults.register(defaults: ["reverse-lookup-filter-star0" : true])
        defaults.register(defaults: ["reverse-lookup-filter-star1" : true])
        defaults.register(defaults: ["reverse-lookup-filter-star2" : true])
        defaults.register(defaults: ["reverse-lookup-filter-star3" : true])
        defaults.register(defaults: ["reverse-lookup-filter-long" : true])
        defaults.register(defaults: ["reverse-lookup-filter-short" : true])
        defaults.register(defaults: ["reverse-lookup-filter-build" : true])
        defaults.register(defaults: ["reverse-lookup-filter-stir" : true])
        defaults.register(defaults: ["reverse-lookup-filter-shake" : true])
        defaults.register(defaults: ["reverse-lookup-filter-blend" : true])
        defaults.register(defaults: ["reverse-lookup-filter-others" : true])
        
        recipeSortPrimary = defaults.integer(forKey: "reverse-lookup-sort-primary")
        recipeSortSecondary = defaults.integer(forKey: "reverse-lookup-sort-secondary")
        recipeFilterStar0 = defaults.bool(forKey: "reverse-lookup-filter-star0")
        recipeFilterStar1 = defaults.bool(forKey: "reverse-lookup-filter-star1")
        recipeFilterStar2 = defaults.bool(forKey: "reverse-lookup-filter-star2")
        recipeFilterStar3 = defaults.bool(forKey: "reverse-lookup-filter-star3")
        recipeFilterLong = defaults.bool(forKey: "reverse-lookup-filter-long")
        recipeFilterShort = defaults.bool(forKey: "reverse-lookup-filter-short")
        recipeFilterBuild = defaults.bool(forKey: "reverse-lookup-filter-build")
        recipeFilterStir = defaults.bool(forKey: "reverse-lookup-filter-stir")
        recipeFilterShake = defaults.bool(forKey: "reverse-lookup-filter-shake")
        recipeFilterBlend = defaults.bool(forKey: "reverse-lookup-filter-blend")
        recipeFilterOthers = defaults.bool(forKey: "reverse-lookup-filter-others")
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
            recipeFilterLong && recipeFilterShort && recipeFilterBuild && recipeFilterStir &&
            recipeFilterShake && recipeFilterBlend && recipeFilterOthers {
        }else{
            conditionText += "、絞り込みあり"
        }
        
        searchConditionLabel.text = conditionText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.recipeTableView.flashScrollIndicators()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func loadIngredientsFromUserDefaults(){
        let defaults = UserDefaults.standard
        if let first = defaults.string(forKey: "ReverseLookupFirst"){
            ingredientTextField1.text = textWithoutSpace(text: first)
        }else{
            defaults.set("", forKey: "ReverseLookupFirst")
        }
        if let second = defaults.string(forKey: "ReverseLookupSecond"){
            ingredientTextField2.text = textWithoutSpace(text: second)
        }else{
            defaults.set("", forKey: "ReverseLookupSecond")
        }
        if let third = defaults.string(forKey: "ReverseLookupThird"){
            ingredientTextField3.text = textWithoutSpace(text: third)
        }else{
            defaults.set("", forKey: "ReverseLookupThird")
        }
    }
    
    func setUserDefaultsSearchText(){
        let defaults = UserDefaults.standard
        defaults.set(textWithoutSpace(text: ingredientTextField1.text!), forKey: "ReverseLookupFirst")
        defaults.set(textWithoutSpace(text: ingredientTextField2.text!), forKey: "ReverseLookupSecond")
        defaults.set(textWithoutSpace(text: ingredientTextField3.text!), forKey: "ReverseLookupThird")
    }
    
    func reloadRecipeList(){
        recipeBasicList.removeAll()
        
        if ingredientTextField1.text != nil && textWithoutSpace(text: ingredientTextField1.text!) != ""{
            if ingredientTextField2.text != nil && textWithoutSpace(text: ingredientTextField2.text!) != ""{
                if ingredientTextField3.text != nil && textWithoutSpace(text: ingredientTextField3.text!) != ""{
                    createRecipeBasicList(text1: textWithoutSpace(text: ingredientTextField1.text!), text2: textWithoutSpace(text: ingredientTextField2.text!), text3: textWithoutSpace(text: ingredientTextField3.text!))
                }else{
                    createRecipeBasicList(text1: textWithoutSpace(text: ingredientTextField1.text!), text2: textWithoutSpace(text: ingredientTextField2.text!), text3: nil)
                }
            }else{
                if ingredientTextField3.text != nil && textWithoutSpace(text: ingredientTextField3.text!) != ""{
                    createRecipeBasicList(text1: textWithoutSpace(text: ingredientTextField1.text!), text2: textWithoutSpace(text: ingredientTextField3.text!), text3: nil)
                }else{
                    createRecipeBasicList(text1: textWithoutSpace(text: ingredientTextField1.text!), text2: nil, text3: nil)
                }
            }
        }else{
            if ingredientTextField2.text != nil && textWithoutSpace(text: ingredientTextField2.text!) != ""{
                if ingredientTextField3.text != nil && textWithoutSpace(text: ingredientTextField3.text!) != ""{
                    createRecipeBasicList(text1: textWithoutSpace(text: ingredientTextField2.text!), text2: textWithoutSpace(text: ingredientTextField3.text!), text3: nil)
                }else{
                    createRecipeBasicList(text1: textWithoutSpace(text: ingredientTextField2.text!), text2: nil, text3: nil)
                }
            }else{
                if ingredientTextField3.text != nil && textWithoutSpace(text: ingredientTextField3.text!) != ""{
                    createRecipeBasicList(text1: textWithoutSpace(text: ingredientTextField3.text!), text2: nil, text3: nil)
                }else{
                    createRecipeBasicList()
                }
            }
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
            // TODO
        }
        if recipeFilterShort == false{
            // TODO
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
        
        setTableBackgroundView()
    }
    
    private func setTableBackgroundView(){
        if recipeBasicList.count == 0{
            let noDataLabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.recipeTableView.bounds.size.width, height: self.recipeTableView.bounds.size.height))
            noDataLabel.text = "条件にあてはまるレシピはありません"
            noDataLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            noDataLabel.textAlignment = .center
            self.recipeTableView.backgroundView  = UIView()
            self.recipeTableView.backgroundView?.addSubview(noDataLabel)
            self.recipeTableView.isScrollEnabled = false
        }else{
            self.recipeTableView.backgroundView = nil
            self.recipeTableView.isScrollEnabled = true
        }
    }
    
    private func createRecipeBasicList(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for recipe in recipeList{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method))
        }
    }
    
    private func createRecipeBasicList(text1: String, text2: String?, text3: String?){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",text1)
        if ing.count > 0 {
            for ri in ing.first!.recipeIngredients{
                recipeBasicList.append(RecipeBasic(id: ri.recipe.id, name: ri.recipe.recipeName, shortageNum: ri.recipe.shortageNum, favorites: ri.recipe.favorites, lastViewDate: ri.recipe.lastViewDate, madeNum: ri.recipe.madeNum, method: ri.recipe.method))
            }
            if let t2 = text2 {
                deleteFromRecipeBasicList(withoutUse: t2)
                if let t3 = text3{
                    deleteFromRecipeBasicList(withoutUse: t3)
                }
            }
        }
    }
    
    private func deleteFromRecipeBasicList(withoutUse ingredientName: String){
        let realm = try! Realm()
        for i in (0..<recipeBasicList.count).reversed(){
            var hasIngredient = false
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[i].id)!
            for ri in recipe.recipeIngredients{
                if ri.ingredient.ingredientName == ingredientName{
                    hasIngredient = true
                    break
                }
            }
            if hasIngredient == false{
                recipeBasicList.remove(at: i)
            }
        }
    }
    
    func showRecipeTableView(){
        if editingTextField == -1{
            setUserDefaultsSearchText()
            loadIngredientsFromUserDefaults()
            reloadRecipeList()
            recipeTableView.reloadData()
        }else{
            transitioningSection1 = true
            tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .right)
            
            setUserDefaultsSearchText()
            loadIngredientsFromUserDefaults()
            reloadRecipeList()
            recipeTableView.reloadData()
            
            ingredientTextField1.resignFirstResponder()
            ingredientTextField2.resignFirstResponder()
            ingredientTextField3.resignFirstResponder()
            editingTextField = -1
            
            shoudlHideSearchCell = false
            tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .left)
            transitioningSection1 = false
            tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .left)
            self.recipeTableView.flashScrollIndicators()
        }
        clearButton.isEnabled = true
        cancelButton.isEnabled = false
    }
    
    // MARK: - UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        showRecipeTableView()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if editingTextField == -1{
            shoudlHideSearchCell = true
            tableView.deleteRows(at: [IndexPath(row: 3,section: 0)], with: .left)
            transitioningSection1 = true
            tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .left)
            
            reloadIngredientSuggestList(text: textField.text!)
            editingTextField = textField.tag

            transitioningSection1 = false
            tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .right)
            self.ingredientSuggestTableView.flashScrollIndicators()
        }else{
            reloadIngredientSuggestList(text: textField.text!)
            editingTextField = textField.tag
        }
        clearButton.isEnabled = false
        cancelButton.isEnabled = true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        if editingTextField == 0{
            reloadIngredientSuggestList(text: ingredientTextField1.text!)
        }else if editingTextField == 1{
            reloadIngredientSuggestList(text: ingredientTextField2.text!)
        }else if editingTextField == 2{
            reloadIngredientSuggestList(text: ingredientTextField3.text!)
        }else{
            setUserDefaultsSearchText()
            reloadRecipeList()
            recipeTableView.reloadData()
        }
        return false
    }

    @objc func textFieldDidChange1(_ notification: Notification){
        if let text = ingredientTextField1.text {
            if text.count > 30 {
                ingredientTextField1.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            reloadIngredientSuggestList(text: text)
        }
    }
    
    @objc func textFieldDidChange2(_ notification: Notification){
        if let text = ingredientTextField2.text {
            if text.count > 30 {
                ingredientTextField2.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            reloadIngredientSuggestList(text: text)
        }
    }

    @objc func textFieldDidChange3(_ notification: Notification){
        if let text = ingredientTextField3.text {
            if text.count > 30 {
                ingredientTextField3.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            reloadIngredientSuggestList(text: text)
        }
    }

    func reloadIngredientSuggestList(text: String){
        ingredientSuggestTableView.reloadData()
        ingredientSuggestList.removeAll()
        
        for ingredient in ingredientList! {
            ingredientSuggestList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, stockFlag: ingredient.stockFlag, category: ingredient.category))
        }
        
        if textWithoutSpace(text: text) != "" {
            ingredientSuggestList.removeAll{
                !$0.name.katakana().lowercased().withoutMiddleDot().contains(textWithoutSpace(text: text).katakana().lowercased().withoutMiddleDot())
            }
        }
        
        ingredientSuggestList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
        ingredientSuggestTableView.reloadData()
    }
    
    func textWithoutSpace(text: String) -> String{
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 0{
            return 2
        }else if tableView.tag == 1{
            return 1
        }else if tableView.tag == 2{
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 0{
            return 0
        }
        return 25
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 1{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.tableViewHeaderBackgroundColor
            label.textColor = Style.labelTextColorOnDisableBadge
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.text = "  上の材料(完全一致)をすべて使うレシピ(" + String(self.recipeBasicList.count) + ")"
            return label
        }else if tableView.tag == 2{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.tableViewHeaderBackgroundColor
            label.textColor = Style.labelTextColorOnDisableBadge
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.text = "  材料候補"
            return label
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 0{
            if section == 0{
                if shoudlHideSearchCell{
                    return 3
                }else{
                    return 4
                }
            }else if section == 1{
                if transitioningSection1{
                    return 0
                }else{
                    return 1
                }
            }
        }else if tableView.tag == 1{
            return recipeBasicList.count
        }else if tableView.tag == 2{
            return ingredientSuggestList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            if indexPath.section == 0{
                if indexPath.row < 3{
                    return 35
                }else{
                    return 72
                }
            }else if indexPath.section == 1{
                return safeAreaHeight - 35 * 3
            }
        }else if tableView.tag == 1{
            return 70
        }else if tableView.tag == 2{
            return 30
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
            performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }else if tableView.tag == 2{
            tableView.deselectRow(at: indexPath, animated: true)
            switch editingTextField{
            case 0:
                ingredientTextField1.text = ingredientSuggestList[indexPath.row].name
            case 1:
                ingredientTextField2.text = ingredientSuggestList[indexPath.row].name
            case 2:
                ingredientTextField3.text = ingredientSuggestList[indexPath.row].name
            default:
                break
            }
            showRecipeTableView()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 0{
            if indexPath.section == 0{
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.backgroundColor = Style.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                cell.isUserInteractionEnabled = true
                return cell
            }else if indexPath.section == 1{
                if editingTextField == -1{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.isUserInteractionEnabled = true
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.isUserInteractionEnabled = true
                    return cell
                }
            }
        }else if tableView.tag == 1{
            let cell = recipeTableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!
            cell.recipe = recipe
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }else if tableView.tag == 2{
            let cell = ingredientSuggestTableView.dequeueReusableCell(withIdentifier: "SelectIngredient") as! ReverseLookupSelectIngredientTableViewCell
            cell.backgroundColor = Style.basicBackgroundColor
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientSuggestList[indexPath.row].id)!
            cell.ingredient = ingredient
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = CustomAlertController(title: nil, message: "逆引き検索条件をクリアします", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "クリア", style: .default, handler: {action in
            self.ingredientTextField1.text = ""
            self.ingredientTextField2.text = ""
            self.ingredientTextField3.text = ""
            self.showRecipeTableView()
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        alertView.alertStatusBarStyle = Style.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        self.present(alertView, animated: true, completion: nil)
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        transitioningSection1 = true
        tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .right)
        
        loadIngredientsFromUserDefaults()
        reloadRecipeList()
        recipeTableView.reloadData()
        
        ingredientTextField1.resignFirstResponder()
        ingredientTextField2.resignFirstResponder()
        ingredientTextField3.resignFirstResponder()
        editingTextField = -1
        
        shoudlHideSearchCell = false
        tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .left)
        transitioningSection1 = false
        tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .left)
        
        clearButton.isEnabled = true
        cancelButton.isEnabled = false
        self.recipeTableView.flashScrollIndicators()
    }
    
    @IBAction func searchConditionModifyButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "RecipeSearch", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeSearchModalNavigationController") as! UINavigationController
        nvc.modalPresentationStyle = .custom
        nvc.transitioningDelegate = self
        let vc = nvc.visibleViewController as! RecipeSearchViewController
        vc.onDoneBlock = {
            self.setVC()
        }
        vc.userDefaultsPrefix = "reverse-lookup-"
        present(nvc, animated: true)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        return pc
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedRecipeId = recipeBasicList[indexPath.row].id
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        }
    }
}
