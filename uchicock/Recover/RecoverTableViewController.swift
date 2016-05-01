//
//  RecoverTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import M13Checkbox
import SVProgressHUD

class RecoverTableViewController: UITableViewController {

    var userRecipeNameList = Array<String>()
    var recoverableSampleRecipeList = Array<SampleRecipeBasic>()
    var unrecoverableSampleRecipeList = Array<SampleRecipeBasic>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserRecipe()
        
        let realmPath = NSBundle.mainBundle().pathForResource("default", ofType: "realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(readOnly: true, path: realmPath)
        
        loadSampleRecipe()
        setNavigationTitle()

        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadUserRecipe(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe).sorted("recipeName")
        for ur in recipeList{
            userRecipeNameList.append(ur.recipeName)
        }
    }
    
    func loadSampleRecipe(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe).sorted("recipeName")
        for sr in recipeList{
            var isRecoverable = true
            for ur in userRecipeNameList{
                if sr.recipeName == ur{
                    isRecoverable = false
                    break
                }
            }

            let srb = SampleRecipeBasic()
            srb.name = sr.recipeName
            srb.kanaName = sr.recipeName.katakana().lowercaseString
            srb.recoverable = isRecoverable
            if isRecoverable{
                recoverableSampleRecipeList.append(srb)
            }else{
                unrecoverableSampleRecipeList.append(srb)
            }
        }
        recoverableSampleRecipeList.sortInPlace({ $0.kanaName < $1.kanaName })
        unrecoverableSampleRecipeList.sortInPlace({ $0.kanaName < $1.kanaName })
    }
    
    func setNavigationTitle(){
        var recoverCount = 0
        for rr in recoverableSampleRecipeList{
            if rr.recoverTarget{
                recoverCount += 1
            }
        }
        self.navigationItem.title = "サンプルレシピ復元(" + String(recoverCount) + ")"
    }
    
    func isTargetTapped(sender: M13Checkbox){
        var view = sender.superview
        while(view!.isKindOfClass(RecoverTargetTableViewCell) == false) {
            view = view!.superview
        }
        let cell = view as! RecoverTargetTableViewCell
        let touchIndex = self.tableView.indexPathForCell(cell)
        
        if touchIndex!.row < recoverableSampleRecipeList.count{
            if sender.checkState == .Checked{
                recoverableSampleRecipeList[touchIndex!.row].recoverTarget = true
            }else if sender.checkState == .Unchecked{
                recoverableSampleRecipeList[touchIndex!.row].recoverTarget = false
            }
            setNavigationTitle()
        }
    }
    
    func recover(){
        var recoverRecipeList = Array<RecoverRecipe>()
        for rr in recoverableSampleRecipeList{
            if rr.recoverTarget{
                let realm = try! Realm()
                let recipe = realm.objects(Recipe).filter("recipeName == %@", rr.name).first!
                
                let recoverRecipe = RecoverRecipe()
                recoverRecipe.name = recipe.recipeName
                recoverRecipe.method = recipe.method
                for ri in recipe.recipeIngredients{
                    let recoverIngredient = RecoverIngredient()
                    recoverIngredient.name = ri.ingredient.ingredientName
                    recoverIngredient.amount = ri.amount
                    recoverIngredient.mustflag = ri.mustFlag
                    recoverRecipe.ingredientList.append(recoverIngredient)
                }
                recoverRecipeList.append(recoverRecipe)
            }
        }
        
        let documentDir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let realmPath = documentDir.stringByAppendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(readOnly: false, path: realmPath)
        
        for recoverRecipe in recoverRecipeList{
            let realm = try! Realm()
            let rec = realm.objects(Recipe).filter("recipeName == %@",recoverRecipe.name)
            if rec.count < 1 {
                try! realm.write {
                    for recoverIngredient in recoverRecipe.ingredientList{
                        addIngredient(recoverIngredient.name, stockFlag: false, memo: "")
                    }
                    addRecipe(recoverRecipe.name, favorites: 1, memo: "", method: recoverRecipe.method)
                    
                    for recoverIngredient in recoverRecipe.ingredientList{
                        addRecipeToIngredientLink(recoverRecipe.name, ingredientName: recoverIngredient.name, amount: recoverIngredient.amount, mustFlag: recoverIngredient.mustflag)
                    }
                }
            }
        }
    }
    
    func addRecipe(recipeName:String, favorites:Int, memo:String, method:Int){
        let realm = try! Realm()
        let rec = realm.objects(Recipe).filter("recipeName == %@",recipeName)
        if rec.count < 1 {
            let recipe = Recipe()
            recipe.recipeName = recipeName
            recipe.favorites = favorites
            recipe.memo = memo
            recipe.method = method
            realm.add(recipe)
        }
    }
    
    func addIngredient(ingredientName: String, stockFlag: Bool, memo: String){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName)
        if ing.count < 1 {
            let ingredient = Ingredient()
            ingredient.ingredientName = ingredientName
            ingredient.stockFlag = stockFlag
            ingredient.memo = memo
            realm.add(ingredient)
        }
    }
    
    func addRecipeToIngredientLink(recipeName:String, ingredientName:String, amount:String, mustFlag:Bool){
        let realm = try! Realm()
        let recipeIngredientLink = RecipeIngredientLink()
        recipeIngredientLink.amount = amount
        recipeIngredientLink.mustFlag = mustFlag
        realm.add(recipeIngredientLink)
        
        let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName).first!
        ingredient.recipeIngredients.append(recipeIngredientLink)
        
        let recipe = realm.objects(Recipe).filter("recipeName == %@",recipeName).first!
        recipe.recipeIngredients.append(recipeIngredientLink)
    }

    // MARK: - Table view
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }else{
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if recoverableSampleRecipeList.count == 0{
                let alertView = UIAlertController(title: nil, message: "復元できるレシピはありません", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
                }))
                self.presentViewController(alertView, animated: true, completion: nil)
            }else{
                let alertView = UIAlertController(title: nil, message: String(recoverableSampleRecipeList.count) + "個のサンプルレシピを\n復元します", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "復元", style: .Default, handler: {action in
                    for recipe in self.recoverableSampleRecipeList{
                        recipe.recoverTarget = true
                    }
                    self.recover()
                    SVProgressHUD.showSuccessWithStatus("復元が完了しました")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }else if indexPath.section == 2{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("PushPreview", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "復元したいレシピを選んでください"
        }else{
            return nil
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 1
        }else{
            return recoverableSampleRecipeList.count + unrecoverableSampleRecipeList.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecoverDescription") as! RecoverDescriptionTableViewCell
            cell.recoverableRecipeNum = recoverableSampleRecipeList.count
            cell.sampleRecipeNum = recoverableSampleRecipeList.count + unrecoverableSampleRecipeList.count
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecoverAll") as! RecoverAllTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecoverTarget") as! RecoverTargetTableViewCell
            cell.isTarget.stateChangeAnimation = .Fade(.Fill)
            cell.isTarget.animationDuration = 0.0
            cell.isTarget.backgroundColor = UIColor.clearColor()
            cell.isTarget.boxLineWidth = 1.0
            cell.isTarget.markType = .Checkmark
            cell.isTarget.boxType = .Circle
            cell.isTarget.secondaryTintColor = FlatGray()
            
            if indexPath.row < recoverableSampleRecipeList.count{
                cell.recipeName.text = recoverableSampleRecipeList[indexPath.row].name
                cell.isTarget.enabled = true
                cell.isTarget.tintColor = FlatSkyBlueDark()
                if recoverableSampleRecipeList[indexPath.row].recoverTarget{
                    //CheckedとMixedを直接変換するとエラーになる
                    cell.isTarget.setCheckState(.Unchecked, animated: true)
                    cell.isTarget.setCheckState(.Checked, animated: true)
                }else{
                    cell.isTarget.setCheckState(.Unchecked, animated: true)
                }
                cell.isRecoverable = true
                cell.isTarget.addTarget(self, action: #selector(RecoverTableViewController.isTargetTapped(_:)), forControlEvents: UIControlEvents.ValueChanged)
            }else{
                cell.recipeName.text = unrecoverableSampleRecipeList[indexPath.row - recoverableSampleRecipeList.count].name
                cell.isTarget.enabled = false
                cell.isTarget.tintColor = FlatWhiteDark()
                //CheckedとMixedを直接変換するとエラーになる
                cell.isTarget.setCheckState(.Unchecked, animated: true)
                cell.isTarget.setCheckState(.Mixed, animated: true)
                cell.isRecoverable = false
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        let documentDir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let realmPath = documentDir.stringByAppendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(readOnly: false, path: realmPath)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func recoverButtonTapped(sender: UIBarButtonItem) {
        var recoverCount = 0
        for rr in recoverableSampleRecipeList{
            if rr.recoverTarget{
                recoverCount += 1
            }
        }
        
        if recoverCount == 0{
            let documentDir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let realmPath = documentDir.stringByAppendingPathComponent("default.realm")
            Realm.Configuration.defaultConfiguration = Realm.Configuration(readOnly: false, path: realmPath)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let alertView = UIAlertController(title: nil, message: String(recoverCount) + "個のサンプルレシピを\n復元します", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "復元", style: .Default, handler: {action in
                self.recover()
                SVProgressHUD.showSuccessWithStatus("復元が完了しました")
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushPreview" {
            let vc = segue.destinationViewController as! RecoverPreviewTableViewController
            if let indexPath = sender as? NSIndexPath{
                let realm = try! Realm()
                if indexPath.row < recoverableSampleRecipeList.count{
                    let recipe = realm.objects(Recipe).filter("recipeName == %@", recoverableSampleRecipeList[indexPath.row].name).first!
                    vc.recipe = recipe
                }else{
                    let recipe = realm.objects(Recipe).filter("recipeName == %@", unrecoverableSampleRecipeList[indexPath.row - recoverableSampleRecipeList.count].name).first!
                    vc.recipe = recipe
                }
            }
        }
    }

}
