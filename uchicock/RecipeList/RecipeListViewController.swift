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

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, UIViewControllerTransitioningDelegate, UITextFieldDelegate, ScrollableToTop{

    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var addRecipeButton: UIBarButtonItem!

    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchTextField: CustomTextField!
    @IBOutlet weak var searchConditionModifyButton: UIButton!
    @IBOutlet weak var containerSeparator: UIView!
    @IBOutlet weak var searchTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldLandscapeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchConditionModifyButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    let selectedCellBackgroundView = UIView()

    var recipeList: Results<Recipe>?
    var recipeBasicList = Array<RecipeBasic>()

    var isBookmarkMode = false
    var shouldShowBookmarkGuide = false
    var selectedRecipeId: String? = nil
    var recipeTableViewOffset: CGFloat? = nil
    var bookmarkTableViewOffset: CGFloat? = nil
    var scrollBeginningYPoint: CGFloat? = nil
    var textFieldHasSearchResult = false
    
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
        requestReview()
        
        makeFilterFromSearchUserDefaults()
        setSearchConditionButtonTitle()

        searchTextField.clearButtonEdgeInset = 4.0
        searchTextField.layer.cornerRadius = searchTextField.frame.size.height / 2

        searchConditionModifyButton.layer.borderWidth = 1.5
        searchConditionModifyButton.layer.cornerRadius = searchConditionModifyButton.frame.size.height / 2

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
    }
    
    private func requestReview(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.RequestReviewKey : false, GlobalConstants.LaunchCountKey : 0])

        let hasReviewed = defaults.bool(forKey: GlobalConstants.RequestReviewKey)
        guard hasReviewed == false else { return }
        let launchCount = defaults.integer(forKey: GlobalConstants.LaunchCountKey)

        if let launchDate = defaults.object(forKey: GlobalConstants.LaunchDateKey) as? NSDate {
            defaults.set(launchCount + 1, forKey: GlobalConstants.LaunchCountKey)
            let daySpan = NSDate().timeIntervalSince(launchDate as Date) / 60 / 60 / 24
            if daySpan > 10 && launchCount > 7{
                defaults.set(true, forKey: GlobalConstants.RequestReviewKey)
                SKStoreReviewController.requestReview()
            }
        }else{
            defaults.set(NSDate(), forKey: GlobalConstants.LaunchDateKey)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isBookmarkMode ? changeToBookmarkMode() : changeToRecipeMode()

        searchContainer.backgroundColor = UchicockStyle.filterContainerBackgroundColor
        searchTextField.backgroundColor = UchicockStyle.searchTextViewBackgroundColor
        searchTextField.attributedPlaceholder = NSAttributedString(string: "レシピ名で検索", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        searchTextField.adjustClearButtonColor()
        searchTextField.setSearchIcon()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeListViewController.searchTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.searchTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeListViewController.searchTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.searchTextField)

        searchConditionModifyButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        searchConditionModifyButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        searchConditionModifyButton.backgroundColor = UchicockStyle.basicBackgroundColor
        
        containerSeparator.backgroundColor = UchicockStyle.tableViewSeparatorColor

        self.view.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        
        let realm = try! Realm()
        recipeList = realm.objects(Recipe.self)
        reloadRecipeBasicList()
        updateSearchResultFlag()
        setSearchTextFieldAlertStyle()
        setTableBackgroundView()
        tableView.reloadData()

        if tableView.indexPathsForVisibleRows != nil && selectedRecipeId != nil {
            for indexPath in tableView.indexPathsForVisibleRows! where recipeBasicList.count > indexPath.row {
                if recipeBasicList[indexPath.row].id == selectedRecipeId! {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                    break
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.verticalSizeClass == .compact && searchTextField.isFirstResponder {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }else{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Logic functions
    private func registerUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            GlobalConstants.RecipeSortPrimaryKey : 1,
            GlobalConstants.RecipeSortSecondaryKey : 0,
            GlobalConstants.RecipeFilterStar0Key : true,
            GlobalConstants.RecipeFilterStar1Key : true,
            GlobalConstants.RecipeFilterStar2Key : true,
            GlobalConstants.RecipeFilterStar3Key : true,
            GlobalConstants.RecipeFilterLongKey : true,
            GlobalConstants.RecipeFilterShortKey : true,
            GlobalConstants.RecipeFilterHotKey : true,
            GlobalConstants.RecipeFilterStyleNoneKey : true,
            GlobalConstants.RecipeFilterBuildKey : true,
            GlobalConstants.RecipeFilterStirKey : true,
            GlobalConstants.RecipeFilterShakeKey : true,
            GlobalConstants.RecipeFilterBlendKey : true,
            GlobalConstants.RecipeFilterOthersKey : true,
            GlobalConstants.RecipeFilterNonAlcoholKey : true,
            GlobalConstants.RecipeFilterWeakKey : true,
            GlobalConstants.RecipeFilterMediumKey : true,
            GlobalConstants.RecipeFilterStrongKey : true,
            GlobalConstants.RecipeFilterStrengthNoneKey : true
        ])
    }
    
    private func makeFilterFromSearchUserDefaults(){
        recipeFilterStar.removeAll()
        recipeFilterStyle.removeAll()
        recipeFilterMethod.removeAll()
        recipeFilterStrength.removeAll()

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStar0Key) { recipeFilterStar.append(0) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStar1Key) { recipeFilterStar.append(1) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStar2Key) { recipeFilterStar.append(2) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStar3Key) { recipeFilterStar.append(3) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterLongKey) { recipeFilterStyle.append(0) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterShortKey) { recipeFilterStyle.append(1) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterHotKey) { recipeFilterStyle.append(2) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStyleNoneKey) { recipeFilterStyle.append(3) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterBuildKey) { recipeFilterMethod.append(0) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStirKey) { recipeFilterMethod.append(1) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterShakeKey) { recipeFilterMethod.append(2) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterBlendKey) { recipeFilterMethod.append(3) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterOthersKey) { recipeFilterMethod.append(4) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterNonAlcoholKey) { recipeFilterStrength.append(0) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterWeakKey) { recipeFilterStrength.append(1) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterMediumKey) { recipeFilterStrength.append(2) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStrongKey) { recipeFilterStrength.append(3) }
        if defaults.bool(forKey: GlobalConstants.RecipeFilterStrengthNoneKey) { recipeFilterStrength.append(4) }

        let sortPrimary = defaults.integer(forKey: GlobalConstants.RecipeSortPrimaryKey)
        let sortSecondary = defaults.integer(forKey: GlobalConstants.RecipeSortSecondaryKey)
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
    
    private func reloadRecipeBasicList(){
        if isBookmarkMode{
            recipeBasicList.removeAll()
            for recipe in recipeList! where recipe.bookmarkDate != nil{
                recipeBasicList.append(RecipeBasic(
                    id: recipe.id,
                    name: recipe.recipeName,
                    nameYomi: recipe.recipeNameYomi,
                    katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch,
                    bookmarkDate: recipe.bookmarkDate,
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
            recipeBasicList.sort(by: { $0.bookmarkDate! > $1.bookmarkDate! })
            self.navigationItem.title = "ブックマーク(" + String(recipeBasicList.count) + ")"
        }else{
            createRecipeBasicList()
            sortRecipeBasicList()
            self.navigationItem.title = "レシピ(" + String(recipeBasicList.count) + "/" + String(recipeList!.count) + ")"
        }
    }

    private func createRecipeBasicList(){
        recipeBasicList.removeAll()
        
        let searchText = searchTextField.text!.withoutMiddleSpaceAndMiddleDot()
        let convertedSearchText = searchTextField.text!.convertToYomi().katakanaLowercasedForSearch()
        for recipe in recipeList! {
            if recipeFilterStar.contains(recipe.favorites) && recipeFilterStyle.contains(recipe.style) &&
                recipeFilterMethod.contains(recipe.method) && recipeFilterStrength.contains(recipe.strength) &&
                (searchText == "" ||
                    recipe.katakanaLowercasedNameForSearch.contains(convertedSearchText) ||
                    recipe.recipeName.contains(searchText)){
                recipeBasicList.append(RecipeBasic(
                    id: recipe.id,
                    name: recipe.recipeName,
                    nameYomi: recipe.recipeNameYomi,
                    katakanaLowercasedNameForSearch: recipe.katakanaLowercasedNameForSearch,
                    bookmarkDate: recipe.bookmarkDate,
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
    
    private func updateSearchResultFlag(){
        let searchText = searchTextField.text!.withoutMiddleSpaceAndMiddleDot()
        if searchText != ""{
            let convertedSearchText = searchTextField.text!.convertToYomi().katakanaLowercasedForSearch()
            let realm = try! Realm()
            let searchedRecipe = realm.objects(Recipe.self)
                .filter("katakanaLowercasedNameForSearch CONTAINS %@ OR recipeName CONTAINS %@", convertedSearchText, searchText)
            textFieldHasSearchResult = searchedRecipe.count > 0
        }else{
            textFieldHasSearchResult = true
        }
    }
    
    private func setSearchTextFieldAlertStyle(){
        if textFieldHasSearchResult == false {
            searchTextField.layer.borderWidth = 1
            searchTextField.layer.borderColor = UchicockStyle.alertColor.cgColor
            searchTextField.textColor = UchicockStyle.alertColor
        }else{
            searchTextField.layer.borderWidth = 0
            searchTextField.layer.borderColor = UIColor.clear.cgColor
            searchTextField.textColor = UchicockStyle.labelTextColor
        }
    }
    
    private func setTableBackgroundView(){
        guard recipeBasicList.count == 0 else {
            tableView.backgroundView = nil
            tableView.isScrollEnabled = true
            return
        }

        tableView.backgroundView = UIView()
        tableView.isScrollEnabled = false
            
        let noDataLabel = UILabel()
        noDataLabel.numberOfLines = 0
        noDataLabel.textColor = UchicockStyle.labelTextColorLight
        noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        noDataLabel.textAlignment = .center
        tableView.backgroundView?.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerXConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerX, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        
        if isBookmarkMode{
            let centerYConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerY, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])

            noDataLabel.text = "ブックマークはありません\n\nレシピ画面のブックマークボタンから\n追加できます"
        }else{
            let topConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .top, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .top, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120)
            NSLayoutConstraint.activate([centerXConstraint, topConstraint, heightConstraint])
            
            if recipeList == nil || recipeList!.count == 0{
                noDataLabel.text = "レシピはありません"
            }else{
                if textFieldHasSearchResult{
                    if searchTextField.text!.withoutMiddleSpaceAndMiddleDot() == "" {
                        noDataLabel.text = "絞り込み条件にあてはまるレシピはありません"
                    }else{
                        noDataLabel.text = "入力したレシピ名のレシピはありますが、\n絞り込み条件には該当しません\n絞り込み条件を変更してください"
                    }
                }else{
                    noDataLabel.text = "検索文字列にあてはまるレシピはありません"
                }
            }
        }
    }

    private func deleteRecipe(id: String) {
        let realm = try! Realm()
        let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: id)!
        
        ImageUtil.remove(imageFileName: recipe.imageFileName)

        try! realm.write{
            for ri in recipe.recipeIngredients{
                let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                for i in 0 ..< ingredient.recipeIngredients.count where i < ingredient.recipeIngredients.count{
                    if ingredient.recipeIngredients[i].id == ri.id{
                        ingredient.recipeIngredients.remove(at: i)
                    }
                }
            }
            for ri in recipe.recipeIngredients{
                realm.delete(ri)
            }
            realm.delete(recipe)
        }
    }
    
    // MARK: - ScrollableToTop
    func scrollToTop() {
        tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0{
            scrollBeginningYPoint = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50, isBookmarkMode == false{
            searchTextField.becomeFirstResponder()
        }else if let yPoint = scrollBeginningYPoint, yPoint < scrollView.contentOffset.y {
            searchTextField.resignFirstResponder()
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField){
        scrollBeginningYPoint = nil
        if traitCollection.verticalSizeClass == .compact{
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        textField.text = textField.text!.withoutEndsSpace()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        searchTextField.resignFirstResponder()
        searchTextField.adjustClearButtonColor()
        reloadRecipeBasicList()
        updateSearchResultFlag()
        setSearchTextFieldAlertStyle()
        setTableBackgroundView()
        tableView.reloadData()
        return true
    }

    @objc func searchTextFieldDidChange(_ notification: Notification){
        searchTextField.adjustClearButtonColor()
        reloadRecipeBasicList()
        updateSearchResultFlag()
        setSearchTextFieldAlertStyle()
        setTableBackgroundView()
        tableView.reloadData()
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return recipeBasicList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextField.resignFirstResponder()
        performSegue(withIdentifier: "PushRecipeDetail", sender: recipeBasicList[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit =  UIContextualAction(style: .normal, title: "編集"){ action,view,completionHandler in
            if let editNavi = UIStoryboard(name: "RecipeEdit", bundle: nil).instantiateViewController(withIdentifier: "RecipeEditNavigation") as? BasicNavigationController{
                guard let editVC = editNavi.visibleViewController as? RecipeEditTableViewController else { return }
                
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
        }
        edit.image = UIImage(named: "button-edit")
        edit.backgroundColor = UchicockStyle.tableViewCellEditBackgroundColor
        
        let del =  UIContextualAction(style: .destructive, title: "削除"){ action,view,completionHandler in
            let alertView = CustomAlertController(title: "このレシピを本当に削除しますか？", message: "自作レシピは復元できません。", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            let deleteAction = UIAlertAction(title: "削除", style: .destructive){action in
                self.deleteRecipe(id: self.recipeBasicList[indexPath.row].id)
                self.recipeBasicList.remove(at: indexPath.row)
                self.updateSearchResultFlag()
                self.setSearchTextFieldAlertStyle()
                self.tableView.deleteRows(at: [indexPath], with: .middle)
                self.setTableBackgroundView()
                self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + "/" + String(self.recipeList!.count) + ")"
                completionHandler(true)
            }
            deleteAction.setValue(UchicockStyle.alertColor, forKey: "titleTextColor")
            alertView.addAction(deleteAction)
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel){action in
                completionHandler(false)
            }
            cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
            alertView.addAction(cancelAction)
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        }
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
            self.performSegue(withIdentifier: "PushRecipeDetail", sender: self.recipeBasicList[indexPath.row].id)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
        cell.sortOrder = isBookmarkMode ? .name : sortOrder
        cell.recipe = recipeBasicList[indexPath.row]
        cell.backgroundColor = UchicockStyle.basicBackgroundColor
        cell.selectedBackgroundView = selectedCellBackgroundView
        return cell
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
            guard let editVC = editNavi.visibleViewController as? RecipeEditTableViewController else{ return }
            
            editNavi.modalPresentationStyle = .fullScreen
            editNavi.modalTransitionStyle = .coverVertical
            editVC.mainNavigationController = self.navigationController as? BasicNavigationController
            self.present(editNavi, animated: true, completion: nil)
        }
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        isBookmarkMode.toggle()
        if isBookmarkMode{
            recipeTableViewOffset = max(tableView.contentOffset.y, 0)
            changeToBookmarkMode()
        }else{
            bookmarkTableViewOffset = max(tableView.contentOffset.y, 0)
            changeToRecipeMode()
        }
        
        reloadRecipeBasicList()
        setTableBackgroundView()

        if isBookmarkMode, let offset = bookmarkTableViewOffset{
            tableView.contentOffset.y = offset
        }else if isBookmarkMode == false, let offset = recipeTableViewOffset{
            tableView.contentOffset.y = offset
        }
        tableView.reloadData()
    }
    
    private func changeToBookmarkMode(){
        bookmarkButton.image = UIImage(named: "navigation-recipe-bookmark-on")
        searchTextFieldTopConstraint.constant = 0
        searchTextFieldHeightConstraint.constant = 0
        searchTextFieldBottomConstraint.constant = 0
        searchTextFieldLandscapeBottomConstraint.constant = 0
        searchConditionModifyButtonHeightConstraint.constant = 0
        searchConditionModifyButton.isHidden = true
        containerSeparatorTopConstraint.constant = 0
        containerSeparatorHeightConstraint.constant = 0
        addRecipeButton.isEnabled = false
        searchTextField.resignFirstResponder()
    }
    
    private func changeToRecipeMode(){
        bookmarkButton.image = UIImage(named: "navigation-recipe-bookmark-off")
        searchTextFieldTopConstraint.constant = 6
        searchTextFieldHeightConstraint.constant = 36
        searchTextFieldBottomConstraint.constant = 6
        searchTextFieldLandscapeBottomConstraint.constant = 6
        searchConditionModifyButtonHeightConstraint.constant = 30
        searchConditionModifyButton.isHidden = false
        containerSeparatorTopConstraint.constant = 6
        containerSeparatorHeightConstraint.constant = 1
        addRecipeButton.isEnabled = true
    }
    
    @IBAction func searchConditionModifyButtonTapped(_ sender: UIButton) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        searchTextField.resignFirstResponder()

        let storyboard = UIStoryboard(name: "RecipeSearch", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeSearchModalNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! RecipeSearchViewController
        vc.onDoneBlock = {
            self.makeFilterFromSearchUserDefaults()
            self.setSearchConditionButtonTitle()
            self.reloadRecipeBasicList()
            self.setTableBackgroundView()
            self.tableView.reloadData()
        }
        vc.udPrefix = "recipe-"
        
        var recipeBasicListForFilterModal = Array<RecipeBasic>()
        let searchText = searchTextField.text!.withoutMiddleSpaceAndMiddleDot()
        let convertedSearchText = searchTextField.text!.convertToYomi().katakanaLowercasedForSearch()

        for recipe in recipeList!{
            if searchText == "" ||
                recipe.katakanaLowercasedNameForSearch.contains(convertedSearchText) ||
                recipe.recipeName.contains(searchText){
                recipeBasicListForFilterModal.append(RecipeBasic(
                    id: "",
                    name: "",
                    nameYomi: "",
                    katakanaLowercasedNameForSearch: "",
                    shortageNum: 0,
                    favorites: recipe.favorites,
                    style: recipe.style,
                    method: recipe.method,
                    strength: recipe.strength,
                    madeNum: 0
                ))
            }
        }        
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
