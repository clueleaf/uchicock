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

    
    @IBOutlet weak var ingredientName: CopyableLabel!
    @IBOutlet weak var ingredientNameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var stock: M13Checkbox!
    @IBOutlet weak var memo: CopyableLabel!
    @IBOutlet weak var order: UISegmentedControl!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var amazonButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButtonLabel: UILabel!
    @IBOutlet weak var reminderButtonLabel: UILabel!
    @IBOutlet weak var amazonButtonLabel: UILabel!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    
    var editVC : IngredientEditTableViewController!
    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<IngredientRecipeBasic>()
    let selectedCellBackgroundView = UIView()
    var selectedRecipeId: String? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if Style.isStatusBarLight{
            return .lightContent
        }else{
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stock.boxLineWidth = 1.0
        stock.markType = .checkmark
        stock.boxType = .circle
        
        editButton.layer.cornerRadius = editButton.frame.size.width / 2
        editButton.clipsToBounds = true
        let editImage = UIImage(named: "edit")?.withRenderingMode(.alwaysTemplate)
        editButton.setImage(editImage, for: .normal)
        reminderButton.layer.cornerRadius = reminderButton.frame.size.width / 2
        let reminderImage = UIImage(named: "reminder")?.withRenderingMode(.alwaysTemplate)
        reminderButton.setImage(reminderImage, for: .normal)
        reminderButton.clipsToBounds = true
        amazonButton.layer.cornerRadius = amazonButton.frame.size.width / 2
        let amazonImage = UIImage(named: "amazon")?.withRenderingMode(.alwaysTemplate)
        amazonButton.setImage(amazonImage, for: .normal)
        amazonButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = deleteButton.frame.size.width / 2
        let deleteImage = UIImage(named: "delete")?.withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.clipsToBounds = true

        tableView.register(IngredientRecipeListTableViewCell.self, forCellReuseIdentifier: "IngredientRecipeList")

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPathForSelectedRow = tableView.indexPathForSelectedRow
        super.viewWillAppear(animated)
        
        categoryLabel.textColor = Style.labelTextColor
        stockLabel.textColor = Style.labelTextColor
        memoLabel.textColor = Style.labelTextColor
        category.textColor = Style.labelTextColor
        stock.backgroundColor = UIColor.clear
        stock.tintColor = Style.secondaryColor
        stock.secondaryTintColor = Style.checkboxSecondaryTintColor
        editButtonLabel.textColor = Style.labelTextColor
        reminderButtonLabel.textColor = Style.labelTextColor
        amazonButtonLabel.textColor = Style.labelTextColor
        deleteButtonLabel.textColor = Style.deleteColor
        self.tableView.backgroundColor = Style.basicBackgroundColor
        order.tintColor = Style.secondaryColor
        order.backgroundColor = Style.basicBackgroundColor
        let attribute = [NSAttributedStringKey.foregroundColor:Style.secondaryColor]
        order.setTitleTextAttributes(attribute, for: .normal)
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }

        let realm = try! Realm()
        let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientId)
        if ing == nil {
            let noIngredientAlertView = UIAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            noIngredientAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            if Style.isStatusBarLight{
                noIngredientAlertView.setStatusBarStyle(.lightContent)
            }else{
                noIngredientAlertView.setStatusBarStyle(.default)
            }
            noIngredientAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noIngredientAlertView, animated: true, completion: nil)
        } else {
            ingredient = ing!
            self.navigationItem.title = ingredient.ingredientName
            
            ingredientName.text = ingredient.ingredientName
            ingredientName.textColor = Style.labelTextColor

            switch ingredient.category{
            case 0:
                category.text = "アルコール"
            case 1:
                category.text = "ノンアルコール"
            case 2:
                category.text = "その他"
            default:
                category.text = "その他"
            }
            
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
            
//            if Amazon.product.contains(ingredient.ingredientName){
//                searchInAmazonButton.isEnabled = true
//                searchInAmazonButton.setTitleColor(Style.labelTextColorOnBadge, for: .normal)
//                searchInAmazonButton.backgroundColor = Style.secondaryColor
//                ingredientNameTrailingConstraint.constant = 76
//            }else{
//                searchInAmazonButton.isEnabled = false
//                searchInAmazonButton.setTitleColor(UIColor.clear, for: .normal)
//                searchInAmazonButton.backgroundColor = UIColor.clear
//                ingredientNameTrailingConstraint.constant = 8
//            }
            
            editButton.backgroundColor = Style.secondaryColor
            editButton.tintColor = Style.basicBackgroundColor
            reminderButton.backgroundColor = Style.secondaryColor
            reminderButton.tintColor = Style.basicBackgroundColor
            amazonButton.backgroundColor = Style.secondaryColor
            amazonButton.tintColor = Style.basicBackgroundColor
            deleteButton.backgroundColor = Style.deleteColor
            deleteButton.tintColor = Style.basicBackgroundColor
            
            reloadIngredientRecipeBasicList()
            
            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.reloadData()
            
            if let index = indexPathForSelectedRow {
                if tableView.numberOfRows(inSection: 1) > index.row{
                    let nowRecipeId = (tableView.cellForRow(at: index) as? IngredientRecipeListTableViewCell)?.recipeId
                    if nowRecipeId != nil && selectedRecipeId != nil{
                        if nowRecipeId! == selectedRecipeId!{
                            tableView.selectRow(at: indexPathForSelectedRow, animated: false, scrollPosition: .none)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.tableView.deselectRow(at: index, animated: true)
                            }
                        }
                    }
                }
            }
            selectedRecipeId = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func closeEditVC(_ editVC: IngredientEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
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
            ingredientRecipeBasicList.append(IngredientRecipeBasic(recipeIngredientLinkId: recipeIngredient.id, recipeName: recipeIngredient.recipe.recipeName, shortageNum: recipeIngredient.recipe.shortageNum, japaneseDictionaryOrder: recipeIngredient.recipe.japaneseDictionaryOrder, lastViewDate: recipeIngredient.recipe.lastViewDate, madeNum: recipeIngredient.recipe.madeNum))
        }
        
        if order.selectedSegmentIndex == 1{
            ingredientRecipeBasicList.sort { (a:IngredientRecipeBasic, b:IngredientRecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.japaneseDictionaryOrder.lowercased() < b.japaneseDictionaryOrder.lowercased()
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        }else if order.selectedSegmentIndex == 2{
            ingredientRecipeBasicList.sort(by: { (a:IngredientRecipeBasic, b:IngredientRecipeBasic) -> Bool in
                if a.lastViewDate == nil{
                    if b.lastViewDate == nil{
                        return a.japaneseDictionaryOrder.lowercased() < b.japaneseDictionaryOrder.lowercased()
                    }else{
                        return false
                    }
                }else{
                    if b.lastViewDate == nil{
                        return true
                    }else{
                        return a.lastViewDate! > b.lastViewDate!
                    }
                }
            })
        }else if order.selectedSegmentIndex == 3{
            ingredientRecipeBasicList.sort { (a:IngredientRecipeBasic, b:IngredientRecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    return a.japaneseDictionaryOrder.lowercased() < b.japaneseDictionaryOrder.lowercased()
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        }else{
            ingredientRecipeBasicList.sort(by: { $0.japaneseDictionaryOrder.lowercased() < $1.japaneseDictionaryOrder.lowercased() })
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
            if indexPath.row == 1 || indexPath.row == 4{
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
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if section == 1 {
            if ingredient.recipeIngredients.count > 0 {
                label.text = "  この材料を使うレシピ(" + String(ingredient.recipeIngredients.count) + ")"
            }else {
                label.text = "  この材料を使うレシピはありません"
            }
        }else{
            label.text = nil
        }
        return label
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }else if section == 1 {
            if ingredient.recipeIngredients.count > 0{
                return ingredient.recipeIngredients.count + 1
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
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row > 0 {
                    performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row > 0{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientRecipeList", for: indexPath) as! IngredientRecipeListTableViewCell
                    
                    let realm = try! Realm()
                    let recipeIngredient = realm.object(ofType: RecipeIngredientLink.self, forPrimaryKey: ingredientRecipeBasicList[indexPath.row - 1].recipeIngredientLinkId)!
                    
                    if let image = recipeIngredient.recipe.imageData {
                        cell.photo.image = UIImage(data: image as Data)
                    }else{
                        if Style.isDark{
                            cell.photo.image = UIImage(named: "no-photo-dark")
                        }else{
                            cell.photo.image = UIImage(named: "no-photo")
                        }
                    }
                    
                    cell.recipeId = recipeIngredient.recipe.id
                    cell.recipeName.text = recipeIngredient.recipe.recipeName
                    cell.recipeName.backgroundColor = Style.basicBackgroundColor
                    cell.recipeName.clipsToBounds = true
                    switch recipeIngredient.recipe.favorites{
                    case 0:
                        cell.favorites.text = ""
                    case 1:
                        cell.favorites.text = "★"
                    case 2:
                        cell.favorites.text = "★★"
                    case 3:
                        cell.favorites.text = "★★★"
                    default:
                        cell.favorites.text = ""
                    }
                    cell.favorites.textAlignment = .left
                    cell.favorites.textColor = Style.secondaryColor
                    cell.favorites.backgroundColor = Style.basicBackgroundColor
                    
                    var shortageNum = 0
                    var shortageName = ""
                    for ri in recipeIngredient.recipe.recipeIngredients{
                        if ri.mustFlag && ri.ingredient.stockFlag == false{
                            shortageNum += 1
                            shortageName = ri.ingredient.ingredientName
                        }
                    }
                    if shortageNum == 0 {
                        cell.shortage.text = "すぐ作れる！"
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
                    cell.shortage.backgroundColor = Style.basicBackgroundColor
                    cell.shortage.clipsToBounds = true
                    
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    cell.selectionStyle = .default
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    return cell
                }
            }
        }
        return UITableViewCell()
    }

    // MARK: - IBAction
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
        tableView.reloadData()
    }
    
    @IBAction func orderTapped(_ sender: UISegmentedControl) {
        reloadIngredientRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PushEditIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func reminderButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "CreateEvent", sender: UIBarButtonItem())
    }
    
    @IBAction func amazonButtonTapped(_ sender: UIButton) {
        var urlStr : String = "com.amazon.mobile.shopping://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName + "&linkCode=sl2&tag=uchicock-22"
        var url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }else{
            urlStr = "https://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName + "&linkCode=sl2&tag=uchicock-22"
            url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
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
        if Style.isStatusBarLight{
            alertView.setStatusBarStyle(.lightContent)
        }else{
            alertView.setStatusBarStyle(.default)
        }
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
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
                let recipeIngredient = realm.object(ofType: RecipeIngredientLink.self, forPrimaryKey: ingredientRecipeBasicList[indexPath.row - 1].recipeIngredientLinkId)!
                selectedRecipeId = recipeIngredient.recipe.id
                vc.recipeId = recipeIngredient.recipe.id
            }
        }else if segue.identifier == "CreateEvent" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! ReminderTableViewController
            evc.ingredientName = self.ingredient.ingredientName
        }
    }

}
