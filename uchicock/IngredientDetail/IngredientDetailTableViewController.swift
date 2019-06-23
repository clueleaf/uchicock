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

class IngredientDetailTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var ingredientName: CopyableLabel!
    @IBOutlet weak var stockRecommendLabel: UILabel!
    @IBOutlet weak var category: CustomLabel!
    @IBOutlet weak var stock: M13Checkbox!
    @IBOutlet weak var memo: CopyableLabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var amazonButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    @IBOutlet weak var amazonContainerView: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    
    var editVC : IngredientEditTableViewController!
    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<RecipeBasic>()
    let selectedCellBackgroundView = UIView()
    var recipeOrder = 2
    var selectedRecipeId: String? = nil
    
    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stock.boxLineWidth = 1.0
        stock.markType = .checkmark
        stock.boxType = .circle
        
        stockRecommendLabel.isHidden = true
        
        initActionButtonStyleOf(editButton, with: "edit")
        initActionButtonStyleOf(reminderButton, with: "reminder")
        initActionButtonStyleOf(amazonButton, with: "amazon")
        initActionButtonStyleOf(deleteButton, with: "delete")

        self.tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPathForSelectedRow = tableView.indexPathForSelectedRow
        super.viewWillAppear(animated)

        setupVC()
        if let index = indexPathForSelectedRow {
            if tableView.numberOfRows(inSection: 1) > index.row{
                let nowRecipeId = (tableView.cellForRow(at: index) as? RecipeTableViewCell)?.recipe.id
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
    
    private func setupVC(){
        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        
        stock.secondaryTintColor = Style.checkboxSecondaryTintColor
        stockRecommendLabel.textColor = Style.secondaryColor
        deleteButtonLabel.textColor = Style.deleteColor

        let realm = try! Realm()
        let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientId)
        if ing == nil {
            let noIngredientAlertView = CustomAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            noIngredientAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.navigationController?.popViewController(animated: true)
            }))
            noIngredientAlertView.alertStatusBarStyle = Style.statusBarStyle
            noIngredientAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noIngredientAlertView, animated: true, completion: nil)
        } else {
            ingredient = ing!
            self.navigationItem.title = ingredient.ingredientName
            
            ingredientName.text = ingredient.ingredientName
            
            updateIngredientRecommendLabel()
            
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
        }
    }
    
    // MARK: - Set Style
    private func updateIngredientRecommendLabel(){
        let realm = try! Realm()
        try! realm.write {
            ingredient.calcContribution()
        }
        if ingredient.contributionToRecipeAvailability == 0{
            stockRecommendLabel.isHidden = true
            stockRecommendLabel.text = ""
        }else{
            stockRecommendLabel.isHidden = false
            stockRecommendLabel.text = "入手すると新たに" + String(ingredient.contributionToRecipeAvailability) + "レシピ作れます！"
        }
    }
    
    private func initActionButtonStyleOf(_ button: UIButton, with imageName: String){
        button.layer.cornerRadius = button.frame.size.width / 2
        button.clipsToBounds = true
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
    }

    func reloadIngredientRecipeBasicList(){
        ingredientRecipeBasicList.removeAll()
        for recipeIngredient in ingredient.recipeIngredients{
            ingredientRecipeBasicList.append(RecipeBasic(id: recipeIngredient.recipe.id, name: recipeIngredient.recipe.recipeName, shortageNum: recipeIngredient.recipe.shortageNum, favorites: recipeIngredient.recipe.favorites, lastViewDate: recipeIngredient.recipe.lastViewDate, madeNum: recipeIngredient.recipe.madeNum, method: recipeIngredient.recipe.method, style: recipeIngredient.recipe.style))
        }
        
        switch  recipeOrder {
        case 1:
            ingredientRecipeBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
        case 2:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.name.localizedStandardCompare(b.name) == .orderedAscending
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        case 3:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    return a.name.localizedStandardCompare(b.name) == .orderedAscending
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        case 4:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    return a.name.localizedStandardCompare(b.name) == .orderedAscending
                }else{
                    return a.favorites > b.favorites
                }
            }
        case 5:
            ingredientRecipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.lastViewDate == nil{
                    if b.lastViewDate == nil{
                        return a.name.localizedStandardCompare(b.name) == .orderedAscending
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
        default:
            ingredientRecipeBasicList.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
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
            if indexPath.row == 4{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }else{
                return UITableView.automaticDimension
            }
        }else if indexPath.section == 1{
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row == 0{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
                }else{
                    return 70
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
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if ingredient.recipeIngredients.count > 0{
                if indexPath.row > 0 {
                    performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
                }else{
                    let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alertView.addAction(UIAlertAction(title: "名前順",style: .default){
                        action in
                        self.recipeOrder = 1
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: "作れる順",style: .default){
                        action in
                        self.recipeOrder = 2
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: "作った回数順",style: .default){
                        action in
                        self.recipeOrder = 3
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: "お気に入り順",style: .default){
                        action in
                        self.recipeOrder = 4
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: "最近見た順",style: .default){
                        action in
                        self.recipeOrder = 5
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                    alertView.alertStatusBarStyle = Style.statusBarStyle
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    present(alertView, animated: true, completion: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
                    let realm = try! Realm()
                    let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: ingredientRecipeBasicList[indexPath.row - 1].id)!
                    if recipeOrder == 3{
                        cell.subInfoType = 1
                    }else if recipeOrder == 5{
                        cell.subInfoType = 2
                    }else{
                        cell.subInfoType = 0
                    }
                    cell.hightlightRecipeNameOnlyAvailable = true
                    cell.recipe = recipe
                    cell.backgroundColor = Style.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    cell.textLabel?.textColor = Style.secondaryColor
                    switch recipeOrder{
                    case 1:
                        cell.textLabel?.text = "名前順（タップで変更）"
                    case 2:
                        cell.textLabel?.text = "作れる順（タップで変更）"
                    case 3:
                        cell.textLabel?.text = "作った回数順（タップで変更）"
                    case 4:
                        cell.textLabel?.text = "お気に入り順（タップで変更）"
                    case 5:
                        cell.textLabel?.text = "最近見た順（タップで変更）"
                    default:
                        cell.textLabel?.text = "作れる順（タップで変更）"
                    }
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
                    cell.textLabel?.textAlignment = .center
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
        updateIngredientRecommendLabel()
        reloadIngredientRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PushEditIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func reminderButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Reminder", bundle: nil)
        guard let nvc = storyboard.instantiateViewController(withIdentifier: "ReminderNavigationController") as? BasicNavigationController else{
            return
        }
        nvc.modalPresentationStyle = .custom
        nvc.transitioningDelegate = self
        guard let vc = nvc.visibleViewController as? ReminderTableViewController else{
            return
        }
        vc.ingredientName = self.ingredient.ingredientName
        vc.onDoneBlock = {
            self.setupVC()
        }
        vc.interactor = interactor
        present(nvc, animated: true)
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
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        return pc
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissModalAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
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
                selectedRecipeId = ingredientRecipeBasicList[indexPath.row - 1].id
                vc.recipeId = ingredientRecipeBasicList[indexPath.row - 1].id
            }
        }
    }
    
    func closeEditVC(_ editVC: IngredientEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
    }

}
