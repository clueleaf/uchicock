//
//  IngredientListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var category: CustomSegmentedControl!
    @IBOutlet weak var stockState: CustomSegmentedControl!
    @IBOutlet weak var ingredientRecommendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerSeparator: UIView!
    
    var ingredientList: Results<Ingredient>?
    var ingredientBasicList = Array<IngredientBasic>()
    var scrollBeginingYPoint: CGFloat = 0.0
    let selectedCellBackgroundView = UIView()
    var selectedIngredientId: String? = nil
    var selectedIndexPath: IndexPath? = nil
    var isTyping = false

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVC()
    }
    
    private func setupVC(){
        self.view.backgroundColor = Style.basicBackgroundColor

        segmentedControlContainer.backgroundColor = Style.filterContainerBackgroundColor
        tableView.backgroundColor = Style.basicBackgroundColor
        tableView.separatorColor = Style.labelTextColorLight
        tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor

        searchBar.backgroundImage = UIImage()
        
        let textFieldInSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = Style.labelTextColorLight

        if #available(iOS 13.0, *) {
            searchBar.searchTextField.layer.borderColor = Style.textFieldBorderColor.cgColor
            searchBar.searchTextField.layer.borderWidth = 1.0
            searchBar.searchTextField.layer.cornerRadius = 8.0
        }else{
            for view in searchBar.subviews {
                for subview in view.subviews {
                    if subview is UITextField {
                        let textField: UITextField = subview as! UITextField
                        textField.layer.borderColor = Style.textFieldBorderColor.cgColor
                        textField.layer.borderWidth = 1.0
                        textField.layer.cornerRadius = 8.0
                        for subsubview in subview.subviews{
                            if subsubview is UILabel{
                                let placeholderLabel = subsubview as! UILabel
                                placeholderLabel.textColor = Style.labelTextColorLight
                            }
                        }
                    }
                }
            }
        }

        let font = UIFont.systemFont(ofSize: 12)
        let boldFont = UIFont.boldSystemFont(ofSize: 12)
        if #available(iOS 13.0, *) {
            category.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Style.labelTextColorOnBadge, NSAttributedString.Key.font: boldFont], for: .selected)
            category.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Style.labelTextColor, NSAttributedString.Key.font: font], for: .normal)
        }else{
            category.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .selected)
            category.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            category.layer.cornerRadius = 14.0
            stockState.layer.cornerRadius = 14.0
        }

        category.layer.borderColor = Style.primaryColor.cgColor
        category.layer.borderWidth = 1.0
        category.layer.masksToBounds = true
        stockState.layer.borderColor = Style.primaryColor.cgColor
        stockState.layer.borderWidth = 1.0
        stockState.layer.masksToBounds = true

        ingredientRecommendButton.layer.borderColor = Style.primaryColor.cgColor
        ingredientRecommendButton.layer.borderWidth = 1.5
        ingredientRecommendButton.layer.cornerRadius = 15
        ingredientRecommendButton.setTitleColor(Style.primaryColor, for: .normal)
        ingredientRecommendButton.backgroundColor = Style.basicBackgroundColor
        
        containerSeparator.backgroundColor = Style.labelTextColorLight
        
        reloadIngredientList()
        tableView.reloadData()
        
        if let path = selectedIndexPath{
            if ingredientBasicList.count > path.row{
                let nowIngredientId = ingredientBasicList[path.row].id
                if selectedIngredientId != nil{
                    if nowIngredientId == selectedIngredientId!{
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.selectRow(at: path, animated: false, scrollPosition: .none)
                        }
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
        self.setTableBackgroundView() // 画面リサイズ時や実行端末のサイズがStoryboardsと異なる時、EmptyDataの表示位置がずれないようにするために必要
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
                            placeholderLabel.textColor = Style.labelTextColorLight
                        }
                    }
                }
            }
        }
        if let path = tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: path, animated: true)
        }
        selectedIngredientId = nil
        self.tableView.flashScrollIndicators()
    }
    
    func getTextFieldFromView(_ view: UIView) -> UITextField?{
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
    
    func reloadIngredientList(){
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
        reloadIngredientBasicList()
    }
    
    func reloadIngredientBasicList(){
        ingredientBasicList.removeAll()
        for ingredient in ingredientList!{
            ingredientBasicList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch , stockFlag: ingredient.stockFlag, category: ingredient.category, contributionToRecipeAvailability: ingredient.contributionToRecipeAvailability, usedRecipeNum: ingredient.recipeIngredients.count))
        }
        
        if searchBar.text!.withoutSpaceAndMiddleDot() != ""{
            ingredientBasicList.removeAll{
                !$0.katakanaLowercasedNameForSearch.contains(searchBar.text!.katakanaLowercasedForSearch())
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

        ingredientBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })

        if let allIngredientNum = ingredientList?.count{
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + "/" + String(allIngredientNum) + ")"
        }else{
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + ")"
        }
        
        setTableBackgroundView()
    }
    
    func setTableBackgroundView(){
        if ingredientBasicList.count == 0{
            let noDataLabel  = UILabel(frame: CGRect(x: 0, y: self.tableView.bounds.size.height / 4, width: self.tableView.bounds.size.width, height: 20))
            noDataLabel.text = "条件にあてはまる材料はありません"
            noDataLabel.textColor = Style.labelTextColorLight
            noDataLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            noDataLabel.textAlignment = .center
            self.tableView.backgroundView  = UIView()
            self.tableView.backgroundView?.addSubview(noDataLabel)
            self.tableView.isScrollEnabled = false
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
            }
            
            try! realm.write {
                for ri in ingredient.recipeIngredients{
                    ri.recipe.updateShortageNum()
                }
            }
            
            if stockState.selectedSegmentIndex != 0{
                ingredientBasicList.remove(at: index.row)
                tableView.deleteRows(at: [index], with: .automatic)
                if ingredientBasicList.count == 0{
                    setTableBackgroundView()
                    tableView.reloadData()
                }
                if let allIngredientNum = ingredientList?.count{
                    self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + "/" + String(allIngredientNum) + ")"
                }else{
                    self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + ")"
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
        if scrollView.contentOffset.y < -50{
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
        performSegue(withIdentifier: "PushIngredientDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit =  UIContextualAction(style: .normal, title: "編集", handler: { (action,view,completionHandler ) in
            if let editNavi = UIStoryboard(name: "IngredientEdit", bundle: nil).instantiateViewController(withIdentifier: "IngredientEditNavigation") as? UINavigationController{
                guard let editVC = editNavi.visibleViewController as? IngredientEditTableViewController else{
                    return
                }
                let realm = try! Realm()
                let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
                self.selectedIngredientId = self.ingredientBasicList[indexPath.row].id
                self.selectedIndexPath = indexPath
                editVC.ingredient = ingredient
                
                editNavi.modalPresentationStyle = .fullScreen
                editNavi.modalTransitionStyle = .coverVertical
                editVC.mainNavigationController = self.navigationController
                self.present(editNavi, animated: true, completion: nil)
            }
        })
        edit.image = UIImage(named: "button-edit")
        edit.backgroundColor = Style.tableViewCellEditBackgroundColor
        
        let del =  UIContextualAction(style: .destructive, title: "削除", handler: { (action,view,completionHandler ) in
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
            
            if ingredient.recipeIngredients.count > 0 {
                let alertView = CustomAlertController(title: nil, message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                alertView.alertStatusBarStyle = Style.statusBarStyle
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
            } else{
                let deleteAlertView = CustomAlertController(title: nil, message: "本当に削除しますか？", preferredStyle: .alert)
                deleteAlertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(ingredient)
                    }
                    self.ingredientBasicList.remove(at: indexPath.row)
                    self.setTableBackgroundView()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    if let allIngredientNum = self.ingredientList?.count{
                        self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + "/" + String(allIngredientNum) + ")"
                    }else{
                        self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + ")"
                    }
                }))
                deleteAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                deleteAlertView.alertStatusBarStyle = Style.statusBarStyle
                deleteAlertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(deleteAlertView, animated: true, completion: nil)
            }
        })
        del.image = UIImage(named: "button-delete")
        del.backgroundColor = Style.deleteColor
        
        let realm = try! Realm()
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
        if ingredient.recipeIngredients.count == 0 {
            return UISwipeActionsConfiguration(actions: [del, edit])
        }else{
            return UISwipeActionsConfiguration(actions: [edit])
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientListItem") as! IngredientListItemTableViewCell
            
            let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")
            let accesoryImageView = UIImageView(image: disclosureIndicator)
            accesoryImageView.tintColor = Style.labelTextColorLight
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            cell.accessoryView = accesoryImageView

            cell.stockState = stockState.selectedSegmentIndex
            cell.stock.stateChangeAnimation = .fade
            cell.stock.animationDuration = 0
            
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!

            if ingredient.stockFlag{
                cell.stock.setCheckState(.checked, animated: true)
            }else{
                cell.stock.setCheckState(.unchecked, animated: true)
            }
            cell.ingredient = ingredient
            cell.backgroundColor = Style.basicBackgroundColor
            cell.stock.addTarget(self, action: #selector(IngredientListViewController.cellStockTapped(_:)), for: UIControl.Event.valueChanged)
            
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if let editNavi = UIStoryboard(name: "IngredientEdit", bundle: nil).instantiateViewController(withIdentifier: "IngredientEditNavigation") as? UINavigationController{
            guard let editVC = editNavi.visibleViewController as? IngredientEditTableViewController else{
                return
            }
            
            editNavi.modalPresentationStyle = .fullScreen
            editNavi.modalTransitionStyle = .coverVertical
            editVC.mainNavigationController = self.navigationController
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
        let nvc = storyboard.instantiateViewController(withIdentifier: "IngredientRecommendNavigationController") as! UINavigationController
        let vc = nvc.visibleViewController as! IngredientRecommendTableViewController
        vc.onDoneBlock = { selectedRecommendIngredientId in
            if let selectedRecommendIngredientId = selectedRecommendIngredientId{
                let realm = try! Realm()
                let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: selectedRecommendIngredientId)
                if ing != nil{
                    self.performSegue(withIdentifier: "PushIngredientDetail", sender: selectedRecommendIngredientId)
                }
            }
            self.setupVC()
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
                selectedIndexPath = indexPath
                vc.ingredientId = ingredientBasicList[indexPath.row].id
            }else if let id = sender as? String{
                vc.ingredientId = id
            }
        }
    }
}
