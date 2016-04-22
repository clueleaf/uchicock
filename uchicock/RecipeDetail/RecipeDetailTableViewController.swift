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
import SCLAlertView
import Accounts

class RecipeDetailTableViewController: UITableViewController {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var openInSafari: UIButton!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var recipeId = String()
    var recipe = Recipe()
    var noPhotoFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        openInSafari.setTitleColor(FlatWhite(), forState: .Normal)
        openInSafari.layer.cornerRadius = 4
        
        tableView.registerClass(RecipeIngredientListTableViewCell.self, forCellReuseIdentifier: "RecipeIngredientList")
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecipeDetailTableViewController.cellLongPressed(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
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
            
            let urlStr : String = "http://www.google.co.jp/search?q=" + recipe.recipeName + "+カクテル"
            let url = NSURL(string:urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            if UIApplication.sharedApplication().canOpenURL(url!) {
                openInSafari.enabled = true
                openInSafari.backgroundColor = FlatSkyBlueDark()
            }else{
                openInSafari.enabled = false
                openInSafari.backgroundColor = FlatWhiteDark()
            }
            
            noPhotoFlag = false
            if recipe.imageData != nil{
                photo.image = UIImage(data: recipe.imageData!)
                //レシピ削除のバグに対するワークアラウンド
                if photo.image == nil{
                    noPhotoFlag = true
                }
            }else{
                noPhotoFlag = true
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

    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        if indexPath == nil {
        } else if indexPath?.section == 0 && indexPath?.row == 0 && noPhotoFlag == false &&
            recognizer.state == UIGestureRecognizerState.Began  {
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                alertView.addAction(UIAlertAction(title: "カメラロールへ保存",style: .Default){ action in
                    if self.photo.image != nil{
                        UIImageWriteToSavedPhotosAlbum(self.photo.image!, self, #selector(RecipeDetailTableViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                    })
                alertView.addAction(UIAlertAction(title: "クリップボードへコピー",style: .Default){ action in
                    if self.photo.image != nil{
                        let pasteboard: UIPasteboard = UIPasteboard.generalPasteboard()
                        pasteboard.image = self.photo.image!
                    }
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error == nil{
            let alertView = SCLAlertView()
            alertView.showCloseButton = false
            alertView.showSuccess("", subTitle: "カメラロールへ保存しました", colorStyle: 0x3498DB, duration: 2.0)
        }else{
            let alertView = UIAlertController(title: "カメラロールへの保存に失敗しました", message: "「設定」→「うちカク！」にて写真へのアクセス許可を確認してください", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            }))
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableView
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if noPhotoFlag == false && indexPath.row == 0{
                return UIScreen.mainScreen().bounds.size.width
            }else{
                return UITableViewAutomaticDimension
            }
        }else if indexPath.section == 1{
            return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        }else if indexPath.section == 2{
            return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "材料(" + String(recipe.recipeIngredients.count) + ")"
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if noPhotoFlag {
                return 4
            }else{
                return 5
            }
        }else if section == 1{
            return recipe.recipeIngredients.count
        }else if section == 2{
            return 1
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 0 {
            if noPhotoFlag{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: indexPath.row + 1, inSection: 0))
            }else{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
            }
        }else if indexPath.section == 1{
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        }else if indexPath.section == 2{
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 && noPhotoFlag == false{
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
                for i in 0 ..< self.recipe.recipeIngredients.count {
                    let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@",self.recipe.recipeIngredients[i].id).first!
                    deletingRecipeIngredientList.append(recipeIngredient)
                }
                try! realm.write{
                    for ri in deletingRecipeIngredientList{
                        let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                        for i in 0 ..< ingredient.recipeIngredients.count{
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            if noPhotoFlag{
                let cell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row+1, inSection: 0))
                cell.backgroundColor = FlatWhite()
                return cell
            }else{
                let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
                cell.backgroundColor = FlatWhite()
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeIngredientList", forIndexPath: indexPath) as! RecipeIngredientListTableViewCell
            cell.ingredientName.text = recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            if recipe.recipeIngredients[indexPath.row].mustFlag{
                cell.option.text = ""
                cell.option.backgroundColor = UIColor.clearColor()
            }else{
                cell.option.text = "オプション"
                cell.option.backgroundColor = FlatWhiteDark()
            }
            cell.option.textColor = FlatBlack()
            cell.option.layer.cornerRadius = 4
            cell.option.clipsToBounds = true
            cell.option.textAlignment = NSTextAlignment.Center

            if recipe.recipeIngredients[indexPath.row].ingredient.stockFlag {
                cell.stock.text = "在庫あり"
                cell.stock.textColor = FlatWhite()
                cell.stock.backgroundColor = FlatSkyBlueDark()
                cell.ingredientName.textColor = FlatBlack()
                cell.amount.textColor = FlatBlack()
            }else{
                cell.stock.text = "在庫なし"
                cell.stock.textColor = FlatBlack()
                cell.stock.backgroundColor = FlatWhiteDark()
                cell.ingredientName.textColor = FlatGrayDark()
                cell.amount.textColor = FlatGrayDark()
            }
            cell.stock.layer.cornerRadius = 4
            cell.stock.clipsToBounds = true
            cell.stock.textAlignment = NSTextAlignment.Center
            cell.amount.text = recipe.recipeIngredients[indexPath.row].amount
            
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = .Default
            cell.backgroundColor = FlatWhite()
            return cell
        case 2:
            let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.backgroundColor = FlatWhite()
            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: - IBAction
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditRecipe", sender: UIBarButtonItem())
    }
    
    @IBAction func actionButtonTapped(sender: UIBarButtonItem) {
        let excludedActivityTypes = [
            UIActivityTypeMessage,
            UIActivityTypeMail,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToWeibo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeAirDrop
        ]
        
        let shareText = createLongMessage()
        if noPhotoFlag == false && photo.image != nil{
            let activityVC = UIActivityViewController(activityItems: [shareText, photo.image!], applicationActivities: nil)
            activityVC.excludedActivityTypes = excludedActivityTypes
            self.presentViewController(activityVC, animated: true, completion: nil)
        }else{
            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            activityVC.excludedActivityTypes = excludedActivityTypes
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    func createLongMessage() -> String{
        var message = "【カクテルレシピ】" + recipe.recipeName + "\n"
        switch recipe.method{
        case 0:
            message += "技法：ビルド\n\n"
        case 1:
            message += "技法：ステア\n\n"
        case 2:
            message += "技法：シェイク\n\n"
        case 3:
            message += "技法：ブレンド\n\n"
        case 4:
            message += "技法：その他\n\n"
        default: break
        }
        message += "材料：\n"
        for recipeIngredient in recipe.recipeIngredients{
            message += recipeIngredient.ingredient.ingredientName + " " + recipeIngredient.amount + "\n"
        }
        if recipe.memo != "" {
            message += "\n" + recipe.memo
        }
        return message
    }
    
    @IBAction func openInSafariTapped(sender: UIButton) {
        let urlStr : String = "http://www.google.co.jp/search?q=" + recipe.recipeName + "+カクテル"
        let url = NSURL(string:urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
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
