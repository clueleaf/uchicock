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

    @IBOutlet weak var ingredientName: CopyableLabel!
    @IBOutlet weak var stockRecommendLabel: UILabel!
    @IBOutlet weak var category: CustomLabel!
    @IBOutlet weak var stock: CircularCheckbox!
    @IBOutlet weak var memo: CopyableLabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var amazonButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    @IBOutlet weak var amazonContainerView: UIView!
    @IBOutlet weak var deleteContainerView: UIView!
    @IBOutlet weak var recipeOrderLabel: UILabel!
    
    var coverView = UIView(frame: CGRect.zero)
    var deleteImageView = UIImageView(frame: CGRect.zero)
    
    var ingredientId = String()
    var ingredient = Ingredient()
    var ingredientRecipeBasicList = Array<RecipeBasic>()
    let selectedCellBackgroundView = UIView()
    var recipeOrder = 2
    var selectedRecipeId: String? = nil
    var selectedIndexPath: IndexPath? = nil
    var hasIngredientDeleted = false

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.prefetchDataSource = self

        stock.boxLineWidth = 1.0
        
        stockRecommendLabel.isHidden = true
        
        editButton.layer.cornerRadius = editButton.frame.size.width / 2
        editButton.clipsToBounds = true
        reminderButton.layer.cornerRadius = reminderButton.frame.size.width / 2
        reminderButton.clipsToBounds = true
        amazonButton.layer.cornerRadius = amazonButton.frame.size.width / 2
        amazonButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = deleteButton.frame.size.width / 2
        deleteButton.clipsToBounds = true

        self.tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupVC()
        if let path = selectedIndexPath {
            if ingredientRecipeBasicList.count + 1 > path.row{
                let nowRecipeId = ingredientRecipeBasicList[path.row - 1].id
                if selectedRecipeId != nil{
                    if nowRecipeId == selectedRecipeId!{
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.selectRow(at: path, animated: false, scrollPosition: .none)
                        }
                    }
                }
            }
        }
    }
    
    private func setupVC(){
        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.separatorColor = Style.labelTextColorLight
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        
        stock.secondaryTintColor = Style.primaryColor
        stock.secondaryCheckmarkTintColor = Style.labelTextColorOnBadge
        stockRecommendLabel.textColor = Style.primaryColor
        deleteButtonLabel.textColor = Style.deleteColor

        recipeOrderLabel.textColor = Style.primaryColor
        recipeOrderLabel.font = UIFont.boldSystemFont(ofSize: 17.0)

        let realm = try! Realm()
        let ing = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientId)
        if ing == nil {
            hasIngredientDeleted = true
            coverView.backgroundColor = Style.basicBackgroundColor
            self.tableView.addSubview(coverView)
            deleteImageView.contentMode = .scaleAspectFit
            deleteImageView.image = UIImage(named: "button-delete")
            deleteImageView.tintColor = Style.labelTextColorLight
            coverView.addSubview(deleteImageView)
            self.tableView.setNeedsLayout()
        } else {
            hasIngredientDeleted = false
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
            memo.textColor = Style.labelTextColorLight
            
            editButton.backgroundColor = Style.primaryColor
            editButton.tintColor = Style.basicBackgroundColor
            reminderButton.backgroundColor = Style.primaryColor
            reminderButton.tintColor = Style.basicBackgroundColor
            amazonButton.backgroundColor = Style.primaryColor
            amazonButton.tintColor = Style.basicBackgroundColor
            deleteButton.backgroundColor = Style.deleteColor
            deleteButton.tintColor = Style.basicBackgroundColor
            
            reloadIngredientRecipeBasicList()
            
            if Amazon.product.contains(ingredient.ingredientName.withoutSpaceAndMiddleDot()){
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if hasIngredientDeleted{
            tableView.contentOffset.y = 0
            coverView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
            deleteImageView.frame = CGRect(x: 0, y: tableView.frame.height / 5, width: tableView.frame.width, height: 60)
            self.tableView.bringSubviewToFront(coverView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hasIngredientDeleted{
            let noIngredientAlertView = CustomAlertController(title: "この材料は削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            noIngredientAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.navigationController?.popViewController(animated: true)
            }))
            noIngredientAlertView.alertStatusBarStyle = Style.statusBarStyle
            noIngredientAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noIngredientAlertView, animated: true, completion: nil)
        }
        
        if let path = tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: path, animated: true)
        }
        selectedRecipeId = nil
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
    
    func reloadIngredientRecipeBasicList(){
        ingredientRecipeBasicList.removeAll()
        for recipeIngredient in ingredient.recipeIngredients{
            ingredientRecipeBasicList.append(RecipeBasic(id: recipeIngredient.recipe.id, name: recipeIngredient.recipe.recipeName, shortageNum: recipeIngredient.recipe.shortageNum, favorites: recipeIngredient.recipe.favorites, lastViewDate: recipeIngredient.recipe.lastViewDate, madeNum: recipeIngredient.recipe.madeNum, method: recipeIngredient.recipe.method, style: recipeIngredient.recipe.style, imageFileName: recipeIngredient.recipe.imageFileName))
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
        view.tintColor = Style.tableViewHeaderBackgroundColor
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = Style.tableViewHeaderTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        if section == 1 {
            if ingredient.isInvalidated == false {
                if ingredient.recipeIngredients.count > 0 {
                    header?.textLabel?.text = "この材料を使うレシピ(\(String(ingredient.recipeIngredients.count)))"
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
            return 5
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
                    alertView.popoverPresentationController?.sourceView = self.view
                    alertView.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: indexPath)!.frame
                    alertView.alertStatusBarStyle = Style.statusBarStyle
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
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
            return cell
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
                    cell.hightlightRecipeNameOnlyAvailable = true
                    cell.recipe = recipe
                    cell.backgroundColor = Style.basicBackgroundColor
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
                    cell.backgroundColor = Style.basicBackgroundColor
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
    @IBAction func stockTapped(_ sender: CircularCheckbox) {
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
        guard let vc = nvc.visibleViewController as? ReminderTableViewController else{
            return
        }
        vc.ingredientName = self.ingredient.ingredientName
        vc.onDoneBlock = {
            self.setupVC()
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
        var urlStr : String = "com.amazon.mobile.shopping://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName.withoutSpaceAndMiddleDot() + "&linkCode=sl2&tag=uchicock-22"
        var url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)

        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }else{
            urlStr = "https://www.amazon.co.jp/s/ref=as_li_ss_tl?url=search-alias=aps&field-keywords=" + ingredient.ingredientName.withoutSpaceAndMiddleDot() + "&linkCode=sl2&tag=uchicock-22"
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
                selectedIndexPath = indexPath
                vc.recipeId = ingredientRecipeBasicList[indexPath.row - 1].id
            }
        }
    }
    
    func closeEditVC(_ editVC: IngredientEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
    }

}
