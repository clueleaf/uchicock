//
//  IngredientEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientEditTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var ingredientName: CustomTextField!
    @IBOutlet weak var ingredientNameCounter: UILabel!
    @IBOutlet weak var ingredientNameYomiLabel: UILabel!
    @IBOutlet weak var ingredientNameYomi: CustomTextField!
    @IBOutlet weak var ingredientNameYomiCounter: UILabel!
    @IBOutlet weak var category: CustomSegmentedControl!
    @IBOutlet weak var stock: CircularCheckbox!
    @IBOutlet weak var memo: CustomTextView!
    @IBOutlet weak var memoCounter: UILabel!
    
    weak var mainNavigationController : BasicNavigationController?
    
    var ingredient = Ingredient()

    let ingredientNameMaximum = 30
    let ingredientNameYomiMaximum = 50
    let memoMaximum = 300
    var isAddMode = true
    var showCancelAlert = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
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
        ingredientName.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        ingredientName.attributedPlaceholder = NSAttributedString(string: "材料名", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientName.adjustClearButtonColor(with: 4)

        ingredientNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
        ingredientNameYomi.text = ingredient.ingredientNameYomi
        ingredientNameYomi.delegate = self
        ingredientNameYomi.layer.cornerRadius = 5.0
        ingredientNameYomi.layer.borderWidth = 1
        ingredientNameYomi.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        ingredientNameYomi.attributedPlaceholder = NSAttributedString(string: "材料名（ヨミガナ）", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])

        stock.boxLineWidth = 1.0
        stock.stateChangeAnimation = .expand
        if ingredient.stockFlag{
            stock.setCheckState(.checked, animated: true)
        }else{
            stock.setCheckState(.unchecked, animated: true)
        }

        memo.text = ingredient.memo
        memo.delegate = self
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.labelTextColorLight
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        NotificationCenter.default.addObserver(self, selector:#selector(IngredientEditTableViewController.ingredientNameTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientName)
        NotificationCenter.default.addObserver(self, selector: #selector(IngredientEditTableViewController.ingredientNameTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientName)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientEditTableViewController.ingredientNameYomiTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientNameYomi)
        NotificationCenter.default.addObserver(self, selector: #selector(IngredientEditTableViewController.ingredientNameYomiTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientNameYomi)

        if #available(iOS 13.0, *) {
        }else{
            category.layer.cornerRadius = 14.0
        }
        category.layer.borderColor = UchicockStyle.primaryColor.cgColor
        category.layer.borderWidth = 1.0
        category.layer.masksToBounds = true
        stock.secondaryTintColor = UchicockStyle.primaryColor
        stock.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        memo.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        memo.keyboardAppearance = UchicockStyle.isDark ? .dark : .light
        
        if ingredient.category >= 0 && ingredient.category < 3 {
            category.selectedSegmentIndex = ingredient.category
        } else {
            category.selectedSegmentIndex = 2
        }
        
        updateIngredientNameCounter()
        updateIngredientNameYomiCounter()
        updateMemoCounter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAddMode{
            ingredientName.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        ingredientNameYomi.resignFirstResponder()
        return true
    }
    
    @objc func ingredientNameTextFieldDidChange(_ notification: Notification){
        ingredientName.adjustClearButtonColor(with: 4)
        ingredientNameYomi.text = ingredientName.text!.convertToYomi()
        ingredientNameYomi.adjustClearButtonColor(with: 4)
        showCancelAlert = true
        updateIngredientNameCounter()
        updateIngredientNameYomiCounter()
    }
    
    @objc func ingredientNameYomiTextFieldDidChange(_ notification: Notification){
        ingredientNameYomi.adjustClearButtonColor(with: 4)
        showCancelAlert = true
        updateIngredientNameYomiCounter()
    }
    
    private func updateIngredientNameCounter(){
        let num = ingredientName.text!.withoutEndsSpace().count
        ingredientNameCounter.text = String(num) + "/" + String(ingredientNameMaximum)
        
        if num > ingredientNameMaximum{
            ingredientNameCounter.textColor = UchicockStyle.alertColor
        }else{
            ingredientNameCounter.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    private func updateIngredientNameYomiCounter(){
        let num = ingredientNameYomi.text!.withoutEndsSpace().count
        ingredientNameYomiCounter.text = String(num) + "/" + String(ingredientNameYomiMaximum)
        
        if num > ingredientNameYomiMaximum{
            ingredientNameYomiCounter.textColor = UchicockStyle.alertColor
        }else{
            ingredientNameYomiCounter.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        showCancelAlert = true
        updateMemoCounter()
    }
    
    private func updateMemoCounter(){
        let num = memo.text.count
        memoCounter.text = String(num) + "/" + String(memoMaximum)
            
        if num > memoMaximum{
            memoCounter.textColor = UchicockStyle.alertColor
        }else{
            memoCounter.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UchicockStyle.basicBackgroundColor
        if indexPath.row < 3{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
        }else{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if showCancelAlert {
            let alertView = CustomAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "はい",style: .default){ action in
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(UIAlertAction(title: "いいえ", style: .cancel){ action in })
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func presentAlert(_ message: String){
        let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if ingredientName.text == nil || ingredientName.text!.withoutEndsSpace() == ""{
            presentAlert("材料名を入力してください")
        }else if ingredientName.text!.withoutEndsSpace().count > ingredientNameMaximum{
            presentAlert("材料名を" + String(ingredientNameMaximum) + "文字以下にしてください")
        }else if ingredientNameYomi.text == nil || ingredientNameYomi.text!.withoutEndsSpace() == ""{
            presentAlert("ヨミガナを入力してください")
        }else if ingredientNameYomi.text!.withoutEndsSpace().count > ingredientNameYomiMaximum{
            presentAlert("ヨミガナを" + String(ingredientNameYomiMaximum) + "文字以下にしてください")
        }else if memo.text.count > memoMaximum{
            presentAlert("メモを" + String(memoMaximum) + "文字以下にしてください")
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", ingredientName.text!.withoutEndsSpace())
                if sameNameIngredient.count != 0{
                    presentAlert("同じ名前の材料が既に登録されています")
                }else{
                    let newIngredient = Ingredient()
                    newIngredient.ingredientName = ingredientName.text!.withoutEndsSpace()
                    newIngredient.ingredientNameYomi = ingredientNameYomi.text!.withoutEndsSpace()
                    newIngredient.katakanaLowercasedNameForSearch = ingredientNameYomi.text!.katakanaLowercasedForSearch()
                    newIngredient.category = category.selectedSegmentIndex
                    if stock.checkState == .checked{
                        newIngredient.stockFlag = true
                    }else{
                        newIngredient.stockFlag = false
                    }
                    newIngredient.memo = memo.text
                    try! realm.write {
                        realm.add(newIngredient)
                        MessageHUD.show("材料を登録しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                    let detailVC = UIStoryboard(name: "IngredientDetail", bundle: nil).instantiateViewController(withIdentifier: "IngredientDetail") as! IngredientDetailTableViewController
                    detailVC.ingredientId = newIngredient.id
                    
                    if mainNavigationController != nil {
                        mainNavigationController!.pushViewController(detailVC, animated: false)
                        detailVC.closeEditVC(self)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }else{
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", ingredientName.text!.withoutEndsSpace())
                if sameNameIngredient.count != 0 && ingredient.ingredientName != ingredientName.text!.withoutEndsSpace(){
                    presentAlert("同じ名前の材料が既に登録されています")
                }else{
                    try! realm.write {
                        ingredient.ingredientName = ingredientName.text!.withoutEndsSpace()
                        ingredient.ingredientNameYomi = ingredientNameYomi.text!.withoutEndsSpace()
                        ingredient.katakanaLowercasedNameForSearch = ingredientNameYomi.text!.katakanaLowercasedForSearch()
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
                        MessageHUD.show("材料を保存しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                    let detailVC = UIStoryboard(name: "IngredientDetail", bundle: nil).instantiateViewController(withIdentifier: "IngredientDetail") as! IngredientDetailTableViewController
                    detailVC.ingredientId = ingredient.id
                    
                    if mainNavigationController != nil {
                        mainNavigationController!.pushViewController(detailVC, animated: false)
                        detailVC.closeEditVC(self)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }                    
                }
            }
        }
    }
    
    @IBAction func stockCheckboxTapped(_ sender: CircularCheckbox) {
        showCancelAlert = true
    }
    
    @IBAction func categorySegmentedControlTapped(_ sender: CustomSegmentedControl) {
        showCancelAlert = true
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
