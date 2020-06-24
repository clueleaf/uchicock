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
    @IBOutlet weak var ingredientTextField1: CustomTextField!
    @IBOutlet weak var ingredientTextField2: CustomTextField!
    @IBOutlet weak var ingredientTextField3: CustomTextField!
    @IBOutlet weak var searchConditionModifyButton: UIButton!
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var ingredientTableView: UITableView!

    var ingredientList: Results<Ingredient>?
    var recipeBasicList = Array<RecipeBasic>()
    var ingredientSuggestList = Array<IngredientSuggestBasic>()
    var selectedRecipeId: String? = nil
    let selectedCellBackgroundView = UIView()

    var hiddenLabel = UILabel()
    var editingTextField = -1
    var textFieldHasSearchResult = false
    var noIngredientForTextField = false

    var sortOrder = RecipeSortType.name
    var recipeFilterStar: [Int] = []
    var recipeFilterStyle: [Int] = []
    var recipeFilterMethod: [Int] = []
    var recipeFilterStrength: [Int] = []

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerUserDefaults()
        readFilterAndSortOrderFromUserDefaults()
        setSearchConditionButtonTitle()

        ingredientTextField1.layer.cornerRadius = ingredientTextField1.frame.size.height / 2
        ingredientTextField2.layer.cornerRadius = ingredientTextField2.frame.size.height / 2
        ingredientTextField3.layer.cornerRadius = ingredientTextField3.frame.size.height / 2
        ingredientTextField1.setLeftPadding()
        ingredientTextField2.setLeftPadding()
        ingredientTextField3.setLeftPadding()

        searchConditionModifyButton.layer.borderWidth = 1.5
        searchConditionModifyButton.layer.cornerRadius = searchConditionModifyButton.frame.size.height / 2

        recipeTableView.tableFooterView = UIView(frame: CGRect.zero)
        recipeTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        ingredientTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        hiddenLabel.font = UIFont.systemFont(ofSize: 14.0)
        hiddenLabel.numberOfLines = 1
        hiddenLabel.text = "Thank you for using うちカク!!!!"
        hiddenLabel.textAlignment = .center
        recipeTableView.addSubview(hiddenLabel)
        hiddenLabel.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = NSLayoutConstraint(item: hiddenLabel, attribute: .centerX, relatedBy: .equal, toItem: recipeTableView, attribute: .centerX, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: hiddenLabel, attribute: .top, relatedBy: .equal, toItem: recipeTableView, attribute: .top, multiplier: 1, constant: -180)
        let heightConstraint = NSLayoutConstraint(item: hiddenLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        NSLayoutConstraint.activate([centerXConstraint, topConstraint, heightConstraint])

        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
        
        cancelButton.isEnabled = false
    }
    
    private func registerUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            GlobalConstants.ReverseLookupSortPrimaryKey : 1,
            GlobalConstants.ReverseLookupSortSecondaryKey : 0,
            GlobalConstants.ReverseLookupFilterStar0Key : true,
            GlobalConstants.ReverseLookupFilterStar1Key : true,
            GlobalConstants.ReverseLookupFilterStar2Key : true,
            GlobalConstants.ReverseLookupFilterStar3Key : true,
            GlobalConstants.ReverseLookupFilterLongKey : true,
            GlobalConstants.ReverseLookupFilterShortKey : true,
            GlobalConstants.ReverseLookupFilterHotKey : true,
            GlobalConstants.ReverseLookupFilterStyleNoneKey : true,
            GlobalConstants.ReverseLookupFilterBuildKey : true,
            GlobalConstants.ReverseLookupFilterStirKey : true,
            GlobalConstants.ReverseLookupFilterShakeKey : true,
            GlobalConstants.ReverseLookupFilterBlendKey : true,
            GlobalConstants.ReverseLookupFilterOthersKey : true,
            GlobalConstants.ReverseLookupFilterNonAlcoholKey : true,
            GlobalConstants.ReverseLookupFilterWeakKey : true,
            GlobalConstants.ReverseLookupFilterMediumKey : true,
            GlobalConstants.ReverseLookupFilterStrongKey : true,
            GlobalConstants.ReverseLookupFilterStrengthNoneKey : true,
            GlobalConstants.ReverseLookupFirstIngredientKey : "",
            GlobalConstants.ReverseLookupSecondIngredientKey : "",
            GlobalConstants.ReverseLookupThirdIngredientKey: ""
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        recipeTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        ingredientTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        recipeTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        ingredientTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        recipeTableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        ingredientTableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        
        ingredientTextField1.attributedPlaceholder = NSAttributedString(string: "材料1", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientTextField2.attributedPlaceholder = NSAttributedString(string: "材料2", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientTextField3.attributedPlaceholder = NSAttributedString(string: "材料3", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])

        searchConditionModifyButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        searchConditionModifyButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        searchConditionModifyButton.backgroundColor = UchicockStyle.basicBackgroundColor
        
        hiddenLabel.textColor = UchicockStyle.labelTextColorLight

        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientTextField1)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientTextField2)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientTextField3)
        NotificationCenter.default.addObserver(self, selector: #selector(ReverseLookupTableViewController.textFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientTextField1)
        NotificationCenter.default.addObserver(self, selector: #selector(ReverseLookupTableViewController.textFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientTextField2)
        NotificationCenter.default.addObserver(self, selector: #selector(ReverseLookupTableViewController.textFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientTextField3)
        
        tableView.reloadData()
        // iPadや画面回転でキーボードが消えるため、他のタブに行ってデータの更新が可能
        // 整合性のために逆引き表示では常にレシピテーブルを表示するようにする
        setTextFieldTextFromUserDefaults()
        showRecipeTableView()

        if recipeTableView.indexPathsForVisibleRows != nil && selectedRecipeId != nil {
            for indexPath in recipeTableView.indexPathsForVisibleRows! where recipeBasicList.count > indexPath.row {
                if recipeBasicList[indexPath.row].id == selectedRecipeId! {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.recipeTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                    break
                }
            }
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
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    // MARK: - Logic functions
    private func readFilterAndSortOrderFromUserDefaults(){
        recipeFilterStar.removeAll()
        recipeFilterStyle.removeAll()
        recipeFilterMethod.removeAll()
        recipeFilterStrength.removeAll()

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar0Key) { recipeFilterStar.append(0) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar1Key) { recipeFilterStar.append(1) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar2Key) { recipeFilterStar.append(2) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStar3Key) { recipeFilterStar.append(3) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterLongKey) { recipeFilterStyle.append(0) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterShortKey) { recipeFilterStyle.append(1) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterHotKey) { recipeFilterStyle.append(2) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStyleNoneKey) { recipeFilterStyle.append(3) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterBuildKey) { recipeFilterMethod.append(0) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStirKey) { recipeFilterMethod.append(1) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterShakeKey) { recipeFilterMethod.append(2) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterBlendKey) { recipeFilterMethod.append(3) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterOthersKey) { recipeFilterMethod.append(4) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterNonAlcoholKey) { recipeFilterStrength.append(0) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterWeakKey) { recipeFilterStrength.append(1) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterMediumKey) { recipeFilterStrength.append(2) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStrongKey) { recipeFilterStrength.append(3) }
        if defaults.bool(forKey: GlobalConstants.ReverseLookupFilterStrengthNoneKey) { recipeFilterStrength.append(4) }
        
        let sortPrimary = defaults.integer(forKey: GlobalConstants.ReverseLookupSortPrimaryKey)
        let sortSecondary = defaults.integer(forKey: GlobalConstants.ReverseLookupSortSecondaryKey)
        
        switch (sortPrimary, sortSecondary) {
        case let (primary, _) where primary == 1: sortOrder = .name
        case let (primary, secondary) where primary == 2 && secondary == 1: sortOrder = .makeableName
        case let (primary, secondary) where primary == 2 && secondary == 3: sortOrder = .makeableMadenumName
        case let (primary, secondary) where primary == 2 && secondary == 4: sortOrder = .makeableFavoriteName
        case let (primary, secondary) where primary == 2 && secondary == 5: sortOrder = .makeableViewdName
        case let (primary, _) where primary == 2: sortOrder = .makeableName
        case let (primary, secondary) where primary == 3 && secondary == 1: sortOrder = .madenumName
        case let (primary, secondary) where primary == 3 && secondary == 2: sortOrder = .madenumMakeableName
        case let (primary, secondary) where primary == 3 && secondary == 4: sortOrder = .madenumFavoriteName
        case let (primary, secondary) where primary == 3 && secondary == 5: sortOrder = .madenumViewedName
        case let (primary, _) where primary == 3: sortOrder = .madenumName
        case let (primary, secondary) where primary == 4 && secondary == 1: sortOrder = .favoriteName
        case let (primary, secondary) where primary == 4 && secondary == 2: sortOrder = .favoriteMakeableName
        case let (primary, secondary) where primary == 4 && secondary == 3: sortOrder = .favoriteMadenumName
        case let (primary, secondary) where primary == 4 && secondary == 5: sortOrder = .favoriteViewedName
        case let (primary, _) where primary == 4: sortOrder = .favoriteName
        case let (primary, _) where primary == 5: sortOrder = .viewedName
        default: sortOrder = .name
        }
    }
    
    private func setSearchConditionButtonTitle(){
        var conditionText = ""
        
        switch sortOrder{
        case .name: conditionText = "名前順"
        case .makeableName: conditionText = "作れる順 > 名前順"
        case .makeableMadenumName: conditionText = "作れる順 > 作った回数順"
        case .makeableFavoriteName: conditionText = "作れる順 > お気に入り順"
        case .makeableViewdName: conditionText = "作れる順 > 最近見た順"
        case .madenumName: conditionText = "作った回数順 > 名前順"
        case .madenumMakeableName: conditionText = "作った回数順 > 作れる順"
        case .madenumFavoriteName: conditionText = "作った回数順 > お気に入り順"
        case .madenumViewedName: conditionText = "作った回数順 > 最近見た順"
        case .favoriteName: conditionText = "お気に入り順 > 名前順"
        case .favoriteMakeableName: conditionText = "お気に入り順 > 作れる順"
        case .favoriteMadenumName: conditionText = "お気に入り順 > 作った回数順"
        case .favoriteViewedName: conditionText = "お気に入り順 > 最近見た順"
        case .viewedName: conditionText = "最近見た順"
        }
        
        if ([0,1,2,3].allSatisfy(recipeFilterStar.contains) && [0,1,2,3].allSatisfy(recipeFilterStyle.contains) &&
            [0,1,2,3,4].allSatisfy(recipeFilterMethod.contains) && [0,1,2,3,4].allSatisfy(recipeFilterStrength.contains))
            == false {
            conditionText += "、絞り込み有"
        }
        
        UIView.performWithoutAnimation {
            searchConditionModifyButton.setTitle(conditionText, for: .normal)
            searchConditionModifyButton.layoutIfNeeded()
        }
    }
    
    private func setTextFieldTextFromUserDefaults(){
        let defaults = UserDefaults.standard
        if let first = defaults.string(forKey: GlobalConstants.ReverseLookupFirstIngredientKey){
            ingredientTextField1.text = first.withoutEndsSpace()
        }
        if let second = defaults.string(forKey: GlobalConstants.ReverseLookupSecondIngredientKey){
            ingredientTextField2.text = second.withoutEndsSpace()
        }
        if let third = defaults.string(forKey: GlobalConstants.ReverseLookupThirdIngredientKey){
            ingredientTextField3.text = third.withoutEndsSpace()
        }
    }
    
    private func setSearchTextToUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.set(ingredientTextField1.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupFirstIngredientKey)
        defaults.set(ingredientTextField2.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupSecondIngredientKey)
        defaults.set(ingredientTextField3.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupThirdIngredientKey)
    }

    private func showRecipeTableView(){
        ingredientTextField1.resignFirstResponder()
        ingredientTextField2.resignFirstResponder()
        ingredientTextField3.resignFirstResponder()

        reloadRecipeBasicList(recipeArray: &recipeBasicList)
        textFieldHasSearchResult = recipeBasicList.count > 0
        filterAndSortRecipeBasicList()
        recipeTableView.reloadData()

        if editingTextField != -1 {
            editingTextField = -1

            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .right)
            tableView.insertRows(at: [IndexPath(row: 1,section: 0)], with: .left)
            tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .left)
            tableView.endUpdates()
            
            recipeTableView.flashScrollIndicators()
        }
        setTextFieldAlertStyle(alwaysNormalColor: false)
        setTableBackgroundView()
        cancelButton.isEnabled = false
        ingredientTextField1.adjustClearButtonColor()
        ingredientTextField2.adjustClearButtonColor()
        ingredientTextField3.adjustClearButtonColor()
    }
    
    private func reloadRecipeBasicList(recipeArray: inout Array<RecipeBasic>){
        let text1 = ingredientTextField1.text!.withoutEndsSpace()
        let text2 = ingredientTextField2.text!.withoutEndsSpace()
        let text3 = ingredientTextField3.text!.withoutEndsSpace()
        var textList = Array<String>()

        if text1 != "" { textList.append(text1) }
        if text2 != "" { textList.append(text2) }
        if text3 != "" { textList.append(text3) }
        
        reloadRecipeBasicList(recipeArray: &recipeArray, textList: textList)
    }
    
    private func reloadRecipeBasicList(recipeArray: inout Array<RecipeBasic>, textList: Array<String>){
        recipeArray.removeAll()
        let realm = try! Realm()
        
        guard textList.count != 0 else{
            let recipeList = realm.objects(Recipe.self)
            for recipe in recipeList{
                recipeArray.append(RecipeBasic(
                    id: recipe.id,
                    name: recipe.recipeName,
                    nameYomi: recipe.recipeNameYomi,
                    katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch,
                    shortageNum: recipe.shortageNum,
                    shortageIngredientName: recipe.shortageIngredientName,
                    lastViewDate: recipe.lastViewDate,
                    favorites: recipe.favorites,
                    style: recipe.style,
                    method: recipe.method,
                    strength: recipe.strength,
                    madeNum: recipe.madeNum,
                    imageFileName: recipe.imageFileName
                ))
            }
            return
        }

        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@", textList[0])
        guard ing.count > 0 else { return }
        
        for ri in ing.first!.recipeIngredients{
            recipeArray.append(RecipeBasic(
                id: ri.recipe.id,
                name: ri.recipe.recipeName,
                nameYomi: ri.recipe.recipeNameYomi,
                katakanaLowercasedNameForSearch: ri.recipe.katakanaLowercasedNameForSearch,
                shortageNum: ri.recipe.shortageNum,
                shortageIngredientName: ri.recipe.shortageIngredientName,
                lastViewDate: ri.recipe.lastViewDate,
                favorites: ri.recipe.favorites,
                style: ri.recipe.style,
                method: ri.recipe.method,
                strength: ri.recipe.strength,
                madeNum: ri.recipe.madeNum,
                imageFileName: ri.recipe.imageFileName
            ))
        }
        guard textList.count > 1 else { return }
        
        for i in 1..<textList.count where textList[i] != ""{
            for j in (0..<recipeArray.count).reversed(){
                var hasIngredient = false
                let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeArray[j].id)!
                for ri in recipe.recipeIngredients where ri.ingredient.ingredientName == textList[i]{
                    hasIngredient = true
                    break
                }
                if hasIngredient == false{ recipeArray.remove(at: j) }
            }
        }
    }
    
    private func filterAndSortRecipeBasicList(){
        recipeBasicList.removeAll{
            recipeFilterStar.contains($0.favorites) == false ||
            recipeFilterStyle.contains($0.style) == false ||
            recipeFilterMethod.contains($0.method) == false ||
            recipeFilterStrength.contains($0.strength) == false
        }

        switch sortOrder{
        case .name:
            recipeBasicList.sort { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending }
        case .makeableName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        case .makeableMadenumName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    if a.madeNum == b.madeNum{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.madeNum > b.madeNum
                    }
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        case .makeableFavoriteName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    if a.favorites == b.favorites{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.favorites > b.favorites
                    }
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        case .makeableViewdName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
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
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        case .madenumName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        case .madenumMakeableName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    if a.shortageNum == b.shortageNum{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.shortageNum < b.shortageNum
                    }
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        case .madenumFavoriteName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    if a.favorites == b.favorites{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.favorites > b.favorites
                    }
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        case .madenumViewedName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
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
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        case .favoriteName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.favorites > b.favorites
                }
            }
        case .favoriteMakeableName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    if a.shortageNum == b.shortageNum{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.shortageNum < b.shortageNum
                    }
                }else{
                    return a.favorites > b.favorites
                }
            }
        case .favoriteMadenumName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    if a.madeNum == b.madeNum {
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.madeNum > b.madeNum
                    }
                }else{
                    return a.favorites > b.favorites
                }
            }
        case .favoriteViewedName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
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
                }else{
                    return a.favorites > b.favorites
                }
            }
        case .viewedName:
            recipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
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
            }
        }
    }

    private func setTableBackgroundView(){
        guard recipeBasicList.count == 0 else {
            recipeTableView.backgroundView = nil
            recipeTableView.isScrollEnabled = true
            return
        }

        recipeTableView.backgroundView  = UIView()
        recipeTableView.isScrollEnabled = false

        let noDataLabel = UILabel()
        noDataLabel.numberOfLines = 0
        noDataLabel.textColor = UchicockStyle.labelTextColorLight
        noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        noDataLabel.textAlignment = .center
        recipeTableView.backgroundView?.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerXConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerX, relatedBy: .equal, toItem: recipeTableView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerY, relatedBy: .equal, toItem: recipeTableView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])

        if noIngredientForTextField {
            noDataLabel.text = "存在しない材料が指定されています"
        }else{
            if textFieldHasSearchResult{
                if ingredientTextField1.text!.withoutEndsSpace() == "" && ingredientTextField2.text!.withoutEndsSpace() == "" && ingredientTextField3.text!.withoutEndsSpace() == ""{
                    noDataLabel.text = "絞り込み条件にあてはまるレシピはありません"
                }else{
                    noDataLabel.text = "入力した材料を使うレシピはありますが、\n絞り込み条件には該当しません\n絞り込み条件を変更してください"
                }
            }else{
                noDataLabel.text = "入力した材料を全て使うレシピはありません"
            }
        }
    }

    private func setTextFieldAlertStyle(alwaysNormalColor: Bool){
        noIngredientForTextField = false
        
        ingredientTextField1.layer.borderWidth = 0
        ingredientTextField1.layer.borderColor = UIColor.clear.cgColor
        ingredientTextField1.textColor = UchicockStyle.labelTextColor
        ingredientTextField2.layer.borderWidth = 0
        ingredientTextField2.layer.borderColor = UIColor.clear.cgColor
        ingredientTextField2.textColor = UchicockStyle.labelTextColor
        ingredientTextField3.layer.borderWidth = 0
        ingredientTextField3.layer.borderColor = UIColor.clear.cgColor
        ingredientTextField3.textColor = UchicockStyle.labelTextColor
        
        if alwaysNormalColor { return }
        let realm = try! Realm()
        if ingredientTextField1.text != ""{
            let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientTextField1.text!)
            if ing.count == 0 {
                noIngredientForTextField = true
                ingredientTextField1.layer.borderWidth = 1
                ingredientTextField1.layer.borderColor = UchicockStyle.alertColor.cgColor
                ingredientTextField1.textColor = UchicockStyle.alertColor
            }
        }
        if ingredientTextField2.text != ""{
            let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientTextField2.text!)
            if ing.count == 0 {
                noIngredientForTextField = true
                ingredientTextField2.layer.borderWidth = 1
                ingredientTextField2.layer.borderColor = UchicockStyle.alertColor.cgColor
                ingredientTextField2.textColor = UchicockStyle.alertColor
            }
        }
        if ingredientTextField3.text != ""{
            let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientTextField3.text!)
            if ing.count == 0 {
                noIngredientForTextField = true
                ingredientTextField3.layer.borderWidth = 1
                ingredientTextField3.layer.borderColor = UchicockStyle.alertColor.cgColor
                ingredientTextField3.textColor = UchicockStyle.alertColor
            }
        }
    }
    
    private func reloadIngredientSuggestList(text: String){
        ingredientSuggestList.removeAll()
        
        let searchText = text.withoutMiddleSpaceAndMiddleDot()
        let convertedSearchText = text.convertToYomi().katakanaLowercasedForSearch()
        for ingredient in ingredientList! {
            if searchText == "" ||
            ingredient.katakanaLowercasedNameForSearch.contains(convertedSearchText) ||
            ingredient.ingredientName.contains(searchText){
                ingredientSuggestList.append(IngredientSuggestBasic(
                    name: ingredient.ingredientName,
                    nameYomi: ingredient.ingredientNameYomi,
                    katakanaLowercasedNameForSearch: "",
                    stockFlag: ingredient.stockFlag,
                    category: ingredient.category
                ))
            }
        }
        
        ingredientSuggestList.sort { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending }
        ingredientTableView.reloadData()
    }
    
    // MARK: - ScrollableToTop
    func scrollToTop() {
        recipeTableView?.setContentOffset(CGPoint.zero, animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        setSearchTextToUserDefaults()
        showRecipeTableView()
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
            
            self.ingredientTableView.flashScrollIndicators()
        }else{
            editingTextField = textField.tag
            reloadIngredientSuggestList(text: textField.text!)
        }
        cancelButton.isEnabled = true
        setTextFieldAlertStyle(alwaysNormalColor: true)
    }
    
    @objc func textFieldDidChange(_ notification: Notification){
        guard editingTextField != -1 else{
            setSearchTextToUserDefaults()
            showRecipeTableView()
            return
        }
        
        if editingTextField == 0{
            reloadIngredientSuggestList(text: ingredientTextField1.text!)
        }else if editingTextField == 1{
            reloadIngredientSuggestList(text: ingredientTextField2.text!)
        }else if editingTextField == 2{
            reloadIngredientSuggestList(text: ingredientTextField3.text!)
        }
        setTextFieldAlertStyle(alwaysNormalColor: true)
        ingredientTextField1.adjustClearButtonColor()
        ingredientTextField2.adjustClearButtonColor()
        ingredientTextField3.adjustClearButtonColor()
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
                        return 41
                    }else{
                        return 111
                    }
                }else{
                    return 36
                }
            }else if indexPath.section == 1{
                if editingTextField != -1 {
                    if traitCollection.verticalSizeClass == .compact{
                        return view.frame.size.height - 41
                    }else{
                        return view.frame.size.height - 111
                    }
                }else{
                    if traitCollection.verticalSizeClass == .compact{
                        return view.frame.size.height - 41 - 36
                    }else{
                        return view.frame.size.height - 111 - 36
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
            if indexPath.row < recipeBasicList.count{
                performSegue(withIdentifier: "PushRecipeDetail", sender: recipeBasicList[indexPath.row].id)
            }
        }else if tableView.tag == 2{
            tableView.deselectRow(at: indexPath, animated: true)
            switch editingTextField{
            case 0: ingredientTextField1.text = ingredientSuggestList[indexPath.row].name
            case 1: ingredientTextField2.text = ingredientSuggestList[indexPath.row].name
            case 2: ingredientTextField3.text = ingredientSuggestList[indexPath.row].name
            default: break
            }
            setSearchTextToUserDefaults()
            showRecipeTableView()
        }
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard tableView.tag == 1 else { return nil }
        
        let previewProvider: () -> RecipeDetailTableViewController? = {
            let vc = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
            vc.fromContextualMenu = true
            vc.recipeId = self.recipeBasicList[indexPath.row].id
            return vc
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: previewProvider, actionProvider: nil)
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating){
        guard let indexPath = configuration.identifier as? IndexPath else { return }

        animator.addCompletion {
            if indexPath.row < self.recipeBasicList.count{
                self.performSegue(withIdentifier: "PushRecipeDetail", sender: self.recipeBasicList[indexPath.row].id)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 0{
            if indexPath.section == 0{
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                return cell
            }else if indexPath.section == 1{
                if editingTextField == -1{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    return cell
                }
            }
        }else if tableView.tag == 1{
            let cell = recipeTableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
            cell.sortOrder = sortOrder
            cell.recipe = recipeBasicList[indexPath.row]
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }else if tableView.tag == 2{
            let cell = ingredientTableView.dequeueReusableCell(withIdentifier: "SelectIngredient") as! ReverseLookupSelectIngredientTableViewCell
            cell.ingredient = ingredientSuggestList[indexPath.row]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 66, bottom: 0, right: 0)
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
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
        setTextFieldTextFromUserDefaults()
        showRecipeTableView()
    }
    
    @IBAction func searchConditionModifyButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "RecipeSearch", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeSearchModalNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! RecipeSearchViewController
        vc.onDoneBlock = {
            self.readFilterAndSortOrderFromUserDefaults()
            self.setSearchConditionButtonTitle()
            self.showRecipeTableView()
        }
        vc.udPrefix = "reverse-lookup-"
        
        var recipeBasicListForFilterModal = Array<RecipeBasic>()
        reloadRecipeBasicList(recipeArray: &recipeBasicListForFilterModal)
        vc.recipeBasicList = recipeBasicListForFilterModal

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
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
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
            if let id = sender as? String{
                selectedRecipeId = id
                vc.recipeId = id
            }
        }
    }
}
