//
//  IngredientListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIViewControllerTransitioningDelegate, ScrollableToTop {

    @IBOutlet weak var reminderButton: BadgeBarButtonItem!
    @IBOutlet weak var addIngredientButton: UIBarButtonItem!
    
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var searchTextField: CustomTextField!
    @IBOutlet weak var categorySegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var stockSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var ingredientRecommendButton: UIButton!
    @IBOutlet weak var containerSeparator: UIView!
    
    @IBOutlet weak var searchTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stockStateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stockStateBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientRecommendButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorLandscapeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    let selectedCellBackgroundView = UIView()

    var ingredientList: Results<Ingredient>?
    var ingredientBasicList = Array<IngredientBasic>()
    
    var isReminderMode = false
    var shouldShowReminderGuide = false
    var selectedIngredientId: String? = nil
    var ingredientTableOffset: CGFloat? = nil
    var reminderTableOffset: CGFloat? = nil
    var scrollBeginningYPoint: CGFloat? = nil
    var textFieldHasSearchResult = false

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.layer.cornerRadius = searchTextField.frame.size.height / 2

        ingredientRecommendButton.layer.borderWidth = 1.5
        ingredientRecommendButton.layer.cornerRadius = ingredientRecommendButton.frame.size.height / 2

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setReminderBadge()
        isReminderMode ? changeToReminderMode() : changeToIngredientMode()

        self.view.backgroundColor = UchicockStyle.basicBackgroundColor
        searchTextField.backgroundColor = UchicockStyle.searchTextViewBackgroundColor
        searchTextField.attributedPlaceholder = NSAttributedString(string: "材料名で検索", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        searchTextField.adjustClearButtonColor()
        searchTextField.setSearchIcon()
        segmentedControlContainer.backgroundColor = UchicockStyle.filterContainerBackgroundColor

        categorySegmentedControl.layoutSubviews()
        stockSegmentedControl.layoutSubviews()

        ingredientRecommendButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        ingredientRecommendButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        ingredientRecommendButton.backgroundColor = UchicockStyle.basicBackgroundColor
        
        containerSeparator.backgroundColor = UchicockStyle.tableViewSeparatorColor
        
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor

        NotificationCenter.default.addObserver(self, selector:#selector(IngredientListViewController.searchTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.searchTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(IngredientListViewController.searchTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.searchTextField)

        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
        reloadIngredientBasicList()
        updateSearchResultFlag()
        setTextFieldAlertStyle()
        setTableBackgroundView()
        tableView.reloadData()
        
        highlightSelectedRow()
    }
    
    private func highlightSelectedRow(){
        if tableView.indexPathsForVisibleRows != nil && selectedIngredientId != nil {
            for indexPath in tableView.indexPathsForVisibleRows! where ingredientBasicList.count > indexPath.row {
                if ingredientBasicList[indexPath.row].id == selectedIngredientId! {
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
        selectedIngredientId = nil
        
        tableView.flashScrollIndicators()
        
        if shouldShowReminderGuide{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                MessageHUD.show("←材料に戻る", for: 2.0, withCheckmark: false, isCenter: false)
            }
            shouldShowReminderGuide = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Logic functions
    private func setReminderBadge(){
        let realm = try! Realm()
        let reminderNum = realm.objects(Ingredient.self).filter("reminderSetDate != nil").count

        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[1]
            tabItem.badgeColor = UchicockStyle.badgeBackgroundColor
            tabItem.badgeValue = reminderNum == 0 ? nil : "!"
            reminderButton.badgeText = reminderNum == 0 ? nil : "!"
        }
    }
    
    private func reloadIngredientBasicList(){
        if isReminderMode{
            ingredientBasicList.removeAll()

            for ingredient in ingredientList! where ingredient.reminderSetDate != nil{
                ingredientBasicList.append(IngredientBasic(
                    id: ingredient.id,
                    name: ingredient.ingredientName,
                    nameYomi: ingredient.ingredientNameYomi,
                    katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch,
                    stockFlag: ingredient.stockFlag,
                    category: ingredient.category,
                    contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability,
                    usingRecipeNum: ingredient.recipeIngredients.count,
                    reminderSetDate: ingredient.reminderSetDate
                ))
            }
            
            ingredientBasicList.sort { $0.reminderSetDate! > $1.reminderSetDate! }
            self.navigationItem.title = "購入リマインダー(" + String(ingredientBasicList.count) + ")"
        }else{
            createSearchedIngredientBaiscList()
            ingredientBasicList.sort { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending }
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + "/" + String(ingredientList!.count) + ")"
        }
    }
    
    private func createSearchedIngredientBaiscList(){
        ingredientBasicList.removeAll()
        
        var ingredientFilterStock: [Bool] = []
        var ingredientFilterCategory: [Int] = []

        if stockSegmentedControl.selectedSegmentIndex == 0{
            ingredientFilterStock.append(true)
            ingredientFilterStock.append(false)
        }else if stockSegmentedControl.selectedSegmentIndex == 1{
            ingredientFilterStock.append(true)
        }else if stockSegmentedControl.selectedSegmentIndex == 2{
            ingredientFilterStock.append(false)
        }
        if categorySegmentedControl.selectedSegmentIndex == 0{
            ingredientFilterCategory.append(0)
            ingredientFilterCategory.append(1)
            ingredientFilterCategory.append(2)
        }else{
            ingredientFilterCategory.append(categorySegmentedControl.selectedSegmentIndex - 1)
        }
        
        let searchText = searchTextField.text!.withoutMiddleSpaceAndMiddleDot()
        let convertedSearchText = searchTextField.text!.convertToYomi().katakanaLowercasedForSearch()
        for ingredient in ingredientList! where ingredientFilterStock.contains(ingredient.stockFlag) &&
            ingredientFilterCategory.contains(ingredient.category){
            if searchText == "" ||
                ingredient.katakanaLowercasedNameForSearch.contains(convertedSearchText) ||
                ingredient.ingredientName.contains(searchText){
                    ingredientBasicList.append(IngredientBasic(
                    id: ingredient.id,
                    name: ingredient.ingredientName,
                    nameYomi: ingredient.ingredientNameYomi,
                    katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch,
                    stockFlag: ingredient.stockFlag,
                    category: ingredient.category,
                    contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability,
                    usingRecipeNum: ingredient.recipeIngredients.count,
                    reminderSetDate: ingredient.reminderSetDate
                ))
            }
        }
    }
    
    private func updateSearchResultFlag(){
        let searchText = searchTextField.text!.withoutMiddleSpaceAndMiddleDot()
        if searchText != ""{
            let convertedSearchText = searchTextField.text!.convertToYomi().katakanaLowercasedForSearch()
            let realm = try! Realm()
            let searchedIng = realm.objects(Ingredient.self).filter("katakanaLowercasedNameForSearch CONTAINS %@ OR ingredientName CONTAINS %@", convertedSearchText, searchText)
            textFieldHasSearchResult = searchedIng.count > 0
        }else{
            textFieldHasSearchResult = true
        }
    }
    
    private func setTableBackgroundView(){
        guard ingredientBasicList.count == 0 else {
            tableView.backgroundView = nil
            tableView.isScrollEnabled = true
            return
        }
        tableView.backgroundView  = UIView()
        tableView.isScrollEnabled = false

        let noDataLabel = UILabel()
        noDataLabel.numberOfLines = 0
        noDataLabel.textColor = UchicockStyle.labelTextColorLight
        noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        noDataLabel.textAlignment = .center
        self.tableView.backgroundView?.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerXConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerX, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)

        if isReminderMode{
            let centerYConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerY, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])

            noDataLabel.text = "購入リマインダーはありません\n\n材料画面の「購入リマインダー」から\n登録できます"
        }else{
            let topConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .top, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .top, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
            NSLayoutConstraint.activate([centerXConstraint, topConstraint, heightConstraint])

            if ingredientList == nil || ingredientList!.count == 0{
                noDataLabel.text = "材料はありません"
            }else{
                if textFieldHasSearchResult{
                    if searchTextField.text!.withoutMiddleSpaceAndMiddleDot() == "" {
                        noDataLabel.text = "絞り込み条件にあてはまる材料はありません"
                    }else{
                        noDataLabel.text = "入力した材料名の材料はありますが、\n絞り込み条件には該当しません\n絞り込み条件を変更してください"
                    }
                }else{
                    noDataLabel.text = "検索文字列にあてはまる材料はありません"
                }
            }
        }
    }
    
    @objc func cellStockTapped(_ sender: CircularCheckbox){
        var view = sender.superview
        while (view! is IngredientListItemTableViewCell) == false{
            view = view!.superview
        }
        guard let index = tableView.indexPath(for: view as! IngredientListItemTableViewCell) else { return }

        let realm = try! Realm()
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientBasicList[index.row].id)!
        try! realm.write {
            ingredient.stockFlag = sender.checkState == .checked
            for ri in ingredient.recipeIngredients{
                ri.recipe.updateShortageNum()
            }
        }

        if ingredient.stockFlag && ingredient.reminderSetDate != nil{
            let alertView = CustomAlertController(title: nil, message: ingredient.ingredientName + "は購入リマインダーに登録されています。\n解除しますか？", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            let noAction = UIAlertAction(title: "解除しない", style: .cancel, handler: nil)
            if #available(iOS 13.0, *){ noAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
            alertView.addAction(noAction)
            let yesAction = UIAlertAction(title: "解除する", style: .default){action in
                try! realm.write {
                    ingredient.reminderSetDate = nil
                    if self.isReminderMode{
                        self.ingredientBasicList.remove(at: index.row)
                        self.tableView.deleteRows(at: [index], with: .middle)
                        self.setTableBackgroundView()
                        self.navigationItem.title = "購入リマインダー(" + String(self.ingredientBasicList.count) + ")"
                    }else{
                        MessageHUD.show("リマインダーを解除しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                    self.setReminderBadge()
                }
            }
            if #available(iOS 13.0, *){ yesAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
            alertView.addAction(yesAction)
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        }
        
        if self.isReminderMode == false && stockSegmentedControl.selectedSegmentIndex != 0{
            ingredientBasicList.remove(at: index.row)
            tableView.deleteRows(at: [index], with: .middle)
            setTableBackgroundView()
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + "/" + String(ingredientList!.count) + ")"
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
        if scrollView.contentOffset.y < -50, isReminderMode == false{
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
        reloadIngredientBasicList()
        updateSearchResultFlag()
        setTextFieldAlertStyle()
        setTableBackgroundView()
        tableView.reloadData()
        return true
    }

    @objc func searchTextFieldDidChange(_ notification: Notification){
        searchTextField.adjustClearButtonColor()
        reloadIngredientBasicList()
        updateSearchResultFlag()
        setTextFieldAlertStyle()
        setTableBackgroundView()
        tableView.reloadData()
    }
    
    private func setTextFieldAlertStyle(){
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

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientBasicList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextField.resignFirstResponder()
        if indexPath.row < ingredientBasicList.count{
            performSegue(withIdentifier: "PushIngredientDetail", sender: ingredientBasicList[indexPath.row].id)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let realm = try! Realm()
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!

        let edit =  UIContextualAction(style: .normal, title: "編集"){ action,view,completionHandler in
            if let editNavi = UIStoryboard(name: "IngredientEdit", bundle: nil).instantiateViewController(withIdentifier: "IngredientEditNavigation") as? BasicNavigationController{
                guard let editVC = editNavi.visibleViewController as? IngredientEditTableViewController else{ return }
                
                let realm = try! Realm()
                let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
                self.selectedIngredientId = self.ingredientBasicList[indexPath.row].id
                editVC.ingredient = ingredient                
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
            if ingredient.recipeIngredients.count > 0 {
                let alertView = CustomAlertController(title: nil, message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
                if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                    alertView.overrideUserInterfaceStyle = .dark
                }
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                if #available(iOS 13.0, *){ okAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                alertView.addAction(okAction)
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
                completionHandler(false)
            }else{
                let deleteAlertView = CustomAlertController(title: nil, message: "この材料を本当に削除しますか？", preferredStyle: .alert)
                if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                    deleteAlertView.overrideUserInterfaceStyle = .dark
                }
                let deleteAction = UIAlertAction(title: "削除", style: .destructive){action in
                    try! realm.write { realm.delete(ingredient) }
                    self.ingredientBasicList.remove(at: indexPath.row)
                    self.updateSearchResultFlag()
                    self.setTextFieldAlertStyle()
                    tableView.deleteRows(at: [indexPath], with: .middle)
                    self.setTableBackgroundView()
                    self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + "/" + String(self.ingredientList!.count) + ")"
                    self.setReminderBadge()
                    completionHandler(true)
                }
                if #available(iOS 13.0, *){ deleteAction.setValue(UchicockStyle.alertColor, forKey: "titleTextColor") }
                deleteAlertView.addAction(deleteAction)
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel){action in
                    completionHandler(false)
                }
                if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                deleteAlertView.addAction(cancelAction)
                deleteAlertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(deleteAlertView, animated: true, completion: nil)
            }
        }
        del.image = UIImage(named: "button-delete")
        del.backgroundColor = UchicockStyle.alertColor
        
        if ingredient.recipeIngredients.count == 0 && isReminderMode == false {
            return UISwipeActionsConfiguration(actions: [del, edit])
        }else{
            return UISwipeActionsConfiguration(actions: [edit])
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientListItem") as! IngredientListItemTableViewCell
        cell.selectedBackgroundView = selectedCellBackgroundView
        cell.backgroundColor = UchicockStyle.basicBackgroundColor

        let accesoryImageView = UIImageView(image: UIImage(named: "accesory-disclosure-indicator"))
        accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
        accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        cell.accessoryView = accesoryImageView
        cell.shouldAnimate = stockSegmentedControl.selectedSegmentIndex == 0
        cell.ingredient = ingredientBasicList[indexPath.row]
        cell.stockCheckbox.addTarget(self, action: #selector(IngredientListViewController.cellStockTapped(_:)), for: UIControl.Event.valueChanged)
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func reminderButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        isReminderMode.toggle()
        if isReminderMode{
            ingredientTableOffset = max(tableView.contentOffset.y, 0)
            changeToReminderMode()
        }else{
            reminderTableOffset = max(tableView.contentOffset.y, 0)
            changeToIngredientMode()
        }

        reloadIngredientBasicList()
        setTableBackgroundView()

        if isReminderMode, let offset = reminderTableOffset{
            tableView.contentOffset.y = offset
        }else if isReminderMode == false, let offset = ingredientTableOffset{
            tableView.contentOffset.y = offset
        }
        tableView.reloadData()
    }
    
    private func changeToReminderMode(){
        reminderButton.image = UIImage(named: "navigation-reminder-filled")
        searchTextFieldTopConstraint.constant = 0
        searchTextFieldHeightConstraint.constant = 0
        searchTextFieldBottomConstraint.constant = 0
        categoryHeightConstraint.constant = 0
        categorySegmentedControl.isHidden = true
        categoryBottomConstraint.constant = 0
        stockStateHeightConstraint.constant = 0
        stockSegmentedControl.isHidden = true
        stockStateBottomConstraint.constant = 0
        ingredientRecommendButtonHeightConstraint.constant = 0
        ingredientRecommendButton.isHidden = true
        containerSeparatorTopConstraint.constant = 0
        containerSeparatorLandscapeTopConstraint.constant = 0
        containerSeparatorHeightConstraint.constant = 0
        addIngredientButton.isEnabled = false
        searchTextField.resignFirstResponder()
    }
    
    private func changeToIngredientMode(){
        reminderButton.image = UIImage(named: "navigation-reminder-empty")
        searchTextFieldTopConstraint.constant = 6
        searchTextFieldHeightConstraint.constant = 36
        searchTextFieldBottomConstraint.constant = 6
        categoryHeightConstraint.constant = 28
        categorySegmentedControl.isHidden = false
        categoryBottomConstraint.constant = 6
        stockStateHeightConstraint.constant = 28
        stockSegmentedControl.isHidden = false
        stockStateBottomConstraint.constant = 6
        ingredientRecommendButtonHeightConstraint.constant = 30
        ingredientRecommendButton.isHidden = false
        containerSeparatorTopConstraint.constant = 6
        containerSeparatorLandscapeTopConstraint.constant = 6
        containerSeparatorHeightConstraint.constant = 1
        addIngredientButton.isEnabled = true
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if let editNavi = UIStoryboard(name: "IngredientEdit", bundle: nil).instantiateViewController(withIdentifier: "IngredientEditNavigation") as? BasicNavigationController{
            guard let editVC = editNavi.visibleViewController as? IngredientEditTableViewController else{ return }
            
            editNavi.modalPresentationStyle = .fullScreen
            editNavi.modalTransitionStyle = .coverVertical
            editVC.mainNavigationController = self.navigationController as? BasicNavigationController
            self.present(editNavi, animated: true, completion: nil)
        }
    }
    
    @IBAction func segmentedControlTapped(_ sender: CustomSegmentedControl) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        reloadIngredientBasicList()
        setTableBackgroundView()
        tableView.reloadData()
    }
    
    @IBAction func ingredientRecommendButtonTapped(_ sender: UIButton) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        searchTextField.resignFirstResponder()
        let storyboard = UIStoryboard(name: "IngredientRecommend", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "IngredientRecommendNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! IngredientRecommendTableViewController
        
        vc.onDoneBlock = { selectedRecommendIngredientId in
            if let selectedRecommendIngredientId = selectedRecommendIngredientId{
                let realm = try! Realm()
                let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: selectedRecommendIngredientId)
                if ing != nil{
                    self.performSegue(withIdentifier: "PushIngredientDetail", sender: selectedRecommendIngredientId)
                    self.highlightSelectedRow()
                }
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
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destination as! IngredientDetailTableViewController
            if let id = sender as? String{
                selectedIngredientId = id
                vc.ingredientId = id
            }
        }
    }
}
