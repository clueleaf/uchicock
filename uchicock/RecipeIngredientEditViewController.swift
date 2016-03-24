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
    
    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var option: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientName.delegate = self
        amount.delegate = self
        
        if isAddMode == false{
            ingredientName.text = recipeIngredient.ingredientName
            amount.text = recipeIngredient.amount
            option.on = !recipeIngredient.mustFlag
            self.navigationItem.title = "材料の変更"
        }else{
            option.on = false
            self.navigationItem.title = "材料の追加"
        }
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
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        return true
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
            let alertView = UIAlertController(title: "このレシピの材料から外しますか？", message: "", preferredStyle: .ActionSheet)
            alertView.addAction(UIAlertAction(title: "外す",style: .Destructive){
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
