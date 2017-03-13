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

class ReverseLookupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var recipeTableView: UITableView!

    var firstIngredientLabel = ""
    var secondIngredientLabel = ""
    var thirdIngredientLabel = ""
    var selectedRecipeId: String? = nil
    var recipeList: Results<Recipe>?
    var recipeBasicList = Array<RecipeBasic>()
    let selectedCellBackgroundView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientTableView.tag = 0
        recipeTableView.tag = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedPathForIngredientTableView = ingredientTableView.indexPathForSelectedRow
        let selectedPathForRecipeTableView = recipeTableView.indexPathForSelectedRow
        
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        
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
        let realm = try! Realm()
        recipeList = realm.objects(Recipe.self).sorted(byKeyPath: "recipeName")
        try! realm.write {
            for recipe in recipeList!{
                recipe.updateShortageNum()
            }
        }
        reloadRecipeBasicList()
    }
    
    func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        for recipe in recipeList!{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName, shortageNum: recipe.shortageNum, favorites: recipe.favorites, japaneseDictionaryOrder: recipe.japaneseDictionaryOrder))
        }
        
        // 対象外のレシピを除外する
        
        recipeBasicList.sort(by: { $0.japaneseDictionaryOrder < $1.japaneseDictionaryOrder })
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.tableViewHeaderBackgroundColor
            label.textColor = Style.labelTextColorOnDisableBadge
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.text = "  材料名は完全一致で検索されます"
            return label
        }else if tableView.tag == 1{
            let label : UILabel = UILabel()
            label.backgroundColor = Style.tableViewHeaderBackgroundColor
            label.textColor = Style.labelTextColorOnDisableBadge
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.text = "  上の材料を全て使うレシピ(" + String(self.recipeBasicList.count) + ")"
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
                cell.ingredientNumberLabel.text = "材料1："
                cell.ingredientNameLabel.text = firstIngredientLabel
            }else if indexPath.row == 1{
                cell.ingredientNumberLabel.text = "材料2："
                cell.ingredientNameLabel.text = secondIngredientLabel
            }else if indexPath.row == 2{
                cell.ingredientNumberLabel.text = "材料3："
                cell.ingredientNameLabel.text = thirdIngredientLabel
            }
            cell.isUserInteractionEnabled = true
            return cell
        }else if tableView.tag == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReverseLookupRecipeItem", for: indexPath) as! ReverseLookupRecipeTableViewCell
            let realm = try! Realm()
            let recipe = realm.objects(Recipe.self).filter("id == %@", recipeBasicList[indexPath.row].id).first!
            cell.recipe = recipe
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView

            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func clearButtonTapped(_ sender: Any) {
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
