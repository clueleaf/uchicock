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

    var recipeBasicList = Array<RecipeBasic>()
    var ingredientList: Results<Ingredient>?
    var ingredientSuggestList = Array<IngredientBasic>()
    var selectedRecipeId: String? = nil
    let selectedCellBackgroundView = UIView()

    var hiddenLabel = UILabel()
    var editingTextField = -1
    var textFieldHasSearchResult = false
    var noIngredientForTextField1 = false
    var noIngredientForTextField2 = false
    var noIngredientForTextField3 = false

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
        
        makeFilterFromUserDefaults()
        setSearchConditionButtonTitle()
        setTextFieldFromUserDefaults()

        ingredientTextField1.clearButtonEdgeInset = 5.0
        ingredientTextField2.clearButtonEdgeInset = 5.0
        ingredientTextField3.clearButtonEdgeInset = 5.0
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
        ingredientTextField1.adjustClearButtonColor()
        ingredientTextField2.adjustClearButtonColor()
        ingredientTextField3.adjustClearButtonColor()

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
        
        // iPadや画面回転でキーボードが消えるため、他のタブに行ってデータの更新が可能
        // 整合性のために逆引き表示では常にレシピテーブルを表示するようにする
        showRecipeTableView(shouldSetToUserDefaults: false)

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
    private func makeFilterFromUserDefaults(){
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
    
    private func setTextFieldFromUserDefaults(){
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
        ingredientTextField1.adjustClearButtonColor()
        ingredientTextField2.adjustClearButtonColor()
        ingredientTextField3.adjustClearButtonColor()
    }
    
    private func setSearchTextToUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.set(ingredientTextField1.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupFirstIngredientKey)
        defaults.set(ingredientTextField2.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupSecondIngredientKey)
        defaults.set(ingredientTextField3.text!.withoutEndsSpace(), forKey: GlobalConstants.ReverseLookupThirdIngredientKey)
    }

    private func createRecipeBasicList(recipeArray: inout Array<RecipeBasic>, shouldUpdateTextFieldHasSearchResult: Bool){
        let text1 = ingredientTextField1.text!.withoutEndsSpace()
        let text2 = ingredientTextField2.text!.withoutEndsSpace()
        let text3 = ingredientTextField3.text!.withoutEndsSpace()
        var textList = Array<String>()

        if text1 != "" { textList.append(text1) }
        if text2 != "" { textList.append(text2) }
        if text3 != "" { textList.append(text3) }
        
        createRecipeBasicList(recipeArray: &recipeArray, textList: textList)

        if shouldUpdateTextFieldHasSearchResult{
            textFieldHasSearchResult = recipeArray.count > 0
        }
    }
    
    private func createRecipeBasicList(recipeArray: inout Array<RecipeBasic>, textList: Array<String>){
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
    
    private func filterRecipeBasicList(){
        recipeBasicList.removeAll{
            recipeFilterStar.contains($0.favorites) == false ||
            recipeFilterStyle.contains($0.style) == false ||
            recipeFilterMethod.contains($0.method) == false ||
            recipeFilterStrength.contains($0.strength) == false
        }
    }
    
    private func sortRecipeBasicList(){
        switch sortOrder{
        case .name:
            recipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        case .makeableName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.shortageNum < b.shortageNum
                }
            })
        case .makeableMadenumName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    if a.madeNum == b.madeNum{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.madeNum > b.madeNum
                    }
                }else{
                    return a.shortageNum < b.shortageNum
                }
            })
        case .makeableFavoriteName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    if a.favorites == b.favorites{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.favorites > b.favorites
                    }
                }else{
                    return a.shortageNum < b.shortageNum
                }
            })
        case .makeableViewdName:
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
                }else{
                    return a.shortageNum < b.shortageNum
                }
            })
        case .madenumName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.madeNum > b.madeNum
                }
            })
        case .madenumMakeableName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    if a.shortageNum == b.shortageNum{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.shortageNum < b.shortageNum
                    }
                }else{
                    return a.madeNum > b.madeNum
                }
            })
        case .madenumFavoriteName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    if a.favorites == b.favorites{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.favorites > b.favorites
                    }
                }else{
                    return a.madeNum > b.madeNum
                }
            })
        case .madenumViewedName:
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
                }else{
                    return a.madeNum > b.madeNum
                }
            })
        case .favoriteName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.favorites > b.favorites
                }
            })
        case .favoriteMakeableName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    if a.shortageNum == b.shortageNum{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.shortageNum < b.shortageNum
                    }
                }else{
                    return a.favorites > b.favorites
                }
            })
        case .favoriteMadenumName:
            recipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    if a.madeNum == b.madeNum {
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                    }else{
                        return a.madeNum > b.madeNum
                    }
                }else{
                    return a.favorites > b.favorites
                }
            })
        case .favoriteViewedName:
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
                }else{
                    return a.favorites > b.favorites
                }
            })
        case .viewedName:
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
        recipeTableView.backgroundView?.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerXConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerX, relatedBy: .equal, toItem: recipeTableView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerY, relatedBy: .equal, toItem: recipeTableView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])

        if noIngredientForTextField1 || noIngredientForTextField2 || noIngredientForTextField3 {
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
        noDataLabel.textColor = UchicockStyle.labelTextColorLight
        noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        noDataLabel.textAlignment = .center
    }

    //todo
    private func showRecipeTableView(shouldSetToUserDefaults: Bool){
        ingredientTextField1.resignFirstResponder()
        ingredientTextField2.resignFirstResponder()
        ingredientTextField3.resignFirstResponder()

        if shouldSetToUserDefaults{
            setSearchTextToUserDefaults()
        }
        setTextFieldFromUserDefaults()
        createRecipeBasicList(recipeArray: &recipeBasicList, shouldUpdateTextFieldHasSearchResult: true)
        filterRecipeBasicList()
        sortRecipeBasicList()
        setTableBackgroundView()//todo
        recipeTableView.reloadData()

        if editingTextField != -1 {
            editingTextField = -1

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
        setTextFieldColor(textField: ingredientTextField1, alwaysNormalColor: false, hasNonExistingIngredient: &noIngredientForTextField1)
        setTextFieldColor(textField: ingredientTextField2, alwaysNormalColor: false, hasNonExistingIngredient: &noIngredientForTextField2)
        setTextFieldColor(textField: ingredientTextField3, alwaysNormalColor: false, hasNonExistingIngredient: &noIngredientForTextField3)
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
    
    // MARK: - ScrollableToTop
    func scrollToTop() {
        recipeTableView?.setContentOffset(CGPoint.zero, animated: true)
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
            
            self.ingredientTableView.flashScrollIndicators()
        }else{
            reloadIngredientSuggestList(text: textField.text!)
            editingTextField = textField.tag
        }
        cancelButton.isEnabled = true
        setTextFieldColor(textField: ingredientTextField1, alwaysNormalColor: true, hasNonExistingIngredient: &noIngredientForTextField1)
        setTextFieldColor(textField: ingredientTextField2, alwaysNormalColor: true, hasNonExistingIngredient: &noIngredientForTextField2)
        setTextFieldColor(textField: ingredientTextField3, alwaysNormalColor: true, hasNonExistingIngredient: &noIngredientForTextField3)
    }
    
    @objc func textFieldDidChange1(_ notification: Notification){
        if editingTextField == 0{
            reloadIngredientSuggestList(text: ingredientTextField1.text!)
        }else if editingTextField == 1{
            reloadIngredientSuggestList(text: ingredientTextField2.text!)
        }else if editingTextField == 2{
            reloadIngredientSuggestList(text: ingredientTextField3.text!)
        }else{
            setSearchTextToUserDefaults()
            createRecipeBasicList(recipeArray: &recipeBasicList, shouldUpdateTextFieldHasSearchResult: true)
            filterRecipeBasicList()
            sortRecipeBasicList()
            setTableBackgroundView()
            recipeTableView.reloadData()
        }
        setTextFieldColor(textField: ingredientTextField1, alwaysNormalColor: true, hasNonExistingIngredient: &noIngredientForTextField1)
        ingredientTextField1.adjustClearButtonColor()
    }
    
    @objc func textFieldDidChange2(_ notification: Notification){
        if editingTextField == 0{
            reloadIngredientSuggestList(text: ingredientTextField1.text!)
        }else if editingTextField == 1{
            reloadIngredientSuggestList(text: ingredientTextField2.text!)
        }else if editingTextField == 2{
            reloadIngredientSuggestList(text: ingredientTextField3.text!)
        }else{
            setSearchTextToUserDefaults()
            createRecipeBasicList(recipeArray: &recipeBasicList, shouldUpdateTextFieldHasSearchResult: true)
            filterRecipeBasicList()
            sortRecipeBasicList()
            setTableBackgroundView()
            recipeTableView.reloadData()
        }
        setTextFieldColor(textField: ingredientTextField2, alwaysNormalColor: true, hasNonExistingIngredient: &noIngredientForTextField2)
        ingredientTextField2.adjustClearButtonColor()
    }

    @objc func textFieldDidChange3(_ notification: Notification){
        if editingTextField == 0{
            reloadIngredientSuggestList(text: ingredientTextField1.text!)
        }else if editingTextField == 1{
            reloadIngredientSuggestList(text: ingredientTextField2.text!)
        }else if editingTextField == 2{
            reloadIngredientSuggestList(text: ingredientTextField3.text!)
        }else{
            setSearchTextToUserDefaults()
            createRecipeBasicList(recipeArray: &recipeBasicList, shouldUpdateTextFieldHasSearchResult: true)
            filterRecipeBasicList()
            sortRecipeBasicList()
            setTableBackgroundView()
            recipeTableView.reloadData()
        }
        setTextFieldColor(textField: ingredientTextField3, alwaysNormalColor: true, hasNonExistingIngredient: &noIngredientForTextField3)
        ingredientTextField3.adjustClearButtonColor()
    }

    private func reloadIngredientSuggestList(text: String){
        ingredientTableView.reloadData()
        ingredientSuggestList.removeAll()
        
        let searchText = text.withoutMiddleSpaceAndMiddleDot()
        let convertedSearchText = text.convertToYomi().katakanaLowercasedForSearch()
        for ingredient in ingredientList! {
            if searchText == "" ||
            ingredient.katakanaLowercasedNameForSearch.contains(convertedSearchText) ||
            ingredient.ingredientName.contains(searchText){
                let ib = IngredientBasic(
                    id: ingredient.id,
                    name: ingredient.ingredientName,
                    nameYomi: ingredient.ingredientNameYomi,
                    katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch,
                    stockFlag: ingredient.stockFlag,
                    category: ingredient.category,
                    contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability,
                    usingRecipeNum: ingredient.recipeIngredients.count
                )
                ingredientSuggestList.append(ib)
            }
        }
        
        ingredientSuggestList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        ingredientTableView.reloadData()
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
            cell.sortOrder = sortOrder
            cell.recipe = recipeBasicList[indexPath.row]
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }else if tableView.tag == 2{
            let cell = ingredientTableView.dequeueReusableCell(withIdentifier: "SelectIngredient") as! ReverseLookupSelectIngredientTableViewCell
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.ingredient = ingredientSuggestList[indexPath.row]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 66, bottom: 0, right: 0)
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
            self.makeFilterFromUserDefaults()
            self.setSearchConditionButtonTitle()
            self.createRecipeBasicList(recipeArray: &self.recipeBasicList, shouldUpdateTextFieldHasSearchResult: true)
            self.filterRecipeBasicList()
            self.sortRecipeBasicList()
            self.setTableBackgroundView()
            self.recipeTableView.reloadData()
        }
        vc.udPrefix = "reverse-lookup-"
        
        var recipeBasicListForFilterModal = Array<RecipeBasic>()
        createRecipeBasicList(recipeArray: &recipeBasicListForFilterModal, shouldUpdateTextFieldHasSearchResult: false)
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
            if let indexPath = sender as? IndexPath{
                selectedRecipeId = recipeBasicList[indexPath.row].id
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        }
    }
}
