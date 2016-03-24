//
//  RecipeEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeEditTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var recipeNameTableViewCell: UITableViewCell!
    @IBOutlet weak var favoriteTableViewCell: UITableViewCell!
    @IBOutlet weak var methodTableViewCell: UITableViewCell!
    @IBOutlet weak var memoTableViewCell: UITableViewCell!
    
    var recipe = Recipe()
    var isAddMode = true
    var editingRecipeIngredientList = Array<EditingRecipeIngredient>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(RecipeEditIngredientTableViewCell.self, forCellReuseIdentifier: "RecipeEditIngredient")
        
        for ri in recipe.recipeIngredients {
            let editingRecipeIngredient = EditingRecipeIngredient()
            editingRecipeIngredient.id = ri.id
            editingRecipeIngredient.ingredientName = ri.ingredient.ingredientName
            editingRecipeIngredient.amount = ri.amount
            editingRecipeIngredient.mustFlag = ri.mustFlag
            editingRecipeIngredientList.append(editingRecipeIngredient)
        }
        
        if recipe.recipeName == "" {
            self.navigationItem.title = "レシピ登録"
            star1.setTitle("★", forState: .Normal)
            star2.setTitle("☆", forState: .Normal)
            star3.setTitle("☆", forState: .Normal)
            method.selectedSegmentIndex = 0
            isAddMode = true
        } else {
            self.navigationItem.title = "レシピ編集"
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
            method.selectedSegmentIndex = recipe.method
            isAddMode = false
        }
        
        recipeName.text = recipe.recipeName
        recipeName.delegate = self
        memo.text = recipe.memo
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        memo.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool{
        recipeName.resignFirstResponder()
        return true
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            } else if indexPath.row == editingRecipeIngredientList.count{
                return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            }else if indexPath.row == editingRecipeIngredientList.count{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
            }
        }
        return 0
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else if section == 1{
            return 30
        }
        return 0
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else if section == 1{
            return 30
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        } else if section == 1{
            return editingRecipeIngredientList.count + 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        } else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeEditIngredient", forIndexPath: indexPath) as! RecipeEditIngredientTableViewCell
                cell.ingredientName.text = editingRecipeIngredientList[indexPath.row].ingredientName
                cell.amount.text = editingRecipeIngredientList[indexPath.row].amount
                if editingRecipeIngredientList[indexPath.row].mustFlag{
                    cell.option.text = ""
                }else{
                    cell.option.text = "オプション"
                }
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = .Default
                return cell
            }else if indexPath.row == editingRecipeIngredientList.count{
                return super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("PushEditIngredient", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row < editingRecipeIngredientList.count{
            return true
        }else{
            return false
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            editingRecipeIngredientList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    // MARK: - IBAction
    @IBAction func star1Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("☆", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
    }
    
    @IBAction func star2Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
    }
    
    @IBAction func star3Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("★", forState: .Normal)
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if recipeName.text == nil || recipeName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())==""{
            //名前を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "レシピ名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if editingRecipeIngredientList.count == 0{
            //材料が一つもない
            let noNameAlertView = UIAlertController(title: "", message: "材料を一つ以上入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameRecipe = realm.objects(Recipe).filter("recipeName == %@",recipeName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                if sameNameRecipe.count != 0{
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前のレシピが既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write{
                        let newRecipe = Recipe()
                        newRecipe.recipeName = recipeName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        if star3.currentTitle == "★" {
                            newRecipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            newRecipe.favorites = 2
                        }else{
                            newRecipe.favorites = 1
                        }
                        
                        newRecipe.method = method.selectedSegmentIndex
                        newRecipe.memo = memo.text
                        realm.add(newRecipe)
                        
                        for editingRecipeIngredient in editingRecipeIngredientList{
                            let recipeIngredientLink = RecipeIngredientLink()
                            recipeIngredientLink.amount = editingRecipeIngredient.amount
                            recipeIngredientLink.mustFlag = editingRecipeIngredient.mustFlag
                            realm.add(recipeIngredientLink)

                            let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",editingRecipeIngredient.ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)

                            let recipe = realm.objects(Recipe).filter("recipeName == %@",newRecipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }else{
                let sameNameRecipe = realm.objects(Recipe).filter("recipeName == %@",recipeName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                if sameNameRecipe.count != 0 && recipe.recipeName != recipeName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()){
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前のレシピが既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write {
                        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
                        for ri in recipe.recipeIngredients{
                            let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@", ri.id).first!
                            deletingRecipeIngredientList.append(recipeIngredient)
                        }
                        
                        for ri in deletingRecipeIngredientList{
                            let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                            for var i = 0; i < ingredient.recipeIngredients.count; ++i{
                                if ingredient.recipeIngredients[i].id == ri.id{
                                    ingredient.recipeIngredients.removeAtIndex(i)
                                }
                            }
                        }
                        let editingRecipe = realm.objects(Recipe).filter("id == %@",recipe.id).first!
                        editingRecipe.recipeIngredients.removeAll()
                        for ri in deletingRecipeIngredientList{
                            realm.delete(ri)
                        }

                        recipe.recipeName = recipeName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        if star3.currentTitle == "★" {
                            recipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            recipe.favorites = 2
                        }else{
                            recipe.favorites = 1
                        }
                        recipe.method = method.selectedSegmentIndex
                        recipe.memo = memo.text
                        
                        for editingRecipeIngredient in editingRecipeIngredientList{
                            let recipeIngredientLink = RecipeIngredientLink()
                            recipeIngredientLink.amount = editingRecipeIngredient.amount
                            recipeIngredientLink.mustFlag = editingRecipeIngredient.mustFlag
                            realm.add(recipeIngredientLink)
                            
                            let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",editingRecipeIngredient.ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)
                            
                            let recipe = realm.objects(Recipe).filter("recipeName == %@",self.recipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                        
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        if touch.view!.isDescendantOfView(recipeNameTableViewCell) {
            return true
        }else if touch.view!.isDescendantOfView(favoriteTableViewCell){
            return true
        }else if touch.view!.isDescendantOfView(methodTableViewCell){
            return true
        }else if touch.view!.isDescendantOfView(memoTableViewCell){
            return true
        }
        return false
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        let riec = fromViewController as! RecipeIngredientEditViewController
        if riec.isAddMode{
            let editingRecipeIngredient = EditingRecipeIngredient()
            editingRecipeIngredient.ingredientName = riec.ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            editingRecipeIngredient.amount = riec.amount.text!
            editingRecipeIngredient.mustFlag = !riec.option.on
            editingRecipeIngredientList.append(editingRecipeIngredient)
        }else{
            if riec.deleteFlag{
                for var i = 0; i < editingRecipeIngredientList.count; ++i{
                    if editingRecipeIngredientList[i].id == riec.recipeIngredient.id{
                        editingRecipeIngredientList.removeAtIndex(i)
                    }
                }
            }else{
                for editingRecipeIngredient in editingRecipeIngredientList{
                    if editingRecipeIngredient.id == riec.recipeIngredient.id{
                        editingRecipeIngredient.ingredientName = riec.ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        editingRecipeIngredient.amount = riec.amount.text!
                        editingRecipeIngredient.mustFlag = !riec.option.on
                    }
                }
            }
        }
        return true
    }
    
    @IBAction func screenTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func unwindToRecipeEdit(segue: UIStoryboardSegue) {
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destinationViewController as! UINavigationController
            let evc = enc.visibleViewController as! RecipeIngredientEditViewController
            if let indexPath = sender as? NSIndexPath{
                if indexPath.row < editingRecipeIngredientList.count{
                    if self.editingRecipeIngredientList[indexPath.row].id == ""{
                        self.editingRecipeIngredientList[indexPath.row].id = NSUUID().UUIDString
                    }
                    evc.recipeIngredient = self.editingRecipeIngredientList[indexPath.row]
                    evc.isAddMode = false
                }else if indexPath.row == editingRecipeIngredientList.count{
                    evc.isAddMode = true
                }
            }
        }
    }
    
}
