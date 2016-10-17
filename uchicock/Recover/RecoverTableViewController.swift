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
    let queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL)
    var isRecovering = false
    let leastWaitTime = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserRecipe()
        
        var config = Realm.Configuration(schemaVersion: 1)
        config.fileURL = NSBundle.mainBundle().URLForResource("default", withExtension: "realm")
        config.readOnly = true
        Realm.Configuration.defaultConfiguration = config

        loadSampleRecipe()
        setNavigationTitle()
        isRecovering = false
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
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

            let srb = SampleRecipeBasic(name: sr.recipeName, recoverable: isRecoverable, recoverTarget: false)
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
        if isRecovering == false {
            var view = sender.superview
            while(view!.isKindOfClass(RecoverTargetTableViewCell) == false) {
                view = view!.superview
            }
            let cell = view as! RecoverTargetTableViewCell
            let touchIndex = self.tableView.indexPathForCell(cell)
            
            if touchIndex!.row - 1 < recoverableSampleRecipeList.count{
                if sender.checkState == .Checked{
                    recoverableSampleRecipeList[touchIndex!.row - 1].recoverTarget = true
                }else if sender.checkState == .Unchecked{
                    recoverableSampleRecipeList[touchIndex!.row - 1].recoverTarget = false
                }
                setNavigationTitle()
            }            
        }
    }
    
    func recover(){
        var recoverRecipeList = Array<RecoverRecipe>()
        for rr in recoverableSampleRecipeList{
            if rr.recoverTarget{
                let realm = try! Realm()
                let recipe = realm.objects(Recipe).filter("recipeName == %@", rr.name).first!
                
                var recoverRecipe = RecoverRecipe(name: recipe.recipeName, method: recipe.method, ingredientList: [])
                for ri in recipe.recipeIngredients{
                    recoverRecipe.ingredientList.append(RecoverIngredient(name: ri.ingredient.ingredientName, amount: ri.amount, mustflag: ri.mustFlag))
                }
                recoverRecipeList.append(recoverRecipe)
            }
        }
        
        var config = Realm.Configuration(schemaVersion: 1)
        config.fileURL = config.fileURL!.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        
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
    
    func waitAtLeast(time : NSTimeInterval, @noescape _ block: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent()
        let wait = max(0.0, time - (end - start))
        if wait > 0.0 {
            NSThread.sleepForTimeInterval(wait)
        }
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
            if indexPath.row == 0 {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                if isRecovering == false {
                    if recoverableSampleRecipeList.count == 0{
                        let alertView = UIAlertController(title: nil, message: "復元できるレシピはありません", preferredStyle: .Alert)
                        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
                        }))
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }else{
                        let alertView = UIAlertController(title: nil, message: String(recoverableSampleRecipeList.count) + "個のサンプルレシピを\n復元します", preferredStyle: .Alert)
                        alertView.addAction(UIAlertAction(title: "復元", style: .Default, handler: {action in
                            self.isRecovering = true
                            SVProgressHUD.showWithStatus("復元中...")
                            dispatch_async(self.queue){
                                self.waitAtLeast(self.leastWaitTime) {
                                    for i in 0..<self.recoverableSampleRecipeList.count {
                                        self.recoverableSampleRecipeList[i].recoverTarget = true
                                    }
                                    self.recover()
                                }
                                dispatch_async(dispatch_get_main_queue()){
                                    SVProgressHUD.showSuccessWithStatus("復元が完了しました")
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            }
                        }))
                        alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }
                }
            }else{
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                if isRecovering == false {
                    performSegueWithIdentifier("PushPreview", sender: indexPath)
                }
            }
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return recoverableSampleRecipeList.count + unrecoverableSampleRecipeList.count + 1
        }else{
            return 0
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
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCellWithIdentifier("RecoverAll") as! RecoverAllTableViewCell
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("RecoverTarget") as! RecoverTargetTableViewCell
                cell.isTarget.stateChangeAnimation = .Fade(.Fill)
                cell.isTarget.animationDuration = 0.0
                cell.isTarget.backgroundColor = UIColor.clearColor()
                cell.isTarget.boxLineWidth = 1.0
                cell.isTarget.markType = .Checkmark
                cell.isTarget.boxType = .Circle
                cell.isTarget.secondaryTintColor = FlatGray()
                
                if indexPath.row - 1 < recoverableSampleRecipeList.count{
                    cell.recipeName.text = recoverableSampleRecipeList[indexPath.row - 1].name
                    cell.isTarget.enabled = true
                    cell.isTarget.tintColor = FlatSkyBlueDark()
                    if recoverableSampleRecipeList[indexPath.row - 1].recoverTarget{
                        //CheckedとMixedを直接変換するとエラーになる
                        cell.isTarget.setCheckState(.Unchecked, animated: true)
                        cell.isTarget.setCheckState(.Checked, animated: true)
                    }else{
                        cell.isTarget.setCheckState(.Unchecked, animated: true)
                    }
                    cell.isRecoverable = true
                    cell.isTarget.addTarget(self, action: #selector(RecoverTableViewController.isTargetTapped(_:)), forControlEvents: UIControlEvents.ValueChanged)
                }else{
                    cell.recipeName.text = unrecoverableSampleRecipeList[indexPath.row - 1 - recoverableSampleRecipeList.count].name
                    cell.isTarget.enabled = false
                    cell.isTarget.tintColor = FlatWhiteDark()
                    //CheckedとMixedを直接変換するとエラーになる
                    cell.isTarget.setCheckState(.Unchecked, animated: true)
                    cell.isTarget.setCheckState(.Mixed, animated: true)
                    cell.isRecoverable = false
                }
                return cell
            }
        default:
            return UITableViewCell()
        }
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        if isRecovering == false {
            var config = Realm.Configuration(schemaVersion: 1)
            config.fileURL = config.fileURL!.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default.realm")
            Realm.Configuration.defaultConfiguration = config
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func recoverButtonTapped(sender: UIBarButtonItem) {
        if isRecovering == false{
            var recoverCount = 0
            for rr in recoverableSampleRecipeList{
                if rr.recoverTarget{
                    recoverCount += 1
                }
            }
            
            if recoverCount == 0{
                var config = Realm.Configuration(schemaVersion: 1)
                config.fileURL = config.fileURL!.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default.realm")
                Realm.Configuration.defaultConfiguration = config
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                let alertView = UIAlertController(title: nil, message: String(recoverCount) + "個のサンプルレシピを\n復元します", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "復元", style: .Default, handler: {action in
                    self.isRecovering = true
                    SVProgressHUD.showWithStatus("復元中...")
                    dispatch_async(self.queue){
                        self.waitAtLeast(self.leastWaitTime) {
                            self.recover()
                        }
                        dispatch_async(dispatch_get_main_queue()){
                            SVProgressHUD.showSuccessWithStatus("復元が完了しました")
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                }))
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushPreview" {
            let vc = segue.destinationViewController as! RecoverPreviewTableViewController
            if let indexPath = sender as? NSIndexPath{
                let realm = try! Realm()
                if indexPath.row - 1 < recoverableSampleRecipeList.count{
                    let recipe = realm.objects(Recipe).filter("recipeName == %@", recoverableSampleRecipeList[indexPath.row - 1].name).first!
                    vc.recipe = recipe
                }else{
                    let recipe = realm.objects(Recipe).filter("recipeName == %@", unrecoverableSampleRecipeList[indexPath.row - 1 - recoverableSampleRecipeList.count].name).first!
                    vc.recipe = recipe
                }
            }
        }
    }

}