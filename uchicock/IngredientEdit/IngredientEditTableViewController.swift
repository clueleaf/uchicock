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

    @IBOutlet weak var ingredientNameTextField: CustomTextField!
    @IBOutlet weak var ingredientNameCounterLabel: UILabel!
    @IBOutlet weak var ingredientNameYomiLabel: UILabel!
    @IBOutlet weak var ingredientNameYomiTextField: CustomTextField!
    @IBOutlet weak var ingredientNameYomiCounterLabel: UILabel!
    @IBOutlet weak var stockCheckbox: CircularCheckbox!
    @IBOutlet weak var categorySegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var memoTextView: CustomTextView!
    @IBOutlet weak var memoCounterLabel: UILabel!
    
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
        }else{
            self.navigationItem.title = "材料編集"
            isAddMode = false
        }

        ingredientNameTextField.clearButtonEdgeInset = 4.0
        ingredientNameTextField.text = ingredient.ingredientName
        ingredientNameTextField.layer.cornerRadius = ingredientNameTextField.frame.size.height / 2
        ingredientNameTextField.attributedPlaceholder = NSAttributedString(string: "材料名", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientNameTextField.adjustClearButtonColor()
        ingredientNameTextField.setLeftPadding()

        ingredientNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
        ingredientNameYomiTextField.text = ingredient.ingredientNameYomi
        ingredientNameYomiTextField.layer.cornerRadius = ingredientNameYomiTextField.frame.size.height / 2
        ingredientNameYomiTextField.attributedPlaceholder = NSAttributedString(string: "材料名（ヨミガナ）", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientNameYomiTextField.setLeftPadding()
        ingredientNameYomiTextField.setRightPadding()

        stockCheckbox.boxLineWidth = 1.0
        stockCheckbox.stateChangeAnimation = .expand
        if ingredient.stockFlag{
            stockCheckbox.setCheckState(.checked, animated: true)
        }else{
            stockCheckbox.setCheckState(.unchecked, animated: true)
        }
        stockCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        stockCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        memoTextView.text = ingredient.memo
        memoTextView.backgroundColor = UchicockStyle.basicBackgroundColorLight
        memoTextView.layer.masksToBounds = true
        memoTextView.layer.cornerRadius = 12
        memoTextView.layer.borderWidth = 0
        memoTextView.keyboardAppearance = UchicockStyle.isKeyboardDark ? .dark : .light
        memoTextView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        NotificationCenter.default.addObserver(self, selector:#selector(IngredientEditTableViewController.ingredientNameTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientNameTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(IngredientEditTableViewController.ingredientNameTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientNameTextField)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientEditTableViewController.ingredientNameYomiTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientNameYomiTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(IngredientEditTableViewController.ingredientNameYomiTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientNameYomiTextField)

        categorySegmentedControl.layer.borderColor = UchicockStyle.primaryColor.cgColor
        categorySegmentedControl.layer.borderWidth = 1.0
        categorySegmentedControl.layer.masksToBounds = true
        
        if ingredient.category >= 0 && ingredient.category < 3 {
            categorySegmentedControl.selectedSegmentIndex = ingredient.category
        }else{
            categorySegmentedControl.selectedSegmentIndex = 2
        }
        
        setTextFieldColor(textField: ingredientNameTextField, maximum: ingredientNameMaximum)
        setTextFieldColor(textField: ingredientNameYomiTextField, maximum: ingredientNameYomiMaximum)
        setTextViewColor(textView: memoTextView, maximum: memoMaximum)
        updateIngredientNameCounter()
        updateIngredientNameYomiCounter()
        updateMemoCounter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAddMode{
            ingredientNameTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ingredientNameTextField.resignFirstResponder()
        ingredientNameYomiTextField.resignFirstResponder()
        return true
    }
    
    @objc func ingredientNameTextFieldDidChange(_ notification: Notification){
        ingredientNameTextField.adjustClearButtonColor()
        ingredientNameYomiTextField.text = ingredientNameTextField.text!.convertToYomi()
        showCancelAlert = true
        updateIngredientNameCounter()
        updateIngredientNameYomiCounter()
        setTextFieldColor(textField: ingredientNameTextField, maximum: ingredientNameMaximum)
        setTextFieldColor(textField: ingredientNameYomiTextField, maximum: ingredientNameYomiMaximum)
    }
    
    @objc func ingredientNameYomiTextFieldDidChange(_ notification: Notification){
        showCancelAlert = true
        updateIngredientNameYomiCounter()
        setTextFieldColor(textField: ingredientNameYomiTextField, maximum: ingredientNameYomiMaximum)
    }
    
    private func updateIngredientNameCounter(){
        let num = ingredientNameTextField.text!.withoutEndsSpace().count
        ingredientNameCounterLabel.text = String(num) + "/" + String(ingredientNameMaximum)
        
        if num > ingredientNameMaximum{
            ingredientNameCounterLabel.textColor = UchicockStyle.alertColor
        }else{
            ingredientNameCounterLabel.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    private func updateIngredientNameYomiCounter(){
        let num = ingredientNameYomiTextField.text!.withoutEndsSpace().count
        ingredientNameYomiCounterLabel.text = String(num) + "/" + String(ingredientNameYomiMaximum)
        
        if num > ingredientNameYomiMaximum{
            ingredientNameYomiCounterLabel.textColor = UchicockStyle.alertColor
        }else{
            ingredientNameYomiCounterLabel.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    private func setTextFieldColor(textField: UITextField, maximum: Int){
        if textField.text!.withoutEndsSpace().count > maximum {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UchicockStyle.alertColor.cgColor
            textField.textColor = UchicockStyle.alertColor
        }else{
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.textColor = UchicockStyle.labelTextColor
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        showCancelAlert = true
        updateMemoCounter()
        setTextViewColor(textView: textView, maximum: memoMaximum)
    }
    
    private func updateMemoCounter(){
        let num = memoTextView.text.count
        memoCounterLabel.text = String(num) + "/" + String(memoMaximum)
            
        if num > memoMaximum{
            memoCounterLabel.textColor = UchicockStyle.alertColor
        }else{
            memoCounterLabel.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    private func setTextViewColor(textView: UITextView, maximum: Int){
        if textView.text!.count > maximum {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UchicockStyle.alertColor.cgColor
            textView.textColor = UchicockStyle.alertColor
        }else{
            textView.layer.borderWidth = 0
            textView.layer.borderColor = UIColor.clear.cgColor
            textView.textColor = UchicockStyle.labelTextColor
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
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            let yesAction = UIAlertAction(title: "はい",style: .default){action in
                self.dismiss(animated: true, completion: nil)
            }
            yesAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
            alertView.addAction(yesAction)
            let noAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
            noAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
            alertView.addAction(noAction)
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func presentAlert(title: String, message: String?, action: (() -> Void)?){
        let alertView = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            alertView.overrideUserInterfaceStyle = .dark
        }
        let alertAction = UIAlertAction(title: "OK", style: .default){_ in
            action?()
        }
        alertAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        alertView.addAction(alertAction)
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        ingredientNameTextField.resignFirstResponder()
        ingredientNameYomiTextField.resignFirstResponder()
        memoTextView.resignFirstResponder()
        if ingredientNameTextField.text == nil || ingredientNameTextField.text!.withoutEndsSpace() == ""{
            presentAlert(title: "材料名を入力してください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.ingredientNameTextField.becomeFirstResponder()
            })
        }else if ingredientNameTextField.text!.withoutEndsSpace().count > ingredientNameMaximum{
            presentAlert(title: "材料名を" + String(ingredientNameMaximum) + "文字以下にしてください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.ingredientNameTextField.becomeFirstResponder()
            })
        }else if ingredientNameYomiTextField.text == nil || ingredientNameYomiTextField.text!.withoutEndsSpace() == ""{
            presentAlert(title: "ヨミガナを入力してください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.ingredientNameYomiTextField.becomeFirstResponder()
            })
        }else if ingredientNameYomiTextField.text!.withoutEndsSpace().count > ingredientNameYomiMaximum{
            presentAlert(title: "ヨミガナを" + String(ingredientNameYomiMaximum) + "文字以下にしてください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.ingredientNameYomiTextField.becomeFirstResponder()
            })
        }else if memoTextView.text.count > memoMaximum{
            presentAlert(title: "メモを" + String(memoMaximum) + "文字以下にしてください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .bottom, animated: true)
                self.memoTextView.becomeFirstResponder()
            })
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", ingredientNameTextField.text!.withoutEndsSpace())
                if sameNameIngredient.count != 0{
                    presentAlert(title: "同じ名前の材料が既に登録されています", message: "材料名を変更してください", action: {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        self.ingredientNameTextField.becomeFirstResponder()
                    })
                }else{
                    let newIngredient = Ingredient()
                    newIngredient.ingredientName = ingredientNameTextField.text!.withoutEndsSpace()
                    newIngredient.ingredientNameYomi = ingredientNameYomiTextField.text!.withoutEndsSpace()
                    newIngredient.katakanaLowercasedNameForSearch = ingredientNameYomiTextField.text!.katakanaLowercasedForSearch()
                    newIngredient.category = categorySegmentedControl.selectedSegmentIndex
                    if stockCheckbox.checkState == .checked{
                        newIngredient.stockFlag = true
                    }else{
                        newIngredient.stockFlag = false
                    }
                    newIngredient.memo = memoTextView.text
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
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", ingredientNameTextField.text!.withoutEndsSpace())
                if sameNameIngredient.count != 0 && ingredient.ingredientName != ingredientNameTextField.text!.withoutEndsSpace(){
                    presentAlert(title: "同じ名前の材料が既に登録されています", message: "材料名を変更してください", action: {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        self.ingredientNameTextField.becomeFirstResponder()
                    })
                }else{
                    try! realm.write {
                        ingredient.ingredientName = ingredientNameTextField.text!.withoutEndsSpace()
                        ingredient.ingredientNameYomi = ingredientNameYomiTextField.text!.withoutEndsSpace()
                        ingredient.katakanaLowercasedNameForSearch = ingredientNameYomiTextField.text!.katakanaLowercasedForSearch()
                        ingredient.category = categorySegmentedControl.selectedSegmentIndex
                        if stockCheckbox.checkState == .checked{
                            ingredient.stockFlag = true
                        }else{
                            ingredient.stockFlag = false
                        }
                        ingredient.memo = memoTextView.text
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
