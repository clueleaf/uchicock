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
    let memoMaximum = 30
    var isAddMode = true
    var showCancelAlert = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            category.selectedSegmentTintColor = .clear
        }

        if ingredient.ingredientName == "" {
            self.navigationItem.title = "材料登録"
            isAddMode = true
        } else {
            self.navigationItem.title = "材料編集"
            isAddMode = false
        }

        ingredientName.text = ingredient.ingredientName
        ingredientName.layer.cornerRadius = ingredientName.frame.size.height / 2
        ingredientName.attributedPlaceholder = NSAttributedString(string: "材料名", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientName.adjustClearButtonColor(with: 4)
        ingredientName.clipsToBounds = true
        ingredientName.setLeftPadding()

        ingredientNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
        ingredientNameYomi.text = ingredient.ingredientNameYomi
        ingredientNameYomi.layer.cornerRadius = ingredientNameYomi.frame.size.height / 2
        ingredientNameYomi.attributedPlaceholder = NSAttributedString(string: "材料名（ヨミガナ）", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientNameYomi.clipsToBounds = true
        ingredientNameYomi.setLeftPadding()

        stock.boxLineWidth = 1.0
        stock.stateChangeAnimation = .expand
        if ingredient.stockFlag{
            stock.setCheckState(.checked, animated: true)
        }else{
            stock.setCheckState(.unchecked, animated: true)
        }

        memo.text = ingredient.memo
        memo.backgroundColor = UchicockStyle.basicBackgroundColorLight
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 0
        memo.keyboardAppearance = UchicockStyle.isDark ? .dark : .light
        memo.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        NotificationCenter.default.addObserver(self, selector:#selector(IngredientEditTableViewController.ingredientNameTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientName)
        NotificationCenter.default.addObserver(self, selector: #selector(IngredientEditTableViewController.ingredientNameTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientName)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientEditTableViewController.ingredientNameYomiTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientNameYomi)
        NotificationCenter.default.addObserver(self, selector: #selector(IngredientEditTableViewController.ingredientNameYomiTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientNameYomi)

        category.layer.borderColor = UchicockStyle.primaryColor.cgColor
        category.layer.borderWidth = 1.0
        category.layer.masksToBounds = true
        stock.secondaryTintColor = UchicockStyle.primaryColor
        stock.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        
        if ingredient.category >= 0 && ingredient.category < 3 {
            category.selectedSegmentIndex = ingredient.category
        } else {
            category.selectedSegmentIndex = 2
        }
        
        setTextFieldColor(textField: ingredientName, maximum: ingredientNameMaximum)
        setTextFieldColor(textField: ingredientNameYomi, maximum: ingredientNameYomiMaximum)
        setTextViewColor(textView: memo, maximum: memoMaximum)
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
        showCancelAlert = true
        updateIngredientNameCounter()
        updateIngredientNameYomiCounter()
        setTextFieldColor(textField: ingredientName, maximum: ingredientNameMaximum)
        setTextFieldColor(textField: ingredientNameYomi, maximum: ingredientNameYomiMaximum)
    }
    
    @objc func ingredientNameYomiTextFieldDidChange(_ notification: Notification){
        showCancelAlert = true
        updateIngredientNameYomiCounter()
        setTextFieldColor(textField: ingredientNameYomi, maximum: ingredientNameYomiMaximum)
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
        let num = memo.text.count
        memoCounter.text = String(num) + "/" + String(memoMaximum)
            
        if num > memoMaximum{
            memoCounter.textColor = UchicockStyle.alertColor
        }else{
            memoCounter.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    private func setTextViewColor(textView: UITextView, maximum: Int){
        if textView.text!.count > maximum {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UchicockStyle.alertColor.cgColor
            textView.tintColor = UchicockStyle.alertColor
            textView.textColor = UchicockStyle.alertColor
        }else{
            textView.layer.borderWidth = 0
            textView.layer.borderColor = UIColor.clear.cgColor
            textView.tintColor = UchicockStyle.labelTextColor
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
    
    private func presentAlert(title: String, message: String?){
        let alertView = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if ingredientName.text == nil || ingredientName.text!.withoutEndsSpace() == ""{
            presentAlert(title: "材料名を入力してください", message: nil)
        }else if ingredientName.text!.withoutEndsSpace().count > ingredientNameMaximum{
            presentAlert(title: "材料名を" + String(ingredientNameMaximum) + "文字以下にしてください", message: nil)
        }else if ingredientNameYomi.text == nil || ingredientNameYomi.text!.withoutEndsSpace() == ""{
            presentAlert(title: "ヨミガナを入力してください", message: nil)
        }else if ingredientNameYomi.text!.withoutEndsSpace().count > ingredientNameYomiMaximum{
            presentAlert(title: "ヨミガナを" + String(ingredientNameYomiMaximum) + "文字以下にしてください", message: nil)
        }else if memo.text.count > memoMaximum{
            presentAlert(title: "メモを" + String(memoMaximum) + "文字以下にしてください", message: nil)
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", ingredientName.text!.withoutEndsSpace())
                if sameNameIngredient.count != 0{
                    presentAlert(title: "同じ名前の材料が既に登録されています", message: "材料名を変更してください")
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
                    presentAlert(title: "同じ名前の材料が既に登録されています", message: "材料名を変更してください")
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
