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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControlContainer.backgroundColor = FlatSand()
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.Done

        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
                
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngredientListViewController.handleKeyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IngredientListViewController.handleKeyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)

        reloadIngredientList()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTextFieldFromView(view: UIView) -> UITextField?{
        for subview in view.subviews{
            if subview.isKindOfClass(UITextField){
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
        return searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func reloadIngredientList(){
        let realm = try! Realm()
        switch stockState.selectedSegmentIndex{
        case 0:
            ingredientList = realm.objects(Ingredient).sorted("ingredientName")
        case 1:
            ingredientList = realm.objects(Ingredient).filter("stockFlag == true").sorted("ingredientName")
        case 2:
            ingredientList = realm.objects(Ingredient).filter("stockFlag == false").sorted("ingredientName")
        default:
            ingredientList = realm.objects(Ingredient).sorted("ingredientName")
        }
        
        reloadIngredientBasicList()
    }
    
    func reloadIngredientBasicList(){
        ingredientBasicList.removeAll()
        for ingredient in ingredientList!{
            ingredientBasicList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName))
        }
        
        for i in (0..<ingredientBasicList.count).reverse(){
            if searchBarTextWithoutSpace() != "" && ingredientBasicList[i].kanaName.containsString(searchBarTextWithoutSpace().katakana().lowercaseString) == false{
                ingredientBasicList.removeAtIndex(i)
            }
        }
        ingredientBasicList.sortInPlace({ $0.kanaName < $1.kanaName })
        
        self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + ")"
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまる材料はありません"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -self.tableView.frame.size.height/4.0
    }
    
    func cellStockTapped(sender: M13Checkbox){
        var view = sender.superview
        while(view!.isKindOfClass(IngredientListItemTableViewCell) == false) {
            view = view!.superview
        }
        let cell = view as! IngredientListItemTableViewCell
        let touchIndex = self.tableView.indexPathForCell(cell)
        
        let realm = try! Realm()
        let ingredient = realm.objects(Ingredient).filter("id == %@", ingredientBasicList[touchIndex!.row].id).first!

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
            ingredientBasicList.removeAtIndex(touchIndex!.row)
            tableView.deleteRowsAtIndexPaths([touchIndex!], withRowAnimation: .Automatic)
            if ingredientBasicList.count == 0{
                tableView.reloadData()
            }
            self.navigationItem.title = "材料(" + String(ingredientBasicList.count) + ")"
        }
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, tabBarController!.tabBar.frame.size.height, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, tabBarController!.tabBar.frame.size.height, 0)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadIngredientBasicList()
        tableView.reloadData()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.reloadIngredientBasicList()
            self.tableView.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(200 * Double(NSEC_PER_MSEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.reloadIngredientBasicList()
            self.tableView.reloadData()
        }
        return true
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if ingredientList == nil{
                reloadIngredientList()
            }
            return ingredientBasicList.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushIngredientDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "編集") {
            (action, indexPath) in
            self.performSegueWithIdentifier("PushAddIngredient", sender: indexPath)
        }
        edit.backgroundColor = FlatGray()
        
        let del = UITableViewRowAction(style: .Default, title: "削除") {
            (action, indexPath) in
            let realm = try! Realm()
            let ingredient = realm.objects(Ingredient).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!

            
            if ingredient.recipeIngredients.count > 0 {
                let alertView = UIAlertController(title: "", message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                self.presentViewController(alertView, animated: true, completion: nil)
            } else{
                let favoriteAlertView = UIAlertController(title: "本当に削除しますか？", message: nil, preferredStyle: .Alert)
                favoriteAlertView.addAction(UIAlertAction(title: "削除", style: .Destructive, handler: {action in
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(ingredient)
                    }
                    self.ingredientBasicList.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    self.navigationItem.title = "材料(" + String(self.ingredientBasicList.count) + ")"
                }))
                favoriteAlertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                self.presentViewController(favoriteAlertView, animated: true, completion: nil)
            }
        }
        del.backgroundColor = FlatRed()
        
        let realm = try! Realm()
        let ingredient = realm.objects(Ingredient).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!
        if ingredient.recipeIngredients.count == 0 {
            return [del, edit]
        }else{
            return [edit]
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientListItem") as! IngredientListItemTableViewCell
            cell.stockState = stockState.selectedSegmentIndex
            cell.stock.stateChangeAnimation = .Fade(.Fill)
            cell.stock.animationDuration = 0
            
            let realm = try! Realm()
            let ingredient = realm.objects(Ingredient).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!

            if ingredient.stockFlag{
                cell.stock.setCheckState(.Checked, animated: true)
            }else{
                cell.stock.setCheckState(.Unchecked, animated: true)
            }
            cell.ingredient = ingredient
            cell.backgroundColor = FlatWhite()
            cell.stock.addTarget(self, action: #selector(IngredientListViewController.cellStockTapped(_:)), forControlEvents: UIControlEvents.ValueChanged)
            
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushAddIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func stockStateTapped(sender: UISegmentedControl) {
        reloadIngredientList()
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destinationViewController as! IngredientDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                vc.ingredientId = ingredientBasicList[indexPath.row].id
            }
        } else if segue.identifier == "PushAddIngredient" {
            if let indexPath = sender as? NSIndexPath {
                let enc = segue.destinationViewController as! UINavigationController
                let evc = enc.visibleViewController as! IngredientEditTableViewController
                let realm = try! Realm()
                let ingredient = realm.objects(Ingredient).filter("id == %@", self.ingredientBasicList[indexPath.row].id).first!
                evc.ingredient = ingredient
            }
        }
    }
}
