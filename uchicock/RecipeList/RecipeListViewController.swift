//
//  RecipeListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import DZNEmptyDataSet

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var favoriteSelect: UISegmentedControl!
    @IBOutlet weak var order: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var recipeList: Results<Recipe>?
    var recipeBasicList = Array<RecipeBasic>()

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControlContainer.backgroundColor = FlatSand()
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        reloadRecipeList()
        tableView.reloadData()
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
    
    func deleteRecipe(id: String) {
        let realm = try! Realm()
        let recipe = realm.objects(Recipe).filter("id == %@", id).first!
        
        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
        for ri in recipe.recipeIngredients{
            let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@", ri.id).first!
            deletingRecipeIngredientList.append(recipeIngredient)
        }
        
        try! realm.write{
            for ri in deletingRecipeIngredientList{
                let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                for i in 0 ..< ingredient.recipeIngredients.count where i < ingredient.recipeIngredients.count{
                    if ingredient.recipeIngredients[i].id == ri.id{
                        ingredient.recipeIngredients.removeAtIndex(i)
                    }
                }
            }
            for ri in deletingRecipeIngredientList{
                realm.delete(ri)
            }
            //これを実行すると、最後に追加したレシピのimageDataがnilでなくなる現象が確認
            //解決法がわからないのでとりあえずワークアラウンドする
            realm.delete(recipe)
        }
    }
    
    func searchBarTextWithoutSpace() -> String {
        return searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func reloadRecipeList(){
        let realm = try! Realm()
        switch favoriteSelect.selectedSegmentIndex{
        case 0:
            recipeList = realm.objects(Recipe).sorted("recipeName")
        case 1:
            recipeList = realm.objects(Recipe).filter("favorites > 1").sorted("recipeName")
        case 2:
            recipeList = realm.objects(Recipe).filter("favorites == 3").sorted("recipeName")
        default:
            recipeList = realm.objects(Recipe).sorted("recipeName")
        }
        
        if order.selectedSegmentIndex == 1{
            try! realm.write {
                for recipe in recipeList!{
                    recipe.updateShortageNum()
                }
            }
            let sortProperties = [
                SortDescriptor(property: "shortageNum", ascending: true),
                SortDescriptor(property: "recipeName", ascending: true) ]
            recipeList = recipeList!.sorted(sortProperties)
        }
        
        reloadRecipeBasicList()
    }
    
    func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        for recipe in recipeList!{
            let rb = RecipeBasic()
            rb.id = recipe.id
            rb.name = recipe.recipeName
            rb.kanaName = recipe.recipeName.katakana().lowercaseString
            recipeBasicList.append(rb)
        }
        
        for i in (0..<recipeBasicList.count).reverse(){
            if searchBarTextWithoutSpace() != "" && recipeBasicList[i].kanaName.containsString(searchBarTextWithoutSpace().katakana().lowercaseString) == false{
                recipeBasicList.removeAtIndex(i)
            }
        }
        if order.selectedSegmentIndex == 0{
            recipeBasicList.sortInPlace({ $0.kanaName < $1.kanaName })
        }
        
        self.navigationItem.title = "レシピ(" + String(recipeBasicList.count) + ")"
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまるレシピはありません"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -self.tableView.frame.size.height/4.0
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(200 * Double(NSEC_PER_MSEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.reloadRecipeBasicList()
            self.tableView.reloadData()
        }
        return true
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            if recipeList == nil{
                reloadRecipeList()
            }
            return recipeBasicList.count
        }
        return 0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushRecipeDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "編集") {
            (action, indexPath) in
            self.performSegueWithIdentifier("PushAddRecipe", sender: indexPath)
        }
        edit.backgroundColor = FlatGray()
        
        let del = UITableViewRowAction(style: .Default, title: "削除") {
            (action, indexPath) in
            let alertView = UIAlertController(title: "本当に削除しますか？", message: nil, preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "削除", style: .Destructive, handler: {action in
                self.deleteRecipe(self.recipeBasicList[indexPath.row].id)
                self.recipeBasicList.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + ")"
            }))
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        del.backgroundColor = FlatRed()
        
        return [del, edit]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeListItem") as! RecipeListItemTableViewCell
            let realm = try! Realm()
            let recipe = realm.objects(Recipe).filter("id == %@", recipeBasicList[indexPath.row].id).first!
            cell.recipe = recipe
            cell.backgroundColor = FlatWhite()
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func favoriteStateTapped(sender: UISegmentedControl) {
        reloadRecipeList()
        tableView.reloadData()
    }
    
    @IBAction func orderTapped(sender: UISegmentedControl) {
        reloadRecipeList()
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushAddRecipe", sender: UIBarButtonItem())
    }
    
    @IBAction func restoreButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushRecoverRecipe", sender: UIBarButtonItem())
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destinationViewController as! RecipeDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        } else if segue.identifier == "PushAddRecipe" {
            if let indexPath = sender as? NSIndexPath{
                let enc = segue.destinationViewController as! UINavigationController
                let evc = enc.visibleViewController as! RecipeEditTableViewController
                let realm = try! Realm()
                let recipe = realm.objects(Recipe).filter("id == %@", recipeBasicList[indexPath.row].id).first!
                evc.recipe = recipe
            }
        }
    }

}

