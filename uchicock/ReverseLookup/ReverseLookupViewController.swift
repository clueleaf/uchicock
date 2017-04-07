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

class ReverseLookupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var recipeTableView: UITableView!

    var firstIngredientLabel = ""
    var secondIngredientLabel = ""
    var thirdIngredientLabel = ""
    var selectedRecipeId: String? = nil
    var recipeBasicList = Array<RecipeBasic>()
    let selectedCellBackgroundView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeTableView.emptyDataSetSource = self
        recipeTableView.emptyDataSetDelegate = self

        ingredientTableView.tag = 0
        recipeTableView.tag = 1
        recipeTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedPathForIngredientTableView = ingredientTableView.indexPathForSelectedRow
        let selectedPathForRecipeTableView = recipeTableView.indexPathForSelectedRow
        
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        ingredientTableView.backgroundColor = Style.basicBackgroundColor
        recipeTableView.backgroundColor = Style.basicBackgroundColor

        loadIngredientsFromUserDefaults()
        ingredientTableView.reloadData()
        reloadRecipeList()
        recipeTableView.reloadData()

        if let path = selectedPathForIngredientTableView{
            ingredientTableView.selectRow(at: path, animated: false, scrollPosition: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.ingredientTableView.deselectRow(at: path, animated: true)
            }
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadIngredientsFromUserDefaults(){
        let defaults = UserDefaults.standard
        if let first = defaults.string(forKey: "ReverseLookupFirst"){
            firstIngredientLabel = first
        }else{
            defaults.set("", forKey: "ReverseLookupFirst")
        }
        if let second = defaults.string(forKey: "ReverseLookupSecond"){
            secondIngredientLabel = second
        }else{
            defaults.set("", forKey: "ReverseLookupSecond")
        }
        if let third = defaults.string(forKey: "ReverseLookupThird"){
            thirdIngredientLabel = third
        }else{
            defaults.set("", forKey: "ReverseLookupThird")
        }
    }
    
    func reloadRecipeList(){
        recipeBasicList.removeAll()
        
        if firstIngredientLabel != ""{
            if secondIngredientLabel != ""{
                if thirdIngredientLabel != ""{
                    createRecipeBasicList(text1: firstIngredientLabel, text2: secondIngredientLabel, text3: thirdIngredientLabel)
                }else{
                    createRecipeBasicList(text1: firstIngredientLabel, text2: secondIngredientLabel, text3: nil)
                }
            }else{
                if thirdIngredientLabel != ""{
                    createRecipeBasicList(text1: firstIngredientLabel, text2: thirdIngredientLabel, text3: nil)
                }else{
                    createRecipeBasicList(text1: firstIngredientLabel, text2: nil, text3: nil)
                }
            }
        }else{
            if secondIngredientLabel != ""{
                if thirdIngredientLabel != ""{
                    createRecipeBasicList(text1: secondIngredientLabel, text2: thirdIngredientLabel, text3: nil)
                }else{
                    createRecipeBasicList(text1: secondIngredientLabel, text2: nil, text3: nil)
                }
            }else{
                if thirdIngredientLabel != ""{
                    createRecipeBasicList(text1: thirdIngredientLabel, text2: nil, text3: nil)
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
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: 0, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder))
        }
    }

    func createRecipeBasicList(text1: String, text2: String?, text3: String?){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("ingredientName == %@",text1)
        if ing.count > 0 {
            for ri in ing.first!.recipeIngredients{
                recipeBasicList.append(RecipeBasic(id: ri.recipe.id, name: ri.recipe.recipeName, shortageNum: 0, favorites: ri.recipe.favorites, japaneseDictionaryOrder: ri.recipe.japaneseDictionaryOrder))
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
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまるレシピはありません"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1{
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 1{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.tableViewHeaderBackgroundColor
            label.textColor = Style.labelTextColorOnDisableBadge
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.text = "  上の材料をすべて使うレシピ(" + String(self.recipeBasicList.count) + ")"
            return label
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.tag == 0{
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.tag == 0{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.basicBackgroundColor
            label.textColor = Style.labelTextColor
            label.font = UIFont.systemFont(ofSize: 15)
            label.text = "  材料名は完全一致で検索されます"
            return label
        }
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 0{
            return 3
        }else if tableView.tag == 1{
            return recipeBasicList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            if indexPath.row < 3{
                return 50
            }
        }else if tableView.tag == 1{
            return 70
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            performSegue(withIdentifier: "PushSelectIngredient", sender: indexPath)
        }else if tableView.tag == 1{
            performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView.tag == 0{
            let clear = UITableViewRowAction(style: .normal, title: "クリア") {
                (action, indexPath) in
                let defaults = UserDefaults.standard
                if indexPath.row == 0{
                    defaults.set("", forKey: "ReverseLookupFirst")
                }else if indexPath.row == 1{
                    defaults.set("", forKey: "ReverseLookupSecond")
                }else if indexPath.row == 2{
                    defaults.set("", forKey: "ReverseLookupThird")
                }
                self.loadIngredientsFromUserDefaults()
                self.ingredientTableView.reloadData()
                self.reloadRecipeList()
                self.recipeTableView.reloadData()
            }
            clear.backgroundColor = Style.tableViewCellEditBackgroundColor
            return [clear]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0{
            if indexPath.row < 3{
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReverseLookupIngredient") as! ReverseLookupTableViewCell
            if indexPath.row == 0{
                cell.ingredientNumberLabel.text = "材料1"
                cell.ingredientNameLabel.text = firstIngredientLabel
            }else if indexPath.row == 1{
                cell.ingredientNumberLabel.text = "材料2"
                cell.ingredientNameLabel.text = secondIngredientLabel
            }else if indexPath.row == 2{
                cell.ingredientNumberLabel.text = "材料3"
                cell.ingredientNameLabel.text = thirdIngredientLabel
            }
            cell.ingredientNumberLabel.textColor = Style.labelTextColorLight
            cell.ingredientNameLabel.textColor = Style.labelTextColor
            cell.changeLabel.textColor = Style.labelTextColorLight
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.isUserInteractionEnabled = true
            return cell
        }else if tableView.tag == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReverseLookupRecipeItem", for: indexPath) as! ReverseLookupRecipeTableViewCell
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeBasicList[indexPath.row].id)!
            cell.recipe = recipe
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
            self.ingredientTableView.reloadData()
            self.reloadRecipeList()
            self.recipeTableView.reloadData()
        }))
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        self.present(alertView, animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushSelectIngredient" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! ReverseLookupSelectIngredientViewController
            if let indexPath = sender as? IndexPath{
                evc.ingredientNumber = indexPath.row
            }
        }else if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedRecipeId = recipeBasicList[indexPath.row].id
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        }
    }
}
