//
//  RecipeEditViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeEditViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
//    var txtActiveView = UITextView()
    var recipe = Recipe()
    var isAddMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if recipe.recipeName == "" {
            self.navigationItem.title = "レシピ登録"
            isAddMode = true
        } else {
            self.navigationItem.title = "レシピ編集"
            isAddMode = false
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //        let notificationCenter = NSNotificationCenter.defaultCenter()
        //        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        //        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        
//        // NSNotificationCenterの解除処理
//        let notificationCenter = NSNotificationCenter.defaultCenter()
//        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeEditName") as! RecipeEditNameTableViewCell
                cell.recipe = recipe
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeEditFavorite") as! RecipeEditFavoriteTableViewCell
                cell.recipe = recipe
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeEditMethod") as! RecipeEditMethodTableViewCell
                cell.recipe = recipe
                return cell
            }else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeEditMemo") as! RecipeEditMemoTableViewCell
                cell.recipe = recipe
                return cell
            }
        }
        return UITableViewCell()
    }
    

    
//    func handleKeyboardWillShowNotification(notification: NSNotification) {
//        
//        let userInfo = notification.userInfo!
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
//        let txtLimit = txtActiveView.frame.origin.y + txtActiveView.frame.height + 8.0
//        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
//        
//        if txtLimit >= kbdLimit {
//            scrollView.contentOffset.y = txtLimit - kbdLimit
//        }
//    }
//    
//    func handleKeyboardWillHideNotification(notification: NSNotification) {
//        scrollView.contentOffset.y = 0
//    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        var path = NSIndexPath(forRow: 0, inSection: 0)
        let nameCell = tableView.cellForRowAtIndexPath(path) as! RecipeEditNameTableViewCell
        let recipeName = nameCell.recipeName
        path = NSIndexPath(forRow: 1, inSection: 0)
        let favoriteCell = tableView.cellForRowAtIndexPath(path) as! RecipeEditFavoriteTableViewCell
        let star2 = favoriteCell.star2
        let star3 = favoriteCell.star3
        path = NSIndexPath(forRow: 2, inSection: 0)
        let methodCell = tableView.cellForRowAtIndexPath(path) as! RecipeEditMethodTableViewCell
        let method = methodCell.method
        path = NSIndexPath(forRow: 3, inSection: 0)
        let memoCell = tableView.cellForRowAtIndexPath(path) as! RecipeEditMemoTableViewCell
        let memo = memoCell.memo

        if recipeName.text == nil || recipeName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())==""{
            //名前を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "レシピ名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
            
            //TODO:材料を一つも入れていない場合もアラートを出す

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
                    let newRecipe = Recipe()
                    newRecipe.recipeName = recipeName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if star3.currentTitle == "★" {
                        newRecipe.favorites = 3
                    }else if star2.currentTitle == "★" {
                        newRecipe.favorites = 2
                    }else{
                        newRecipe.favorites = 1
                    }
                    
                    switch method.selectedSegmentIndex{
                    case 0:
                        newRecipe.method = 0
                    case 1:
                        newRecipe.method = 1
                    case 2:
                        newRecipe.method = 2
                    case 3:
                        newRecipe.method = 3
                    case 4:
                        newRecipe.method = 4
                    default:
                        newRecipe.method = 4
                    }

                    newRecipe.memo = memo.text
                    
                    //TODO:一番先にリレーションシップを登録する
                    //TODO:材料がない場合は材料も登録する

                    try! realm.write {
                        realm.add(newRecipe)
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
                        recipe.recipeName = recipeName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        if star3.currentTitle == "★" {
                            recipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            recipe.favorites = 2
                        }else{
                            recipe.favorites = 1
                        }
                        switch method.selectedSegmentIndex{
                        case 0:
                            recipe.method = 0
                        case 1:
                            recipe.method = 1
                        case 2:
                            recipe.method = 2
                        case 3:
                            recipe.method = 3
                        case 4:
                            recipe.method = 4
                        default:
                            recipe.method = 4
                        }
                        recipe.memo = memo.text
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
