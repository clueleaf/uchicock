//
//  RecipeIngredientEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/09.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeIngredientEditTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var ingredientNameTextField: CustomTextField!
    @IBOutlet weak var suggestTableViewCell: UITableViewCell!
    @IBOutlet weak var suggestTableView: UITableView!
    @IBOutlet weak var amountTextField: CustomTextField!
    @IBOutlet weak var amountSlider: CustomSlider!
    @IBOutlet weak var optionCheckbox: CircularCheckbox!
    @IBOutlet weak var optionDescriptionLabel: UILabel!
    @IBOutlet weak var deleteTableViewCell: UITableViewCell!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var recipeIngredient = RecipeIngredientBasic(
        ingredientId: "",
        ingredientName: "",
        ingredientNameYomi: "",
        katakanaLowercasedNameForSearch: "",
        amount: "",
        mustFlag: true,
        category: -1,
        displayOrder: -1,
        stockFlag: false
    )
    var ingredientList: Results<Ingredient>?

    var editType = RecipeIngredientEditType.cancel
    var firstShow = false
    var suggestList = Array<IngredientSuggestBasic>()
    let selectedCellBackgroundView = UIView()
    
    var interactor: Interactor?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    var onDoneBlock: ((RecipeIngredientEditType, String, String, Int, Bool) -> Void) = {editType, ingredientName, amount, category, mustFlag in }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if interactor != nil{
            tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }

        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)

        ingredientNameTextField.tag = 0
        amountTextField.tag = 1
        self.tableView.tag = 0
        suggestTableView.tag = 1
        
        optionCheckbox.boxLineWidth = 1.0
        optionCheckbox.stateChangeAnimation = .expand
        optionCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        optionCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        optionDescriptionLabel.textColor = UchicockStyle.labelTextColorLight

        if recipeIngredient.ingredientName == ""{
            self.navigationItem.title = "材料の追加"
            optionCheckbox.setCheckState(.unchecked, animated: true)
            deleteLabel.text = "材料の追加をやめる"
        }else{
            self.navigationItem.title = "材料の変更"
            ingredientNameTextField.text = recipeIngredient.ingredientName
            amountTextField.text = recipeIngredient.amount
            if recipeIngredient.mustFlag{
                optionCheckbox.setCheckState(.unchecked, animated: true)
            }else{
                optionCheckbox.setCheckState(.checked, animated: true)
            }
            deleteLabel.text = "このレシピの材料から外す"
        }
        
        ingredientNameTextField.layer.cornerRadius = ingredientNameTextField.frame.size.height / 2
        ingredientNameTextField.clearButtonEdgeInset = 4.0
        ingredientNameTextField.attributedPlaceholder = NSAttributedString(string: "材料名", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientNameTextField.adjustClearButtonColor()
        ingredientNameTextField.setLeftPadding()
        
        amountTextField.layer.cornerRadius = amountTextField.frame.size.height / 2
        amountTextField.clearButtonEdgeInset = 4.0
        amountTextField.attributedPlaceholder = NSAttributedString(string: "分量", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        amountTextField.adjustClearButtonColor()
        amountTextField.setLeftPadding()
        
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeIngredientEditTableViewController.nameTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientNameTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeIngredientEditTableViewController.nameTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientNameTextField)
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeIngredientEditTableViewController.amountTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.amountTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeIngredientEditTableViewController.amountTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.amountTextField)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        self.tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        suggestTableView.tableFooterView = UIView(frame: CGRect.zero)
        suggestTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        suggestTableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        suggestTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        deleteLabel.textColor = UchicockStyle.alertColor
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if recipeIngredient.ingredientName == "" && firstShow == false{
            ingredientNameTextField.becomeFirstResponder()
            firstShow = true
        }
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDoneBlock(self.editType, self.ingredientNameTextField.text!.withoutEndsSpace(), self.amountTextField.text!.withoutEndsSpace(), self.recipeIngredient.category, (self.optionCheckbox.checkState != .checked))
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Logic functions
    private func reloadSuggestList(){
        suggestList.removeAll()
        
        let searchText = ingredientNameTextField.text!.withoutMiddleSpaceAndMiddleDot()
        let convertedSearchText = ingredientNameTextField.text!.convertToYomi().katakanaLowercasedForSearch()
        for ingredient in ingredientList! {
            if searchText == "" ||
                ingredient.katakanaLowercasedNameForSearch.contains(convertedSearchText) ||
                    ingredient.ingredientName.contains(searchText){
                let suggest = IngredientSuggestBasic(
                    name: ingredient.ingredientName,
                    nameYomi: ingredient.ingredientNameYomi,
                    katakanaLowercasedNameForSearch: "",
                    stockFlag: false,
                    category: ingredient.category
                )
                suggestList.append(suggest)
            }
        }
        
        suggestList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        suggestTableView.reloadData()
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ingredientNameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField.tag == 0{
            tableView.insertRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
            reloadSuggestList()
        }
    }
    
    @objc func nameTextFieldDidChange(_ notification: Notification){
        ingredientNameTextField.adjustClearButtonColor()
        reloadSuggestList()
    }
    
    @objc func amountTextFieldDidChange(_ notification: Notification){
        amountTextField.adjustClearButtonColor()
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        if textField.tag == 0{
            suggestList.removeAll()
            suggestTableView.reloadData()
            tableView.deleteRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let int = interactor, int.hasStarted { scrollView.contentOffset.y = 0.0 }
    }
    
    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 0{
            return 2
        }else if tableView.tag == 1{
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 && section == 0{
            return 30
        }else if tableView.tag == 0 && section == 1{
            return 30
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = (tableView.tag == 1 && section == 0) ? "材料候補" : ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            if ingredientNameTextField.isFirstResponder{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }else{
                if indexPath == IndexPath(row: 1, section: 0){
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 2, section: 0))
                }else{
                    return super.tableView(tableView, heightForRowAt: indexPath)
                }
            }
        }else if tableView.tag == 1{
            return 30
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            if section == 0{
                return ingredientNameTextField.isFirstResponder ? 3 : 2
            }else if section == 1{
                return 1
            }
        }else if tableView.tag == 1{
            return suggestList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 && indexPath == IndexPath(row: 0, section: 1){
            let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            var title = "外す"
            if recipeIngredient.ingredientName == "" {
                title = "追加をやめる"
            }
            let stopAction = UIAlertAction(title: title ,style: .destructive){action in
                self.editType = self.recipeIngredient.ingredientName == "" ? .cancel : .remove
                self.dismiss(animated: true, completion: nil)
            }
            if #available(iOS 13.0, *){ stopAction.setValue(UchicockStyle.alertColor, forKey: "titleTextColor") }
            alertView.addAction(stopAction)
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
            alertView.addAction(cancelAction)
            
            alertView.popoverPresentationController?.sourceView = self.view
            alertView.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: indexPath)!.frame
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }else if tableView.tag == 1{
            tableView.deselectRow(at: indexPath, animated: true)
            ingredientNameTextField.text = suggestList[indexPath.row].name
            ingredientNameTextField.adjustClearButtonColor()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            if ingredientNameTextField.isFirstResponder || indexPath != IndexPath(row: 1, section: 0){
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                if indexPath.section == 0{
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                }else{
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
                return cell
            }else{
                let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: 0))
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                return cell
            }
        }else if tableView.tag == 1 && indexPath.section == 0{
            let cell = suggestTableView.dequeueReusableCell(withIdentifier: "SuggestIngredient") as! SuggestIngredientTableViewCell
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.ingredient = suggestList[indexPath.row]
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - GestureRecognizer
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        guard let interactor = interactor else { return }
        let percentThreshold: CGFloat = 0.3
        
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        if tableView.contentOffset.y <= 0 || interactor.hasStarted{
            switch sender.state {
            case .began:
                interactor.hasStarted = true
                dismiss(animated: true, completion: nil)
            case .changed:
                interactor.shouldFinish = progress > percentThreshold
                interactor.update(progress)
                break
            case .cancelled:
                interactor.hasStarted = false
                interactor.cancel()
            case .ended:
                interactor.hasStarted = false
                interactor.shouldFinish ? interactor.finish() : interactor.cancel()
            default:
                break
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        if touch.view!.isDescendant(of: deleteTableViewCell) ||
            touch.view!.isDescendant(of: suggestTableViewCell){
            return false
        }
        return true
    }
    
    // MARK: - IBAction
    @IBAction func amountSliderValueChanged(_ sender: UISlider) {
        switch floor(sender.value) {
        case 0:
            amountTextField.text = "少々"
        case 1..<13:
            amountTextField.text = String(Int(floor(sender.value) * 5)) + "ml"
        default:
            amountTextField.text = "適量"
        }
        amountTextField.adjustClearButtonColor()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        editType = .cancel
        self.dismiss(animated: true, completion: nil)
    }
    
    private func presentAlert(_ message: String, action: (() -> Void)?){
        let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            alertView.overrideUserInterfaceStyle = .dark
        }
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            action?()
        })
        if #available(iOS 13.0, *){ alertAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(alertAction)
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    private func dismissSelf(withNewIngredientCategory categoryNum: Int){
        let name = self.ingredientNameTextField.text!.withoutEndsSpace()
        let ingredient = Ingredient()
        ingredient.ingredientName = name
        ingredient.ingredientNameYomi = name.convertToYomi()
        ingredient.katakanaLowercasedNameForSearch = name.convertToYomi().katakanaLowercasedForSearch()
        ingredient.stockFlag = false
        ingredient.memo = ""
        ingredient.category = categoryNum
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(ingredient)
            MessageHUD.show("材料を登録しました", for: 2.0, withCheckmark: true, isCenter: true)
        }
        self.recipeIngredient.category = categoryNum
        self.editType = self.recipeIngredient.ingredientName == "" ? .add : .edit
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        ingredientNameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        guard ingredientNameTextField.text!.withoutEndsSpace() != "" else{
            presentAlert("材料名を入力してください", action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.ingredientNameTextField.becomeFirstResponder()
            })
            return
        }
        guard ingredientNameTextField.text!.withoutEndsSpace().count <= 30 else{
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            presentAlert("材料名を30文字以下にしてください", action: {
                self.ingredientNameTextField.becomeFirstResponder()
            })
            return
        }
        guard amountTextField.text!.withoutEndsSpace().count <= 30 else{
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            presentAlert("分量を30文字以下にしてください", action: {
                self.amountTextField.becomeFirstResponder()
            })
            return
        }
        
        let realm = try! Realm()
        let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@", ingredientNameTextField.text!.withoutEndsSpace())
        guard sameNameIngredient.count == 0 else{
            self.recipeIngredient.category = sameNameIngredient.first!.category
            self.editType = self.recipeIngredient.ingredientName == "" ? .add : .edit
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        //同じ名前の材料が存在しないので新規に登録する
        let registAlertView = CustomAlertController(title: nil, message: "この材料はまだ登録されていないので、新たに登録します", preferredStyle: .alert)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            registAlertView.overrideUserInterfaceStyle = .dark
        }
        let alcoholAction = UIAlertAction(title: "「アルコール」として登録", style: .default){action in
            self.dismissSelf(withNewIngredientCategory: 0)
        }
        if #available(iOS 13.0, *){ alcoholAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        registAlertView.addAction(alcoholAction)
        let nonAlcoholAction = UIAlertAction(title: "「ノンアルコール」として登録", style: .default){action in
            self.dismissSelf(withNewIngredientCategory: 1)
        }
        if #available(iOS 13.0, *){ nonAlcoholAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        registAlertView.addAction(nonAlcoholAction)
        let othersAction = UIAlertAction(title: "「その他」として登録", style: .default, handler: {action in
            self.dismissSelf(withNewIngredientCategory: 2)
        })
        if #available(iOS 13.0, *){ othersAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        registAlertView.addAction(othersAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        registAlertView.addAction(cancelAction)
        registAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        registAlertView.modalPresentationCapturesStatusBarAppearance = true
        present(registAlertView, animated: true, completion: nil)
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}
