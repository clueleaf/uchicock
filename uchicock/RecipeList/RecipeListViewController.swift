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

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var recipeList: Results<Recipe>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushRecipeDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            if self.recipeList![indexPath.row].favorites == 3 {
                let favoriteAlertView = UIAlertController(title: "本当に削除しますか？", message: "お気に入り★★★のレシピです", preferredStyle: .Alert)
                favoriteAlertView.addAction(UIAlertAction(title: "はい", style: .Default, handler: {action in
                    let realm = try! Realm()
                    let recipe = self.recipeList![indexPath.row]
                    
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
                        realm.delete(recipe)
                    }
                    
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }))
                favoriteAlertView.addAction(UIAlertAction(title: "いいえ", style: .Cancel){action in
                    })
                presentViewController(favoriteAlertView, animated: true, completion: nil)
            }else{
                let realm = try! Realm()
                let recipe = self.recipeList![indexPath.row]
                
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
                    realm.delete(recipe)
                }
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)                
            }
      }
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            let realm = try! Realm()
            let dataContent = realm.objects(Recipe)
            return dataContent.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let realm = try! Realm()
        recipeList = realm.objects(Recipe).sorted("recipeName")
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeListItem") as! RecipeListItemTableViewCell
            cell.recipe = recipeList![indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushAddRecipe", sender: UIBarButtonItem())
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destinationViewController as! RecipeDetailViewController
            if let indexPath = sender as? NSIndexPath{
                vc.recipeId = recipeList![indexPath.row].id
            }
        } else if segue.identifier == "PushAddRecipe" {
        }
    }

}

