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

    @IBOutlet weak var ingredientNameTextView: CustomTextView!
    @IBOutlet weak var ingredientNameYomiLabel: UILabel!
    @IBOutlet weak var reminderImage: UIImageView!
    @IBOutlet weak var reminderMessageLabel: CustomLabel!
    @IBOutlet weak var removeReminderButton: UIButton!
    @IBOutlet weak var alcoholIconImage: UIImageView!
    @IBOutlet weak var alcoholIconImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryLabel: CustomLabel!
    @IBOutlet weak var stockRecommendLabel: UILabel!
    @IBOutlet weak var stockCheckbox: CircularCheckbox!
    @IBOutlet weak var memoTextView: CustomTextView!
    @IBOutlet weak var memoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var amazonButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    @IBOutlet weak var amazonContainerView: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    @IBOutlet weak var recipeDisplayOrderLabel: UILabel!
    
    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<RecipeBasic>()
    var hasIngredientDeleted = false

    let selectedCellBackgroundView = UIView()
    var selectedRecipeId: String? = nil
    var recipeSort = RecipeSortType.makeableName

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientNameTextView.textContainerInset = .zero
        ingredientNameTextView.textContainer.lineFragmentPadding = 0
        ingredientNameTextView.font = UIFont.systemFont(ofSize: 25.0)
        memoTextView.textContainerInset = .zero
        memoTextView.textContainer.lineFragmentPadding = 0
        memoTextView.font = UIFont.systemFont(ofSize: 15.0)
        stockCheckbox.boxLineWidth = 1.0
        
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

        stockCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        stockCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        stockRecommendLabel.textColor = UchicockStyle.primaryColor
        alcoholIconImage.tintColor = UchicockStyle.primaryColor
        deleteButtonLabel.textColor = UchicockStyle.alertColor
        recipeDisplayOrderLabel.textColor = UchicockStyle.primaryColor
        
        let realm = try! Realm()
        let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientId)
        guard ing != nil else{
            hasIngredientDeleted = true
            tableView.contentOffset.y = 0

            let coverView = UIView()
            coverView.backgroundColor = UchicockStyle.basicBackgroundColor
            self.tableView.addSubview(coverView)
            coverView.translatesAutoresizingMaskIntoConstraints = false

            let coverViewLeadingConstraint = NSLayoutConstraint(item: coverView, attribute: .leading, relatedBy: .equal, toItem: tableView.frameLayoutGuide, attribute: .leading, multiplier: 1, constant: 0)
            let coverViewTopConstraint = NSLayoutConstraint(item: coverView, attribute: .top, relatedBy: .equal, toItem: tableView.frameLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
            let coverViewTrailingConstraint = NSLayoutConstraint(item: coverView, attribute: .trailing, relatedBy: .equal, toItem: tableView.frameLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0)
            let coverViewBottomConstraint = NSLayoutConstraint(item: coverView, attribute: .bottom, relatedBy: .equal, toItem: tableView.frameLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([coverViewLeadingConstraint, coverViewTopConstraint, coverViewTrailingConstraint, coverViewBottomConstraint])

            let deleteImageView = UIImageView()
            deleteImageView.contentMode = .scaleAspectFit
            deleteImageView.image = UIImage(named: "button-delete")
            deleteImageView.tintColor = UchicockStyle.labelTextColorLight
            coverView.addSubview(deleteImageView)
            self.tableView.setNeedsLayout()
            deleteImageView.translatesAutoresizingMaskIntoConstraints = false

            let deleteImageViewLeadingConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .leading, relatedBy: .equal, toItem: coverView, attribute: .leading, multiplier: 1, constant: 0)
            let deleteImageViewTopConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .top, relatedBy: .equal, toItem: coverView, attribute: .bottom, multiplier: 0.2, constant: 0)
            let deleteImageViewTrailingConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .trailing, relatedBy: .equal, toItem: coverView, attribute: .trailing, multiplier: 1, constant: 0)
            let deleteImageViewHeightConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
            NSLayoutConstraint.activate([deleteImageViewLeadingConstraint, deleteImageViewTopConstraint, deleteImageViewTrailingConstraint, deleteImageViewHeightConstraint])

            return
        }
        
        hasIngredientDeleted = false
        ingredient = ing!
        self.navigationItem.title = ingredient.ingredientName
        
        ingredientNameTextView.text = ingredient.ingredientName
        
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
            categoryLabel.text = "アルコール"
            alcoholIconImage.isHidden = false
            alcoholIconImageWidthConstraint.constant = 17
        case 1:
            categoryLabel.text = "ノンアルコール"
            alcoholIconImage.isHidden = true
            alcoholIconImageWidthConstraint.constant = 0
        case 2:
            categoryLabel.text = "その他"
            alcoholIconImage.isHidden = true
            alcoholIconImageWidthConstraint.constant = 0
        default:
            categoryLabel.text = "その他"
            alcoholIconImage.isHidden = true
            alcoholIconImageWidthConstraint.constant = 0
        }
        
        stockCheckbox.stateChangeAnimation = .fade
        stockCheckbox.animationDuration = 0
        if ingredient.stockFlag{
            stockCheckbox.setCheckState(.checked, animated: true)
        }else{
            stockCheckbox.setCheckState(.unchecked, animated: true)
        }
        stockCheckbox.animationDuration = 0.3
        stockCheckbox.stateChangeAnimation = .expand
        
        memoTextView.text = ingredient.memo
        memoTextView.textColor = UchicockStyle.labelTextColorLight
        if ingredient.memo.isEmpty {
            memoBottomConstraint.constant = 0
            memoTextView.isHidden = true
        }else{
            memoBottomConstraint.constant = 15
            memoTextView.isHidden = false
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
        
        amazonContainerView.isHidden = Amazon.product.contains(ingredient.ingredientName.withoutMiddleSpaceAndMiddleDot()) == false
        deleteContainerView.isHidden = ingredient.recipeIngredients.count > 0
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
        
        if tableView.indexPathsForVisibleRows != nil && selectedRecipeId != nil {
            for indexPath in tableView.indexPathsForVisibleRows! where indexPath.section != 0 && indexPath.row != 0{
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard hasIngredientDeleted == false else{
            let noIngredientAlertView = CustomAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                noIngredientAlertView.overrideUserInterfaceStyle = .dark
            }
            let okAction = UIAlertAction(title: "OK", style: .default){action in
                self.navigationController?.popViewController(animated: true)
            }
            okAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
            noIngredientAlertView.addAction(okAction)
            noIngredientAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            noIngredientAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noIngredientAlertView, animated: true, completion: nil)
            return
        }

        if let path = tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: path, animated: true)
        }
        selectedRecipeId = nil
    }
    
    // MARK: - Logic functions
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
            tabItem.badgeValue = reminderNum == 0 ? nil : "!"
        }
    }
    
    private func reloadIngredientRecipeBasicList(){
        ingredientRecipeBasicList.removeAll()
        
        for recipeIngredient in ingredient.recipeIngredients{
            ingredientRecipeBasicList.append(RecipeBasic(
                id: recipeIngredient.recipe.id,
                name: recipeIngredient.recipe.recipeName,
                nameYomi: recipeIngredient.recipe.recipeNameYomi,
                katakanaLowercasedNameForSearch: "",
                shortageNum: recipeIngredient.recipe.shortageNum,
                shortageIngredientName: recipeIngredient.recipe.shortageIngredientName,
                lastViewDate: recipeIngredient.recipe.lastViewDate,
                favorites: recipeIngredient.recipe.favorites,
                style: -1,
                method: -1,
                strength: -1,
                madeNum: recipeIngredient.recipe.madeNum,
                imageFileName: recipeIngredient.recipe.imageFileName
            ))
        }
        
        switch recipeSort {
        case .name:
            ingredientRecipeBasicList.sort(by: { $0.nameYomi.localizedStandardCompare($1.nameYomi) == .orderedAscending })
        case .makeableName:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        case .madenumName:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.madeNum == b.madeNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.madeNum > b.madeNum
                }
            }
        case .favoriteName:
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.favorites == b.favorites {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.favorites > b.favorites
                }
            }
        case .viewedName:
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
            ingredientRecipeBasicList.sort { (a:RecipeBasic, b:RecipeBasic) -> Bool in
                if a.shortageNum == b.shortageNum {
                    return a.nameYomi.localizedStandardCompare(b.nameYomi) == .orderedAscending
                }else{
                    return a.shortageNum < b.shortageNum
                }
            }
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 30 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if ingredient.isInvalidated == false && ingredient.reminderSetDate != nil{
                if indexPath.row == 5{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 5, section: 0))
                }else{
                    return UITableView.automaticDimension
                }
            }else{
                if indexPath.row == 4{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 5, section: 0))
                }else{
                    return UITableView.automaticDimension
                }
            }
        }else if indexPath.section == 1{
            if ingredient.isInvalidated == false && ingredient.recipeIngredients.count > 0{
                if indexPath.row == 0{
                    return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
                }else{
                    return 70
                }
            }
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasIngredientDeleted ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        if section == 1 && ingredient.isInvalidated == false {
            if ingredient.recipeIngredients.count > 0 {
                header?.textLabel?.text = "\(String(ingredient.recipeIngredients.count))個のレシピで使われています"
            }else {
                header?.textLabel?.text = "この材料を使うレシピはありません"
            }
        }else{
            header?.textLabel?.text = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if ingredient.isInvalidated == false && ingredient.reminderSetDate != nil{
                return 6
            }else{
                return 5
            }
        }else if section == 1 {
            if ingredient.isInvalidated == false && ingredient.recipeIngredients.count > 0{
                return ingredient.recipeIngredients.count + 1
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 && ingredient.recipeIngredients.count > 0 else { return }
        
        guard indexPath.row == 0 else{
            performSegue(withIdentifier: "PushRecipeDetail", sender: ingredientRecipeBasicList[indexPath.row - 1].id)
            return
        }
        
        var title1 = "名前順"
        var title2 = "作れる順"
        var title3 = "作った回数順"
        var title4 = "お気に入り順"
        var title5 = "最近見た順"
        
        switch recipeSort {
        case .name: title1 = "✔︎ 名前順"
        case .makeableName: title2 = "✔︎ 作れる順"
        case .madenumName: title3 = "✔︎ 作った回数順"
        case .favoriteName: title4 = "✔︎ お気に入り順"
        case .viewedName: title5 = "✔︎ 最近見た順"
        default: title2 = "✔︎ 作れる順"
        }
        
        let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            alertView.overrideUserInterfaceStyle = .dark
        }
        let action1 = UIAlertAction(title: title1, style: .default){
            action in
            self.recipeSort = .name
            self.reloadIngredientRecipeBasicList()
            self.tableView.reloadData()
        }
        action1.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        alertView.addAction(action1)
        let action2 = UIAlertAction(title: title2, style: .default){
            action in
            self.recipeSort = .makeableName
            self.reloadIngredientRecipeBasicList()
            self.tableView.reloadData()
        }
        action2.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        alertView.addAction(action2)
        let action3 = UIAlertAction(title: title3, style: .default){
            action in
            self.recipeSort = .madenumName
            self.reloadIngredientRecipeBasicList()
            self.tableView.reloadData()
        }
        action3.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        alertView.addAction(action3)
        let action4 = UIAlertAction(title: title4, style: .default){
            action in
            self.recipeSort = .favoriteName
            self.reloadIngredientRecipeBasicList()
            self.tableView.reloadData()
        }
        action4.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        alertView.addAction(action4)
        let action5 = UIAlertAction(title: title5, style: .default){
            action in
            self.recipeSort = .viewedName
            self.reloadIngredientRecipeBasicList()
            self.tableView.reloadData()
        }
        action5.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        alertView.addAction(action5)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        alertView.addAction(cancelAction)
        alertView.popoverPresentationController?.sourceView = self.view
        alertView.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: indexPath)!.frame
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
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
            self.performSegue(withIdentifier: "PushRecipeDetail", sender: self.ingredientRecipeBasicList[indexPath.row - 1].id)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            var cell = UITableViewCell()
            if ingredient.isInvalidated == false && ingredient.reminderSetDate != nil{
                cell = super.tableView(tableView, cellForRowAt: indexPath)
            }else{
                if indexPath.row == 0{
                    cell = super.tableView(tableView, cellForRowAt: indexPath)
                }else{
                    cell = super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: indexPath.section))
                }
            }
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
            return cell
        }else if indexPath.section == 1{
            guard ingredient.isInvalidated == false && ingredient.recipeIngredients.count > 0 else { return UITableViewCell() }

            if indexPath.row > 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
                cell.sortOrder = recipeSort
                cell.shouldHighlightOnlyWhenAvailable = true
                cell.recipe = ingredientRecipeBasicList[indexPath.row - 1]
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                return cell
            }else{
                let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                switch recipeSort{
                case .name: recipeDisplayOrderLabel.text = "名前順（タップで変更）"
                case .makeableName: recipeDisplayOrderLabel.text = "作れる順（タップで変更）"
                case .madenumName: recipeDisplayOrderLabel.text = "作った回数順（タップで変更）"
                case .favoriteName: recipeDisplayOrderLabel.text = "お気に入り順（タップで変更）"
                case .viewedName: recipeDisplayOrderLabel.text = "最近見た順（タップで変更）"
                default: recipeDisplayOrderLabel.text = "作れる順（タップで変更）"
                }
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths where indexPath.section == 1 && indexPath.row > 0{
            let imageFileName = self.ingredientRecipeBasicList[indexPath.row - 1].imageFileName
            DispatchQueue.global(qos: .userInteractive).async{
                ImageUtil.saveToCache(imageFileName: imageFileName)
            }
        }
    }

    // MARK: - IBAction
    @IBAction func removeReminderButtonTapped(_ sender: UIButton) {
        let realm = try! Realm()
        try! realm.write { ingredient.reminderSetDate = nil }
        tableView.deleteRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
        setReminderBadge()
    }
    
    @IBAction func stockTapped(_ sender: CircularCheckbox) {
        let realm = try! Realm()
        try! realm.write {
            ingredient.stockFlag = stockCheckbox.checkState == .checked
            for ri in ingredient.recipeIngredients{
                ri.recipe.updateShortageNum()
            }
        }
        
        if stockCheckbox.checkState == .checked && ingredient.reminderSetDate != nil{
            let alertView = CustomAlertController(title: nil, message: "この材料は購入リマインダーに登録されています。\n解除しますか？", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            let noAction = UIAlertAction(title: "解除しない", style: .cancel, handler: nil)
            noAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
            alertView.addAction(noAction)
            let yesAction = UIAlertAction(title: "解除する", style: .default){action in
                try! realm.write { self.ingredient.reminderSetDate = nil }
                self.tableView.deleteRows(at: [IndexPath(row: 1,section: 0)], with: .middle)
                self.setReminderBadge()
            }
            yesAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
            alertView.addAction(yesAction)
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
        guard let vc = nvc.visibleViewController as? ReminderTableViewController else{ return }

        vc.ingredient = self.ingredient
        vc.onDoneBlock = {
            self.setReminderBadge()
            if self.tableView.numberOfRows(inSection: 0) == 5 && self.ingredient.reminderSetDate != nil {
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
        guard ingredient.recipeIngredients.count == 0 else{
            let alertView = CustomAlertController(title: nil, message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                alertView.overrideUserInterfaceStyle = .dark
            }
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            okAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
            alertView.addAction(okAction)
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
            return
        }

        let deleteAlertView = CustomAlertController(title: nil, message: "この材料を本当に削除しますか？", preferredStyle: .alert)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            deleteAlertView.overrideUserInterfaceStyle = .dark
        }
        let deleteAction = UIAlertAction(title: "削除", style: .destructive){action in
            let realm = try! Realm()
            try! realm.write { realm.delete(self.ingredient) }
            self.setReminderBadge()
            self.navigationController?.popViewController(animated: true)
        }
        deleteAction.setValue(UchicockStyle.alertColor, forKey: "titleTextColor")
        deleteAlertView.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor")
        deleteAlertView.addAction(cancelAction)
        deleteAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        deleteAlertView.modalPresentationCapturesStatusBarAppearance = true
        self.present(deleteAlertView, animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
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
            if let id = sender as? String{
                selectedRecipeId = id
                vc.recipeId = id
            }
        }
    }
    
    func closeEditVC(_ editVC: IngredientEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
    }
}
