//
//  IngredientDetailTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/07.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientDetailTableViewController: UITableViewController, UIViewControllerTransitioningDelegate, UITableViewDataSourcePrefetching {

    @IBOutlet weak var ingredientName: CustomTextView!
    @IBOutlet weak var ingredientNameYomiLabel: UILabel!
    @IBOutlet weak var reminderImage: UIImageView!
    @IBOutlet weak var reminderMessageLabel: CustomLabel!
    @IBOutlet weak var removeReminderButton: UIButton!
    @IBOutlet weak var stockRecommendLabel: UILabel!
    @IBOutlet weak var category: CustomLabel!
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var stock: CircularCheckbox!
    @IBOutlet weak var memo: CustomTextView!
    @IBOutlet weak var memoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var amazonButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    @IBOutlet weak var amazonContainerView: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    @IBOutlet weak var recipeOrderLabel: UILabel!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    
    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<RecipeBasic>()

    var hasIngredientDeleted = false
    var isOnReminder = false
    var coverView = UIView(frame: CGRect.zero)
    var deleteImageView = UIImageView(frame: CGRect.zero)

    let selectedCellBackgroundView = UIView()
    var recipeOrder = 2
    var selectedRecipeId: String? = nil

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientName.isScrollEnabled = false
        ingredientName.textContainerInset = .zero
        ingredientName.textContainer.lineFragmentPadding = 0
        ingredientName.font = UIFont.systemFont(ofSize: 25.0)
        memo.isScrollEnabled = false
        memo.textContainerInset = .zero
        memo.textContainer.lineFragmentPadding = 0
        memo.font = UIFont.systemFont(ofSize: 15.0)
        stock.boxLineWidth = 1.0
        
        removeReminderButton.layer.borderWidth = 1.0
        removeReminderButton.layer.cornerRadius = removeReminderButton.frame.size.height / 2

        editButton.layer.cornerRadius = editButton.frame.size.width / 2
        editButton.clipsToBounds = true
        reminderButton.layer.cornerRadius = reminderButton.frame.size.width / 2
        reminderButton.clipsToBounds = true
        amazonButton.layer.cornerRadius = amazonButton.frame.size.width / 2
        amazonButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = deleteButton.frame.size.width / 2
        deleteButton.clipsToBounds = true

        recipeOrderLabel.font = UIFont.boldSystemFont(ofSize: 17.0)

        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        
        reminderImage.tintColor = UchicockStyle.primaryColor
        reminderMessageLabel.textColor = UchicockStyle.primaryColor
        removeReminderButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        removeReminderButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        removeReminderButton.backgroundColor = UchicockStyle.basicBackgroundColor

        stock.secondaryTintColor = UchicockStyle.primaryColor
        stock.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        stockRecommendLabel.textColor = UchicockStyle.primaryColor
        alcoholIconImage.tintColor = UchicockStyle.primaryColor
        deleteButtonLabel.textColor = UchicockStyle.alertColor
        recipeOrderLabel.textColor = UchicockStyle.primaryColor
        
        let realm = try! Realm()
        let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientId)
        if ing == nil {
            hasIngredientDeleted = true
            coverView.backgroundColor = UchicockStyle.basicBackgroundColor
            self.tableView.addSubview(coverView)
            deleteImageView.contentMode = .scaleAspectFit
            deleteImageView.image = UIImage(named: "button-delete")
            deleteImageView.tintColor = UchicockStyle.labelTextColorLight
            coverView.addSubview(deleteImageView)
            self.tableView.setNeedsLayout()
        } else {
            hasIngredientDeleted = false
            ingredient = ing!
            self.navigationItem.title = ingredient.ingredientName
            
            isOnReminder = ingredient.reminderSetDate != nil
            
            ingredientName.text = ingredient.ingredientName
            
            ingredientNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
            if ingredient.ingredientName.katakanaLowercasedForSearch() == ingredient.ingredientNameYomi.katakanaLowercasedForSearch(){
                ingredientNameYomiLabel.isHidden = true
                ingredientNameYomiLabel.text = " "
            }else{
                ingredientNameYomiLabel.isHidden = false
                ingredientNameYomiLabel.text = ingredient.ingredientNameYomi
            }

            updateIngredientRecommendLabel()
            
            switch ingredient.category{
            case 0:
                category.text = "アルコール"
                alcoholIconImage.isHidden = false
                alcoholIconImageWidthConstraint.constant = 17
            case 1:
                category.text = "ノンアルコール"
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            case 2:
                category.text = "その他"
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            default:
                category.text = "その他"
                alcoholIconImage.isHidden = true
                alcoholIconImageWidthConstraint.constant = 0
            }
            
            stock.stateChangeAnimation = .fade
            stock.animationDuration = 0
            if ingredient.stockFlag{
                stock.setCheckState(.checked, animated: true)
            }else{
                stock.setCheckState(.unchecked, animated: true)
            }
            stock.animationDuration = 0.3
            stock.stateChangeAnimation = .expand
            
            memo.text = ingredient.memo
            memo.textColor = UchicockStyle.labelTextColorLight
            if ingredient.memo.isEmpty {
                memoBottomConstraint.constant = 0
                memo.isHidden = true
            }else{
                memoBottomConstraint.constant = 15
                memo.isHidden = false
            }

            editButton.backgroundColor = UchicockStyle.primaryColor
            editButton.tintColor = UchicockStyle.basicBackgroundColor
            reminderButton.backgroundColor = UchicockStyle.primaryColor
            reminderButton.tintColor = UchicockStyle.basicBackgroundColor
            amazonButton.backgroundColor = UchicockStyle.primaryColor
            amazonButton.tintColor = UchicockStyle.basicBackgroundColor
            deleteButton.backgroundColor = UchicockStyle.alertColor
            deleteButton.tintColor = UchicockStyle.basicBackgroundColor
            
            reloadIngredientRecipeBasicList()
            
            if Amazon.product.contains(ingredient.ingredientName.withoutMiddleSpaceAndMiddleDot()){
                amazonContainerView.isHidden = false
            }else{
                amazonContainerView.isHidden = true
            }
            
            if ingredient.recipeIngredients.count > 0{
                deleteContainerView.isHidden = true
            }else{
                deleteContainerView.isHidden = false
            }
            
            tableView.estimatedRowHeight = 70
            tableView.rowHeight = UITableView.automaticDimension
            tableView.reloadData()
        }
        
        if tableView.indexPathsForVisibleRows != nil && selectedRecipeId != nil {
            for indexPath in tableView.indexPathsForVisibleRows! {
                if indexPath.section == 0 || indexPath.row == 0 { continue }
                if ingredientRecipeBasicList.count + 1 > indexPath.row {
                    if ingredientRecipeBasicList[indexPath.row - 1].id == selectedRecipeId! {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                        break
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if hasIngredientDeleted{
            tableView.contentOffset.y = 0
            coverView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
            deleteImageView.frame = CGRect(x: 0, y: tableView.frame.height / 5, width: tableView.frame.width, height: 60)
            tableView.bringSubviewToFront(coverView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasIngredientDeleted{
            let noIngredientAlertView = CustomAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                noIngredientAlertView.overrideUserInterfaceStyle = .dark
            }
            noIngredientAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.navigationController?.popViewController(animated: true)
            }))
            noIngredientAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            noIngredientAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noIngredientAlertView, animated: true, completion: nil)
        }else{
            if let path = tableView.indexPathForSelectedRow{
                self.tableView.deselectRow(at: path, animated: true)
            }
            selectedRecipeId = nil
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
            stockRecommendLabel.text = "入手すると新たに" + String(ingredient.contributionToRecipeAvailability) + "レシピ作れる！"
        }
    }
    
    private func setReminderBadge(){
        let realm = try! Realm()
        let reminderNum = realm.objects(Ingredient.self).filter("reminderSetDate != nil").count

        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[1]
            tabItem.badgeColor = UchicockStyle.badgeBackgroundColor
            if reminderNum == 0{
                tabItem.badgeValue = nil
            }else{
                tabItem.badgeValue = "!"
            }
        }
    }
    
    private func reloadIngredientRecipeBasicList(){
        ingredientRecipeBasicList.removeAll()
        
        for recipeIngredient in ingredient.recipeIngredients{
            ingredientRecipeBasicList.append(RecipeBasic(id: recipeIngredient.recipe.id, name: recipeIngredient.recipe.recipeName, nameYomi: recipeIngredient.recipe.recipeNameYomi, katakanaLowercasedNameForSearch: recipeIngredient.recipe.katakanaLowercasedNameForSearch,shortageNum: recipeIngredient.recipe.shortageNum, favorites: recipeIngredient.recipe.favorites, lastViewDate: recipeIngredient.recipe.lastViewDate, madeNum: recipeIngredient.recipe.madeNum, method: recipeIngredient.recipe.method, style: recipeIngredient.recipe.style, strength: recipeIngredient.recipe.strength, imageFileName: recipeIngredient.recipe.imageFileName))
        }
        
        switch  recipeOrder {
        case 1:
            ingredientRecipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        case 2:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        case 3:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        case 4:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.favorites > b.favorites
                }
            }
        case 5:
            ingredientRecipeBasicList.sort(by: { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.lastViewDate == nil{
                    if b.lastViewDate == nil{
                        return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
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
            ingredientRecipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 30 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if ingredient.reminderSetDate == nil{
                if indexPath.row == 4{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 5, section: 0))
                }else{
                    return UITableView.automaticDimension
                }
            }else{
                if indexPath.row == 5{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 5, section: 0))
                }else{
                    return UITableView.automaticDimension
                }
            }
        }else if indexPath.section == 1{
            if ingredient.isInvalidated == false{
                if ingredient.recipeIngredients.count > 0{
                    if indexPath.row == 0{
                        return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
                    }else{
                        return 70
                    }
                }
            }else{
                return 70
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        if section == 1 {
            if ingredient.isInvalidated == false {
                if ingredient.recipeIngredients.count > 0 {
                    header?.textLabel?.text = "\(String(ingredient.recipeIngredients.count))個のレシピで使われています"
                }else {
                    header?.textLabel?.text = "この材料を使うレシピはありません"
                }
            }
        }else{
            header?.textLabel?.text = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if ingredient.reminderSetDate == nil{
                return 5
            }else{
                return 6
            }
        }else if section == 1 {
            if ingredient.isInvalidated{
                return 0
            }else{
                if ingredient.recipeIngredients.count > 0{
                    return ingredient.recipeIngredients.count + 1
                }
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
                    var title1 = "名前順"
                    var title2 = "作れる順"
                    var title3 = "作った回数順"
                    var title4 = "お気に入り順"
                    var title5 = "最近見た順"
                    switch self.recipeOrder {
                    case 1: title1 = "✔︎ 名前順"
                    case 2: title2 = "✔︎ 作れる順"
                    case 3: title3 = "✔︎ 作った回数順"
                    case 4: title4 = "✔︎ お気に入り順"
                    case 5: title5 = "✔︎ 最近見た順"
                    default: break
                    }
                    let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                        alertView.overrideUserInterfaceStyle = .dark
                    }
                    alertView.addAction(UIAlertAction(title: title1,style: .default){
                        action in
                        self.recipeOrder = 1
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: title2,style: .default){
                        action in
                        self.recipeOrder = 2
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: title3,style: .default){
                        action in
                        self.recipeOrder = 3
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: title4,style: .default){
                        action in
                        self.recipeOrder = 4
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: title5,style: .default){
                        action in
                        self.recipeOrder = 5
                        self.reloadIngredientRecipeBasicList()
                        self.tableView.reloadData()
                    })
                    alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
                    alertView.popoverPresentationController?.sourceView = self.view
                    alertView.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: indexPath)!.frame
                    alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    present(alertView, animated: true, completion: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == 1, indexPath.row > 0{
            let previewProvider: () -> RecipeDetailTableViewController? = {
                let vc = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
                vc.fromContextualMenu = true
                vc.recipeId = self.ingredientRecipeBasicList[indexPath.row - 1].id
                return vc
            }
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: previewProvider, actionProvider: nil)
        }else{
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating){
        guard let indexPath = configuration.identifier as? IndexPath else { return }

        animator.addCompletion {
            self.performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if ingredient.reminderSetDate == nil{
                if indexPath.row == 0{
                    let cell = super.tableView(tableView, cellForRowAt: indexPath)
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: indexPath.section))
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
                    return cell
                }
            }else{
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
                return cell
            }
        }else if indexPath.section == 1{
            guard ingredient.isInvalidated == false else { return UITableViewCell() }

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
                    cell.shouldHighlightOnlyWhenAvailable = true
                    cell.recipe = recipe
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    return cell
                }else{
                    let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                    switch recipeOrder{
                    case 1:
                        recipeOrderLabel.text = "名前順（タップで変更）"
                    case 2:
                        recipeOrderLabel.text = "作れる順（タップで変更）"
                    case 3:
                        recipeOrderLabel.text = "作った回数順（タップで変更）"
                    case 4:
                        recipeOrderLabel.text = "お気に入り順（タップで変更）"
                    case 5:
                        recipeOrderLabel.text = "最近見た順（タップで変更）"
                    default:
                        recipeOrderLabel.text = "作れる順（タップで変更）"
                    }
                    cell.backgroundColor = UchicockStyle.basicBackgroundColor
                    cell.selectedBackgroundView = selectedCellBackgroundView
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            if indexPath.section == 1 && indexPath.row > 0{
                let imageFileName = self.ingredientRecipeBasicList[indexPath.row - 1].imageFileName
                DispatchQueue.global(qos: .userInteractive).async{
                    ImageUtil.saveToCache(imageFileName: imageFileName)
                }
            }
        }
    }

    // MARK: - IBAction
    @IBAction func removeReminderButtonTapped(_ sender: UIButton) {
        let realm = try! Realm()
        try! realm.write {
            ingredient.reminderSetDate = nil
        }
        isOnReminder = false
        tableView.deleteRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
        
        setReminderBadge()
    }
    
    @IBAction func stockTapped(_ sender: CircularCheckbox) {
        let realm = try! Realm()
        try! realm.write {
            ingredient.stockFlag = stock.checkState == .checked ? true : false
            for ri in ingredient.recipeIngredients{
                ri.recipe.updateShortageNum()
            }
        }
        
        if stock.checkState == .checked && ingredient.reminderSetDate != nil{
            let alertView = CustomAlertController(title: nil, message: "この材料は購入リマインダーに登録されています。\n解除しますか？", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            alertView.addAction(UIAlertAction(title: "解除しない", style: .cancel, handler: {action in}))
            alertView.addAction(UIAlertAction(title: "解除する", style: .default, handler: {action in
                try! realm.write {
                    self.ingredient.reminderSetDate = nil
                }
                self.isOnReminder = false
                self.tableView.deleteRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
                self.setReminderBadge()
            }))
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        }
        
        updateIngredientRecommendLabel()
        reloadIngredientRecipeBasicList()
        tableView.reloadData()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PushEditIngredient", sender: nil)
    }
    
    @IBAction func reminderButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Reminder", bundle: nil)
        guard let nvc = storyboard.instantiateViewController(withIdentifier: "ReminderNavigationController") as? BasicNavigationController else{
            return
        }
        guard let vc = nvc.visibleViewController as? ReminderTableViewController else{
            return
        }
        vc.ingredient = self.ingredient
        vc.onDoneBlock = {
            self.setReminderBadge()
            if self.isOnReminder == false && self.ingredient.reminderSetDate != nil {
                self.isOnReminder = true
                self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .middle)
            }
        }

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .pageSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }
        present(nvc, animated: true)
    }
    
    @IBAction func amazonButtonTapped(_ sender: UIButton) {
        var urlStr : String = "com.amazon.mobile.shopping://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName.withoutMiddleSpaceAndMiddleDot() + "&linkCode=sl2&tag=uchicock-22"
        var url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)

        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }else{
            urlStr = "https://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName.withoutMiddleSpaceAndMiddleDot() + "&linkCode=sl2&tag=uchicock-22"
            url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if ingredient.recipeIngredients.count > 0 {
            let alertView = CustomAlertController(title: nil, message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        } else{
            let deleteAlertView = CustomAlertController(title: nil, message: "この材料を本当に削除しますか？", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                deleteAlertView.overrideUserInterfaceStyle = .dark
            }
            deleteAlertView.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {action in
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(self.ingredient)
                }
                self.setReminderBadge()
                _ = self.navigationController?.popViewController(animated: true)
            }))
            deleteAlertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
            deleteAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
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
            let enc = segue.destination as! BasicNavigationController
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
