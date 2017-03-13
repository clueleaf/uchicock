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
        // recipeTableViewをdeselectする
        
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor

        // Userdefaultsからロードする
        firstIngredientLabel = ""
        secondIngredientLabel = ""
        thirdIngredientLabel = ""

        ingredientTableView.reloadData()
        reloadRecipeList()
        recipeTableView.reloadData()

        if let path = selectedPathForIngredientTableView{
            ingredientTableView.selectRow(at: path, animated: false, scrollPosition: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.ingredientTableView.deselectRow(at: path, animated: true)
            }
        }
        // recipeTableViewをdeselectする
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        // ヘッダーのレシピ数を更新する
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 0{
            return 4
        }else if tableView.tag == 1{
            return recipeBasicList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            switch indexPath.row{
            case 0,1,2:
                return 50
            case 3:
                return 30
            default:
                return 0
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
//            performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView.tag == 0{
            let clear = UITableViewRowAction(style: .normal, title: "クリア") {
                (action, indexPath) in
                // 材料名をクリアする
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
            if indexPath.row < 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReverseLookupIngredient") as! ReverseLookupTableViewCell
                if indexPath.row == 0{
                    cell.ingredientNumberLabel.text = "材料1："
                }else if indexPath.row == 1{
                    cell.ingredientNumberLabel.text = "材料2："
                }else if indexPath.row == 2{
                    cell.ingredientNumberLabel.text = "材料3："
                }
                cell.isUserInteractionEnabled = true
                return cell
            }else if indexPath.row == 3{
                let cell = UITableViewCell()
                cell.textLabel?.text = "材料名は完全一致で検索されます"
                cell.isUserInteractionEnabled = false
                return cell
            }
        }else if tableView.tag == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeList", for: indexPath) as! IngredientRecipeListTableViewCell
            
            let realm = try! Realm()
            let recipe = realm.objects(Recipe.self).filter("id == %@",recipeBasicList[indexPath.row ].id).first!
            
            if let image = recipe.imageData {
                cell.photo.image = UIImage(data: image as Data)
                //レシピ削除のバグに対するワークアラウンド
                if cell.photo.image == nil{
                    if Style.isDark{
                        cell.photo.image = UIImage(named: "no-photo-dark")
                    }else{
                        cell.photo.image = UIImage(named: "no-photo")
                    }
                }
            }else{
                if Style.isDark{
                    cell.photo.image = UIImage(named: "no-photo-dark")
                }else{
                    cell.photo.image = UIImage(named: "no-photo")
                }
            }
            
            cell.recipeId = recipe.id
            cell.recipeName.text = recipe.recipeName
            switch recipe.favorites{
            case 1:
                cell.favorites.text = "★　　"
            case 2:
                cell.favorites.text = "★★　"
            case 3:
                cell.favorites.text = "★★★"
            default:
                cell.favorites.text = "★　　"
            }
            cell.favorites.textAlignment = .left
            cell.favorites.textColor = Style.secondaryColor
            
            var shortageNum = 0
            var shortageName = ""
            for ri in recipe.recipeIngredients{
                if ri.mustFlag && ri.ingredient.stockFlag == false{
                    shortageNum += 1
                    shortageName = ri.ingredient.ingredientName
                }
            }
            if shortageNum == 0 {
                cell.shortage.text = "すぐつくれる！"
                cell.shortage.textColor = Style.secondaryColor
                cell.shortage.font = UIFont.boldSystemFont(ofSize: CGFloat(14))
                cell.recipeName.textColor = Style.labelTextColor
            }else if shortageNum == 1{
                cell.shortage.text = shortageName + "が足りません"
                cell.shortage.textColor = Style.labelTextColorLight
                cell.shortage.font = UIFont.systemFont(ofSize: CGFloat(14))
                cell.recipeName.textColor = Style.labelTextColorLight
            }else{
                cell.shortage.text = "材料が" + String(shortageNum) + "個足りません"
                cell.shortage.textColor = Style.labelTextColorLight
                cell.shortage.font = UIFont.systemFont(ofSize: CGFloat(14))
                cell.recipeName.textColor = Style.labelTextColorLight
            }
            
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell.selectionStyle = .default
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func clearButtonTapped(_ sender: Any) {
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushSelectIngredient" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! ReverseLookupSelectIngredientViewController
            if let indexPath = sender as? IndexPath{
                evc.ingredientNumber = indexPath.row
            }
        }
    }
}
