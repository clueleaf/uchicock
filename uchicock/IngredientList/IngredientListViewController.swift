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
    @IBOutlet weak var stockState: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var ingredientList: Results<Ingredient>?
    var ingredientBasicList = Array<IngredientBasic>()
    var scrollBeginingYPoint: CGFloat = 0.0
    let selectedCellBackgroundView = UIView()
    var selectedIngredientId: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indexPathForSelectedRow = tableView.indexPathForSelectedRow

        segmentedControlContainer.backgroundColor = Style.filterContainerBackgroundColor
        tableView.backgroundColor = Style.basicBackgroundColor
        searchBar.backgroundColor = Style.filterContainerBackgroundColor
        stockState.tintColor = Style.secondaryColor
        stockState.backgroundColor = Style.basicBackgroundColor
        let attribute = [NSForegroundColorAttributeName:Style.secondaryColor]
        stockState.setTitleTextAttributes(attribute, for: .normal)
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    let textField: UITextField = subview as! UITextField
                    textField.backgroundColor = Style.textFieldBackgroundColor
                    textField.textColor = Style.labelTextColor
                    if Style.isDark{
                        textField.keyboardAppearance = .dark
                    }else{
                        textField.keyboardAppearance = .default
                    }
                }
            }
        }

        reloadIngredientList()
        tableView.reloadData()
        
        if indexPathForSelectedRow != nil{
            if tableView.numberOfRows(inSection: 0) > indexPathForSelectedRow!.row{
                let nowIngredientId = (tableView.cellForRow(at: indexPathForSelectedRow!) as? IngredientListItemTableViewCell)?.ingredient.id
                if nowIngredientId != nil && selectedIngredientId != nil{
                    if nowIngredientId! == selectedIngredientId!{
                        tableView.selectRow(at: indexPathForSelectedRow, animated: false, scrollPosition: .none)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.tableView.deselectRow(at: indexPathForSelectedRow!, animated: true)
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
        switch stockState.selectedSegmentIndex{
        case 0:
            ingredientList = realm.objects(Ingredient.self).sorted(byKeyPath: "ingredientName")
        case 1:
            ingredientList = realm.objects(Ingredient.self).filter("stockFlag == true").sorted(byKeyPath: "ingredientName")
        case 2:
            ingredientList = realm.objects(Ingredient.self).filter("stockFlag == false").sorted(byKeyPath: "ingredientName")
        default:
            ingredientList = realm.objects(Ingredient.self).sorted(byKeyPath: "ingredientName")
        }
        
        reloadIngredientBasicList()
    }
    
    func reloadIngredientBasicList(){
        ingredientBasicList.removeAll()
        for ingredient in ingredientList!{
            ingredientBasicList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName))
        }
        
        for i in (0..<ingredientBasicList.count).reversed(){
            if searchBarTextWithoutSpace() != "" && ingredientBasicList[i].kanaName.contains(searchBarTextWithoutSpace().katakana().lowercased()) == false{
                ingredientBasicList.remove(at: i)
            }
        }
        ingredientBasicList.sort(by: { $0.kanaName < $1.kanaName })
        
        self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + ")"
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまる材料はありません"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -self.tableView.frame.size.height/4.0
    }
    
    func cellStockTapped(_ sender: M13Checkbox){
        var view = sender.superview
        while (view! is IngredientListItemTableViewCell) == false{
            view = view!.superview
        }
        let cell = view as! IngredientListItemTableViewCell
        let touchIndex = self.tableView.indexPath(for: cell)
        
        let realm = try! Realm()
        let ingredient = realm.objects(Ingredient.self).filter("id == %@", ingredientBasicList[touchIndex!.row].id).first!

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
            ingredientBasicList.remove(at: touchIndex!.row)
            tableView.deleteRows(at: [touchIndex!], with: .automatic)
            if ingredientBasicList.count == 0{
                tableView.reloadData()
            }
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + ")"
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
            self.performSegue(withIdentifier: "PushAddIngredient", sender: indexPath)
        }
        edit.backgroundColor = Style.tableViewCellEditBackgroundColor
        
        let del = UITableViewRowAction(style: .default, title: "削除") {
            (action, indexPath) in
            let realm = try! Realm()
            let ingredient = realm.objects(Ingredient.self).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!

            
            if ingredient.recipeIngredients.count > 0 {
                let alertView = UIAlertController(title: "", message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                self.present(alertView, animated: true, completion: nil)
            } else{
                let favoriteAlertView = UIAlertController(title: "本当に削除しますか？", message: nil, preferredStyle: .alert)
                favoriteAlertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(ingredient)
                    }
                    self.ingredientBasicList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + ")"
                }))
                favoriteAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                self.present(favoriteAlertView, animated: true, completion: nil)
            }
        }
        del.backgroundColor = Style.deleteColor
        
        let realm = try! Realm()
        let ingredient = realm.objects(Ingredient.self).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!
        if ingredient.recipeIngredients.count == 0 {
            return [del, edit]
        }else{
            return [edit]
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientListItem") as! IngredientListItemTableViewCell
            cell.stockState = stockState.selectedSegmentIndex
            cell.stock.stateChangeAnimation = .fade(.fill)
            cell.stock.animationDuration = 0
            
            let realm = try! Realm()
            let ingredient = realm.objects(Ingredient.self).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!

            if ingredient.stockFlag{
                cell.stock.setCheckState(.checked, animated: true)
            }else{
                cell.stock.setCheckState(.unchecked, animated: true)
            }
            cell.ingredient = ingredient
            cell.backgroundColor = Style.basicBackgroundColor
            cell.stock.addTarget(self, action: #selector(IngredientListViewController.cellStockTapped(_:)), for: UIControlEvents.valueChanged)
            
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "PushAddIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func stockStateTapped(_ sender: UISegmentedControl) {
        reloadIngredientList()
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destination as! IngredientDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedIngredientId = ingredientBasicList[indexPath.row].id
                vc.ingredientId = ingredientBasicList[indexPath.row].id
            }
        } else if segue.identifier == "PushAddIngredient" {
            if let indexPath = sender as? IndexPath {
                let enc = segue.destination as! UINavigationController
                let evc = enc.visibleViewController as! IngredientEditTableViewController
                let realm = try! Realm()
                let ingredient = realm.objects(Ingredient.self).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!
                evc.ingredient = ingredient
            }
        }
    }
}
