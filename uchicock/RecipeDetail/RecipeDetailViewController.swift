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
        
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }
    
    // MARK: - UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "材料"
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 4
        case 1:
            return recipe.recipeIngredients.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if recipe.imageData != nil{
                //レシピ削除のバグに対するワークアラウンド
                let photo = UIImage(data: recipe.imageData!)
                if photo != nil{
                    performSegueWithIdentifier("PushPhotoDetail", sender: indexPath)
                }
            }
        }else if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("PushIngredientDetail", sender: indexPath)
        }else if indexPath.section == 2{
            let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertView.addAction(UIAlertAction(title: "削除",style: .Destructive){
                action in
                let realm = try! Realm()
                let deletingRecipeIngredientList = List<RecipeIngredientLink>()
                for (var i = 0; i < self.recipe.recipeIngredients.count ; ++i){
                    let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@",self.recipe.recipeIngredients[i].id).first!
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
                    realm.delete(self.recipe)
                }
                self.navigationController?.popViewControllerAnimated(true)
            })
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
            presentViewController(alertView, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeDetailName") as! RecipeDetailNameTableViewCell
                cell.recipe = recipe
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeDetailFavorite") as! RecipeDetailFavoriteTableViewCell
                cell.recipe = recipe
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeDetailMethod") as! RecipeDetailMethodTableViewCell
                cell.recipeMethod = recipe.method
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeDetailMemo") as! RecipeDetailMemoTableViewCell
                cell.recipeMemo = recipe.memo
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeIngredientItem") as! RecipeIngredientListTableViewCell
            cell.recipeIngredient = recipe.recipeIngredients[indexPath.row]
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeDetailDelete") as!RecipeDetailDeleteTableViewCell
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - IBAction
    @IBAction func EditButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditRecipe", sender: UIBarButtonItem())
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destinationViewController as! IngredientDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                vc.ingredientId = recipe.recipeIngredients[indexPath.row].ingredient.id
            }
        }else if segue.identifier == "PushEditRecipe" {
            let enc = segue.destinationViewController as! UINavigationController
            let evc = enc.visibleViewController as! RecipeEditTableViewController
            evc.recipe = self.recipe
        }else if segue.identifier == "PushPhotoDetail" {
            let enc = segue.destinationViewController as! UINavigationController
            let pvc = enc.visibleViewController as! PhotoDetailViewController
            pvc.image = UIImage(data: recipe.imageData!)!
            pvc.recipeName = recipe.recipeName
        }
    }

}
