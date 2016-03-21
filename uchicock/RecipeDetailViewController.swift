//
//  RecipeDetailViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/13.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var recipeId = String()
    var recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        let realm = try! Realm()
        let rec = realm.objects(Recipe).filter("id == %@",recipeId)
        if rec.count < 1 {
            let noRecipeAlertView = UIAlertController(title: "このレシピは削除されました", message: "元の画面に戻ります", preferredStyle: .Alert)
            noRecipeAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            presentViewController(noRecipeAlertView, animated: true, completion: nil)
        }else{
            recipe = realm.objects(Recipe).filter("id == %@",recipeId).first!
            self.navigationItem.title = recipe.recipeName
            tableView.reloadData()
            
            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableViewAutomaticDimension
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("PushIngredientDetail", sender: indexPath)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }else if section == 1 {
            return recipe.recipeIngredients.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeName") as! RecipeNameTableViewCell
                cell.recipe = recipe
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeFavorite") as! RecipeFavoriteTableViewCell
                cell.recipe = recipe
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeMethod") as! RecipeMethodTableViewCell
                cell.recipe = recipe
                return cell
            }else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeMemo") as! RecipeMemoTableViewCell
                cell.recipe = recipe
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeIngredientItem") as! RecipeIngredientListTableViewCell
            cell.recipeIngredient = recipe.recipeIngredients[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func EditButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditRecipe", sender: UIBarButtonItem())
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destinationViewController as! IngredientDetailViewController
            if let indexPath = sender as? NSIndexPath{
                vc.ingredientId = recipe.recipeIngredients[indexPath.row].ingredient.id
            }
        }else if segue.identifier == "PushEditRecipe" {
            let enc = segue.destinationViewController as! RecipeEditNavigationController
            let evc = enc.visibleViewController as! RecipeEditViewController
            evc.recipe = self.recipe
        }
    }

}
