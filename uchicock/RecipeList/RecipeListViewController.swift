//
//  RecipeListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching , UISearchBarDelegate, UIViewControllerTransitioningDelegate, ScrollableToTop {

    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var addRecipeButton: UIBarButtonItem!

    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var searchConditionModifyButton: UIButton!
    @IBOutlet weak var containerSeparator: UIView!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchConditionModifyButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    let selectedCellBackgroundView = UIView()
    var recipeList: Results<Recipe>?
    var recipeBasicList = Array<RecipeBasic>()
    var recipeBasicListForFilterModal = Array<RecipeBasic>()

    var selectedRecipeId: String? = nil

    var scrollBeginningYPoint: CGFloat = 0.0

    var isTyping = false
    var isBookmarkMode = false
    var shouldShowBookmarkGuide = false
    
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
        
        requestReview()

        getTextFieldFromView(view: searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.layer.borderWidth = 1.0
            searchBar.searchTextField.layer.cornerRadius = 8.0
        }

        searchConditionModifyButton.layer.borderWidth = 1.5
        searchConditionModifyButton.layer.cornerRadius = 15

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
    }
    
    private func requestReview(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.FirstRequestReviewKey : false, GlobalConstants.LaunchCountAfterReviewKey : 0])

        let hasReviewed = defaults.bool(forKey: GlobalConstants.FirstRequestReviewKey)
        let launchCountAfterReview = defaults.integer(forKey: GlobalConstants.LaunchCountAfterReviewKey)

        if let launchDateAfterReview = defaults.object(forKey: GlobalConstants.LaunchDateAfterReviewKey) as? NSDate {
            if hasReviewed == false{
                defaults.set(launchCountAfterReview + 1, forKey: GlobalConstants.LaunchCountAfterReviewKey)

                let daySpan = NSDate().timeIntervalSince(launchDateAfterReview as Date) / 60 / 60 / 24
                if daySpan > 10 && launchCountAfterReview > 7{
                    defaults.set(true, forKey: GlobalConstants.FirstRequestReviewKey)
                    SKStoreReviewController.requestReview()
                }
            }
        } else {
            defaults.set(NSDate(), forKey: GlobalConstants.LaunchDateAfterReviewKey)
        }
    }
    
    private func getTextFieldFromView(view: UIView) -> UITextField? {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isBookmarkMode ? changeToBookmarkMode() : changeToRecipeMode()

        searchContainer.backgroundColor = UchicockStyle.filterContainerBackgroundColor
        
        let textFieldInSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UchicockStyle.labelTextColorLight

        if #available(iOS 13.0, *) {
            searchBar.searchTextField.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        }else{
            for view in searchBar.subviews {
                for subview in view.subviews {
                    if subview is UITextField {
                        let textField: UITextField = subview as! UITextField
                        textField.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
                        textField.layer.borderWidth = 1.0
                        textField.layer.cornerRadius = 8.0
                        for subsubview in subview.subviews{
                            if subsubview is UILabel{
                                let placeholderLabel = subsubview as! UILabel
                                placeholderLabel.textColor = UchicockStyle.labelTextColorLight
                            }
                        }
                    }
                }
            }
        }
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    for subsubview in subview.subviews{
                        if subsubview is UILabel{
                            let placeholderLabel = subsubview as! UILabel
                            placeholderLabel.textColor = UchicockStyle.labelTextColorLight
                        }
                    }
                }
            }
        }
        
        searchConditionModifyButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        searchConditionModifyButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        searchConditionModifyButton.backgroundColor = UchicockStyle.basicBackgroundColor
        
        containerSeparator.backgroundColor = UchicockStyle.labelTextColorLight

        self.view.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.labelTextColorLight
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        
        setTableViewData()
        
        if tableView.indexPathsForVisibleRows != nil && selectedRecipeId != nil {
            for indexPath in tableView.indexPathsForVisibleRows! {
                if recipeBasicList.count > indexPath.row {
                    if recipeBasicList[indexPath.row].id == selectedRecipeId! {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                        break
                    }
                }
            }
        }
    }
    
    private func setTableViewData(){
        loadSearchUserDefaults()
        setSearchConditionButtonTitle()
        reloadRecipeList()
        tableView.reloadData()
    }
    
    private func loadSearchUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.RecipeSortPrimaryKey : 1])
        defaults.register(defaults: [GlobalConstants.RecipeSortSecondaryKey : 0])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar0Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar1Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar2Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar3Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterLongKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterShortKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterHotKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStyleNoneKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterBuildKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStirKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterShakeKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterBlendKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterOthersKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterNonAlcoholKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterWeakKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterMediumKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStrongKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStrengthNoneKey : true])
        
        recipeSortPrimary = defaults.integer(forKey: GlobalConstants.RecipeSortPrimaryKey)
        recipeSortSecondary = defaults.integer(forKey: GlobalConstants.RecipeSortSecondaryKey)
        recipeFilterStar0 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar0Key)
        recipeFilterStar1 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar1Key)
        recipeFilterStar2 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar2Key)
        recipeFilterStar3 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar3Key)
        recipeFilterLong = defaults.bool(forKey: GlobalConstants.RecipeFilterLongKey)
        recipeFilterShort = defaults.bool(forKey: GlobalConstants.RecipeFilterShortKey)
        recipeFilterHot = defaults.bool(forKey: GlobalConstants.RecipeFilterHotKey)
        recipeFilterStyleNone = defaults.bool(forKey: GlobalConstants.RecipeFilterStyleNoneKey)
        recipeFilterBuild = defaults.bool(forKey: GlobalConstants.RecipeFilterBuildKey)
        recipeFilterStir = defaults.bool(forKey: GlobalConstants.RecipeFilterStirKey)
        recipeFilterShake = defaults.bool(forKey: GlobalConstants.RecipeFilterShakeKey)
        recipeFilterBlend = defaults.bool(forKey: GlobalConstants.RecipeFilterBlendKey)
        recipeFilterOthers = defaults.bool(forKey: GlobalConstants.RecipeFilterOthersKey)
        recipeFilterNonAlcohol = defaults.bool(forKey: GlobalConstants.RecipeFilterNonAlcoholKey)
        recipeFilterWeak = defaults.bool(forKey: GlobalConstants.RecipeFilterWeakKey)
        recipeFilterMedium = defaults.bool(forKey: GlobalConstants.RecipeFilterMediumKey)
        recipeFilterStrong = defaults.bool(forKey: GlobalConstants.RecipeFilterStrongKey)
        recipeFilterStrengthNone = defaults.bool(forKey: GlobalConstants.RecipeFilterStrengthNoneKey)
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
        
        if traitCollection.verticalSizeClass == .compact && isTyping {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }else{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTableBackgroundView() // 画面リサイズ時や実行端末のサイズがStoryboardsと異なる時、EmptyDataの表示位置がずれないようにするために必要
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTableBackgroundView()
        super.viewDidAppear(animated)
        
        if let path = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: path, animated: true)
        }
        selectedRecipeId = nil
                
        tableView.flashScrollIndicators()

        if shouldShowBookmarkGuide{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                MessageHUD.show("←レシピに戻る", for: 2.0, withCheckmark: false, isCenter: false)
            }
            shouldShowBookmarkGuide = false
        }
    }
    
    func scrollToTop() {
        tableView?.flashScrollIndicators()
        tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: - Manage Data
    private func deleteRecipe(id: String) {
        let realm = try! Realm()
        let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: id)!
        
        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
        for ri in recipe.recipeIngredients{
            let recipeIngredient = realm.object(ofType: RecipeIngredientLink.self, forPrimaryKey: ri.id)!
            deletingRecipeIngredientList.append(recipeIngredient)
        }
        
        ImageUtil.remove(imageFileName: recipe.imageFileName)
        
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
    
    private func reloadRecipeList(){
        let realm = try! Realm()
        recipeList = realm.objects(Recipe.self)
        reloadRecipeBasicList()
    }
    
    private func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        
        if isBookmarkMode{
            for recipe in recipeList! {
                if recipe.bookmarkDate != nil{
                    recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, strength: recipe.strength, imageFileName: recipe.imageFileName, bookmarkDate: recipe.bookmarkDate))
                }
            }
            
            recipeBasicList.sort(by: { $0.bookmarkDate! > $1.bookmarkDate! })
            self.navigationItem.title = "ブックマーク(" + String(recipeBasicList.count) + ")"
        }else{
            for recipe in recipeList! {
                recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, strength: recipe.strength, imageFileName: recipe.imageFileName, bookmarkDate: recipe.bookmarkDate))
            }
            
            if searchBar.text!.withoutSpaceAndMiddleDot() != ""{
                recipeBasicList.removeAll{ $0.katakanaLowercasedNameForSearch.contains(searchBar.text!.katakanaLowercasedForSearch()) == false }
            }

            filterRecipeBasicList()
            sortRecipeBasicList()
                
            self.navigationItem.title = "レシピ(" + String(recipeBasicList.count) + "/" + String(recipeList!.count) + ")"
        }
        
        setTableBackgroundView()
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
    }
    
    private func setTableBackgroundView(){
        if recipeBasicList.count == 0{
            tableView.backgroundView = UIView()
            tableView.isScrollEnabled = false
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: tableView.bounds.size.height / 5, width: tableView.bounds.size.width, height: 100))
            noDataLabel.numberOfLines = 0
            noDataLabel.textColor = UchicockStyle.labelTextColorLight
            noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            noDataLabel.textAlignment = .center
            
            if isBookmarkMode{
                noDataLabel.text = "ブックマークはありません\n\nレシピ画面のブックマークボタンから\n追加できます"
            }else{
                noDataLabel.text = "条件にあてはまるレシピはありません"
                if recipeFilterStar0 && recipeFilterStar1 && recipeFilterStar2 && recipeFilterStar3 &&
                    recipeFilterLong && recipeFilterShort && recipeFilterHot && recipeFilterStyleNone &&
                    recipeFilterBuild && recipeFilterStir && recipeFilterShake && recipeFilterBlend && recipeFilterOthers &&
                    recipeFilterNonAlcohol && recipeFilterWeak && recipeFilterMedium && recipeFilterStrong && recipeFilterStrengthNone{
                }else{
                    noDataLabel.text! += "\n絞り込み条件を変えると見つかるかもしれません"
                }
            }
            
            tableView.backgroundView?.addSubview(noDataLabel)
        }else{
            tableView.backgroundView = nil
            tableView.isScrollEnabled = true
        }
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0{
            scrollBeginningYPoint = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50, isBookmarkMode == false{
            searchBar.becomeFirstResponder()
        }else if scrollBeginningYPoint < scrollView.contentOffset.y {
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isTyping = true
        if traitCollection.verticalSizeClass == .compact{
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isTyping = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            reloadRecipeBasicList()
            tableView.reloadData()
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
        if recipeList == nil{
            reloadRecipeList()
        }
        return recipeBasicList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit =  UIContextualAction(style: .normal, title: "編集", handler: { (action,view,completionHandler ) in
            if let editNavi = UIStoryboard(name: "RecipeEdit", bundle: nil).instantiateViewController(withIdentifier: "RecipeEditNavigation") as? BasicNavigationController{
                guard let editVC = editNavi.visibleViewController as? RecipeEditTableViewController else{
                    return
                }
                
                let realm = try! Realm()
                let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: self.recipeBasicList[indexPath.row].id)!
                self.selectedRecipeId = self.recipeBasicList[indexPath.row].id
                editVC.recipe = recipe
                    
                editNavi.modalPresentationStyle = .fullScreen
                editNavi.modalTransitionStyle = .coverVertical
                editVC.mainNavigationController = self.navigationController as? BasicNavigationController
                self.present(editNavi, animated: true, completion: nil)
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        })
        edit.image = UIImage(named: "button-edit")
        edit.backgroundColor = UchicockStyle.tableViewCellEditBackgroundColor
        
        let del =  UIContextualAction(style: .destructive, title: "削除", handler: { (action,view,completionHandler ) in
            let alertView = CustomAlertController(title: "このレシピを本当に削除しますか？", message: "自作レシピは復元できません。", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                self.deleteRecipe(id: self.recipeBasicList[indexPath.row].id)
                self.recipeBasicList.remove(at: indexPath.row)
                self.setTableBackgroundView()
                self.tableView.deleteRows(at: [indexPath], with: .middle)
                if self.isBookmarkMode{
                    self.navigationItem.title = "ブックマーク(" + String(self.recipeBasicList.count) + ")"
                }else{
                    self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + "/" + String(self.recipeList!.count) + ")"
                }
                completionHandler(true)
            }))
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in
                completionHandler(false)
            })
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        })
        del.image = UIImage(named: "button-delete")
        del.backgroundColor = UchicockStyle.alertColor

        return isBookmarkMode ? UISwipeActionsConfiguration(actions: [edit]) : UISwipeActionsConfiguration(actions: [del, edit])
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let previewProvider: () -> RecipeDetailTableViewController? = {
            let vc = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
            vc.fromContextualMenu = true
            vc.recipeId = self.recipeBasicList[indexPath.row].id
            return vc
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: previewProvider, actionProvider: nil)
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating){
        guard let indexPath = configuration.identifier as? IndexPath else { return }
        
        animator.addCompletion {
            self.performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!
            if isBookmarkMode{
                cell.subInfoType = 0
            }else{
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
            }
            cell.recipe = recipe
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - UITabelViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            let imageFileName = self.recipeBasicList[indexPath.row].imageFileName
            DispatchQueue.global(qos: .userInteractive).async{
                ImageUtil.saveToCache(imageFileName: imageFileName)
            }
        }
    }

    // MARK: - IBAction
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if let editNavi = UIStoryboard(name: "RecipeEdit", bundle: nil).instantiateViewController(withIdentifier: "RecipeEditNavigation") as? BasicNavigationController{
            guard let editVC = editNavi.visibleViewController as? RecipeEditTableViewController else{
                    return
            }
            
            editNavi.modalPresentationStyle = .fullScreen
            editNavi.modalTransitionStyle = .coverVertical
            editVC.mainNavigationController = self.navigationController as? BasicNavigationController
            self.present(editNavi, animated: true, completion: nil)
        }
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIBarButtonItem) {
        isBookmarkMode.toggle()
        
        isBookmarkMode ? changeToBookmarkMode() : changeToRecipeMode()
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    private func changeToBookmarkMode(){
        bookmarkButton.image = UIImage(named: "navigation-recipe-bookmark-on")
        searchBarHeightConstraint.constant = 0
        searchBarBottomConstraint.constant = 0
        searchConditionModifyButtonHeightConstraint.constant = 0
        searchConditionModifyButton.isHidden = true
        containerSeparatorTopConstraint.constant = 0
        containerSeparatorHeightConstraint.constant = 0
        addRecipeButton.isEnabled = false
        searchBar.resignFirstResponder()
    }
    
    private func changeToRecipeMode(){
        bookmarkButton.image = UIImage(named: "navigation-recipe-bookmark-off")
        searchBarHeightConstraint.constant = 44
        searchBarBottomConstraint.constant = 4
        searchConditionModifyButtonHeightConstraint.constant = 30
        searchConditionModifyButton.isHidden = false
        containerSeparatorTopConstraint.constant = 8
        containerSeparatorHeightConstraint.constant = 1
        addRecipeButton.isEnabled = true
    }
    
    @IBAction func searchConditionModifyButtonTapped(_ sender: UIButton) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)

        let storyboard = UIStoryboard(name: "RecipeSearch", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeSearchModalNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! RecipeSearchViewController
        vc.onDoneBlock = {
            self.setTableViewData()
        }
        vc.userDefaultsPrefix = "recipe-"
        
        recipeBasicListForFilterModal.removeAll()
        for recipe in recipeList!{
            recipeBasicListForFilterModal.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch, shortageNum: recipe.shortageNum, favorites: recipe.favorites, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method, style: recipe.style, strength: recipe.strength, imageFileName: recipe.imageFileName, bookmarkDate: recipe.bookmarkDate))
        }
        if searchBar.text!.withoutSpaceAndMiddleDot() != ""{
            recipeBasicListForFilterModal.removeAll{ !$0.katakanaLowercasedNameForSearch.contains(searchBar.text!.katakanaLowercasedForSearch()) }
        }

        vc.recipeBasicListForFilterModal = self.recipeBasicListForFilterModal
        searchBar.resignFirstResponder()

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
