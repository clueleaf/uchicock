//
//  IngredientEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import M13Checkbox

class IngredientEditTableViewController: UITableViewController, UITextFieldDelegate  {

    @IBOutlet weak var ingredientName: CustomTextField!
    @IBOutlet weak var category: CustomSegmentedControl!
    @IBOutlet weak var stock: M13Checkbox!
    @IBOutlet weak var memo: CustomTextView!
    
    weak var detailVC : IngredientDetailTableViewController?
    var ingredient = Ingredient()
    var isAddMode = true
    let openTime = Date()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

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
        ingredientName.layer.cornerRadius = 5.0
        ingredientName.layer.borderWidth = 1

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

        let safeAreaBottom: CGFloat = 0.0
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ingredientName.layer.borderColor = Style.memoBorderColor.cgColor
        category.layer.cornerRadius = 14.0
        category.layer.borderColor = Style.secondaryColor.cgColor
        category.layer.borderWidth = 1.0
        category.layer.masksToBounds = true        
        stock.secondaryTintColor = Style.checkboxSecondaryTintColor
        memo.layer.borderColor = Style.memoBorderColor.cgColor
        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black

        memo.keyboardAppearance = Style.isDark ? .dark : .default
        
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
        if indexPath.row < 3{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }else{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if Date().timeIntervalSince(openTime) < 3 {
            _ = detailVC?.navigationController?.popViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
        }else{
            let alertView = CustomAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "はい",style: .default){ action in
                _ = self.detailVC?.navigationController?.popViewController(animated: false)
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(UIAlertAction(title: "いいえ", style: .cancel){ action in })
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }
    }
    
    func presentAlert(_ message: String){
        let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
        alertView.alertStatusBarStyle = Style.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if ingredientName.text == nil || textWithoutSpace(text: ingredientName.text!) == ""{
            presentAlert("材料名を入力してください")
        }else if textWithoutSpace(text: ingredientName.text!).count > 30{
            presentAlert("材料名を30文字以下にしてください")
        }else if memo.text.count > 300{
            presentAlert("メモを300文字以下にしてください")
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", textWithoutSpace(text: ingredientName.text!))
                if sameNameIngredient.count != 0{
                    presentAlert("同じ名前の材料が既に登録されています")
                }else{
                    let newIngredient = Ingredient()
                    newIngredient.ingredientName = textWithoutSpace(text: ingredientName.text!)
                    newIngredient.category = category.selectedSegmentIndex
                    if stock.checkState == .checked{
                        newIngredient.stockFlag = true
                    }else{
                        newIngredient.stockFlag = false
                    }
                    newIngredient.memo = memo.text
                    try! realm.write {
                        realm.add(newIngredient)
                        SVProgressHUD.showSuccess(withStatus: "材料を登録しました")
                    }
                    detailVC?.ingredientId = newIngredient.id
                    if detailVC == nil{
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        detailVC!.closeEditVC(self)
                    }
                }
            }else{
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@",textWithoutSpace(text: ingredientName.text!))
                if sameNameIngredient.count != 0 && ingredient.ingredientName != textWithoutSpace(text: ingredientName.text!){
                    presentAlert("同じ名前の材料が既に登録されています")
                }else{
                    try! realm.write {
                        ingredient.ingredientName = textWithoutSpace(text: ingredientName.text!)
                        ingredient.category = category.selectedSegmentIndex
                        if stock.checkState == .checked{
                            ingredient.stockFlag = true
                        }else{
                            ingredient.stockFlag = false
                        }
                        ingredient.memo = memo.text
                        for ri in ingredient.recipeIngredients{
                            ri.recipe.updateShortageNum()
                        }
                        SVProgressHUD.showSuccess(withStatus: "材料を保存しました")
                    }
                    detailVC?.ingredientId = ingredient.id
                    if detailVC == nil{
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        detailVC!.closeEditVC(self)
                    }
                }
            }
        }
    }

    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
