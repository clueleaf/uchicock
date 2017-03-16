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

    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var category: UISegmentedControl!
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

        stock.boxLineWidth = 1.0
        stock.markType = .checkmark
        stock.boxType = .circle
        stock.stateChangeAnimation = .expand(.fill)
        if ingredient.stockFlag{
            stock.setCheckState(.checked, animated: true)
        }else{
            stock.setCheckState(.unchecked, animated: true)
        }

        memo.text = ingredient.memo
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ingredientName.backgroundColor = Style.textFieldBackgroundColor
        ingredientName.textColor = Style.labelTextColor
        ingredientNameLabel.textColor = Style.labelTextColor
        categoryLabel.textColor = Style.labelTextColor
        stockLabel.textColor = Style.labelTextColor
        memoLabel.textColor = Style.labelTextColor
        category.tintColor = Style.secondaryColor
        category.backgroundColor = Style.basicBackgroundColor
        let attribute = [NSForegroundColorAttributeName:Style.secondaryColor]
        category.setTitleTextAttributes(attribute, for: .normal)
        stock.backgroundColor = UIColor.clear
        stock.tintColor = Style.secondaryColor
        stock.secondaryTintColor = Style.checkboxSecondaryTintColor
        memo.backgroundColor = Style.textFieldBackgroundColor
        memo.textColor = Style.labelTextColor
        memo.layer.borderColor = Style.memoBorderColor.cgColor
        self.tableView.backgroundColor = Style.basicBackgroundColor
        
        if Style.isDark {
            ingredientName.keyboardAppearance = .dark
            memo.keyboardAppearance = .dark
        }else{
            ingredientName.keyboardAppearance = .default
            memo.keyboardAppearance = .default
        }
        
        if ingredient.category >= 0 && ingredient.category < 3 {
            category.selectedSegmentIndex = ingredient.category
        } else {
            category.selectedSegmentIndex = 2
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAddMode{
            ingredientName.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        return true
    }
    
    func textWithoutSpace ( text: String ) -> String {
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = Style.basicBackgroundColor
        return cell
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "はい",style: .default){ action in
            self.dismiss(animated: true, completion: nil)
            })
        alertView.addAction(UIAlertAction(title: "いいえ", style: .cancel){ action in })
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if ingredientName.text == nil || textWithoutSpace(text: ingredientName.text!) == ""{
            //材料名を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            present(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(text: ingredientName.text!).characters.count > 30{
            //材料名が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "材料名を30文字以下にしてください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            present(noNameAlertView, animated: true, completion: nil)
        }else if memo.text.characters.count > 300{
            //メモが長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "メモを300文字以下にしてください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            present(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", textWithoutSpace(text: ingredientName.text!))
                if sameNameIngredient.count != 0{
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前の材料が既に登録されています", preferredStyle: .alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                    present(sameNameAlertView, animated: true, completion: nil)
                }else{
                    let newIngredient = Ingredient()
                    newIngredient.ingredientName = textWithoutSpace(text: ingredientName.text!)
                    newIngredient.japaneseDictionaryOrder = textWithoutSpace(text: ingredientName.text!).japaneseDictionaryOrder()
                    newIngredient.category = category.selectedSegmentIndex
                    if stock.checkState == .checked{
                        newIngredient.stockFlag = true
                    }else{
                        newIngredient.stockFlag = false
                    }
                    newIngredient.memo = memo.text
                    try! realm.write {
                        realm.add(newIngredient)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@",textWithoutSpace(text: ingredientName.text!))
                if sameNameIngredient.count != 0 && ingredient.ingredientName != textWithoutSpace(text: ingredientName.text!){
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前の材料が既に登録されています", preferredStyle: .alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                    present(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write {
                        ingredient.ingredientName = textWithoutSpace(text: ingredientName.text!)
                        ingredient.japaneseDictionaryOrder = textWithoutSpace(text: ingredientName.text!).japaneseDictionaryOrder()
                        ingredient.category = category.selectedSegmentIndex
                        if stock.checkState == .checked{
                            ingredient.stockFlag = true
                        }else{
                            ingredient.stockFlag = false
                        }
                        ingredient.memo = memo.text
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
