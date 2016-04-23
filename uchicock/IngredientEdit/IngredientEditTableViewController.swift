//
//  IngredientEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import M13Checkbox

class IngredientEditTableViewController: UITableViewController, UITextFieldDelegate  {

    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var stock: M13Checkbox!
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

        stock.backgroundColor = FlatWhite()
        stock.tintColor = FlatSkyBlueDark()
        stock.secondaryTintColor = FlatSkyBlueDark()
        stock.boxLineWidth = 2.0
        stock.markType = .Checkmark
        stock.boxType = .Circle
        stock.stateChangeAnimation = .Expand(.Fill)
        if ingredient.stockFlag{
            stock.setCheckState(.Checked, animated: true)
        }else{
            stock.setCheckState(.Unchecked, animated: true)
        }
        stock.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stockTapped:"))

        memo.text = ingredient.memo
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        memo.layer.borderColor = FlatWhiteDark().CGColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        return true
    }
    
    func textWithoutSpace ( text: String ) -> String {
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func stockTapped(sender: UITapGestureRecognizer) {
        stock.toggleCheckState()
    }

    // MARK: - UITableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.backgroundColor = FlatWhite()
        return cell
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "はい",style: .Default){ action in
            self.dismissViewControllerAnimated(true, completion: nil)
            })
        alertView.addAction(UIAlertAction(title: "いいえ", style: .Cancel){ action in })
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if ingredientName.text == nil || textWithoutSpace(ingredientName.text!) == ""{
            //材料名を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(ingredientName.text!).characters.count > 30{
            //材料名が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "材料名を30文字以下にしてください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if memo.text.characters.count > 300{
            //メモが長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "メモを300文字以下にしてください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameIngredient = realm.objects(Ingredient).filter("ingredientName == %@", textWithoutSpace(ingredientName.text!))
                if sameNameIngredient.count != 0{
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前の材料が既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    let newIngredient = Ingredient()
                    newIngredient.ingredientName = textWithoutSpace(ingredientName.text!)
                    if stock.checkState == .Checked{
                        newIngredient.stockFlag = true
                    }else{
                        newIngredient.stockFlag = false
                    }
                    newIngredient.memo = memo.text
                    try! realm.write {
                        realm.add(newIngredient)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }else{
                let sameNameIngredient = realm.objects(Ingredient).filter("ingredientName == %@",textWithoutSpace(ingredientName.text!))
                if sameNameIngredient.count != 0 && ingredient.ingredientName != textWithoutSpace(ingredientName.text!){
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前の材料が既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write {
                        ingredient.ingredientName = textWithoutSpace(ingredientName.text!)
                        if stock.checkState == .Checked{
                            ingredient.stockFlag = true
                        }else{
                            ingredient.stockFlag = false
                        }
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

}
