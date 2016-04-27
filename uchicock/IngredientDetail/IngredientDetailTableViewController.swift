//
//  IngredientDetailTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/07.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import M13Checkbox

class IngredientDetailTableViewController: UITableViewController {

    
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var stock: M13Checkbox!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!

    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<IngredientRecipeBasic>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stock.backgroundColor = UIColor.clearColor()
        stock.tintColor = FlatSkyBlueDark()
        stock.secondaryTintColor = FlatGray()
        stock.boxLineWidth = 1.0
        stock.markType = .Checkmark
        stock.boxType = .Circle
        stock.stateChangeAnimation = .Expand(.Fill)

        tableView.registerClass(IngredientRecipeListTableViewCell.self, forCellReuseIdentifier: "IngredientRecipeList")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
            
            ingredientName.text = ingredient.ingredientName
            if ingredient.stockFlag{
                stock.setCheckState(.Checked, animated: true)
            }else{
                stock.setCheckState(.Unchecked, animated: true)
            }
            memo.text = ingredient.memo
            memo.textColor = FlatGrayDark()            
            deleteLabel.textColor = FlatRed()
            
            ingredientRecipeBasicList.removeAll()
            for recipeIngredient in ingredient.recipeIngredients{
                let ingredientRecipeBasic = IngredientRecipeBasic()
                ingredientRecipeBasic.recipeIngredientLinkId = recipeIngredient.id
                ingredientRecipeBasic.recipeName = recipeIngredient.recipe.recipeName
                ingredientRecipeBasic.recipeKanaName = recipeIngredient.recipe.recipeName.katakana()
                ingredientRecipeBasicList.append(ingredientRecipeBasic)
            }
            ingredientRecipeBasicList.sortInPlace({ $0.recipeKanaName < $1.recipeKanaName })
            
            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableView
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 1{
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            }else{
                return UITableViewAutomaticDimension
            }
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
            if ingredient.recipeIngredients.count > 0 {
                return "この材料を使うレシピ(" + String(ingredient.recipeIngredients.count) + ")"
            }else {
                return "この材料を使うレシピはありません"
            }
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else if section == 1 {
            if ingredient.recipeIngredients.count > 0{
                return ingredient.recipeIngredients.count
            }else{
                return 1
            }
        }
        return 0
    }
    
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
        if indexPath.section == 1 {
            if ingredient.recipeIngredients.count > 0{
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                performSegueWithIdentifier("PushRecipeDetail", sender: indexPath)
            }else{
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
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.backgroundColor = FlatWhite()
            return cell
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientRecipeList", forIndexPath: indexPath) as! IngredientRecipeListTableViewCell
                
                let realm = try! Realm()
                let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@",ingredientRecipeBasicList[indexPath.row].recipeIngredientLinkId).first!

                if recipeIngredient.recipe.imageData != nil{
                    cell.photo.image = UIImage(data: recipeIngredient.recipe.imageData!)
                    //レシピ削除のバグに対するワークアラウンド
                    if cell.photo.image == nil{
                        cell.photo.image = UIImage(named: "no-photo")
                    }
                }else{
                    cell.photo.image = UIImage(named: "no-photo")
                }
                
                cell.recipeName.text = recipeIngredient.recipe.recipeName
                switch recipeIngredient.recipe.favorites{
                case 1:
                    cell.favorites.text = "★☆☆"
                case 2:
                    cell.favorites.text = "★★☆"
                case 3:
                    cell.favorites.text = "★★★"
                default:
                    cell.favorites.text = "★☆☆"
                }
                var shortageNum = 0
                var shortageName = ""
                for ri in recipeIngredient.recipe.recipeIngredients{
                    if ri.mustFlag && ri.ingredient.stockFlag == false{
                        shortageNum += 1
                        shortageName = ri.ingredient.ingredientName
                    }
                }
                if shortageNum == 0 {
                    cell.shortage.text = "すぐつくれる！"
                    cell.shortage.textColor = FlatSkyBlueDark()
                    cell.shortage.font = UIFont.boldSystemFontOfSize(CGFloat(14))
                    cell.recipeName.textColor = FlatBlack()
                }else if shortageNum == 1{
                    if shortageName.characters.count > 10{
                        cell.shortage.text = (shortageName as NSString).substringToIndex(10) + "...が足りません"
                    }else{
                        cell.shortage.text = shortageName + "が足りません"
                    }
                    cell.shortage.textColor = FlatGrayDark()
                    cell.shortage.font = UIFont.systemFontOfSize(CGFloat(14))
                    cell.recipeName.textColor = FlatGrayDark()
                }else{
                    cell.shortage.text = "材料が" + String(shortageNum) + "個足りません"
                    cell.shortage.textColor = FlatGrayDark()
                    cell.shortage.font = UIFont.systemFontOfSize(CGFloat(14))
                    cell.recipeName.textColor = FlatGrayDark()
                }
                
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = .Default
                cell.backgroundColor = FlatWhite()
                return cell
            }else{
                let cell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
                cell.backgroundColor = FlatWhite()
                return cell
            }
        }
        return UITableViewCell()
    }

    // MARK: - IBAction
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func stockTapped(sender: M13Checkbox) {
        let realm = try! Realm()
        try! realm.write {
            if stock.checkState == .Checked{
                ingredient.stockFlag = true
            }else{
                ingredient.stockFlag = false
            }
        }
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
    @IBAction func actionButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("CreateEvent", sender: UIBarButtonItem())
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destinationViewController as! UINavigationController
            let evc = enc.visibleViewController as! IngredientEditTableViewController
            evc.ingredient = self.ingredient
        }else if segue.identifier == "PushRecipeDetail"{
            let vc = segue.destinationViewController as! RecipeDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                let realm = try! Realm()
                let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@",ingredientRecipeBasicList[indexPath.row].recipeIngredientLinkId).first!
                vc.recipeId = recipeIngredient.recipe.id
            }
        }else if segue.identifier == "CreateEvent" {
            let enc = segue.destinationViewController as! UINavigationController
            let evc = enc.visibleViewController as! ReminderTableViewController
            evc.ingredientName = self.ingredient.ingredientName
        }
    }

}
