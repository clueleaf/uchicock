//
//  IngredientListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import DZNEmptyDataSet
import M13Checkbox

class IngredientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var category: UISegmentedControl!
    @IBOutlet weak var stockState: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var ingredientList: Results<Ingredient>?
    var ingredientBasicList = Array<IngredientBasic>()
    var scrollBeginingYPoint: CGFloat = 0.0
    let selectedCellBackgroundView = UIView()
    var selectedIngredientId: String? = nil
    var selectedIndexPath: IndexPath? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if Style.isStatusBarLight{
            return .lightContent
        }else{
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        segmentedControlContainer.backgroundColor = Style.filterContainerBackgroundColor
        tableView.backgroundColor = Style.basicBackgroundColor
        searchBar.backgroundColor = Style.filterContainerBackgroundColor
        stockState.tintColor = Style.secondaryColor
        stockState.backgroundColor = Style.basicBackgroundColor
        let attribute = [NSAttributedString.Key.foregroundColor:Style.secondaryColor]
        stockState.setTitleTextAttributes(attribute, for: .normal)
        category.tintColor = Style.secondaryColor
        category.backgroundColor = Style.basicBackgroundColor
        category.setTitleTextAttributes(attribute, for: .normal)
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }

        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    let textField: UITextField = subview as! UITextField
                    textField.backgroundColor = Style.textFieldBackgroundColor
                    textField.textColor = Style.labelTextColor
                    textField.layer.borderColor = Style.memoBorderColor.cgColor
                    textField.layer.borderWidth = 1.0
                    textField.layer.cornerRadius = 5.0
                    if Style.isDark{
                        textField.keyboardAppearance = .dark
                    }else{
                        textField.keyboardAppearance = .default
                    }
                    for subsubview in subview.subviews{
                        if subsubview is UILabel{
                            let placeholderLabel = subsubview as! UILabel
                            placeholderLabel.textColor = Style.labelTextColor
                        }
                    }
                }
            }
        }

        reloadIngredientList()
        tableView.reloadData()
        
        if let path = selectedIndexPath{
            if tableView.numberOfRows(inSection: 0) > path.row{
                let nowIngredientId = (tableView.cellForRow(at: path) as? IngredientListItemTableViewCell)?.ingredient.id
                if nowIngredientId != nil && selectedIngredientId != nil{
                    if nowIngredientId! == selectedIngredientId!{
                        tableView.selectRow(at: path, animated: false, scrollPosition: .none)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.tableView.deselectRow(at: path, animated: true)
                        }
                    }
                }
            }
        }
        selectedIngredientId = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func searchBarTextWithoutSpace() -> String {
        return searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func reloadIngredientList(){
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
        reloadIngredientBasicList()
    }
    
    func reloadIngredientBasicList(){
        ingredientBasicList.removeAll()
        for ingredient in ingredientList!{
            ingredientBasicList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, stockFlag: ingredient.stockFlag, japaneseDictionaryOrder: ingredient.japaneseDictionaryOrder, category: ingredient.category))
        }
        
        if searchBarTextWithoutSpace() != ""{
            ingredientBasicList.removeAll{
                !$0.kanaName.contains(searchBarTextWithoutSpace().katakana().lowercased())
            }
        }
        
        for i in (0..<ingredientBasicList.count).reversed(){
            switch stockState.selectedSegmentIndex{
            case 1:
                if ingredientBasicList[i].stockFlag == false{
                    ingredientBasicList.remove(at: i)
                }
            case 2:
                if ingredientBasicList[i].stockFlag{
                    ingredientBasicList.remove(at: i)
                }
            default:
                break
            }
        }

        if category.selectedSegmentIndex != 0{
            ingredientBasicList.removeAll{
                $0.category != category.selectedSegmentIndex - 1
            }
        }

        ingredientBasicList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })

        if let allIngredientNum = ingredientList?.count{
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + "/" + String(allIngredientNum) + ")"
        }else{
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + ")"
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまる材料はありません"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -self.tableView.frame.size.height/4.0
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: false)
    }

    @objc func cellStockTapped(_ sender: M13Checkbox){
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
            
            if stockState.selectedSegmentIndex != 0{
                ingredientBasicList.remove(at: index.row)
                tableView.deleteRows(at: [index], with: .automatic)
                if ingredientBasicList.count == 0{
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "編集") {
            (action, indexPath) in
            if let editNavi = UIStoryboard(name: "IngredientEdit", bundle: nil).instantiateViewController(withIdentifier: "IngredientEditNavigation") as? UINavigationController{
                guard var history = self.navigationController?.viewControllers,
                    let editVC = editNavi.visibleViewController as? IngredientEditTableViewController,
                    let detailVC = UIStoryboard(name: "IngredientDetail", bundle: nil).instantiateViewController(withIdentifier: "IngredientDetail") as? IngredientDetailTableViewController else{
                        return
                }
                let realm = try! Realm()
                let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
                self.selectedIngredientId = self.ingredientBasicList[indexPath.row].id
                self.selectedIndexPath = indexPath
                editVC.ingredient = ingredient
                
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
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
            
            if ingredient.recipeIngredients.count > 0 {
                let alertView = UIAlertController(title: nil, message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                if Style.isStatusBarLight{
                    alertView.setStatusBarStyle(.lightContent)
                }else{
                    alertView.setStatusBarStyle(.default)
                }
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
            } else{
                let deleteAlertView = UIAlertController(title: nil, message: "本当に削除しますか？", preferredStyle: .alert)
                deleteAlertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(ingredient)
                    }
                    self.ingredientBasicList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    if let allIngredientNum = self.ingredientList?.count{
                        self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + "/" + String(allIngredientNum) + ")"
                    }else{
                        self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + ")"
                    }
                }))
                deleteAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                if Style.isStatusBarLight{
                    deleteAlertView.setStatusBarStyle(.lightContent)
                }else{
                    deleteAlertView.setStatusBarStyle(.default)
                }
                deleteAlertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(deleteAlertView, animated: true, completion: nil)
            }
        }
        del.backgroundColor = Style.deleteColor
        
        let realm = try! Realm()
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientBasicList[indexPath.row].id)!
        if ingredient.recipeIngredients.count == 0 {
            return [del, edit]
        }else{
            return [edit]
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientListItem") as! IngredientListItemTableViewCell
            cell.stockState = stockState.selectedSegmentIndex
            cell.stock.stateChangeAnimation = .fade(.fill)
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
            guard var history = self.navigationController?.viewControllers,
                let editVC = editNavi.visibleViewController as? IngredientEditTableViewController,
                let detailVC = UIStoryboard(name: "IngredientDetail", bundle: nil).instantiateViewController(withIdentifier: "IngredientDetail") as? IngredientDetailTableViewController else{
                    return
            }
            
            history.append(detailVC)
            editVC.detailVC = detailVC
            self.present(editNavi, animated: true, completion: {
                self.navigationController?.setViewControllers(history, animated: false)
            })
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destination as! IngredientDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedIngredientId = ingredientBasicList[indexPath.row].id
                selectedIndexPath = indexPath
                vc.ingredientId = ingredientBasicList[indexPath.row].id
            }
        }
    }
}
