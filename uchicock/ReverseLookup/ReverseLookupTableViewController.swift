//
//  ReverseLookupViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import DZNEmptyDataSet

class ReverseLookupTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITextFieldDelegate {

    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var ingredientSuggestTableView: UITableView!
    @IBOutlet weak var ingredientNumberLabel1: UILabel!
    @IBOutlet weak var ingredientNumberLabel2: UILabel!
    @IBOutlet weak var ingredientNumberLabel3: UILabel!
    @IBOutlet weak var ingredientTextField1: UITextField!
    @IBOutlet weak var ingredientTextField2: UITextField!
    @IBOutlet weak var ingredientTextField3: UITextField!
    
    var firstIngredientName = ""
    var secondIngredientName = ""
    var thirdIngredientName = ""
    var editingTextField: Int = -1
    var selectedRecipeId: String? = nil
    var recipeBasicList = Array<RecipeBasic>()
    var ingredientList: Results<Ingredient>?
    var ingredientSuggestList = Array<IngredientBasic>()
    let selectedCellBackgroundView = UIView()
    var transitioning = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if Style.isStatusBarLight{
            return .lightContent
        }else{
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        recipeTableView.emptyDataSetSource = self
//        recipeTableView.emptyDataSetDelegate = self
        ingredientTextField1.delegate = self
        ingredientTextField2.delegate = self
        ingredientTextField3.delegate = self
        ingredientTextField1.tag = 0
        ingredientTextField1.tag = 1
        ingredientTextField1.tag = 2

        tableView.tag = 0
        recipeTableView.tag = 1
        ingredientSuggestTableView.tag = 2

        recipeTableView.tableFooterView = UIView(frame: CGRect.zero)
        ingredientSuggestTableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInsetAdjustmentBehavior = .never
        recipeTableView.contentInsetAdjustmentBehavior = .never
        ingredientSuggestTableView.contentInsetAdjustmentBehavior = .never
        
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let selectedPathForIngredientTableView = ingredientTableView.indexPathForSelectedRow
        let selectedPathForRecipeTableView = recipeTableView.indexPathForSelectedRow
        
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        tableView.backgroundColor = Style.basicBackgroundColor
        recipeTableView.backgroundColor = Style.basicBackgroundColor
        ingredientSuggestTableView.backgroundColor = Style.basicBackgroundColor
        if Style.isBackgroundDark{
            self.recipeTableView.indicatorStyle = .white
        }else{
            self.recipeTableView.indicatorStyle = .black
        }
        ingredientNumberLabel1.textColor = Style.labelTextColorLight
        ingredientNumberLabel2.textColor = Style.labelTextColorLight
        ingredientNumberLabel3.textColor = Style.labelTextColorLight
        ingredientTextField1.backgroundColor = Style.textFieldBackgroundColor
        ingredientTextField2.backgroundColor = Style.textFieldBackgroundColor
        ingredientTextField3.backgroundColor = Style.textFieldBackgroundColor
        ingredientTextField1.textColor = Style.labelTextColor
        ingredientTextField2.textColor = Style.labelTextColor
        ingredientTextField3.textColor = Style.labelTextColor
        
//        cell.ingredientNumberLabel.backgroundColor = Style.basicBackgroundColor
//        cell.ingredientNumberLabel.clipsToBounds = true

        if Style.isDark {
            ingredientTextField1.keyboardAppearance = .dark
            ingredientTextField2.keyboardAppearance = .dark
            ingredientTextField3.keyboardAppearance = .dark
        }else{
            ingredientTextField1.keyboardAppearance = .default
            ingredientTextField2.keyboardAppearance = .default
            ingredientTextField3.keyboardAppearance = .default
        }

        loadIngredientsFromUserDefaults()
//        ingredientTableView.reloadData() //???
        reloadRecipeList()
        recipeTableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange1(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self.ingredientTextField1)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange2(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self.ingredientTextField2)
        NotificationCenter.default.addObserver(self, selector:#selector(ReverseLookupTableViewController.textFieldDidChange3(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self.ingredientTextField3)

        if let path = selectedPathForRecipeTableView {
            if recipeTableView.numberOfRows(inSection: 0) > path.row{
                let nowRecipeId = (recipeTableView.cellForRow(at: path) as? ReverseLookupRecipeTableViewCell)?.recipe.id
                if nowRecipeId != nil && selectedRecipeId != nil{
                    if nowRecipeId! == selectedRecipeId!{
                        recipeTableView.selectRow(at: path, animated: false, scrollPosition: .none)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.recipeTableView.deselectRow(at: path, animated: true)
                        }
                    }
                }
            }
        }
        selectedRecipeId = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadIngredientsFromUserDefaults(){
        let defaults = UserDefaults.standard
        if let first = defaults.string(forKey: "ReverseLookupFirst"){
            ingredientTextField1.text = first
        }else{
            defaults.set("", forKey: "ReverseLookupFirst")
        }
        if let second = defaults.string(forKey: "ReverseLookupSecond"){
            ingredientTextField2.text = second
        }else{
            defaults.set("", forKey: "ReverseLookupSecond")
        }
        if let third = defaults.string(forKey: "ReverseLookupThird"){
            ingredientTextField3.text = third
        }else{
            defaults.set("", forKey: "ReverseLookupThird")
        }
    }
    
    func reloadRecipeList(){
        recipeBasicList.removeAll()
        
        if ingredientTextField1.text != nil && ingredientTextField1.text != ""{
            if ingredientTextField2.text != nil && ingredientTextField2.text != ""{
                if ingredientTextField3.text != nil && ingredientTextField3.text != ""{
                    createRecipeBasicList(text1: ingredientTextField1.text!, text2: ingredientTextField2.text!, text3: ingredientTextField3.text!)
                }else{
                    createRecipeBasicList(text1: ingredientTextField1.text!, text2: ingredientTextField2.text!, text3: nil)
                }
            }else{
                if ingredientTextField3.text != nil && ingredientTextField3.text != ""{
                    createRecipeBasicList(text1: ingredientTextField1.text!, text2: ingredientTextField3.text!, text3: nil)
                }else{
                    createRecipeBasicList(text1: ingredientTextField1.text!, text2: nil, text3: nil)
                }
            }
        }else{
            if ingredientTextField2.text != nil && ingredientTextField2.text != ""{
                if ingredientTextField3.text != nil && ingredientTextField3.text != ""{
                    createRecipeBasicList(text1: ingredientTextField2.text!, text2: ingredientTextField3.text!, text3: nil)
                }else{
                    createRecipeBasicList(text1: ingredientTextField2.text!, text2: nil, text3: nil)
                }
            }else{
                if ingredientTextField3.text != nil && ingredientTextField3.text != ""{
                    createRecipeBasicList(text1: ingredientTextField3.text!, text2: nil, text3: nil)
                }else{
                    createRecipeBasicList()
                }
            }
        }
        
        recipeBasicList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })
    }
    
    func createRecipeBasicList(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self)
        for recipe in recipeList{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: 0, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder, lastViewDate: recipe.lastViewDate, madeNum: recipe.madeNum, method: recipe.method))
        }
    }
    
    func createRecipeBasicList(text1: String, text2: String?, text3: String?){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",text1)
        if ing.count > 0 {
            for ri in ing.first!.recipeIngredients{
                recipeBasicList.append(RecipeBasic(id: ri.recipe.id, name: ri.recipe.recipeName, shortageNum: 0, favorites: ri.recipe.favorites, japaneseDictionaryOrder: ri.recipe.japaneseDictionaryOrder, lastViewDate: ri.recipe.lastViewDate, madeNum: ri.recipe.madeNum, method: ri.recipe.method))
            }
            if let t2 = text2 {
                deleteFromRecipeBasicList(withoutUse: t2)
                if let t3 = text3{
                    deleteFromRecipeBasicList(withoutUse: t3)
                }
            }
        }
    }
    
    func deleteFromRecipeBasicList(withoutUse ingredientName: String){
        let realm = try! Realm()
        for i in (0..<recipeBasicList.count).reversed(){
            var hasIngredient = false
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[i].id)!
            for ri in recipe.recipeIngredients{
                if ri.ingredient.ingredientName == ingredientName{
                    hasIngredient = true
                    break
                }
            }
            if hasIngredient == false{
                recipeBasicList.remove(at: i)
            }
        }
    }
    
    func showRecipeTableView(){
        transitioning = true
        tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .middle)

        let defaults = UserDefaults.standard
        switch editingTextField{
        case 0:
            defaults.set(textWithoutSpace(text: ingredientTextField1.text!), forKey: "ReverseLookupFirst")
        case 1:
            defaults.set(textWithoutSpace(text: ingredientTextField2.text!), forKey: "ReverseLookupSecond")
        case 2:
            defaults.set(textWithoutSpace(text: ingredientTextField3.text!), forKey: "ReverseLookupThirt")
        default:
            break
        }
        reloadRecipeList()
        recipeTableView.reloadData()
        
        ingredientTextField1.resignFirstResponder()
        ingredientTextField2.resignFirstResponder()
        ingredientTextField3.resignFirstResponder()
        editingTextField = -1
        
        transitioning = false
        tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .middle)
    }
    
    func showIngredientSuggestTableView(_ textField: UITextField){
        print("================")
        transitioning = true
        tableView.deleteRows(at: [IndexPath(row: 0,section: 1)], with: .middle)

        if textField.tag == 0, let text = ingredientTextField1.text{
            reloadIngredientSuggestList(text: text)
            editingTextField = 0
        }else if textField.tag == 1, let text = ingredientTextField2.text{
            reloadIngredientSuggestList(text: text)
            editingTextField = 1
        }else if textField.tag == 2, let text = ingredientTextField3.text{
            reloadIngredientSuggestList(text: text)
            editingTextField = 2
        }

        transitioning = false
        tableView.insertRows(at: [IndexPath(row: 0,section: 1)], with: .middle)
    }
    
    // MARK: - UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        showRecipeTableView()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        showIngredientSuggestTableView(textField)
    }

    @objc func textFieldDidChange1(_ notification: Notification){
        if let text = ingredientTextField1.text {
            if text.count > 30 {
                ingredientTextField1.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            reloadIngredientSuggestList(text: text)
        }
    }
    
    @objc func textFieldDidChange2(_ notification: Notification){
        if let text = ingredientTextField2.text {
            if text.count > 30 {
                ingredientTextField2.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            reloadIngredientSuggestList(text: text)
        }
    }

    @objc func textFieldDidChange3(_ notification: Notification){
        if let text = ingredientTextField3.text {
            if text.count > 30 {
                ingredientTextField3.text = String(text[..<text.index(text.startIndex, offsetBy: 30)])
            }
            reloadIngredientSuggestList(text: text)
        }
    }

    func reloadIngredientSuggestList(text: String){
        ingredientSuggestList.removeAll()
        
        for ingredient in ingredientList! {
            ingredientSuggestList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, stockFlag: ingredient.stockFlag, japaneseDictionaryOrder: ingredient.japaneseDictionaryOrder, category: ingredient.category))
        }
        
        if textWithoutSpace(text: text) != "" {
            ingredientSuggestList.removeAll{
                !$0.kanaName.contains(textWithoutSpace(text: text).katakana().lowercased())
            }
        }
        
        ingredientSuggestList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })
        ingredientSuggestTableView.reloadData()
    }
    
    func textWithoutSpace(text: String) -> String{
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまるレシピはありません"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 0{
            return 2
        }else if tableView.tag == 1{
            return 1
        }else if tableView.tag == 2{
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 0{
            return 0
        }
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 1{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.tableViewHeaderBackgroundColor
            label.textColor = Style.labelTextColorOnDisableBadge
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.text = "  上の材料をすべて使うレシピ(" + String(self.recipeBasicList.count) + ")"
            return label
        }else if tableView.tag == 2{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.tableViewHeaderBackgroundColor
            label.textColor = Style.labelTextColorOnDisableBadge
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.text = "  材料候補"
            return label
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.tag == 0 && section == 0{
            return 30
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.tag == 0 && section == 0{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.basicBackgroundColor
            label.textColor = Style.labelTextColorLight
            label.font = UIFont.systemFont(ofSize: 15)
            label.text = "  材料名は完全一致で検索されます"
            return label
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 0{
            if section == 0{
                return 3
            }else if section == 1{
                if transitioning{
                    return 0
                }else{
                    return 1
                }
            }
        }else if tableView.tag == 1{
            return recipeBasicList.count
        }else if tableView.tag == 2{
            return ingredientSuggestList.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let window = UIApplication.shared.keyWindow
        let safeAreaHeight = view.frame.size.height - window!.safeAreaInsets.top - window!.safeAreaInsets.bottom

        if tableView.tag == 0{
            if indexPath.section == 0{
                return 40
            }else if indexPath.section == 1{
                return safeAreaHeight - 40 * 3 - 30
            }
        }else if tableView.tag == 1{
            return 70
        }else if tableView.tag == 2{
            return 40
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
            performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }else if tableView.tag == 2{
            tableView.deselectRow(at: indexPath, animated: true)
            switch editingTextField{
            case 0:
                ingredientTextField1.text = ingredientSuggestList[indexPath.row].name
            case 1:
                ingredientTextField2.text = ingredientSuggestList[indexPath.row].name
            case 2:
                ingredientTextField3.text = ingredientSuggestList[indexPath.row].name
            default:
                break
            }
            showRecipeTableView()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 0{
            if indexPath.section == 0{
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.backgroundColor = Style.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                cell.isUserInteractionEnabled = true
                return cell
            }else if indexPath.section == 1{
                if editingTextField == -1{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.isUserInteractionEnabled = true
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.isUserInteractionEnabled = true
                    return cell
                }
            }
        }else if tableView.tag == 1{
            let cell = recipeTableView.dequeueReusableCell(withIdentifier: "ReverseLookupRecipeItem") as! ReverseLookupRecipeTableViewCell
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!
            cell.recipe = recipe
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }else if tableView.tag == 2{
            let cell = ingredientSuggestTableView.dequeueReusableCell(withIdentifier: "SelectIngredient") as! ReverseLookupSelectIngredientTableViewCell
            let realm = try! Realm()
            let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.ingredientSuggestList[indexPath.row].id)!
            cell.ingredient = ingredient
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: nil, message: "逆引き検索条件をクリアします", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "クリア", style: .default, handler: {action in
            let defaults = UserDefaults.standard
            defaults.set("", forKey: "ReverseLookupFirst")
            defaults.set("", forKey: "ReverseLookupSecond")
            defaults.set("", forKey: "ReverseLookupThird")
            self.loadIngredientsFromUserDefaults()
            self.tableView.reloadData()
            self.ingredientSuggestTableView.reloadData()
            self.reloadRecipeList()
            self.recipeTableView.reloadData()
            self.showRecipeTableView()
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        if Style.isStatusBarLight{
            alertView.setStatusBarStyle(.lightContent)
        }else{
            alertView.setStatusBarStyle(.default)
        }
        alertView.modalPresentationCapturesStatusBarAppearance = true
        self.present(alertView, animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedRecipeId = recipeBasicList[indexPath.row].id
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        }
    }
}