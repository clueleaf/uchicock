//
//  IngredientEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientEditTableViewController: UITableViewController, UITextFieldDelegate  {

    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var stock: UISwitch!
    @IBOutlet weak var memo: UITextView!
    
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

        ingredientName.text = ingredient.ingredientName
        ingredientName.delegate = self
        stock.on = ingredient.stockFlag
        memo.text = ingredient.memo
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        memo.layer.borderColor = UIColor.grayColor().CGColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        return true
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 0
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "", message: "編集をやめますか？", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "はい",style: .Default){
            action in
            self.dismissViewControllerAnimated(true, completion: nil)
            })
        alertView.addAction(UIAlertAction(title: "いいえ", style: .Cancel){action in})
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if ingredientName.text == nil || ingredientName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())==""{
            //名前を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if ingredientName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 30{
            //材料名が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "材料名が長すぎます", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if memo.text.characters.count > 300{
            //メモが長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "メモが長すぎます", preferredStyle: .Alert)
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

    @IBAction func screenTapped(sender: UITapGestureRecognizer) {
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
