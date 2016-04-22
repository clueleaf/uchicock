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

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControlContainer.backgroundColor = FlatSand()
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
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
    
    func deleteRecipe(recipe: Recipe) {
        let realm = try! Realm()
        
        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
        for ri in recipe.recipeIngredients{
            let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@", ri.id).first!
            deletingRecipeIngredientList.append(recipeIngredient)
        }
        
        try! realm.write{
            for ri in deletingRecipeIngredientList{
                let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                for var i = 0; i < ingredient.recipeIngredients.count; ++i{
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
            recipeList = realm.objects(Recipe).filter("recipeName contains %@", searchBarTextWithoutSpace()).sorted("recipeName")
        case 1:
            recipeList = realm.objects(Recipe).filter("recipeName contains %@ and favorites > 1", searchBarTextWithoutSpace()).sorted("recipeName")
        case 2:
            recipeList = realm.objects(Recipe).filter("recipeName contains %@ and favorites == 3", searchBarTextWithoutSpace()).sorted("recipeName")
        default:
            recipeList = realm.objects(Recipe).filter("recipeName contains %@", searchBarTextWithoutSpace()).sorted("recipeName")
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
        
        self.navigationItem.title = "レシピ(" + String(recipeList!.count) + ")"
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまるレシピはありません"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
        
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        reloadRecipeList()
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            let realm = try! Realm()
            switch favoriteSelect.selectedSegmentIndex{
            case 0:
                return realm.objects(Recipe).filter("recipeName contains %@", searchBarTextWithoutSpace()).count
            case 1:
                return realm.objects(Recipe).filter("recipeName contains %@ and favorites > 1", searchBarTextWithoutSpace()).count
            case 2:
                return realm.objects(Recipe).filter("recipeName contains %@ and favorites == 3", searchBarTextWithoutSpace()).count
            default:
                return realm.objects(Recipe).filter("recipeName contains %@", searchBarTextWithoutSpace()).count
            }
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
            let alertView = UIAlertController(title: "本当に削除しますか？", message: "一度削除すると戻せません", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "削除", style: .Destructive, handler: {action in
                self.deleteRecipe(self.recipeList![indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.navigationItem.title = "レシピ(" + String(self.recipeList!.count) + ")"
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
            cell.recipe = recipeList![indexPath.row]
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
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destinationViewController as! RecipeDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                vc.recipeId = recipeList![indexPath.row].id
            }
        } else if segue.identifier == "PushAddRecipe" {
            if let indexPath = sender as? NSIndexPath{
                let enc = segue.destinationViewController as! UINavigationController
                let evc = enc.visibleViewController as! RecipeEditTableViewController
                evc.recipe = recipeList![indexPath.row]
            }
        }
    }

}

