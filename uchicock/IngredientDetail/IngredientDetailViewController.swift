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
        }else if indexPath.section == 2{
            if ingredient.recipeIngredients.count > 0 {
                let alertView = UIAlertController(title: "", message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                presentViewController(alertView, animated: true, completion: nil)
            } else{
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                alertView.addAction(UIAlertAction(title: "削除",style: .Destructive){
                    action in
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(self.ingredient)
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                presentViewController(alertView, animated: true, completion: nil)
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if ingredient.recipeIngredients.count > 0 {
            return 2
        }else{
            return 3
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else if section == 1 {
            return ingredient.recipeIngredients.count
        }else if section == 2 {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            if ingredient.recipeIngredients.count > 0 {
                return "この材料を使うレシピ"
            }else {
                return "この材料を使うレシピはありません"
            }
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientDetailName") as! IngredientDetailNameTableViewCell
                cell.name = ingredient.ingredientName
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientDetailStock") as! IngredientDetailStockTableViewCell
                cell.ingredientStock = ingredient.stockFlag
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientDetailMemo") as! IngredientDetailMemoTableViewCell
                cell.ingredientMemo = ingredient.memo
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientRecipeItem") as! IngredientRecipeListTableViewCell
            cell.recipeIngredient = ingredient.recipeIngredients[indexPath.row]
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientDetailDelete") as! IngredientDetailDeleteTableViewCell
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func stockButtonTapped(sender: UISwitch) {
        if sender.on{
            let realm = try! Realm()
            try! realm.write {
                ingredient.stockFlag = true
            }
        }else{
            let realm = try! Realm()
            try! realm.write {
                ingredient.stockFlag = false
            }
        }
        tableView.reloadData()
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destinationViewController as! UINavigationController
            let evc = enc.visibleViewController as! IngredientEditTableViewController
            evc.ingredient = self.ingredient
        }else if segue.identifier == "PushRecipeDetail"{
            let vc = segue.destinationViewController as! RecipeDetailViewController
            if let indexPath = sender as? NSIndexPath{
                vc.recipeId = ingredient.recipeIngredients[indexPath.row].recipe.id
            }
        }
    }
    
}
