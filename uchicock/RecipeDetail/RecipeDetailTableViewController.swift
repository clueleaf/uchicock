//
//  RecipeDetailTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/08.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class RecipeDetailTableViewController: UITableViewController {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var recipeId = String()
    var recipe = Recipe()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(RecipeIngredientListTableViewCell.self, forCellReuseIdentifier: "RecipeIngredientList")
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
            
            if recipe.imageData != nil{
                photo.image = UIImage(data: recipe.imageData!)
                //レシピ削除のバグに対するワークアラウンド
                if photo.image == nil{
                    photo.image = UIImage(named: "no-photo")
                }
            }else{
                photo.image = UIImage(named: "no-photo")
            }
            
            recipeName.text = recipe.recipeName
            
            switch recipe.favorites{
            case 1:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("☆", forState: .Normal)
                star3.setTitle("☆", forState: .Normal)
            case 2:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("★", forState: .Normal)
                star3.setTitle("☆", forState: .Normal)
            case 3:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("★", forState: .Normal)
                star3.setTitle("★", forState: .Normal)
            default:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("☆", forState: .Normal)
                star3.setTitle("☆", forState: .Normal)
            }
            
            if recipe.method >= 0 && recipe.method < 5 {
                method.selectedSegmentIndex = recipe.method
            } else {
                method.selectedSegmentIndex = 4
            }

            memo.text = recipe.memo
            memo.textColor = FlatGrayDark()

            deleteLabel.textColor = FlatRed()

            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableViewAutomaticDimension
            tableView.reloadData()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableView
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }
    
    //TODO: 写真の有無で分岐させる
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            } else{
                return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "材料"
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            //TODO:写真の有無で分岐させる
            return 6
        }else if section == 1{
            return recipe.recipeIngredients.count + 1
        }else{
            return 0
        }
    }
    
    //TODO:写真の有無で分岐させる
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            }else{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
            if indexPath.row < recipe.recipeIngredients.count{
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                performSegueWithIdentifier("PushIngredientDetail", sender: indexPath)
            }else if indexPath.row == recipe.recipeIngredients.count{
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
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }

    //TODO:写真の有無で分岐させる
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditRecipe", sender: UIBarButtonItem())
    }
    
    @IBAction func star1Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("☆", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
        
        let realm = try! Realm()
        try! realm.write {
            recipe.favorites = 1
        }
    }
    
    @IBAction func star2Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
        
        let realm = try! Realm()
        try! realm.write {
            recipe.favorites = 2
        }
    }
    
    @IBAction func star3Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("★", forState: .Normal)
        
        let realm = try! Realm()
        try! realm.write {
            recipe.favorites = 3
        }
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
