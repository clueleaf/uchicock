//
//  ReverseLookupViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class ReverseLookupTableViewController: UITableViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate, UITableViewDataSourcePrefetching, ScrollableToTop {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var ingredientSuggestTableView: UITableView!
    @IBOutlet weak var ingredientTextField1: CustomTextField!
    @IBOutlet weak var ingredientTextField2: CustomTextField!
    @IBOutlet weak var ingredientTextField3: CustomTextField!
    @IBOutlet weak var searchConditionModifyButton: UIButton!
    
    var hiddenLabel = UILabel()
    var firstIngredientName = ""
    var secondIngredientName = ""
    var thirdIngredientName = ""
    var editingTextField: Int = -1
    var selectedRecipeId: String? = nil
    var recipeBasicList = Array<RecipeBasic>()
    var recipeBasicListForFilterModal = Array<RecipeBasic>()
    var ingredientList: Results<Ingredient>?
    var ingredientSuggestList = Array<IngredientBasic>()
    let selectedCellBackgroundView = UIView()

    var textFieldHasSearchResult = false
    var hasNonExistingIngredient1 = false
    var hasNonExistingIngredient2 = false
    var hasNonExistingIngredient3 = false

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
    var recipeFilterNonAlcohol = true
    var recipeFilterWeak = true
    var recipeFilterMedium = true
    var recipeFilterStrong = true
    var recipeFilterStrengthNone = true

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientTextField1.tag = 0
        ingredientTextField2.tag = 1
        ingredientTextField3.tag = 2
        ingredientTextField1.layer.cornerRadius = ingredientTextField1.frame.size.height / 2
        ingredientTextField2.layer.cornerRadius = ingredientTextField2.frame.size.height / 2
        ingredientTextField3.layer.cornerRadius = ingredientTextField3.frame.size.height / 2
        ingredientTextField1.clipsToBounds = true
        ingredientTextField2.clipsToBounds = true
        ingredientTextField3.clipsToBounds = true
        ingredientTextField1.setLeftPadding()
        ingredientTextField2.setLeftPadding()
        ingredientTextField3.setLeftPadding()

        self.tableView.tag = 0
        recipeTableView.tag = 1
        ingredientSuggestTableView.tag = 2

        recipeTableView.tableFooterView = UIView(frame: CGRect.zero)
        ingredientSuggestTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        hiddenLabel.font = UIFont.systemFont(ofSize: 14.0)
        hiddenLabel.text = "Thank you for using うちカク!!!!"
        hiddenLabel.frame = CGRect(x: 0, y: -180, width: 0, height: 20)
        hiddenLabel.textAlignment = .center
        recipeTableView.addSubview(hiddenLabel)
        
        searchConditionModifyButton.layer.borderWidth = 1.5
        searchConditionModifyButton.layer.cornerRadius = searchConditionModifyButton.frame.size.height / 2

        self.recipeTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
        
        cancelButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        recipeTableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        ingredientSuggestTableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        recipeTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        ingredientSuggestTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        recipeTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        ingredientSuggestTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        
        ingredientTextField1.attributedPlaceholder = NSAttributedString(string: "材料1", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientTextField2.attributedPlaceholder = NSAttributedString(string: "材料2", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientTextField3.attributedPlaceholder = NSAttributedString(string: "材料3", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientTextField1.adjustClearButtonColor(with: 5)
        ingredientTextField2.adjustClearButtonColor(with: 5)
        ingredientTextField3.adjustClearButtonColor(with: 5)

        searchConditionModifyButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        searchConditionModifyButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        searchConditionModifyButton.backgroundColor = UchicockStyle.basicBackgroundColor
        
        hiddenLabel.textColor = UchicockStyle.labelTextColorLight

        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange1(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientTextField1)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange2(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientTextField2)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange3(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientTextField3)
        NotificationCenter.default.addObserver(self, selector: #selector(ReverseLookupTableViewController.textFieldDidChange1(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientTextField1)
        NotificationCenter.default.addObserver(self, selector: #selector(ReverseLookupTableViewController.textFieldDidChange2(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientTextField2)
        NotificationCenter.default.addObserver(self, selector: #selector(ReverseLookupTableViewController.textFieldDidChange3(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientTextField3)
        
        if recipeTableView.indexPathsForVisibleRows != nil && selectedRecipeId != nil {
            for indexPath in recipeTableView.indexPathsForVisibleRows! {
                if recipeBasicList.count > indexPath.row {
                    if recipeBasicList[indexPath.row].id == selectedRecipeId! {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.recipeTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                        break
                    }
                }
            }
        }

        loadFromUserDefaults()
        // iPadや画面回転でキーボードが消えるため、他のタブに行ってデータの更新が可能
        // 整合性のために逆引き表示では常にレシピテーブルを表示するようにする
        showRecipeTableView(shouldSetToUserDefaults: false)
        setSearchConditionButtonTitle()
        tableView.reloadData()
    }
    
    private func setupData(){
        loadFromUserDefaults()
        setSearchConditionButtonTitle()
        reloadRecipeList()
        recipeTableView.reloadData()
        tableView.reloadData()
    }
    
    private func loadFromUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.ReverseLookupSortPrimaryKey : 1])
        defaults.register(defaults: [GlobalConstants.ReverseLookupSortSecondaryKey : 0])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStar0Key : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStar1Key : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStar2Key : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStar3Key : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterLongKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterShortKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterHotKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStyleNoneKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterBuildKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStirKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterShakeKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterBlendKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterOthersKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterNonAlcoholKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterWeakKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterMediumKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStrongKey : true])
        defaults.register(defaults: [GlobalConstants.ReverseLookupFilterStrengthNoneKey : true])

        recipeSortPrimary = defaults.integer(forKey: GlobalConstants.ReverseLookupSortPrimaryKey)
        recipeSortSecondary = defaults.integer(forKey: GlobalConstants.ReverseLookupSortSecondaryKey)
        recipeFilterStar0 = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar0Key)
        recipeFilterStar1 = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar1Key)
        recipeFilterStar2 = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar2Key)
        recipeFilterStar3 = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar3Key)
        recipeFilterLong = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterLongKey)
        recipeFilterShort = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterShortKey)
        recipeFilterHot = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterHotKey)
        recipeFilterStyleNone = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStyleNoneKey)
        recipeFilterBuild = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterBuildKey)
        recipeFilterStir = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStirKey)
        recipeFilterShake = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterShakeKey)
        recipeFilterBlend = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterBlendKey)
        recipeFilterOthers = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterOthersKey)
        recipeFilterNonAlcohol = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterNonAlcoholKey)
        recipeFilterWeak = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterWeakKey)
        recipeFilterMedium = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterMediumKey)
        recipeFilterStrong = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStrongKey)
        recipeFilterStrengthNone = defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStrengthNoneKey)

        if let first = defaults.string(forKey: GlobalConstants.ReverseLookupFirstIngredientKey){
            ingredientTextField1.text = first.withoutEndsSpace()
        }else{
            defaults.set("", forKey: GlobalConstants.ReverseLookupFirstIngredientKey)
        }
        if let second = defaults.string(forKey: GlobalConstants.ReverseLookupSecondIngredientKey){
            ingredientTextField2.text = second.withoutEndsSpace()
        }else{
            defaults.set("", forKey: GlobalConstants.ReverseLookupSecondIngredientKey)
        }
        if let third = defaults.string(forKey: GlobalConstants.ReverseLookupThirdIngredientKey){
            ingredientTextField3.text = third.withoutEndsSpace()
        }else{
            defaults.set("", forKey: GlobalConstants.ReverseLookupThirdIngredientKey)
        }
        
        ingredientTextField1.adjustClearButtonColor(with: 5)
        ingredientTextField2.adjustClearButtonColor(with: 5)
        ingredientTextField3.adjustClearButtonColor(with: 5)
    }
    
    private func setSearchConditionButtonTitle(){
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
            recipeFilterBuild && recipeFilterStir && recipeFilterShake && recipeFilterBlend && recipeFilterOthers &&
            recipeFilterNonAlcohol && recipeFilterWeak && recipeFilterMedium && recipeFilterStrong && recipeFilterStrengthNone{
        }else{
            conditionText += "、絞り込み有"
        }
        
        UIView.performWithoutAnimation {
            searchConditionModifyButton.setTitle(conditionText, for: .normal)
            searchConditionModifyButton.layoutIfNeeded()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        tableView.reloadData()
        if editingTextField == 0{
            ingredientTextField1.becomeFirstResponder()
        }else if editingTextField == 1{
            ingredientTextField2.becomeFirstResponder()
        }else if editingTextField == 2{
            ingredientTextField3.becomeFirstResponder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setTableBackgroundView() // 画面リサイズ時や実行端末のサイズがStoryboardsと異なる時、EmptyDataの表示位置がずれないようにするために必要
        hiddenLabel.frame = CGRect(x: 0, y: -180, width: recipeTableView.frame.width, height: 20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTableBackgroundView() // 実行端末のサイズがStoryboardsと異なる時、EmptyDataの表示位置がずれないようにするために必要
        super.viewDidAppear(animated)
        
        if let path = recipeTableView.indexPathForSelectedRow{
            self.recipeTableView.deselectRow(at: path, animated: true)
        }
        selectedRecipeId = nil
        self.recipeTableView.flashScrollIndicators()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func scrollToTop() {
        recipeTableView?.setContentOffset(CGPoint.zero, animated: true)
    }

    private func setSearchTextToUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.set(ingredientTextField1.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupFirstIngredientKey)
        defaults.set(ingredientTextField2.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupSecondIngredientKey)
        defaults.set(ingredientTextField3.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupThirdIngredientKey)
    }
    
    private func reloadRecipeList(){
        createRecipeBasicListWithIngredientTextField(recipeArray: &recipeBasicList)
        textFieldHasSearchResult = recipeBasicList.count > 0
        filterRecipeBasicList()
        sortRecipeBasicList()
        setTableBackgroundView()
    }
    
    private func createRecipeBasicListWithIngredientTextField(recipeArray: inout Array<RecipeBasic>){
        recipeArray.removeAll()
        
        if ingredientTextField1.text != nil && ingredientTextField1.text!.withoutEndsSpace() != ""{
            if ingredientTextField2.text != nil && ingredientTextField2.text!.withoutEndsSpace() != ""{
                if ingredientTextField3.text != nil && ingredientTextField3.text!.withoutEndsSpace() != ""{
                    createRecipeBasicList(recipeArray: &recipeArray, text1: ingredientTextField1.text!.withoutEndsSpace(), text2: ingredientTextField2.text!.withoutEndsSpace(), text3: ingredientTextField3.text!.withoutEndsSpace())
                }else{
                    createRecipeBasicList(recipeArray: &recipeArray, text1: ingredientTextField1.text!.withoutEndsSpace(), text2: ingredientTextField2.text!.withoutEndsSpace(), text3: nil)
                }
            }else{
                if ingredientTextField3.text != nil && ingredientTextField3.text!.withoutEndsSpace() != ""{
                    createRecipeBasicList(recipeArray: &recipeArray, text1: ingredientTextField1.text!.withoutEndsSpace(), text2: ingredientTextField3.text!.withoutEndsSpace(), text3: nil)
                }else{
                    createRecipeBasicList(recipeArray: &recipeArray, text1: ingredientTextField1.text!.withoutEndsSpace(), text2: nil, text3: nil)
                }
            }
        }else{
            if ingredientTextField2.text != nil && ingredientTextField2.text!.withoutEndsSpace() != ""{
                if ingredientTextField3.text != nil && ingredientTextField3.text!.withoutEndsSpace() != ""{
                    createRecipeBasicList(recipeArray: &recipeArray, text1: ingredientTextField2.text!.withoutEndsSpace(), text2: ingredientTextField3.text!.withoutEndsSpace(), text3: nil)
                }else{
                    createRecipeBasicList(recipeArray: &recipeArray, text1: ingredientTextField2.text!.withoutEndsSpace(), text2: nil, text3: nil)
                }
            }else{
                if ingredientTextField3.text != nil && ingredientTextField3.text!.withoutEndsSpace() != ""{
                    createRecipeBasicList(recipeArray: &recipeArray, text1: ingredientTextField3.text!.withoutEndsSpace(), text2: nil, text3: nil)
                }else{
                    createRecipeBasicList(recipeArray: &recipeArray)
                }
            }
        }
    }
    
    private func createRecipeBasicList(recipeArray: inout Array<RecipeBasic>){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for recipe in recipeList{
            recipeArray.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, nameYomi: recipe.recipeNameYomi, katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch,shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, strength: recipe.strength, imageFileName: recipe.imageFileName))
        }
    }
    
    private func createRecipeBasicList(recipeArray: inout Array<RecipeBasic>, text1: String, text2: String?, text3: String?){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",text1)
        if ing.count > 0 {
            for ri in ing.first!.recipeIngredients{
                recipeArray.append(RecipeBasic(id: ri.recipe.id, name: ri.recipe.recipeName, nameYomi: ri.recipe.recipeNameYomi, katakanaLowercasedNameForSearch: ri.recipe.katakanaLowercasedNameForSearch, shortageNum: ri.recipe.shortageNum, favorites: ri.recipe.favorites, lastViewDate: ri.recipe.lastViewDate, madeNum: ri.recipe.madeNum, method: ri.recipe.method, style: ri.recipe.style, strength: ri.recipe.strength, imageFileName: ri.recipe.imageFileName))
            }
            if let t2 = text2 {
                deleteFromRecipeBasicList(recipeArray: &recipeArray, withoutUse: t2)
                if let t3 = text3{
                    deleteFromRecipeBasicList(recipeArray: &recipeArray, withoutUse: t3)
                }
            }
        }
    }
    
    private func deleteFromRecipeBasicList(recipeArray: inout Array<RecipeBasic>, withoutUse ingredientName: String){
        let realm = try! Realm()
        for i in (0..<recipeArray.count).reversed(){
            var hasIngredient = false
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeArray[i].id)!
            for ri in recipe.recipeIngredients{
                if ri.ingredient.ingredientName == ingredientName{
                    hasIngredient = true
                    break
                }
            }
            if hasIngredient == false{
                recipeArray.remove(at: i)
            }
        }
    }
    
    private func filterRecipeBasicList(){
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
        if recipeFilterNonAlcohol == false{
            recipeBasicList.removeAll{ $0.strength == 0 }
        }
        if recipeFilterWeak == false{
            recipeBasicList.removeAll{ $0.strength == 1 }
        }
        if recipeFilterMedium == false{
            recipeBasicList.removeAll{ $0.strength == 2 }
        }
        if recipeFilterStrong == false{
            recipeBasicList.removeAll{ $0.strength == 3 }
        }
        if recipeFilterStrengthNone == false{
            recipeBasicList.removeAll{ $0.strength == 4 }
        }
    }
    
    private func sortRecipeBasicList(){
        switch recipeSortPrimary{
        case 1: // 名前順
            recipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        case 2:
            switch recipeSortSecondary{
            case 1: // 作れる順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.shortageNum == b.shortageNum {
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    } else {
                        return a.shortageNum < b.shortageNum
                    }
                })
            case 3: // 作れる順 > 作った回数順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.shortageNum == b.shortageNum {
                        if a.madeNum == b.madeNum{
                            return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                            return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                                return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    } else {
                        return a.madeNum > b.madeNum
                    }
                })
            case 2: // 作った回数順 > 作れる順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.madeNum == b.madeNum {
                        if a.shortageNum == b.shortageNum{
                            return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                            return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                                return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    } else {
                        return a.favorites > b.favorites
                    }
                })
            case 2: // お気に入り順 > 作れる順 > 名前順
                recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                    if a.favorites == b.favorites {
                        if a.shortageNum == b.shortageNum{
                            return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                            return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                                return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    } else {
                        return a.favorites > b.favorites
                    }
                })
            }
        case 5: // 最近見た順 > 名前順
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.lastViewDate == nil{
                    if b.lastViewDate == nil{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
            recipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        }
    }
    
    private func setTableBackgroundView(){
        if recipeBasicList.count == 0{
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: self.recipeTableView.bounds.size.height / 3, width: self.recipeTableView.bounds.size.width, height: 100))
            noDataLabel.numberOfLines = 0
            if hasNonExistingIngredient1 || hasNonExistingIngredient2 || hasNonExistingIngredient3 {
                noDataLabel.text = "存在しない材料が指定されています"
            }else{
                if textFieldHasSearchResult{
                    if ingredientTextField1.text!.withoutEndsSpace() == "" && ingredientTextField2.text!.withoutEndsSpace() == "" && ingredientTextField3.text!.withoutEndsSpace() == ""{
                        noDataLabel.text = "絞り込み条件にあてはまるレシピはありません"
                    }else{
                        noDataLabel.text = "入力した材料を使うレシピはありましたが、\n絞り込み条件には該当しません\n\n絞り込み条件を変更してください"
                    }
                }else{
                    noDataLabel.text = "入力した材料を全て使うレシピはありません"
                }
            }
            noDataLabel.textColor = UchicockStyle.labelTextColorLight
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

    private func showRecipeTableView(shouldSetToUserDefaults: Bool){
        if editingTextField == -1 {
            setSearchTextToUserDefaults()
            loadFromUserDefaults()
            reloadRecipeList()
            recipeTableView.reloadData()
        }else{
            ingredientTextField1.resignFirstResponder()
            ingredientTextField2.resignFirstResponder()
            ingredientTextField3.resignFirstResponder()
            editingTextField = -1
            if shouldSetToUserDefaults{
                setSearchTextToUserDefaults()
            }
            loadFromUserDefaults()
            reloadRecipeList()
            recipeTableView.reloadData()

            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .right)
            tableView.insertRows(at: [IndexPath(row: 1,section: 0)], with: .left)
            tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .left)
            tableView.endUpdates()
            
            // 逆引き画面の材料選択から戻った後のEmptyDataSetの文字の高さを正しくするために必要
            setTableBackgroundView()
            
            recipeTableView.flashScrollIndicators()
        }
        cancelButton.isEnabled = false
        setTextFieldColor(textField: ingredientTextField1, alwaysNormalColor: false, hasNonExistingIngredient: &hasNonExistingIngredient1)
        setTextFieldColor(textField: ingredientTextField2, alwaysNormalColor: false, hasNonExistingIngredient: &hasNonExistingIngredient2)
        setTextFieldColor(textField: ingredientTextField3, alwaysNormalColor: false, hasNonExistingIngredient: &hasNonExistingIngredient3)
    }
    
    private func setTextFieldColor(textField: UITextField, alwaysNormalColor: Bool, hasNonExistingIngredient: inout Bool){
        hasNonExistingIngredient = false
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.textColor = UchicockStyle.labelTextColor
        if alwaysNormalColor == false{
            if textField.text != ""{
                let realm = try! Realm()
                let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",textField.text!)
                if ing.count == 0 {
                    hasNonExistingIngredient = true
                    textField.layer.borderWidth = 1
                    textField.layer.borderColor = UchicockStyle.alertColor.cgColor
                    textField.textColor = UchicockStyle.alertColor
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        showRecipeTableView(shouldSetToUserDefaults: true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if editingTextField == -1{
            editingTextField = textField.tag
            reloadIngredientSuggestList(text: textField.text!)

            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 1,section: 0)], with: .left)
            tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .left)
            tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .right)
            tableView.endUpdates()
            
            self.ingredientSuggestTableView.flashScrollIndicators()
        }else{
            reloadIngredientSuggestList(text: textField.text!)
            editingTextField = textField.tag
        }
        cancelButton.isEnabled = true
        setTextFieldColor(textField: ingredientTextField1, alwaysNormalColor: true, hasNonExistingIngredient: &hasNonExistingIngredient1)
        setTextFieldColor(textField: ingredientTextField2, alwaysNormalColor: true, hasNonExistingIngredient: &hasNonExistingIngredient2)
        setTextFieldColor(textField: ingredientTextField3, alwaysNormalColor: true, hasNonExistingIngredient: &hasNonExistingIngredient3)
    }
    
    @objc func textFieldDidChange1(_ notification: Notification){
        if let text = ingredientTextField1.text {
            if text.count > 30 {
                ingredientTextField1.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            if editingTextField == 0{
                reloadIngredientSuggestList(text: ingredientTextField1.text!)
            }else if editingTextField == 1{
                reloadIngredientSuggestList(text: ingredientTextField2.text!)
            }else if editingTextField == 2{
                reloadIngredientSuggestList(text: ingredientTextField3.text!)
            }else{
                setSearchTextToUserDefaults()
                reloadRecipeList()
                recipeTableView.reloadData()
            }
            setTextFieldColor(textField: ingredientTextField1, alwaysNormalColor: true, hasNonExistingIngredient: &hasNonExistingIngredient1)
        }
        ingredientTextField1.adjustClearButtonColor(with: 5)
        setTableBackgroundView()
    }
    
    @objc func textFieldDidChange2(_ notification: Notification){
        if let text = ingredientTextField2.text {
            if text.count > 30 {
                ingredientTextField2.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            if editingTextField == 0{
                reloadIngredientSuggestList(text: ingredientTextField1.text!)
            }else if editingTextField == 1{
                reloadIngredientSuggestList(text: ingredientTextField2.text!)
            }else if editingTextField == 2{
                reloadIngredientSuggestList(text: ingredientTextField3.text!)
            }else{
                setSearchTextToUserDefaults()
                reloadRecipeList()
                recipeTableView.reloadData()
            }
            setTextFieldColor(textField: ingredientTextField2, alwaysNormalColor: true, hasNonExistingIngredient: &hasNonExistingIngredient2)
        }
        ingredientTextField2.adjustClearButtonColor(with: 5)
        setTableBackgroundView()
    }

    @objc func textFieldDidChange3(_ notification: Notification){
        if let text = ingredientTextField3.text {
            if text.count > 30 {
                ingredientTextField3.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            if editingTextField == 0{
                reloadIngredientSuggestList(text: ingredientTextField1.text!)
            }else if editingTextField == 1{
                reloadIngredientSuggestList(text: ingredientTextField2.text!)
            }else if editingTextField == 2{
                reloadIngredientSuggestList(text: ingredientTextField3.text!)
            }else{
                setSearchTextToUserDefaults()
                reloadRecipeList()
                recipeTableView.reloadData()
            }
            setTextFieldColor(textField: ingredientTextField3, alwaysNormalColor: true, hasNonExistingIngredient: &hasNonExistingIngredient3)
        }
        ingredientTextField3.adjustClearButtonColor(with: 5)
        setTableBackgroundView()
    }

    private func reloadIngredientSuggestList(text: String){
        ingredientSuggestTableView.reloadData()
        ingredientSuggestList.removeAll()
        
        for ingredient in ingredientList! {
            ingredientSuggestList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, nameYomi: ingredient.ingredientNameYomi, katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch, stockFlag: ingredient.stockFlag, category: ingredient.category, contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability, usedRecipeNum: ingredient.recipeIngredients.count))
        }
        
        let convertedSearchText = text.convertToYomi().katakanaLowercasedForSearch()
        if text.withoutEndsSpace() != "" {
            ingredientSuggestList.removeAll{
                ($0.katakanaLowercasedNameForSearch.contains(convertedSearchText) == false) &&
                ($0.name.contains(text) == false)
            }
        }
        
        ingredientSuggestList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        ingredientSuggestTableView.reloadData()
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
        return tableView.tag == 0 ? 0 : 25
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        if tableView.tag == 1 {
            header?.textLabel?.text = "上の材料を全て使うレシピ(\(String(self.recipeBasicList.count)))"
        }else if tableView.tag == 2{
            header?.textLabel?.text = "材料候補"
        }else{
            header?.textLabel?.text = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 0{
            if section == 0{
                return editingTextField == -1 ? 2 : 1
            }else if section == 1{
                return 1
            }
        }else if tableView.tag == 1{
            return recipeBasicList.count
        }else if tableView.tag == 2{
            return ingredientSuggestList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    if traitCollection.verticalSizeClass == .compact{
                        return 38
                    }else{
                        return 108
                    }
                }else{
                    return 39
                }
            }else if indexPath.section == 1{
                if editingTextField != -1 {
                    if traitCollection.verticalSizeClass == .compact{
                        return view.frame.size.height - 38
                    }else{
                        return view.frame.size.height - 108
                    }
                }else{
                    if traitCollection.verticalSizeClass == .compact{
                        return view.frame.size.height - 38 - 39
                    }else{
                        return view.frame.size.height - 108 - 39
                    }
                }
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
            showRecipeTableView(shouldSetToUserDefaults: true)
        }
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if tableView.tag == 1{
            let previewProvider: () -> RecipeDetailTableViewController? = {
                let vc = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
                vc.fromContextualMenu = true
                vc.recipeId = self.recipeBasicList[indexPath.row].id
                return vc
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: previewProvider, actionProvider: nil)
        }else{
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating){
        guard let indexPath = configuration.identifier as? IndexPath else { return }

        animator.addCompletion {
            self.performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 0{
            if indexPath.section == 0{
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.isUserInteractionEnabled = true
                return cell
            }else if indexPath.section == 1{
                if editingTextField == -1{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.isUserInteractionEnabled = true
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.isUserInteractionEnabled = true
                    return cell
                }
            }
        }else if tableView.tag == 1{
            let cell = recipeTableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
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
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }else if tableView.tag == 2{
            let cell = ingredientSuggestTableView.dequeueReusableCell(withIdentifier: "SelectIngredient") as! ReverseLookupSelectIngredientTableViewCell
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientSuggestList[indexPath.row].id)!
            cell.ingredient = ingredient
            cell.separatorInset = UIEdgeInsets(top: 0, left: 61, bottom: 0, right: 0)
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if tableView.tag == 1 {
            for indexPath in indexPaths{
                let imageFileName = self.recipeBasicList[indexPath.row].imageFileName
                DispatchQueue.global(qos: .userInteractive).async{
                    ImageUtil.saveToCache(imageFileName: imageFileName)
                }
            }
        }
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        showRecipeTableView(shouldSetToUserDefaults: false)
    }
    
    @IBAction func searchConditionModifyButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "RecipeSearch", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeSearchModalNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! RecipeSearchViewController
        vc.onDoneBlock = {
            self.setupData()
        }
        vc.userDefaultsPrefix = "reverse-lookup-"
        
        createRecipeBasicListWithIngredientTextField(recipeArray: &recipeBasicListForFilterModal)
        vc.recipeBasicListForFilterModal = self.recipeBasicListForFilterModal

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .pageSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }
        
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
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        }
    }
}
