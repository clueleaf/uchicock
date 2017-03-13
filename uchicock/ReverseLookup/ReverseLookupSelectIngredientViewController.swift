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
    @IBOutlet weak var suggestTableView: UITableView!
    
    var ingredientNumber: Int?
    var ingredientList: Results<Ingredient>?
    var suggestList = Array<IngredientBasic>()
    
    let selectedCellBackgroundView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientName.delegate = self
        
        let realm = try! Realm()
        ingredientList = realm.objects(Ingredient.self)

        suggestTableView.tableFooterView = UIView(frame: CGRect.zero)
        reloadSuggestList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor

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
        reloadSuggestList()
    }
    
    func reloadSuggestList(){
        suggestList.removeAll()
        
        for ingredient in ingredientList! {
            suggestList.append(IngredientBasic(id: ingredient.id, name: ingredient.ingredientName, stockFlag: ingredient.stockFlag, japaneseDictionaryOrder: ingredient.japaneseDictionaryOrder))
        }
        
        for i in (0..<suggestList.count).reversed() {
            if ingredientName.text! != "" && suggestList[i].kanaName.contains(ingredientName.text!.katakana().lowercased()) == false{
                suggestList.remove(at: i)
            }
        }
        
        suggestList.sort(by: { $0.japaneseDictionaryOrder < $1.japaneseDictionaryOrder })
        suggestTableView.reloadData()
    }
    
    func textWithoutSpace(text: String) -> String{
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
        let ingredient = realm.objects(Ingredient.self).filter("id == %@", self.suggestList[indexPath.row].id).first!
        cell.ingredient = ingredient
        cell.backgroundColor = Style.basicBackgroundColor
        cell.selectedBackgroundView = selectedCellBackgroundView
        return cell
    }

    // MARK: - IBAction
    @IBAction func doneButtonTapped(_ sender: Any) {
        // userDefaultsに保存する
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
