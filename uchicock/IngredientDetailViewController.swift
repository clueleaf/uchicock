//
//  IngredientDetailViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var ingredientId = String()
    var ingredient = Ingredient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        let realm = try! Realm()
        let ing = realm.objects(Ingredient).filter("id == %@",ingredientId)
        if ing.count < 1 {
            let noIngredientAlertView = UIAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .Alert)
            noIngredientAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            presentViewController(noIngredientAlertView, animated: true, completion: nil)
        } else {
            ingredient = realm.objects(Ingredient).filter("id == %@",ingredientId).first!
            self.navigationItem.title = ingredient.ingredientName
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
            performSegueWithIdentifier("PushRecipeDetail", sender: indexPath)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else if section == 1 {
            return ingredient.recipeIngredients.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientName") as! IngredientNameTableViewCell
                cell.ingredient = ingredient
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientStock") as! IngredientStockTableViewCell
                cell.ingredient = ingredient
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientMemo") as! IngredientMemoTableViewCell
                cell.ingredient = ingredient
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientRecipeItem") as! IngredientRecipeListTableViewCell
            cell.recipeIngredient = ingredient.recipeIngredients[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditIngredient", sender: UIBarButtonItem())
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destinationViewController as! IngredientEditNavigationController
            let evc = enc.visibleViewController as! IngredientEditViewController
            evc.ingredient = self.ingredient
        }else if segue.identifier == "PushRecipeDetail"{
            let vc = segue.destinationViewController as! RecipeDetailViewController
            if let indexPath = sender as? NSIndexPath{
                vc.recipeId = ingredient.recipeIngredients[indexPath.row].recipe.id
            }
        }
    }
    
}
