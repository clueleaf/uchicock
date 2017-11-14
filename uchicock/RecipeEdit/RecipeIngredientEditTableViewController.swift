//
//  RecipeIngredientEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/09.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import M13Checkbox

class RecipeIngredientEditTableViewController: UITableViewController, UITextFieldDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var suggestTableViewCell: UITableViewCell!
    @IBOutlet weak var suggestTableView: UITableView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var amountSlider: UISlider!
    @IBOutlet weak var option: M13Checkbox!
    @IBOutlet weak var deleteTableViewCell: UITableViewCell!
    @IBOutlet weak var deleteLabel: UILabel!
    
    var recipeIngredient = EditingRecipeIngredient(id: "", ingredientName: "", amount: "", mustFlag: true)
    var ingredientList: Results<Ingredient>?

    var isAddMode = false
    var deleteFlag = false
    var isTypingName = false
    var suggestList = Array<IngredientName>()
    let selectedCellBackgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)

        ingredientName.tag = 0
        amount.tag = 1
        self.tableView.tag = 0
        suggestTableView.tag = 1
        
        option.boxLineWidth = 1.0
        option.markType = .checkmark
        option.boxType = .circle
        option.stateChangeAnimation = .expand(.fill)
        
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
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        suggestTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.backgroundColor = Style.basicBackgroundColor
        ingredientName.backgroundColor = Style.textFieldBackgroundColor
        ingredientName.textColor = Style.labelTextColor
        amount.backgroundColor = Style.textFieldBackgroundColor
        ingredientNameLabel.textColor = Style.labelTextColor
        amountLabel.textColor = Style.labelTextColor
        amount.textColor = Style.labelTextColor
        amountSlider.minimumTrackTintColor = Style.secondaryColor
        amountSlider.maximumTrackTintColor = Style.labelTextColorLight
        optionLabel.textColor = Style.labelTextColor
        option.backgroundColor = UIColor.clear
        option.tintColor = Style.secondaryColor
        option.secondaryTintColor = Style.checkboxSecondaryTintColor
        deleteLabel.textColor = Style.deleteColor
        suggestTableView.backgroundColor = Style.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        
        if Style.isDark {
            ingredientName.keyboardAppearance = .dark
            amount.keyboardAppearance = .dark
        }else{
            ingredientName.keyboardAppearance = .default
            amount.keyboardAppearance = .default
        }

        NotificationCenter.default.addObserver(self, selector:#selector(RecipeIngredientEditTableViewController.textFieldDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self.ingredientName)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAddMode{
            ingredientName.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
    
    @objc func textFieldDidChange(_ notification: Notification){
        reloadSuggestList()
    }
    
    func reloadSuggestList(){
        suggestList.removeAll()
        
        for ingredient in ingredientList! {
            suggestList.append(IngredientName(name: ingredient.ingredientName, japaneseDictionaryOrder: ingredient.japaneseDictionaryOrder))
        }
        
        for i in (0..<suggestList.count).reversed() {
            if textWithoutSpace(text: ingredientName.text!) != "" && suggestList[i].kanaName.contains(textWithoutSpace(text: ingredientName.text!).katakana().lowercased()) == false{
                suggestList.remove(at: i)
            }
        }
        
        suggestList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })
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
    
    func textWithoutSpace(text: String) -> String{
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if tableView.tag == 1 && section == 0{
            label.text = "  材料候補"
        }else{
            label.text = nil
        }
        return label
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
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertView.addAction(UIAlertAction(title: "追加をやめる",style: .destructive){
                    action in
                    self.deleteFlag = true
                    self.performSegue(withIdentifier: "UnwindToRecipeEdit", sender: self)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                present(alertView, animated: true, completion: nil)
            }else{
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertView.addAction(UIAlertAction(title: "外す",style: .destructive){
                    action in
                    self.deleteFlag = true
                    self.performSegue(withIdentifier: "UnwindToRecipeEdit", sender: self)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                present(alertView, animated: true, completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }else if tableView.tag == 1{
            tableView.deselectRow(at: indexPath, animated: true)
            ingredientName.text = suggestList[indexPath.row].name
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            if isTypingName{
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.backgroundColor = Style.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                return cell
            }else{
                if indexPath.section == 0 && indexPath.row > 0{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: 0))
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: indexPath)
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    return cell
                }
            }
        }else if tableView.tag == 1 && indexPath.section == 0{
            let cell = suggestTableView.dequeueReusableCell(withIdentifier: "SuggestIngredient") as! SuggestIngredientTableViewCell
            cell.name = suggestList[indexPath.row].name
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - GestureRecognizer
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
    @IBAction func amoutSliderValueChanged(_ sender: UISlider) {
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if textWithoutSpace(text: ingredientName.text!) == "" {
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            present(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(text: ingredientName.text!).count > 30{
            //材料名が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "材料名を30文字以下にしてください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            present(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(text: amount.text!).count > 30{
            //分量が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "分量を30文字以下にしてください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            present(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            let sameNameIngredient = realm.objects(Ingredient.self).filter("ingredientName == %@",textWithoutSpace(text: ingredientName.text!))
            if sameNameIngredient.count == 0{
                //同じ名前の材料が存在しないので新規に登録する
                let registAlertView = UIAlertController(title: "", message: "この材料はまだ登録されていないので、新たに登録します", preferredStyle: .alert)
                registAlertView.addAction(UIAlertAction(title: "「アルコール」として登録", style: .default, handler: {action in
                    let ingredient = Ingredient()
                    ingredient.ingredientName = self.textWithoutSpace(text: self.ingredientName.text!)
                    ingredient.japaneseDictionaryOrder = self.textWithoutSpace(text: self.ingredientName.text!).japaneseDictionaryOrder()
                    ingredient.stockFlag = false
                    ingredient.memo = ""
                    ingredient.category = 0
                    try! realm.write {
                        realm.add(ingredient)
                    }
                    self.performSegue(withIdentifier: "UnwindToRecipeEdit", sender: self)}))
                registAlertView.addAction(UIAlertAction(title: "「ノンアルコール」として登録", style: .default, handler: {action in
                    let ingredient = Ingredient()
                    ingredient.ingredientName = self.textWithoutSpace(text: self.ingredientName.text!)
                    ingredient.japaneseDictionaryOrder = self.textWithoutSpace(text: self.ingredientName.text!).japaneseDictionaryOrder()
                    ingredient.stockFlag = false
                    ingredient.memo = ""
                    ingredient.category = 1
                    try! realm.write {
                        realm.add(ingredient)
                    }
                    self.performSegue(withIdentifier: "UnwindToRecipeEdit", sender: self)}))
                registAlertView.addAction(UIAlertAction(title: "「その他」として登録", style: .default, handler: {action in
                    let ingredient = Ingredient()
                    ingredient.ingredientName = self.textWithoutSpace(text: self.ingredientName.text!)
                    ingredient.japaneseDictionaryOrder = self.textWithoutSpace(text: self.ingredientName.text!).japaneseDictionaryOrder()
                    ingredient.stockFlag = false
                    ingredient.memo = ""
                    ingredient.category = 2
                    try! realm.write {
                        realm.add(ingredient)
                    }
                    self.performSegue(withIdentifier: "UnwindToRecipeEdit", sender: self)}))
                registAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                present(registAlertView, animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "UnwindToRecipeEdit", sender: self)
            }
        }
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindToRecipeEdit"{
        }
    }
    
}
