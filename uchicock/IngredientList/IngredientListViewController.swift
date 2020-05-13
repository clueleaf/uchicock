//
//  IngredientListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIViewControllerTransitioningDelegate, ScrollableToTop {

    @IBOutlet weak var reminderButton: BadgeBarButtonItem!
    @IBOutlet weak var addIngredientButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var category: CustomSegmentedControl!
    @IBOutlet weak var stockState: CustomSegmentedControl!
    @IBOutlet weak var ingredientRecommendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerSeparator: UIView!
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stockStateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stockStateBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientRecommendButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorLandscapeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSeparatorHeightConstraint: NSLayoutConstraint!
    
    var ingredientList: Results<Ingredient>?
    var ingredientBasicList = Array<IngredientBasic>()
    
    var scrollBeginingYPoint: CGFloat = 0.0
    let selectedCellBackgroundView = UIView()
    var selectedIngredientId: String? = nil
    var isTyping = false
    var isReminderMode = false
    var shouldShowReminderGuide = false

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.backgroundImage = UIImage()
        
        category.layer.borderWidth = 1.0
        category.layer.masksToBounds = true
        stockState.layer.borderWidth = 1.0
        stockState.layer.masksToBounds = true

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setReminderBadge()
        isReminderMode ? changeToReminderMode() : changeToIngredientMode()
        self.view.backgroundColor = UchicockStyle.basicBackgroundColor

        segmentedControlContainer.backgroundColor = UchicockStyle.filterContainerBackgroundColor
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.labelTextColorLight
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor

        let textFieldInSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UchicockStyle.labelTextColorLight

        if #available(iOS 13.0, *) {
            searchBar.searchTextField.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
            searchBar.searchTextField.layer.borderWidth = 1.0
            searchBar.searchTextField.layer.cornerRadius = 8.0
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

        let font = UIFont.systemFont(ofSize: 12)
        let boldFont = UIFont.boldSystemFont(ofSize: 12)
        if #available(iOS 13.0, *) {
            category.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorOnBadge, NSAttributedString.Key.font: boldFont], for: .selected)
            category.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColor, NSAttributedString.Key.font: font], for: .normal)
        }else{
            category.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .selected)
            category.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            category.layer.cornerRadius = 14.0
            stockState.layer.cornerRadius = 14.0
        }

        category.layer.borderColor = UchicockStyle.primaryColor.cgColor
        stockState.layer.borderColor = UchicockStyle.primaryColor.cgColor

        ingredientRecommendButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        ingredientRecommendButton.layer.borderWidth = 1.5
        ingredientRecommendButton.layer.cornerRadius = 15
        ingredientRecommendButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        ingredientRecommendButton.backgroundColor = UchicockStyle.basicBackgroundColor
        
        containerSeparator.backgroundColor = UchicockStyle.labelTextColorLight
        
        reloadIngredientList()
        tableView.reloadData()
        
        highlightSelectedRow()
    }
    
    private func highlightSelectedRow(){
        if tableView.indexPathsForVisibleRows != nil && selectedIngredientId != nil {
            for indexPath in tableView.indexPathsForVisibleRows! {
                if ingredientBasicList.count > indexPath.row {
                    if ingredientBasicList[indexPath.row].id == selectedIngredientId! {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                        break
                    }
                }
            }
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
        setTableBackgroundView() // 実行端末のサイズがStoryboardsと異なる時、EmptyDataの表示位置がずれないようにするために必要
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
    
    func scrollToTop() {
        tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    private func setReminderBadge(){
        let realm = try! Realm()
        let reminderNum = realm.objects(Ingredient.self).filter("reminderSetDate != nil").count

        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[1]
            tabItem.badgeColor = UchicockStyle.badgeBackgroundColor
            if reminderNum == 0{
                tabItem.badgeValue = nil
                reminderButton.badgeText = nil
            }else{
                tabItem.badgeValue = "！"
                reminderButton.badgeText = "！"
            }
        }
    }
    
    private func getTextFieldFromView(_ view: UIView) -> UITextField?{
        for subview in view.subviews{
            if subview is UITextField {
                return subview as? UITextField
            }else{
                let textField = self.getTextFieldFromView(subview)
                if textField != nil{
                    return textField
                }
            }
        }
        return nil
    }
    
    // MARK: - Manage Data
    private func reloadIngredientList(){
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
        reloadIngredientBasicList()
    }
    
    private func reloadIngredientBasicList(){
        ingredientBasicList.removeAll()
        for ingredient in ingredientList!{
            ingredientBasicList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, nameYomi: ingredient.ingredientNameYomi, katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch , stockFlag: ingredient.stockFlag, category: ingredient.category, contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability, usedRecipeNum: ingredient.recipeIngredients.count, reminderSetDate: ingredient.reminderSetDate))
        }
        
        if isReminderMode{
            ingredientBasicList.removeAll{ $0.reminderSetDate == nil }
            ingredientBasicList.sort(by: { $0.reminderSetDate! > $1.reminderSetDate! })
            self.navigationItem.title = "購入リマインダー(" + String(ingredientBasicList.count) + ")"
        }else{
            let searchText = searchBar.text!
            let convertedSearchText = searchBar.text!.convertToYomi().katakanaLowercasedForSearch()
            if searchBar.text!.withoutMiddleSpaceAndMiddleDot() != ""{
                ingredientBasicList.removeAll{
                    ($0.katakanaLowercasedNameForSearch.contains(convertedSearchText) == false) &&
                    ($0.name.contains(searchText) == false)
                }
            }
            
            switch stockState.selectedSegmentIndex{
            case 1:
                ingredientBasicList.removeAll{ $0.stockFlag == false }
            case 2:
                ingredientBasicList.removeAll{ $0.stockFlag }
            default:
                break
            }
            
            if category.selectedSegmentIndex != 0{
                ingredientBasicList.removeAll{
                    $0.category != category.selectedSegmentIndex - 1
                }
            }

            ingredientBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })

            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + "/" + String(ingredientList!.count) + ")"
        }
        
        setTableBackgroundView()
    }
    
    private func setTableBackgroundView(){
        if ingredientBasicList.count == 0{
            self.tableView.backgroundView  = UIView()
            self.tableView.isScrollEnabled = false
            let noDataLabel  = UILabel(frame: CGRect(x: 0, y: self.tableView.bounds.size.height / 5, width: self.tableView.bounds.size.width, height: 100))
            noDataLabel.numberOfLines = 0
            noDataLabel.textColor = UchicockStyle.labelTextColorLight
            noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            noDataLabel.textAlignment = .center

            if isReminderMode{
                noDataLabel.text = "購入リマインダーはありません\n\n材料画面の「購入リマインダー」から\n登録できます"
            }else{
                noDataLabel.text = "条件にあてはまる材料はありません"
            }
            self.tableView.backgroundView?.addSubview(noDataLabel)
        }else{
            self.tableView.backgroundView = nil
            self.tableView.isScrollEnabled = true
        }
    }
    
    @objc func cellStockTapped(_ sender: CircularCheckbox){
        var view = sender.superview
        while (view! is IngredientListItemTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! IngredientListItemTableViewCell
        let touchIndex = self.tableView.indexPath(for: cell)
        
        if let index = touchIndex {
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientBasicList[index.row].id)!
            if ingredient.stockFlag {
                try! realm.write {
                    ingredient.stockFlag = false
                }
            }else{
                try! realm.write {
                    ingredient.stockFlag = true
                }
                if ingredient.reminderSetDate != nil{
                    let alertView = CustomAlertController(title: nil, message: ingredient.ingredientName + "は購入リマインダーに登録されています。\n解除しますか？", preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "解除しない", style: .cancel, handler: {action in}))
                    alertView.addAction(UIAlertAction(title: "解除する", style: .default, handler: {action in
                        try! realm.write {
                            ingredient.reminderSetDate = nil
                            if self.isReminderMode{
                                self.ingredientBasicList.remove(at: index.row)
                                self.tableView.deleteRows(at: [index], with: .middle)
                                if self.ingredientBasicList.count == 0{
                                    self.setTableBackgroundView()
                                    self.tableView.reloadData()
                                }
                                self.navigationItem.title = "購入リマインダー(" + String(self.ingredientBasicList.count) + ")"
                            }else{
                                MessageHUD.show("リマインダーを解除しました", for: 2.0, withCheckmark: true, isCenter: true)
                            }
                            self.setReminderBadge()
                        }
                    }))
                    alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    self.present(alertView, animated: true, completion: nil)
                }
            }
            
            try! realm.write {
                for ri in ingredient.recipeIngredients{
                    ri.recipe.updateShortageNum()
                }
            }
            
            if self.isReminderMode == false{
                if stockState.selectedSegmentIndex != 0{
                    ingredientBasicList.remove(at: index.row)
                    tableView.deleteRows(at: [index], with: .middle)
                    if ingredientBasicList.count == 0{
                        setTableBackgroundView()
                        tableView.reloadData()
                    }
                    self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + "/" + String(ingredientList!.count) + ")"
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0{
            scrollBeginingYPoint = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50, isReminderMode == false{
            searchBar.becomeFirstResponder()
        }else if scrollBeginingYPoint < scrollView.contentOffset.y {
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
        reloadIngredientBasicList()
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.reloadIngredientBasicList()
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.reloadIngredientBasicList()
            self.tableView.reloadData()
        }
        return true
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if ingredientList == nil{
                reloadIngredientList()
            }
            return ingredientBasicList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "PushIngredientDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit =  UIContextualAction(style: .normal, title: "編集", handler: { (action,view,completionHandler ) in
            if let editNavi = UIStoryboard(name: "IngredientEdit", bundle: nil).instantiateViewController(withIdentifier: "IngredientEditNavigation") as? BasicNavigationController{
                guard let editVC = editNavi.visibleViewController as? IngredientEditTableViewController else{
                    return
                }
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
        })
        edit.image = UIImage(named: "button-edit")
        edit.backgroundColor = UchicockStyle.tableViewCellEditBackgroundColor
        
        let del =  UIContextualAction(style: .destructive, title: "削除", handler: { (action,view,completionHandler ) in
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
            
            if ingredient.recipeIngredients.count > 0 {
                let alertView = CustomAlertController(title: nil, message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
                completionHandler(false)
            } else{
                let deleteAlertView = CustomAlertController(title: nil, message: "この材料を本当に削除しますか？", preferredStyle: .alert)
                deleteAlertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(ingredient)
                    }
                    self.ingredientBasicList.remove(at: indexPath.row)
                    self.setTableBackgroundView()
                    tableView.deleteRows(at: [indexPath], with: .middle)
                    if self.isReminderMode{
                        self.navigationItem.title = "購入リマインダー(" + String(self.ingredientBasicList.count) + ")"
                    }else{
                        self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + "/" + String(self.ingredientList!.count) + ")"
                    }
                    self.setReminderBadge()
                    completionHandler(true)
                }))
                deleteAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in
                    completionHandler(false)
                })
                deleteAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                deleteAlertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(deleteAlertView, animated: true, completion: nil)
            }
        })
        del.image = UIImage(named: "button-delete")
        del.backgroundColor = UchicockStyle.alertColor
        
        let realm = try! Realm()
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
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

        let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")
        let accesoryImageView = UIImageView(image: disclosureIndicator)
        accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
        accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        cell.accessoryView = accesoryImageView

        cell.stockState = stockState.selectedSegmentIndex
        
        let realm = try! Realm()
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
        cell.ingredient = ingredient

        cell.stock.addTarget(self, action: #selector(IngredientListViewController.cellStockTapped(_:)), for: UIControl.Event.valueChanged)
        
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func reminderButtonTapped(_ sender: UIBarButtonItem) {
        isReminderMode.toggle()
        
        isReminderMode ? changeToReminderMode() : changeToIngredientMode()
        reloadIngredientBasicList()
        tableView.reloadData()
    }
    
    private func changeToReminderMode(){
        reminderButton.image = UIImage(named: "navigation-reminder-filled")
        searchBarHeightConstraint.constant = 0
        categoryHeightConstraint.constant = 0
        category.isHidden = true
        categoryBottomConstraint.constant = 0
        stockStateHeightConstraint.constant = 0
        stockState.isHidden = true
        stockStateBottomConstraint.constant = 0
        ingredientRecommendButtonHeightConstraint.constant = 0
        ingredientRecommendButton.isHidden = true
        containerSeparatorTopConstraint.constant = 0
        containerSeparatorLandscapeTopConstraint.constant = 0
        containerSeparatorHeightConstraint.constant = 0
        addIngredientButton.isEnabled = false
        searchBar.resignFirstResponder()
    }
    
    private func changeToIngredientMode(){
        reminderButton.image = UIImage(named: "navigation-reminder-empty")
        searchBarHeightConstraint.constant = 44
        categoryHeightConstraint.constant = 28
        category.isHidden = false
        categoryBottomConstraint.constant = 4
        stockStateHeightConstraint.constant = 28
        stockState.isHidden = false
        stockStateBottomConstraint.constant = 8
        ingredientRecommendButtonHeightConstraint.constant = 30
        ingredientRecommendButton.isHidden = false
        containerSeparatorTopConstraint.constant = 6
        containerSeparatorLandscapeTopConstraint.constant = 4
        containerSeparatorHeightConstraint.constant = 1
        addIngredientButton.isEnabled = true
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if let editNavi = UIStoryboard(name: "IngredientEdit", bundle: nil).instantiateViewController(withIdentifier: "IngredientEditNavigation") as? BasicNavigationController{
            guard let editVC = editNavi.visibleViewController as? IngredientEditTableViewController else{
                return
            }
            
            editNavi.modalPresentationStyle = .fullScreen
            editNavi.modalTransitionStyle = .coverVertical
            editVC.mainNavigationController = self.navigationController as? BasicNavigationController
            self.present(editNavi, animated: true, completion: nil)
        }
    }
    
    @IBAction func categoryTapped(_ sender: UISegmentedControl) {
        reloadIngredientBasicList()
        tableView.reloadData()
    }
    
    @IBAction func stockStateTapped(_ sender: UISegmentedControl) {
        reloadIngredientBasicList()
        tableView.reloadData()
    }
    
    @IBAction func ingredientRecommendButtonTapped(_ sender: UIButton) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        let storyboard = UIStoryboard(name: "IngredientRecommend", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "IngredientRecommendNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! IngredientRecommendTableViewController
        
        vc.onDoneBlock = { selectedRecommendIngredientId in
            if let selectedRecommendIngredientId = selectedRecommendIngredientId{
                let realm = try! Realm()
                let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: selectedRecommendIngredientId)
                if ing != nil{
                    self.performSegue(withIdentifier: "PushIngredientDetail", sender: selectedRecommendIngredientId)
                }
            }
            self.highlightSelectedRow()
        }
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .pageSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }
        
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
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destination as! IngredientDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedIngredientId = ingredientBasicList[indexPath.row].id
                vc.ingredientId = ingredientBasicList[indexPath.row].id
            }else if let id = sender as? String{
                selectedIngredientId = id
                vc.ingredientId = id
            }
        }
    }
}
