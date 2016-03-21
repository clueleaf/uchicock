//
//  IngredientEditViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/19.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientEditViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
//    var txtActiveView = UITextView()
    var ingredient = Ingredient()
    var isAddMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ingredient.ingredientName == "" {
            self.navigationItem.title = "材料登録"
            isAddMode = true
        } else {
            self.navigationItem.title = "材料編集"
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
            return 3
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientEditName") as! IngredientEditNameTableViewCell
                cell.ingredient = ingredient
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientEditStock") as! IngredientEditStockTableViewCell
                cell.ingredient = ingredient
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IngredientEditMemo") as! IngredientEditMemoTableViewCell
                cell.ingredient = ingredient
                return cell
            }
        }
        return UITableViewCell()
    }

    
//    func handleKeyboardWillShowNotification(notification: NSNotification) {
//        let userInfo = notification.userInfo!
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
//        let txtLimit = txtActiveView.frame.origin.y + txtActiveView.frame.height + 8.0
//        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
//        if txtLimit >= kbdLimit {
//            tableView.contentOffset.y = txtLimit - kbdLimit
//        }
//    }
//    
//    func handleKeyboardWillHideNotification(notification: NSNotification) {
//        tableView.contentOffset.y = 0
//    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        var path = NSIndexPath(forRow: 0, inSection: 0)
        let nameCell = tableView.cellForRowAtIndexPath(path) as! IngredientEditNameTableViewCell
        let ingredientName = nameCell.ingredientName
        path = NSIndexPath(forRow: 1, inSection: 0)
        let stockCell = tableView.cellForRowAtIndexPath(path) as! IngredientEditStockTableViewCell
        let stock = stockCell.stock
        path = NSIndexPath(forRow: 2, inSection: 0)
        let memoCell = tableView.cellForRowAtIndexPath(path) as! IngredientEditMemoTableViewCell
        let memo = memoCell.memo
        
        if ingredientName.text == nil || ingredientName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())==""{
            //名前を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameIngredient = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                if sameNameIngredient.count != 0{
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前の材料が既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    let newIngredient = Ingredient()
                    newIngredient.ingredientName = ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    newIngredient.stockFlag = stock.on
                    newIngredient.memo = memo.text
                    try! realm.write {
                        realm.add(newIngredient)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }else{
                let sameNameIngredient = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                if sameNameIngredient.count != 0 && ingredient.ingredientName != ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()){
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前の材料が既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write {
                        ingredient.ingredientName = ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        ingredient.stockFlag = stock.on
                        ingredient.memo = memo.text
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
