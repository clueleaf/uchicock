//
//  RecipeIngredientEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/09.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class RecipeIngredientEditTableViewController: UITableViewController, UITextFieldDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var suggestTableViewCell: UITableViewCell!
    @IBOutlet weak var suggestTableView: UITableView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var option: UISwitch!
    @IBOutlet weak var deleteTableViewCell: UITableViewCell!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var recipeIngredient = EditingRecipeIngredient()
    var isAddMode = false
    var deleteFlag = false
    var suggestList = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientName.tag = 0
        amount.tag = 1
        self.tableView.tag = 0
        suggestTableView.tag = 1
        
        if isAddMode == false{
            ingredientName.text = recipeIngredient.ingredientName
            amount.text = recipeIngredient.amount
            option.on = !recipeIngredient.mustFlag
            self.navigationItem.title = "材料の変更"
            deleteLabel.text = "このレシピの材料から外す"
        }else{
            option.on = false
            self.navigationItem.title = "材料の追加"
            deleteLabel.text = "材料の追加をやめる"
        }
        deleteLabel.textColor = FlatRed()
        
        suggestTableView.backgroundColor = FlatWhite()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(RecipeIngredientEditTableViewController.textFieldDidChange(_:)), name: UITextFieldTextDidChangeNotification, object: self.ingredientName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        amount.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField){
        if textField.tag == 0{
            suggestList.removeAll()
            let realm = try! Realm()
            let ingredientList = realm.objects(Ingredient).filter("ingredientName contains %@",ingredientName.text!).sorted("ingredientName")
            for ingredient in ingredientList {
                suggestList.append(ingredient.ingredientName)
            }
            suggestTableView.reloadData()
        }
    }
    
    func textFieldDidChange(notification:NSNotification){
        suggestList.removeAll()
        let realm = try! Realm()
        let ingredientList = realm.objects(Ingredient).filter("ingredientName contains %@",ingredientName.text!).sorted("ingredientName")
        for ingredient in ingredientList {
            suggestList.append(ingredient.ingredientName)
        }
        suggestTableView.reloadData()
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        if textField.tag == 0{
            suggestList.removeAll()
            suggestTableView.reloadData()
        }
    }
    
    func textWithoutSpace(text: String) -> String{
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    // MARK: - UITableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView.tag == 0{
            return 2
        }else if tableView.tag == 1{
            return 1
        }
        return 0
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 && section == 0{
            return 30
        }else if tableView.tag == 0 && section == 1{
            return 30
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.tag == 1 && section == 0{
            return "材料候補"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.tag == 0 {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }else if tableView.tag == 1{
            return 30
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            if section == 0{
                return 4
            }else if section == 1{
                return 1
            }
        }else if tableView.tag == 1{
            return suggestList.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 0 && indexPath.section == 1 && indexPath.row == 0{
            if isAddMode{
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                alertView.addAction(UIAlertAction(title: "追加をやめる",style: .Destructive){
                    action in
                    self.deleteFlag = true
                    self.performSegueWithIdentifier("UnwindToRecipeEdit", sender: self)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                presentViewController(alertView, animated: true, completion: nil)
            }else{
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                alertView.addAction(UIAlertAction(title: "外す",style: .Destructive){
                    action in
                    self.deleteFlag = true
                    self.performSegueWithIdentifier("UnwindToRecipeEdit", sender: self)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
                presentViewController(alertView, animated: true, completion: nil)
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }else if tableView.tag == 1{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            ingredientName.text = suggestList[indexPath.row]
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.backgroundColor = FlatWhite()
            return cell
        }else if tableView.tag == 1 && indexPath.section == 0{
            let cell = suggestTableView.dequeueReusableCellWithIdentifier("SuggestIngredient") as! SuggestIngredientTableViewCell
            cell.name = suggestList[indexPath.row]
            cell.backgroundColor = FlatWhite()
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - GestureRecognizer
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        if touch.view!.isDescendantOfView(deleteTableViewCell) {
            return false
        }else if touch.view!.isDescendantOfView(suggestTableViewCell){
            return false
        }
        return true
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        if textWithoutSpace(ingredientName.text!) == "" {
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(ingredientName.text!).characters.count > 30{
            //材料名が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "材料名を30文字以下にしてください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(amount.text!).characters.count > 30{
            //分量が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "分量を30文字以下にしてください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            let sameNameIngredient = realm.objects(Ingredient).filter("ingredientName == %@",textWithoutSpace(ingredientName.text!))
            if sameNameIngredient.count == 0{
                //同じ名前の材料が存在しないので新規に登録する
                let registAlertView = UIAlertController(title: "", message: "この材料はまだ登録されていないので、新たに登録します", preferredStyle: .Alert)
                registAlertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {action in
                    let ingredient = Ingredient()
                    ingredient.ingredientName = self.textWithoutSpace(self.ingredientName.text!)
                    ingredient.stockFlag = false
                    ingredient.memo = ""
                    try! realm.write {
                        realm.add(ingredient)
                    }
                    self.performSegueWithIdentifier("UnwindToRecipeEdit", sender: self)}))
                registAlertView.addAction(UIAlertAction(title: "キャンセル", style: .Default){action in})
                presentViewController(registAlertView, animated: true, completion: nil)
            }else{
                self.performSegueWithIdentifier("UnwindToRecipeEdit", sender: self)
            }
        }
    }
    
    @IBAction func screenTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UnwindToRecipeEdit"{
        }
    }
    
}
