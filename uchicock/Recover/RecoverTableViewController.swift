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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushPreview", sender: indexPath)
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
            let cell = tableView.dequeueReusableCellWithIdentifier("RecoverTarget") as! RecoverTargetTableViewCell
            cell.isTarget.stateChangeAnimation = .Fade(.Fill)
            cell.isTarget.animationDuration = 0
            cell.isTarget.backgroundColor = UIColor.clearColor()
            cell.isTarget.boxLineWidth = 1.0
            cell.isTarget.markType = .Checkmark
            cell.isTarget.boxType = .Circle

            if indexPath.row < recoverableSampleRecipeList.count{
                cell.isRecoverable = true
                cell.recipeName.text = recoverableSampleRecipeList[indexPath.row].name
                cell.isTarget.enabled = true
                cell.isTarget.tintColor = FlatSkyBlueDark()
                if recoverableSampleRecipeList[indexPath.row].recoverTarget{
                    cell.isTarget.setCheckState(.Checked, animated: true)
                }else{
                    cell.isTarget.setCheckState(.Unchecked, animated: true)
                }
            }else{
                cell.isRecoverable = false
                cell.recipeName.text = unrecoverableSampleRecipeList[indexPath.row - recoverableSampleRecipeList.count].name
                cell.isTarget.enabled = false
                cell.isTarget.tintColor = FlatWhiteDark()
                cell.isTarget.setCheckState(.Mixed, animated: true)
            }
            cell.isTarget.addTarget(self, action: #selector(RecoverTableViewController.isTargetTapped(_:)), forControlEvents: UIControlEvents.ValueChanged)

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
        //レシピリスト（材料リスト含む）を変数に保存
        
        let documentDir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let realmPath = documentDir.stringByAppendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(readOnly: false, path: realmPath)
        
        /*レシピ数だけ繰り返し*/
        //レシピ登録
        
        //材料の存在確認
        
        //なければ材料登録
        
        //レシピ材料登録
        
        /*レシピ数だけ繰り返し*/

        self.dismissViewControllerAnimated(true, completion: nil)
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
