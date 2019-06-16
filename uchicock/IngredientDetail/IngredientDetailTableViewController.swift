//
//  IngredientDetailTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/07.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import M13Checkbox

class IngredientDetailTableViewController: UITableViewController {

    
    @IBOutlet weak var ingredientName: CopyableLabel!
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
    @IBOutlet weak var amazonContainerView: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    
    var editVC : IngredientEditTableViewController!
    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<IngredientRecipeBasic>()
    let selectedCellBackgroundView = UIView()
    var selectedRecipeId: String? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stock.boxLineWidth = 1.0
        stock.markType = .checkmark
        stock.boxType = .circle
        
        initActionButtonStyleOf(editButton, with: "edit")
        initActionButtonStyleOf(reminderButton, with: "reminder")
        initActionButtonStyleOf(amazonButton, with: "amazon")
        initActionButtonStyleOf(deleteButton, with: "delete")

        tableView.register(IngredientRecipeListTableViewCell.self, forCellReuseIdentifier: "IngredientRecipeList")

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPathForSelectedRow = tableView.indexPathForSelectedRow
        super.viewWillAppear(animated)
        
        categoryLabel.textColor = Style.labelTextColor
        stockLabel.textColor = Style.labelTextColor
        memoLabel.textColor = Style.labelTextColor
        category.textColor = Style.labelTextColor
        stock.secondaryTintColor = Style.checkboxSecondaryTintColor
        editButtonLabel.textColor = Style.labelTextColor
        reminderButtonLabel.textColor = Style.labelTextColor
        amazonButtonLabel.textColor = Style.labelTextColor
        deleteButtonLabel.textColor = Style.deleteColor
        self.tableView.backgroundColor = Style.basicBackgroundColor
        let attribute = [NSAttributedString.Key.foregroundColor:Style.secondaryColor]
        order.setTitleTextAttributes(attribute, for: .normal)
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        
        let realm = try! Realm()
        let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientId)
        if ing == nil {
            let noIngredientAlertView = CustomAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            noIngredientAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            noIngredientAlertView.alertStatusBarStyle = Style.statusBarStyle
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
            
            editButton.backgroundColor = Style.secondaryColor
            editButton.tintColor = Style.basicBackgroundColor
            reminderButton.backgroundColor = Style.secondaryColor
            reminderButton.tintColor = Style.basicBackgroundColor
            amazonButton.backgroundColor = Style.secondaryColor
            amazonButton.tintColor = Style.basicBackgroundColor
            deleteButton.backgroundColor = Style.deleteColor
            deleteButton.tintColor = Style.basicBackgroundColor
            
            reloadIngredientRecipeBasicList()
            
            if Amazon.product.contains(ingredient.ingredientName.withoutMiddleDot()){
                amazonContainerView.isHidden = false
            }else{
                amazonContainerView.isHidden = true
            }
            
            if ingredient.recipeIngredients.count > 0{
                deleteContainerView.isHidden = true
            }else{
                deleteContainerView.isHidden = false
            }

            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.reloadData()
            
//            if let index = indexPathForSelectedRow {
//                if tableView.numberOfRows(inSection: 1) > index.row{
//                    let nowRecipeId = (tableView.cellForRow(at: index) as? IngredientRecipeListTableViewCell)?.recipeId
//                    if nowRecipeId != nil && selectedRecipeId != nil{
//                        if nowRecipeId! == selectedRecipeId!{
//                            tableView.selectRow(at: indexPathForSelectedRow, animated: false, scrollPosition: .none)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                self.tableView.deselectRow(at: index, animated: true)
//                            }
//                        }
//                    }
//                }
//            }

            selectedRecipeId = nil
        }
    }
    
    // MARK: - Set Style
    private func initActionButtonStyleOf(_ button: UIButton, with imageName: String){
        button.layer.cornerRadius = button.frame.size.width / 2
        button.clipsToBounds = true
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
    }

    func reloadIngredientRecipeBasicList(){
        ingredientRecipeBasicList.removeAll()
        for recipeIngredient in ingredient.recipeIngredients{
            ingredientRecipeBasicList.append(IngredientRecipeBasic(recipeId: recipeIngredient.recipe.id, recipeName: recipeIngredient.recipe.recipeName, shortageNum: recipeIngredient.recipe.shortageNum, lastViewDate: recipeIngredient.recipe.lastViewDate, madeNum: recipeIngredient.recipe.madeNum, favorites: recipeIngredient.recipe.favorites))
        }
        
        if order.selectedSegmentIndex == 1{
            ingredientRecipeBasicList.sort { (a:IngredientRecipeBasic, b:IngredientRecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.recipeName.localizedStandardCompare(b.recipeName) == .orderedAscending
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        }else if order.selectedSegmentIndex == 2{
            ingredientRecipeBasicList.sort(by: { (a:IngredientRecipeBasic, b:IngredientRecipeBasic) -> Bool in
                if a.lastViewDate == nil{
                    if b.lastViewDate == nil{
                        return a.recipeName.localizedStandardCompare(b.recipeName) == .orderedAscending
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
                    return a.recipeName.localizedStandardCompare(b.recipeName) == .orderedAscending
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        }else{
            ingredientRecipeBasicList.sort(by: { $0.recipeName.localizedStandardCompare($1.recipeName) == .orderedAscending })
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
                return UITableView.automaticDimension
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
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            return cell
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row > 0{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientRecipeList", for: indexPath) as! IngredientRecipeListTableViewCell
                    
                    let realm = try! Realm()
                    let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: ingredientRecipeBasicList[indexPath.row - 1].recipeId)!

                    if let image = recipe.imageData {
                        cell.photo.image = UIImage(data: image as Data)
                    }else{
                        if Style.isDark{
                            cell.photo.image = UIImage(named: "no-photo-dark")
                        }else{
                            cell.photo.image = UIImage(named: "no-photo")
                        }
                    }
                    
                    cell.recipeName.text = recipe.recipeName
                    cell.recipeName.backgroundColor = Style.basicBackgroundColor
                    cell.recipeName.clipsToBounds = true
                    switch recipe.favorites{
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
                    for ri in recipe.recipeIngredients{
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
                    
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                    cell.selectionStyle = .default
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 77, bottom: 0, right: 0)
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
            ingredient.stockFlag = stock.checkState == .checked ? true : false
            for ri in ingredient.recipeIngredients{
                ri.recipe.updateShortageNum()
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
        var urlStr : String = "com.amazon.mobile.shopping://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName.withoutMiddleDot() + "&linkCode=sl2&tag=uchicock-22"
        var url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)

        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }else{
            urlStr = "https://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName.withoutMiddleDot() + "&linkCode=sl2&tag=uchicock-22"
            url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if ingredient.recipeIngredients.count > 0 {
            let alertView = CustomAlertController(title: nil, message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        } else{
            let deleteAlertView = CustomAlertController(title: nil, message: "本当に削除しますか？", preferredStyle: .alert)
            deleteAlertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(self.ingredient)
                }
                _ = self.navigationController?.popViewController(animated: true)
            }))
            deleteAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
            deleteAlertView.alertStatusBarStyle = Style.statusBarStyle
            deleteAlertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(deleteAlertView, animated: true, completion: nil)
        }
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
                selectedRecipeId = ingredientRecipeBasicList[indexPath.row - 1].recipeId
                vc.recipeId = ingredientRecipeBasicList[indexPath.row - 1].recipeId
            }
        }else if segue.identifier == "CreateEvent" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! ReminderTableViewController
            evc.ingredientName = self.ingredient.ingredientName
        }
    }
    
    func closeEditVC(_ editVC: IngredientEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
    }

}
