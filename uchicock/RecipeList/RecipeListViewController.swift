//
//  RecipeListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import DZNEmptyDataSet
import MYBlurIntroductionView

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MYIntroductionDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var favoriteSelect: UISegmentedControl!
    @IBOutlet weak var order: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var recipeList: Results<Recipe>?
    var recipeBasicList = Array<RecipeBasic>()
    var scrollBeginingYPoint: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControlContainer.backgroundColor = FlatSand()
        getTextFieldFromView(view: searchBar)?.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = UIReturnKeyType.done
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        let defaults = UserDefaults.standard
        let dic = ["firstLaunch": true]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "firstLaunch") {
            showIntroduction()
            defaults.set(false, forKey: "firstLaunch")
        }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.backgroundColor = FlatSand()

        reloadRecipeList()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTextFieldFromView(view: UIView) -> UITextField?{
        for subview in view.subviews{
            if subview is UITextField{
                return subview as? UITextField
            }else{
                let textField = self.getTextFieldFromView(view: subview)
                if textField != nil{
                    return textField
                }
            }
        }
        return nil
    }
    
    func deleteRecipe(id: String) {
        let realm = try! Realm()
        let recipe = realm.objects(Recipe.self).filter("id == %@", id).first!
        
        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
        for ri in recipe.recipeIngredients{
            let recipeIngredient = realm.objects(RecipeIngredientLink.self).filter("id == %@", ri.id).first!
            deletingRecipeIngredientList.append(recipeIngredient)
        }
        
        try! realm.write{
            for ri in deletingRecipeIngredientList{
                let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                for i in 0 ..< ingredient.recipeIngredients.count where i < ingredient.recipeIngredients.count{
                    if ingredient.recipeIngredients[i].id == ri.id{
                        ingredient.recipeIngredients.remove(at: i)
                    }
                }
            }
            for ri in deletingRecipeIngredientList{
                realm.delete(ri)
            }
            realm.delete(recipe)
        }
    }
    
    func searchBarTextWithoutSpace() -> String {
        return searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func reloadRecipeList(){
        let realm = try! Realm()
        switch favoriteSelect.selectedSegmentIndex{
        case 0:
            recipeList = realm.objects(Recipe.self).sorted(byProperty: "recipeName")
        case 1:
            recipeList = realm.objects(Recipe.self).filter("favorites > 1").sorted(byProperty: "recipeName")
        case 2:
            recipeList = realm.objects(Recipe.self).filter("favorites == 3").sorted(byProperty: "recipeName")
        default:
            recipeList = realm.objects(Recipe.self).sorted(byProperty: "recipeName")
        }
        
        if order.selectedSegmentIndex == 1{
            try! realm.write {
                for recipe in recipeList!{
                    recipe.updateShortageNum()
                }
            }
            let sortProperties = [
                SortDescriptor(property: "shortageNum", ascending: true),
                SortDescriptor(property: "recipeName", ascending: true) ]
            recipeList = recipeList!.sorted(by: sortProperties)
        }
        
        reloadRecipeBasicList()
    }
    
    func reloadRecipeBasicList(){
        recipeBasicList.removeAll()
        for recipe in recipeList!{
            recipeBasicList.append(RecipeBasic(id: recipe.id, name: recipe.recipeName))
        }
        
        for i in (0..<recipeBasicList.count).reversed(){
            if searchBarTextWithoutSpace() != "" && recipeBasicList[i].kanaName.contains(searchBarTextWithoutSpace().katakana().lowercased()) == false{
                recipeBasicList.remove(at: i)
            }
        }
        if order.selectedSegmentIndex == 0{
            recipeBasicList.sort(by: { $0.kanaName < $1.kanaName })
        }
        
        self.navigationItem.title = "レシピ(" + String(recipeBasicList.count) + ")"
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "条件にあてはまるレシピはありません"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -self.tableView.frame.size.height/4.0
    }
    
    func showIntroduction(){
        let desc0 = "ダウンロードしていただき、ありがとうございます！使い方を簡単に説明します。"
        let introductionPanel0 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "Thank you for downloading!!", description: desc0)
        
        let desc1 = "レシピの検索や新規登録はこの画面から。\nサンプルレシピですら、編集して自前でアレンジ可能！\nカクテルをつくったらぜひ写真を登録してみよう！"
        let introductionPanel1 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "レシピ", description: desc1, image: UIImage(named: "screen-recipe"))
        introductionPanel1!.panelImageView.contentMode = UIViewContentMode.scaleAspectFit

        let desc2 = "ワンタップで材料の在庫を登録できます。在庫を登録することで、今の手持ちでつくれるレシピがわかります。\n材料からレシピを探すのもこの画面から。"
        let introductionPanel2 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "材料", description: desc2, image: UIImage(named: "screen-ingredient"))
        introductionPanel2!.panelImageView.contentMode = UIViewContentMode.scaleAspectFit

        let desc3 = "アプリに登録されているレシピの写真だけを取り出して表示します。\n表示順をシャッフルして、気まぐれにカクテルを選んでみては？"
        let introductionPanel3 = MYIntroductionPanel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), title: "アルバム", description: desc3, image: UIImage(named: "screen-album"))
        introductionPanel3!.panelImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        let introductionView = MYBlurIntroductionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        introductionView.backgroundImageView.image = UIImage(named: "launch-background")
        introductionView.rightSkipButton.backgroundColor = UIColor.clear
        introductionView.delegate = self
        introductionView.buildIntroduction(withPanels: [introductionPanel0!,introductionPanel1!,introductionPanel2!,introductionPanel3!])

        let window = UIApplication.shared.keyWindow!
        window.addSubview(introductionView)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0{
            scrollBeginingYPoint = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50{
            searchBar.becomeFirstResponder()
        }else if scrollBeginingYPoint < scrollView.contentOffset.y {
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadRecipeBasicList()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.reloadRecipeBasicList()
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.reloadRecipeBasicList()
            self.tableView.reloadData()
        }
        return true
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            if recipeList == nil{
                reloadRecipeList()
            }
            return recipeBasicList.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "編集") {
            (action, indexPath) in
            self.performSegue(withIdentifier: "PushAddRecipe", sender: indexPath)
        }
        edit.backgroundColor = FlatGray()
        
        let del = UITableViewRowAction(style: .default, title: "削除") {
            (action, indexPath) in
            let alertView = UIAlertController(title: "本当に削除しますか？", message: nil, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                self.deleteRecipe(id: self.recipeBasicList[indexPath.row].id)
                self.recipeBasicList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.navigationItem.title = "レシピ(" + String(self.recipeBasicList.count) + ")"
            }))
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
            self.present(alertView, animated: true, completion: nil)
        }
        del.backgroundColor = FlatRed()
        
        return [del, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeListItem") as! RecipeListItemTableViewCell
            let realm = try! Realm()
            let recipe = realm.objects(Recipe.self).filter("id == %@", recipeBasicList[indexPath.row].id).first!
            cell.recipe = recipe
            cell.backgroundColor = FlatWhite()
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func favoriteStateTapped(_ sender: UISegmentedControl) {
        reloadRecipeList()
        tableView.reloadData()
    }
    
    @IBAction func orderTapped(_ sender: UISegmentedControl) {
        reloadRecipeList()
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "PushAddRecipe", sender: UIBarButtonItem())
    }
    
    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)        
        reloadRecipeBasicList()
        tableView.reloadData()
        showIntroduction()
    }
    
    @IBAction func restoreButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "PushRecoverRecipe", sender: UIBarButtonItem())
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destination as! RecipeDetailTableViewController
            if let indexPath = sender as? IndexPath{
                vc.recipeId = recipeBasicList[indexPath.row].id
            }
        } else if segue.identifier == "PushAddRecipe" {
            if let indexPath = sender as? IndexPath{
                let enc = segue.destination as! UINavigationController
                let evc = enc.visibleViewController as! RecipeEditTableViewController
                let realm = try! Realm()
                let recipe = realm.objects(Recipe.self).filter("id == %@", recipeBasicList[indexPath.row].id).first!
                evc.recipe = recipe
            }
        }
    }

}

