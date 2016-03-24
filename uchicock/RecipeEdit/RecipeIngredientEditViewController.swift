//
//  RecipeIngredientEditViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/24.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeIngredientEditViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate {

    var recipeIngredient = EditingRecipeIngredient()
    var isAddMode = false
    var deleteFlag = false
    var suggestList = Array<String>()
    
    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var option: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientName.delegate = self
        amount.delegate = self
        ingredientName.tag = 0
        amount.tag = 1
        
        if isAddMode == false{
            ingredientName.text = recipeIngredient.ingredientName
            amount.text = recipeIngredient.amount
            option.on = !recipeIngredient.mustFlag
            self.navigationItem.title = "材料の変更"
        }else{
            option.on = false
            self.navigationItem.title = "材料の追加"
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"textFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.ingredientName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            tableView.reloadData()
        }
    }
    
    func textFieldDidChange(notification:NSNotification){
        suggestList.removeAll()
        let realm = try! Realm()
        let ingredientList = realm.objects(Ingredient).filter("ingredientName contains %@",ingredientName.text!).sorted("ingredientName")
        for ingredient in ingredientList {
            suggestList.append(ingredient.ingredientName)
        }
        tableView.reloadData()
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        if textField.tag == 0{
            suggestList.removeAll()
            tableView.reloadData()
        }
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        ingredientName.text = suggestList[indexPath.row]
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 30
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return suggestList.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SuggestIngredient", forIndexPath: indexPath) as! SuggestIngredientTableViewCell
        cell.name = suggestList[indexPath.row]
        return cell
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        if touch.view!.isDescendantOfView(tableView) {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "材料候補"
    }


    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        if ingredientName.text == "" {
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
            return
        }
        
        let realm = try! Realm()
        let sameNameIngredient = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        if sameNameIngredient.count == 0{
            //同じ名前の材料が存在しないので新規に登録する
            let registAlertView = UIAlertController(title: "", message: "この材料はまだ登録されていないので、新たに登録します", preferredStyle: .Alert)
            registAlertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {action in
                let ingredient = Ingredient()
                ingredient.ingredientName = self.ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
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
    
    @IBAction func notUseButtonTapped(sender: UIButton) {
        if isAddMode{
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let alertView = UIAlertController(title: "このレシピの材料から削除しますか？", message: "", preferredStyle: .ActionSheet)
            alertView.addAction(UIAlertAction(title: "削除する",style: .Destructive){
                action in
                self.deleteFlag = true
                self.performSegueWithIdentifier("UnwindToRecipeEdit", sender: self)
                })
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
            presentViewController(alertView, animated: true, completion: nil)
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
