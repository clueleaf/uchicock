//
//  ReverseLookupSelectIngredientViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ReverseLookupSelectIngredientViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ingredientContainer: UIView!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var category: UISegmentedControl!
    @IBOutlet weak var suggestTableView: UITableView!
    
    var ingredientNumber: Int?
    var ingredientList: Results<Ingredient>?
    var suggestList = Array<IngredientBasic>()
    var scrollBeginingYPoint: CGFloat = 0.0
    
    let selectedCellBackgroundView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientName.delegate = self
        
        let defaults = UserDefaults.standard
        if ingredientNumber == 0{
            if let name = defaults.string(forKey: "ReverseLookupFirst"){
                ingredientName.text = name
            }
        }else if ingredientNumber == 1{
            if let name = defaults.string(forKey: "ReverseLookupSecond"){
                ingredientName.text = name
            }
        }else if ingredientNumber == 2{
            if let name = defaults.string(forKey: "ReverseLookupThird"){
                ingredientName.text = name
            }
        }
        
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)

        suggestTableView.tableFooterView = UIView(frame: CGRect.zero)
        reloadSuggestList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        category.tintColor = Style.secondaryColor
        category.backgroundColor = Style.basicBackgroundColor
        let attribute = [NSAttributedStringKey.foregroundColor:Style.secondaryColor]
        category.setTitleTextAttributes(attribute, for: .normal)
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        suggestTableView.backgroundColor = Style.basicBackgroundColor
        ingredientContainer.backgroundColor = Style.basicBackgroundColor
        ingredientNameLabel.textColor = Style.labelTextColor
        ingredientName.backgroundColor = Style.textFieldBackgroundColor
        ingredientName.textColor = Style.labelTextColor
        
        if Style.isDark {
            ingredientName.keyboardAppearance = .dark
        }else{
            ingredientName.keyboardAppearance = .default
        }

        NotificationCenter.default.addObserver(self, selector:#selector(RecipeIngredientEditTableViewController.textFieldDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self.ingredientName)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ingredientName.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        reloadSuggestList()
    }
    
    func textFieldDidChange(_ notification: Notification){
        if let text = ingredientName.text {
            if text.characters.count > 30 {
                ingredientName.text = text.substring(to: text.index(text.startIndex, offsetBy: 30))
            }
        }
        reloadSuggestList()
    }
    
    func reloadSuggestList(){
        suggestList.removeAll()
        
        for ingredient in ingredientList! {
            suggestList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, stockFlag: ingredient.stockFlag, japaneseDictionaryOrder: ingredient.japaneseDictionaryOrder, category: ingredient.category))
        }
        
        for i in (0..<suggestList.count).reversed() {
            if textWithoutSpace(text: ingredientName.text!) != "" && suggestList[i].kanaName.contains(textWithoutSpace(text: ingredientName.text!).katakana().lowercased()) == false{
                suggestList.remove(at: i)
            }
        }
        
        for i in (0..<suggestList.count).reversed(){
            switch category.selectedSegmentIndex{
            case 1:
                if suggestList[i].category != 0{
                    suggestList.remove(at: i)
                }
            case 2:
                if suggestList[i].category != 1{
                    suggestList.remove(at: i)
                }
            case 3:
                if suggestList[i].category != 2{
                    suggestList.remove(at: i)
                }
            default:
                break
            }
        }
        
        suggestList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })
        suggestTableView.reloadData()
    }
    
    func textWithoutSpace(text: String) -> String{
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0{
            scrollBeginingYPoint = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -30{
            ingredientName.becomeFirstResponder()
        }else if scrollBeginingYPoint < scrollView.contentOffset.y {
            ingredientName.resignFirstResponder()
        }
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "  材料候補"
        return label
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return suggestList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        ingredientName.text = suggestList[indexPath.row].name
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = suggestTableView.dequeueReusableCell(withIdentifier: "SelectIngredient") as! ReverseLookupSelectIngredientTableViewCell
        let realm = try! Realm()
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: self.suggestList[indexPath.row].id)!
        cell.ingredient = ingredient
        cell.backgroundColor = Style.basicBackgroundColor
        cell.selectedBackgroundView = selectedCellBackgroundView
        return cell
    }

    // MARK: - IBAction
    @IBAction func categoryTapped(_ sender: UISegmentedControl) {
        reloadSuggestList()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        let defaults = UserDefaults.standard
        if ingredientNumber == 0{
            defaults.set(textWithoutSpace(text: ingredientName.text!), forKey: "ReverseLookupFirst")
        }else if ingredientNumber == 1{
            defaults.set(textWithoutSpace(text: ingredientName.text!), forKey: "ReverseLookupSecond")
        }else if ingredientNumber == 2{
            defaults.set(textWithoutSpace(text: ingredientName.text!), forKey: "ReverseLookupThird")
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
