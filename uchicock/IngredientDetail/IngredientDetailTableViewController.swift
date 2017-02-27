//
//  IngredientDetailTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/07.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import M13Checkbox

class IngredientDetailTableViewController: UITableViewController {

    
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var stock: M13Checkbox!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var order: UISegmentedControl!
    @IBOutlet weak var deleteLabel: UILabel!

    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<IngredientRecipeBasic>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stock.backgroundColor = UIColor.clear
        stock.tintColor = Style.secondaryColor
        stock.secondaryTintColor = Style.checkboxSecondaryTintColor
        stock.boxLineWidth = 1.0
        stock.markType = .checkmark
        stock.boxType = .circle
        
        tableView.register(IngredientRecipeListTableViewCell.self, forCellReuseIdentifier: "IngredientRecipeList")

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        let ing = realm.objects(Ingredient.self).filter("id == %@",ingredientId)
        if ing.count < 1 {
            let noIngredientAlertView = UIAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            noIngredientAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            present(noIngredientAlertView, animated: true, completion: nil)
        } else {
            ingredient = realm.objects(Ingredient.self).filter("id == %@",ingredientId).first!
            self.navigationItem.title = ingredient.ingredientName
            
            ingredientName.text = ingredient.ingredientName

            stock.stateChangeAnimation = .fade(.fill)
            stock.animationDuration = 0
            if ingredient.stockFlag{
                stock.setCheckState(.checked, animated: true)
            }else{
                stock.setCheckState(.unchecked, animated: true)
            }
            stock.animationDuration = 0.3
            stock.stateChangeAnimation = .expand(.fill)

            memo.text = ingredient.memo
            memo.textColor = Style.labelTextColorLight
            deleteLabel.textColor = Style.deleteColor
            
            reloadIngredientRecipeBasicList()
            
            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadIngredientRecipeBasicList(){
        let realm = try! Realm()
        try! realm.write {
            for ri in ingredient.recipeIngredients{
                ri.recipe.updateShortageNum()
            }
        }

        ingredientRecipeBasicList.removeAll()
        for recipeIngredient in ingredient.recipeIngredients{
            ingredientRecipeBasicList.append(IngredientRecipeBasic(recipeIngredientLinkId: recipeIngredient.id, recipeName: recipeIngredient.recipe.recipeName, shortageNum: recipeIngredient.recipe.shortageNum))
        }
        
        if order.selectedSegmentIndex == 1{
            ingredientRecipeBasicList.sort { (a:IngredientRecipeBasic, b:IngredientRecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.recipeKanaName < b.recipeKanaName
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        }else{
            ingredientRecipeBasicList.sort(by: { $0.recipeKanaName < $1.recipeKanaName })
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 1{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }else{
                return UITableViewAutomaticDimension
            }
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row == 0{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
                }else{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 1))
                }
            } else{
                return super.tableView(tableView, heightForRowAt: IndexPath(row: 2, section: 1))
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            if ingredient.recipeIngredients.count > 0 {
                return "この材料を使うレシピ(" + String(ingredient.recipeIngredients.count) + ")"
            }else {
                return "この材料を使うレシピはありません"
            }
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else if section == 1 {
            if ingredient.recipeIngredients.count > 0{
                return ingredient.recipeIngredients.count + 1
            }else{
                return 1
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row == 0{
                    return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 1))
                }else{
                    return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 1, section: 1))
                }
            }else{
                return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 2, section: 1))
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row > 0 {
                    tableView.deselectRow(at: indexPath, animated: true)
                    performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
                }
            }else{
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertView.addAction(UIAlertAction(title: "削除",style: .destructive){
                    action in
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(self.ingredient)
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                    })
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                present(alertView, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            return cell
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row > 0{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientRecipeList", for: indexPath) as! IngredientRecipeListTableViewCell
                    
                    let realm = try! Realm()
                    let recipeIngredient = realm.objects(RecipeIngredientLink.self).filter("id == %@",ingredientRecipeBasicList[indexPath.row - 1].recipeIngredientLinkId).first!
                    
                    if recipeIngredient.recipe.imageData != nil{
                        cell.photo.image = UIImage(data: recipeIngredient.recipe.imageData! as Data)
                        //レシピ削除のバグに対するワークアラウンド
                        if cell.photo.image == nil{
                            cell.photo.image = UIImage(named: "no-photo")
                        }
                    }else{
                        cell.photo.image = UIImage(named: "no-photo")
                    }
                    
                    cell.recipeName.text = recipeIngredient.recipe.recipeName
                    switch recipeIngredient.recipe.favorites{
                    case 1:
                        cell.favorites.text = "★☆☆"
                    case 2:
                        cell.favorites.text = "★★☆"
                    case 3:
                        cell.favorites.text = "★★★"
                    default:
                        cell.favorites.text = "★☆☆"
                    }
                    var shortageNum = 0
                    var shortageName = ""
                    for ri in recipeIngredient.recipe.recipeIngredients{
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
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.backgroundColor = Style.basicBackgroundColor
                    return cell
                }
            }else{
                let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 1))
                cell.backgroundColor = Style.basicBackgroundColor
                return cell
            }
        }
        return UITableViewCell()
    }

    // MARK: - IBAction
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "PushEditIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func stockTapped(_ sender: M13Checkbox) {
        let realm = try! Realm()
        try! realm.write {
            if stock.checkState == .checked{
                ingredient.stockFlag = true
            }else{
                ingredient.stockFlag = false
            }
        }
        reloadIngredientRecipeBasicList()
        tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .none)
    }
    
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "CreateEvent", sender: UIBarButtonItem())
    }
    
    @IBAction func orderTapped(_ sender: UISegmentedControl) {
        reloadIngredientRecipeBasicList()
        tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .none)
    }
    
    func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! IngredientEditTableViewController
            evc.ingredient = self.ingredient
        }else if segue.identifier == "PushRecipeDetail"{
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                let realm = try! Realm()
                let recipeIngredient = realm.objects(RecipeIngredientLink.self).filter("id == %@",ingredientRecipeBasicList[indexPath.row - 1].recipeIngredientLinkId).first!
                vc.recipeId = recipeIngredient.recipe.id
            }
        }else if segue.identifier == "CreateEvent" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! ReminderTableViewController
            evc.ingredientName = self.ingredient.ingredientName
        }
    }

}
