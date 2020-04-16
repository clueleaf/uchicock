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

    @IBOutlet weak var ingredientName: CustomTextField!
    @IBOutlet weak var suggestTableViewCell: UITableViewCell!
    @IBOutlet weak var suggestTableView: UITableView!
    @IBOutlet weak var amount: CustomTextField!
    @IBOutlet weak var amountSlider: CustomSlider!
    @IBOutlet weak var option: CircularCheckbox!
    @IBOutlet weak var optionDescriptionLabel: UILabel!
    @IBOutlet weak var deleteTableViewCell: UITableViewCell!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var recipeIngredient = RecipeIngredientBasic(recipeIngredientId: "", ingredientId: "", ingredientName: "", amount: "", mustFlag: true, category: -1, displayOrder: -1, stockFlag: false)
    var ingredientList: Results<Ingredient>?

    var isCancel = true
    var isAddMode = false
    var alreadyShowedOnce = false
    var deleteFlag = false
    var isTypingName = false
    var suggestList = Array<IngredientSuggestBasic>()
    let selectedCellBackgroundView = UIView()
    
    var interactor: Interactor?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    var onDoneBlock: ((Bool, Bool, Bool, String, String, Int, Bool, String) -> Void) = {isCancel, deleteFlag, isAddMode, ingredientName, amount, category, mustFlag, recipeIngredientId in }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if interactor != nil{
            tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }

        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)

        ingredientName.tag = 0
        amount.tag = 1
        self.tableView.tag = 0
        suggestTableView.tag = 1
        
        ingredientName.layer.cornerRadius = 5.0
        ingredientName.layer.borderWidth = 1
        amount.layer.cornerRadius = 5.0
        amount.layer.borderWidth = 1
        
        option.boxLineWidth = 1.0
        option.stateChangeAnimation = .expand
        
        if isAddMode == false{
            ingredientName.text = recipeIngredient.ingredientName
            amount.text = recipeIngredient.amount
            if recipeIngredient.mustFlag{
                option.setCheckState(.unchecked, animated: true)
            }else{
                option.setCheckState(.checked, animated: true)
            }
            self.navigationItem.title = "材料の変更"
            deleteLabel.text = "このレシピの材料から外す"
        }else{
            option.setCheckState(.unchecked, animated: true)
            self.navigationItem.title = "材料の追加"
            deleteLabel.text = "材料の追加をやめる"
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        suggestTableView.tableFooterView = UIView(frame: CGRect.zero)
                
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeIngredientEditTableViewController.nameTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.ingredientName)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeIngredientEditTableViewController.nameTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.ingredientName)
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeIngredientEditTableViewController.amountTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.amount)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeIngredientEditTableViewController.amountTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.amount)
        
        self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        self.tableView.separatorColor = UchicockStyle.labelTextColorLight
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        self.suggestTableView.backgroundColor = UchicockStyle.basicBackgroundColor
        self.suggestTableView.separatorColor = UchicockStyle.labelTextColorLight
        self.suggestTableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        ingredientName.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        ingredientName.attributedPlaceholder = NSAttributedString(string: "材料名", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        ingredientName.adjustClearButtonColor(with: 4)
        amount.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        amount.attributedPlaceholder = NSAttributedString(string: "分量", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        amount.adjustClearButtonColor(with: 4)
        option.secondaryTintColor = UchicockStyle.primaryColor
        option.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        optionDescriptionLabel.textColor = UchicockStyle.labelTextColorLight
        deleteLabel.textColor = UchicockStyle.alertColor
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAddMode && alreadyShowedOnce == false{
            ingredientName.becomeFirstResponder()
            alreadyShowedOnce = true
        }
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock(self.isCancel, self.deleteFlag, self.isAddMode, self.ingredientName.text!.withoutSpace(), self.amount.text!.withoutSpace(), self.recipeIngredient.category, (self.option.checkState != .checked), self.recipeIngredient.recipeIngredientId)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        amount.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField.tag == 0{
            isTypingName = true
            tableView.insertRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
            reloadSuggestList()
        }
    }
    
    @objc func nameTextFieldDidChange(_ notification: Notification){
        ingredientName.adjustClearButtonColor(with: 4)
        reloadSuggestList()
    }
    
    @objc func amountTextFieldDidChange(_ notification: Notification){
        amount.adjustClearButtonColor(with: 4)
    }

    func reloadSuggestList(){
        suggestList.removeAll()
        
        for ingredient in ingredientList! {
            let suggest = IngredientSuggestBasic(name: ingredient.ingredientName, katakanaLowercasedNameForSearch: ingredient.katakanaLowercasedNameForSearch, category: ingredient.category)
            suggestList.append(suggest)
        }
        
        if ingredientName.text!.withoutSpaceAndMiddleDot() != ""{
            suggestList.removeAll{
                !$0.katakanaLowercasedNameForSearch.contains(ingredientName.text!.katakanaLowercasedForSearch())
            }
        }
        
        suggestList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
        suggestTableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        if textField.tag == 0{
            suggestList.removeAll()
            suggestTableView.reloadData()
            isTypingName = false
            tableView.deleteRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
        }
    }
    
    // MARK: - UITableView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if interactor != nil{
            if interactor!.hasStarted {
                tableView.contentOffset.y = 0.0
            }
        }
    }

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
        view.tintColor = UchicockStyle.tableViewHeaderBackgroundColor
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.tableViewHeaderTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = (tableView.tag == 1 && section == 0) ? "材料候補" : ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            if isTypingName{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }else{
                if indexPath.section == 0 && indexPath.row > 0{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: indexPath.row + 1, section: 0))
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
                if isTypingName{
                    return 4
                }else{
                    return 3
                }
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
        if tableView.tag == 0 && indexPath.section == 1 && indexPath.row == 0{
            if isAddMode{
                let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertView.addAction(UIAlertAction(title: "追加をやめる",style: .destructive){
                    action in
                    self.deleteFlag = true
                    self.isCancel = false
                    self.dismiss(animated: true, completion: nil)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                alertView.popoverPresentationController?.sourceView = self.view
                alertView.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: indexPath)!.frame
                alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                alertView.modalPresentationCapturesStatusBarAppearance = true
                present(alertView, animated: true, completion: nil)
            }else{
                let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertView.addAction(UIAlertAction(title: "外す",style: .destructive){
                    action in
                    self.deleteFlag = true
                    self.isCancel = false
                    self.dismiss(animated: true, completion: nil)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                alertView.popoverPresentationController?.sourceView = self.view
                alertView.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: indexPath)!.frame
                alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                alertView.modalPresentationCapturesStatusBarAppearance = true
                present(alertView, animated: true, completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }else if tableView.tag == 1{
            tableView.deselectRow(at: indexPath, animated: true)
            ingredientName.text = suggestList[indexPath.row].name
            ingredientName.adjustClearButtonColor(with: 4)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            if isTypingName{
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
                if indexPath.section == 0 && indexPath.row > 0{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: 0))
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: indexPath)
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    if indexPath.section == 0{
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                    }else{
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    }
                    return cell
                }
            }
        }else if tableView.tag == 1 && indexPath.section == 0{
            let cell = suggestTableView.dequeueReusableCell(withIdentifier: "SuggestIngredient") as! SuggestIngredientTableViewCell
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.name = suggestList[indexPath.row].name
            cell.category = suggestList[indexPath.row].category
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
                interactor.shouldFinish
                    ? interactor.finish()
                    : interactor.cancel()
            default:
                break
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if touch.view!.isDescendant(of: deleteTableViewCell) {
            return false
        }else if touch.view!.isDescendant(of: suggestTableViewCell){
            return false
        }
        return true
    }
    
    // MARK: - IBAction
    @IBAction func amountSliderValueChanged(_ sender: UISlider) {
        amount.adjustClearButtonColor(with: 4)
        switch floor(sender.value) {
        case 0:
            amount.text = "少々"
        case 1..<13:
            amount.text = String(Int(floor(sender.value) * 5)) + "ml"
        default:
            amount.text = "適量"
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.isCancel = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert(_ message: String){
        let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    private func setIngredient(_ categoryNum: Int) -> Ingredient{
        let ingredient = Ingredient()
        ingredient.ingredientName = self.ingredientName.text!.withoutSpace()
        ingredient.katakanaLowercasedNameForSearch = self.ingredientName.text!.katakanaLowercasedForSearch()
        ingredient.stockFlag = false
        ingredient.memo = ""
        ingredient.category = categoryNum
        return ingredient
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if ingredientName.text!.withoutSpace() == "" {
            presentAlert("材料名を入力してください")
        }else if ingredientName.text!.withoutSpace().count > 30{
            presentAlert("材料名を30文字以下にしてください")
        }else if amount.text!.withoutSpace().count > 30{
            presentAlert("分量を30文字以下にしてください")
        }else{
            let realm = try! Realm()
            let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ingredientName.text!.withoutSpace())
            if sameNameIngredient.count == 0{
                //同じ名前の材料が存在しないので新規に登録する
                let registAlertView = CustomAlertController(title: nil, message: "この材料はまだ登録されていないので、新たに登録します", preferredStyle: .alert)
                registAlertView.addAction(UIAlertAction(title: "「アルコール」として登録", style: .default, handler: {action in
                    try! realm.write {
                        realm.add(self.setIngredient(0))
                        MessageHUD.show("材料を登録しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                    self.recipeIngredient.category = 0
                    self.isCancel = false
                    self.dismiss(animated: true, completion: nil)
                }))
                registAlertView.addAction(UIAlertAction(title: "「ノンアルコール」として登録", style: .default, handler: {action in
                    try! realm.write {
                        realm.add(self.setIngredient(1))
                        MessageHUD.show("材料を登録しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                    self.recipeIngredient.category = 1
                    self.isCancel = false
                    self.dismiss(animated: true, completion: nil)
                }))
                registAlertView.addAction(UIAlertAction(title: "「その他」として登録", style: .default, handler: {action in
                    try! realm.write {
                        realm.add(self.setIngredient(2))
                        MessageHUD.show("材料を登録しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                    self.recipeIngredient.category = 2
                    self.isCancel = false
                    self.dismiss(animated: true, completion: nil)
                }))
                registAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                registAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                registAlertView.modalPresentationCapturesStatusBarAppearance = true
                present(registAlertView, animated: true, completion: nil)
            }else{
                self.recipeIngredient.category = sameNameIngredient.first!.category
                self.isCancel = false
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}
