//
//  RecipeDetailTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/08.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import Accounts

class RecipeDetailTableViewController: UITableViewController, UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var recipeNameTextView: CustomTextView!
    @IBOutlet weak var recipeNameYomiLabel: UILabel!
    @IBOutlet weak var bookmarkButton: ExpandedButton!
    @IBOutlet weak var shortageLabel: UILabel!
    @IBOutlet weak var lastViewDateLabel: UILabel!
    @IBOutlet weak var star1Button: ExpandedButton!
    @IBOutlet weak var star2Button: ExpandedButton!
    @IBOutlet weak var star3Button: ExpandedButton!
    @IBOutlet weak var styleLabel: CustomLabel!
    @IBOutlet weak var methodLabel: CustomLabel!
    @IBOutlet weak var strengthLabel: CustomLabel!
    @IBOutlet weak var styleTipButton: ExpandedButton!
    @IBOutlet weak var methodTipButton: ExpandedButton!
    @IBOutlet weak var strengthTipButton: ExpandedButton!
    @IBOutlet weak var memoTextView: CustomTextView!
    @IBOutlet weak var memoBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var madeNumPlusButton: ExpandedButton!
    @IBOutlet weak var madeNumMinusButton: ExpandedButton!
    @IBOutlet weak var madeNumCountUpLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var openInSafariButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    @IBOutlet weak var similarRecipeCollectionView: UICollectionView!
    
    var recipeId = String()
    var recipe = Recipe()
    var recipeIngredientList = Array<RecipeIngredientBasic>()
    var hasRecipeDeleted = false
    
    var headerView: UIView!
    var photoWidth: CGFloat = 0
    var photoHeight: CGFloat = 0
    var imageViewNaturalHeight: CGFloat = 0.0
    var imageViewMinHeight: CGFloat = 0.0
    var calcImageViewSizeCount = 0

    var shouldUpdateLastViewDate = true
    var firstShow = true
    var fromContextualMenu = false

    let selectedCellBackgroundView = UIView()
    var selectedIngredientId: String? = nil
    var selectedRecipeId: String? = nil
    var highlightSimilarRecipeIndexPath: IndexPath? = nil

    var selfRecipe : SimilarRecipeBasic? = nil
    var allRecipeList: Results<Recipe>?
    var similarRecipeList = Array<SimilarRecipeBasic>()
    var displaySimilarRecipeList = Array<SimilarRecipeBasic>()
    
    let interactor = Interactor()

    let excludedActivityTypes = [
        UIActivity.ActivityType.print,
        UIActivity.ActivityType.assignToContact,
        UIActivity.ActivityType.addToReadingList,
        UIActivity.ActivityType.postToFlickr,
        UIActivity.ActivityType.postToVimeo,
        UIActivity.ActivityType.postToWeibo,
        UIActivity.ActivityType.postToTencentWeibo,
        UIActivity.ActivityType.openInIBooks
    ]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if fromContextualMenu{ tableView.isScrollEnabled = false }
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0))
        tableView.addSubview(headerView)
        
        photoImageView.clipsToBounds = true

        recipeNameTextView.textContainerInset = .zero
        recipeNameTextView.textContainer.lineFragmentPadding = 0
        recipeNameTextView.font = UIFont.systemFont(ofSize: 25.0)
        memoTextView.textContainerInset = .zero
        memoTextView.textContainer.lineFragmentPadding = 0
        memoTextView.font = UIFont.systemFont(ofSize: 15.0)

        bookmarkButton.minimumHitWidth = 36
        bookmarkButton.minimumHitHeight = 36
        star1Button.minimumHitWidth = 36
        star1Button.minimumHitHeight = 36
        star2Button.minimumHitWidth = 36
        star2Button.minimumHitHeight = 36
        star3Button.minimumHitWidth = 36
        star3Button.minimumHitHeight = 36
        styleTipButton.minimumHitWidth = 50
        styleTipButton.minimumHitHeight = 44
        methodTipButton.minimumHitWidth = 50
        methodTipButton.minimumHitHeight = 44
        strengthTipButton.minimumHitWidth = 50
        strengthTipButton.minimumHitHeight = 44
        madeNumPlusButton.minimumHitWidth = 36
        madeNumPlusButton.minimumHitHeight = 36
        madeNumMinusButton.minimumHitWidth = 36
        madeNumMinusButton.minimumHitHeight = 36
        
        madeNumPlusButton.layer.cornerRadius = madeNumPlusButton.frame.size.width / 2
        madeNumPlusButton.layer.borderWidth = 1.5
        madeNumMinusButton.layer.cornerRadius = madeNumMinusButton.frame.size.width / 2
        madeNumMinusButton.layer.borderWidth = 1.5
        
        editButton.layer.cornerRadius = editButton.frame.size.width / 2
        editButton.clipsToBounds = true
        shareButton.layer.cornerRadius = shareButton.frame.size.width / 2
        shareButton.clipsToBounds = true
        openInSafariButton.layer.cornerRadius = openInSafariButton.frame.size.width / 2
        openInSafariButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = deleteButton.frame.size.width / 2
        deleteButton.clipsToBounds = true

        tableView.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientCell")
        similarRecipeCollectionView.register(UINib(nibName: "SimilarRecipeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecipeNameCell")

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeDetailTableViewController.photoTapped(_:)))
        photoImageView.addGestureRecognizer(tapRecognizer)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecipeDetailTableViewController.photoLongPressed(_:)))
        longPressRecognizer.allowableMovement = 100
        longPressRecognizer.minimumPressDuration = 0.2
        photoImageView.addGestureRecognizer(longPressRecognizer)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        headerView.backgroundColor = UchicockStyle.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        lastViewDateLabel.textColor = UchicockStyle.labelTextColorLight
        deleteButtonLabel.textColor = UchicockStyle.alertColor
        
        let realm = try! Realm()
        let rec = realm.object(ofType: Recipe.self, forPrimaryKey: recipeId)
        guard rec != nil else{
            hasRecipeDeleted = true
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
            deleteImageView.translatesAutoresizingMaskIntoConstraints = false

            let deleteImageViewLeadingConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .leading, relatedBy: .equal, toItem: coverView, attribute: .leading, multiplier: 1, constant: 0)
            let deleteImageViewTopConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .top, relatedBy: .equal, toItem: coverView, attribute: .bottom, multiplier: 0.2, constant: 0)
            let deleteImageViewTrailingConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .trailing, relatedBy: .equal, toItem: coverView, attribute: .trailing, multiplier: 1, constant: 0)
            let deleteImageViewHeightConstraint = NSLayoutConstraint(item: deleteImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
            NSLayoutConstraint.activate([deleteImageViewLeadingConstraint, deleteImageViewTopConstraint, deleteImageViewTrailingConstraint, deleteImageViewHeightConstraint])
            return
        }

        recipe = rec!
        self.navigationItem.title = recipe.recipeName

        if let recipeImage = ImageUtil.loadImageOf(recipeId: recipe.id, imageFileName: recipe.imageFileName, forList: false), fromContextualMenu == false{
            photoImageView.image = recipeImage
            photoWidth = recipeImage.size.width
            photoHeight = recipeImage.size.height
        }else{
            photoImageView.image = nil
            photoWidth = 0
            photoHeight = 0
        }
        calcImageViewSizeCount = 3
        updateImageView()

        if recipe.bookmarkDate == nil{
            bookmarkButton.setImage(UIImage(named: "navigation-recipe-bookmark-off"), for: .normal)
        }else{
            bookmarkButton.setImage(UIImage(named: "navigation-recipe-bookmark-on"), for: .normal)
        }
        bookmarkButton.tintColor = UchicockStyle.primaryColor

        recipeNameTextView.text = recipe.recipeName
        recipeNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
        if recipe.recipeName.katakanaLowercasedForSearch() == recipe.recipeNameYomi.katakanaLowercasedForSearch(){
            recipeNameYomiLabel.isHidden = true
            recipeNameYomiLabel.text = " "
        }else{
            recipeNameYomiLabel.isHidden = false
            recipeNameYomiLabel.text = recipe.recipeNameYomi
        }

        switch recipe.shortageNum {
        case 0:
            shortageLabel.text = "すぐ作れる！"
            shortageLabel.textColor = UchicockStyle.primaryColor
            shortageLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        case 1:
            if let iname = recipe.shortageIngredientName{
                shortageLabel.text = iname + "が足りません"
            }else{
                shortageLabel.text = "材料が" + String(recipe.shortageNum) + "個足りません"
            }
            shortageLabel.textColor = UchicockStyle.labelTextColorLight
            shortageLabel.font = UIFont.systemFont(ofSize: 14.0)
        default:
            shortageLabel.text = "材料が" + String(recipe.shortageNum) + "個足りません"
            shortageLabel.textColor = UchicockStyle.labelTextColorLight
            shortageLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
        
        if shouldUpdateLastViewDate {
            let timeFormatter: DateFormatter = DateFormatter()
            if let lastViewDate = recipe.lastViewDate{
                let calendar = Calendar(identifier: .gregorian)
                if calendar.isDateInToday(lastViewDate){
                    timeFormatter.dateFormat = "HH:mm"
                    lastViewDateLabel.text = "最終閲覧：今日 " + timeFormatter.string(from: lastViewDate)
                }else if calendar.isDateInYesterday(lastViewDate){
                    timeFormatter.dateFormat = "HH:mm"
                    lastViewDateLabel.text = "最終閲覧：昨日 " + timeFormatter.string(from: lastViewDate)
                }else{
                    timeFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                    lastViewDateLabel.text = "最終閲覧：" + timeFormatter.string(from: lastViewDate)
                }
            }else{
                lastViewDateLabel.text = "最終閲覧：--"
            }
            shouldUpdateLastViewDate = false
        }

        switch recipe.favorites{
        case 0: setStarImageOf(star1isFilled: false, star2isFilled: false, star3isFilled: false)
        case 1: setStarImageOf(star1isFilled: true, star2isFilled: false, star3isFilled: false)
        case 2: setStarImageOf(star1isFilled: true, star2isFilled: true, star3isFilled: false)
        case 3: setStarImageOf(star1isFilled: true, star2isFilled: true, star3isFilled: true)
        default: setStarImageOf(star1isFilled: false, star2isFilled: false, star3isFilled: false)
        }
        star1Button.tintColor = UchicockStyle.primaryColor
        star2Button.tintColor = UchicockStyle.primaryColor
        star3Button.tintColor = UchicockStyle.primaryColor

        switch recipe.style{
        case 0: styleLabel.text = "ロング"
        case 1: styleLabel.text = "ショート"
        case 2: styleLabel.text = "ホット"
        case 3: styleLabel.text = "未指定"
        default: styleLabel.text = "未指定"
        }
        
        switch recipe.method{
        case 0: methodLabel.text = "ビルド"
        case 1: methodLabel.text = "ステア"
        case 2: methodLabel.text = "シェイク"
        case 3: methodLabel.text = "ブレンド"
        case 4: methodLabel.text = "その他"
        default: methodLabel.text = "その他"
        }
        
        switch recipe.strength{
        case 0: strengthLabel.text = "ノンアルコール"
        case 1: strengthLabel.text = "弱い"
        case 2: strengthLabel.text = "やや強い"
        case 3: strengthLabel.text = "強い"
        case 4: strengthLabel.text = "未指定"
        default: strengthLabel.text = "未指定"
        }

        styleTipButton.tintColor = UchicockStyle.primaryColor
        methodTipButton.tintColor = UchicockStyle.primaryColor
        strengthTipButton.tintColor = UchicockStyle.primaryColor

        memoTextView.text = recipe.memo
        memoTextView.textColor = UchicockStyle.labelTextColorLight
        if recipe.memo.isEmpty {
            memoBottomConstraint.constant = 0
            memoTextView.isHidden = true
        }else{
            memoBottomConstraint.constant = 15
            memoTextView.isHidden = false
        }
        
        madeNumCountUpLabel.text = String(recipe.madeNum) + "回"
        setMadeNumButton()
        
        for ri in recipe.recipeIngredients where ri.displayOrder < 0{
            try! realm.write{
                for i in 0 ..< recipe.recipeIngredients.count {
                    recipe.recipeIngredients[i].displayOrder = i
                }
            }
            break
        }
        
        recipeIngredientList.removeAll()
        for ri in recipe.recipeIngredients {
            recipeIngredientList.append(RecipeIngredientBasic(
                ingredientId: ri.ingredient.id,
                ingredientName: ri.ingredient.ingredientName,
                ingredientNameYomi: "",
                katakanaLowercasedNameForSearch: "",
                amount: ri.amount,
                mustFlag: ri.mustFlag,
                category: ri.ingredient.category,
                displayOrder: ri.displayOrder,
                stockFlag: ri.ingredient.stockFlag
            ))
        }
        recipeIngredientList.sort { $0.displayOrder < $1.displayOrder }
        
        editButton.backgroundColor = UchicockStyle.primaryColor
        editButton.tintColor = UchicockStyle.basicBackgroundColor
        shareButton.backgroundColor = UchicockStyle.primaryColor
        shareButton.tintColor = UchicockStyle.basicBackgroundColor
        openInSafariButton.backgroundColor = UchicockStyle.primaryColor
        openInSafariButton.tintColor = UchicockStyle.basicBackgroundColor
        deleteButton.backgroundColor = UchicockStyle.alertColor
        deleteButton.tintColor = UchicockStyle.basicBackgroundColor
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
        similarRecipeCollectionView.backgroundColor = UchicockStyle.basicBackgroundColor
        similarRecipeCollectionView.reloadData()
        similarRecipeCollectionView.layoutIfNeeded()

        if tableView.indexPathsForVisibleRows != nil && selectedIngredientId != nil {
            for indexPath in tableView.indexPathsForVisibleRows! where indexPath.section != 0{
                if recipeIngredientList.count > indexPath.row {
                    if recipeIngredientList[indexPath.row].ingredientId == selectedIngredientId! {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        }
                        break
                    }
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calcImageViewSizeCount = 3
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()

        guard hasRecipeDeleted == false else{
            let noRecipeAlertView = CustomAlertController(title: "このレシピは削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                noRecipeAlertView.overrideUserInterfaceStyle = .dark
            }
            let action = UIAlertAction(title: "OK", style: .default){action in
                self.navigationController?.popViewController(animated: true)
            }
            if #available(iOS 13.0, *){ action.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
            noRecipeAlertView.addAction(action)
            noRecipeAlertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            noRecipeAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noRecipeAlertView, animated: true, completion: nil)
            return
        }
        
        let realm = try! Realm()
        if fromContextualMenu == false{
            try! realm.write { recipe.lastViewDate = Date() }
        }
        
        if let path = tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: path, animated: true)
        }
        selectedIngredientId = nil

        var ingredientList = Array<SimilarRecipeIngredient>()
        for ri in recipe.recipeIngredients{
            ingredientList.append(SimilarRecipeIngredient(
                name: ri.ingredient.ingredientName,
                weight: ri.mustFlag ? 1.0 : 0.3
            ))
        }
        selfRecipe = SimilarRecipeBasic(
            id: recipe.id,
            name: recipe.recipeName,
            isBookmarked: (recipe.bookmarkDate != nil),
            canMake: recipe.shortageNum == 0,
            style: recipe.style,
            method: recipe.method,
            strength: recipe.strength,
            imageFileName: recipe.imageFileName,
            point: 0,
            ingredientList: ingredientList
        )

        allRecipeList = realm.objects(Recipe.self)
        similarRecipeList.removeAll()
        for anotherRecipe in allRecipeList!{
            var ingredientList = Array<SimilarRecipeIngredient>()
            for ri in anotherRecipe.recipeIngredients{
                ingredientList.append(SimilarRecipeIngredient(
                    name: ri.ingredient.ingredientName,
                    weight: ri.mustFlag ? 1.0 : 0.3
                ))
            }
            similarRecipeList.append(SimilarRecipeBasic(
                id: anotherRecipe.id,
                name: anotherRecipe.recipeName,
                isBookmarked: (anotherRecipe.bookmarkDate != nil),
                canMake: anotherRecipe.shortageNum == 0,
                style: anotherRecipe.style,
                method: anotherRecipe.method,
                strength: anotherRecipe.strength,
                imageFileName: anotherRecipe.imageFileName,
                point: 0,
                ingredientList: ingredientList
            ))
        }
        
        DispatchQueue.global(qos: .userInteractive).async{
            self.rateSimilarity()

            DispatchQueue.main.async {
                self.similarRecipeCollectionView.reloadData()
                self.similarRecipeCollectionView.layoutIfNeeded()
                self.setCollectionBackgroundView()
                if self.highlightSimilarRecipeIndexPath != nil{
                    if let cell = self.similarRecipeCollectionView.cellForItem(at: self.highlightSimilarRecipeIndexPath!) as? SimilarRecipeCollectionViewCell {
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.highlightView.backgroundColor = UIColor.clear
                        }, completion: nil)
                    }
                }
                self.highlightSimilarRecipeIndexPath = nil
                self.selectedRecipeId = nil
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if recipe.isInvalidated == false && fromContextualMenu == false{
            let realm = try! Realm()
            try! realm.write { recipe.lastViewDate = Date() }
        }
    }
    
    // MARK: - Logic Functions
    private func setReminderBadge(){
        let realm = try! Realm()
        let reminderNum = realm.objects(Ingredient.self).filter("reminderSetDate != nil").count

        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[1]
            tabItem.badgeColor = UchicockStyle.badgeBackgroundColor
            tabItem.badgeValue = reminderNum == 0 ? nil : "!"
        }
    }
    
    private func setStarImageOf(star1isFilled: Bool, star2isFilled: Bool, star3isFilled: Bool){
        if star1isFilled {
            star1Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
        }else{
            star1Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
        }
        if star2isFilled {
            star2Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
        }else{
            star2Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
        }
        if star3isFilled {
            star3Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
        }else{
            star3Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
        }
    }

    private func setMadeNumButton(){
        if recipe.madeNum <= 0 {
            madeNumMinusButton.isEnabled = false
            madeNumMinusButton.setTitleColor(UchicockStyle.labelTextColorLight, for: .normal)
            madeNumMinusButton.layer.borderColor = UchicockStyle.labelTextColorLight.cgColor
        }else{
            madeNumMinusButton.isEnabled = true
            madeNumMinusButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
            madeNumMinusButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        }
        if recipe.madeNum >= 9999 {
            madeNumPlusButton.isEnabled = false
            madeNumPlusButton.setTitleColor(UchicockStyle.labelTextColorLight, for: .normal)
            madeNumPlusButton.layer.borderColor = UchicockStyle.labelTextColorLight.cgColor
        }else{
            madeNumPlusButton.isEnabled = true
            madeNumPlusButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
            madeNumPlusButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        }
    }
    
    // MARK: - Photo Header
    private func updateImageView(){
        guard recipe.isInvalidated == false else { return }
        if calcImageViewSizeCount > 0{
            let minimumVisibleTableViewHeight: CGFloat = 115.0
            if photoWidth == 0 {
                imageViewNaturalHeight = 0
            }else{
                imageViewNaturalHeight = min(tableView.bounds.height - minimumVisibleTableViewHeight, tableView.bounds.width * photoHeight / photoWidth)
            }
            imageViewMinHeight = min(tableView.bounds.width / 2, (tableView.bounds.height - minimumVisibleTableViewHeight) / 2, imageViewNaturalHeight)
            imageViewNaturalHeight = floor(imageViewNaturalHeight)
            imageViewMinHeight = floor(imageViewMinHeight)

            if let currentTableHeaderView = tableView.tableHeaderView{
                let newTableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: imageViewNaturalHeight))
            
                if abs(currentTableHeaderView.frame.width - newTableHeaderView.frame.width) > 1 || abs(currentTableHeaderView.frame.height - newTableHeaderView.frame.height) > 1 {
                    tableView.tableHeaderView = newTableHeaderView
                }
            }

            if firstShow{
                tableView.contentOffset.y = imageViewNaturalHeight - imageViewMinHeight
                firstShow = false
            }
                
            // tableViewのスクロールバーが画像に隠れる問題へのワークアラウンド
            tableView.showsVerticalScrollIndicator = false
            self.view.bringSubviewToFront(headerView)
            tableView.showsVerticalScrollIndicator = true

            calcImageViewSizeCount -= 1
        }
        
        if recipe.imageFileName != nil{
            var headRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: imageViewNaturalHeight)
            if tableView.contentOffset.y < (imageViewNaturalHeight - imageViewMinHeight) {
                headRect.origin.y = tableView.contentOffset.y
                headRect.size.height = imageViewNaturalHeight - tableView.contentOffset.y
            }else{
                headRect.origin.y = imageViewNaturalHeight - imageViewMinHeight
                headRect.size.height = imageViewMinHeight
            }
            headerView.frame = headRect
        }else{
            headerView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
    }
    
    @objc func photoTapped(_ recognizer: UITapGestureRecognizer) {
        if recipe.imageFileName != nil {
            let storyboard = UIStoryboard(name: "ImageViewer", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "ImageViewerController") as! ImageViewerController
            ivc.originalImageView = photoImageView
            ivc.captionText = recipe.recipeName
            ivc.modalPresentationStyle = .overFullScreen
            ivc.modalTransitionStyle = .crossDissolve
            ivc.modalPresentationCapturesStatusBarAppearance = true
            self.present(ivc, animated: true)
        }
    }
    
    @objc func photoLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        // 画像ファイルが消えた時に変なオブジェクトがクリップボードにコピーされるバグのためのワークアラウンド
        guard let imageFileName = recipe.imageFileName else{ return }
        
        let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName + ".png")
        let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
        
        guard loadedImage != nil && recognizer.state == UIGestureRecognizer.State.began else { return }
        
        let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            alertView.overrideUserInterfaceStyle = .dark
        }
        let photoAction = UIAlertAction(title: "「写真」アプリへ保存",style: .default){action in
            UIImageWriteToSavedPhotosAlbum(loadedImage!, self, #selector(RecipeDetailTableViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        if #available(iOS 13.0, *){ photoAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(photoAction)
        let clipboardAction = UIAlertAction(title: "クリップボードへコピー",style: .default){action in
            UIPasteboard.general.image = loadedImage!
            MessageHUD.show("画像をコピーしました", for: 2.0, withCheckmark: true, isCenter: true)
        }
        if #available(iOS 13.0, *){ clipboardAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(clipboardAction)
        let shareAction = UIAlertAction(title: "写真を共有",style: .default){action in
            let activityVC = CustomActivityController(activityItems: [loadedImage!], applicationActivities: nil)
            if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
                activityVC.overrideUserInterfaceStyle = .dark
            }
            activityVC.excludedActivityTypes = self.excludedActivityTypes
            activityVC.activityStatusBarStyle = UchicockStyle.statusBarStyle
            activityVC.modalPresentationCapturesStatusBarAppearance = true
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = self.photoImageView.frame
            self.present(activityVC, animated: true, completion: nil)
        }
        if #available(iOS 13.0, *){ shareAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(shareAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(cancelAction)
        
        alertView.popoverPresentationController?.sourceView = self.view
        alertView.popoverPresentationController?.sourceRect = self.photoImageView.frame
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        guard error != nil else{
            MessageHUD.show("画像を保存しました", for: 2.0, withCheckmark: true, isCenter: true)
            return
        }
        
        let alertView = CustomAlertController(title: "「写真」アプリへの保存に失敗しました", message: "「設定」→「うちカク！」にて写真へのアクセス許可を確認してください", preferredStyle: .alert)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            alertView.overrideUserInterfaceStyle = .dark
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(cancelAction)
        let settingAction = UIAlertAction(title: "設定を開く", style: .default){action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        if #available(iOS 13.0, *){ settingAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(settingAction)
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }else if indexPath.section == 1{
            return 70
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasRecipeDeleted ? 1 : 4
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        if recipe.isInvalidated == false{
            if section == 1{
                header?.textLabel?.text = "材料(\(String(recipeIngredientList.count)))"
            }else if section == 2{
                header?.textLabel?.text = ""
            }else{
                header?.textLabel?.text = "似ているかも？"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return super.tableView(tableView, numberOfRowsInSection: 0)
        }else if section == 1{
            return recipeIngredientList.count
        }else if section == 2{
            return 1
        }else if section == 3{
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            performSegue(withIdentifier: "PushIngredientDetail", sender: recipeIngredientList[indexPath.row].ingredientId)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return nil }
        
        let reminder =  UIContextualAction(style: .normal, title: "リマインダー"){ action,view,completionHandler in
            let storyboard = UIStoryboard(name: "Reminder", bundle: nil)
            guard let nvc = storyboard.instantiateViewController(withIdentifier: "ReminderNavigationController") as? BasicNavigationController else{
                completionHandler(false)
                return
            }
            guard let vc = nvc.visibleViewController as? ReminderTableViewController else{
                completionHandler(false)
                return
            }
            for ri in self.recipe.recipeIngredients{
                if ri.ingredient.id == self.recipeIngredientList[indexPath.row].ingredientId{
                    vc.ingredient = ri.ingredient
                    break
                }
            }
            vc.onDoneBlock = {
                self.setReminderBadge()
            }

            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
                nvc.modalPresentationStyle = .pageSheet
            }else{
                nvc.modalPresentationStyle = .custom
                nvc.transitioningDelegate = self
                vc.interactor = self.interactor
            }
            self.present(nvc, animated: true)
            completionHandler(true)
        }
        reminder.image = UIImage(named: "navigation-reminder-empty")
        reminder.backgroundColor = UchicockStyle.primaryColor

        return UISwipeActionsConfiguration(actions: [reminder])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell") as! RecipeIngredientTableViewCell
            
            let accesoryImageView = UIImageView(image: UIImage(named: "accesory-disclosure-indicator"))
            accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            cell.accessoryView = accesoryImageView

            cell.isDuplicated = false
            cell.shouldDisplayStock = true
            cell.isNameTextViewSelectable = false
            cell.recipeIngredient = RecipeIngredientBasic(
                ingredientId: "",
                ingredientName: recipeIngredientList[indexPath.row].ingredientName,
                ingredientNameYomi: "",
                katakanaLowercasedNameForSearch: "",
                amount: recipeIngredientList[indexPath.row].amount,
                mustFlag: recipeIngredientList[indexPath.row].mustFlag,
                category: recipeIngredientList[indexPath.row].category,
                displayOrder: -1,
                stockFlag: recipeIngredientList[indexPath.row].stockFlag
            )

            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            return cell
        case 2:
            let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 2))
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        case 3:
            let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 3))
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: - Calc Similar Point
    private func rateSimilarity(){
        displaySimilarRecipeList.removeAll()
        guard let selfRecipe = selfRecipe else { return }

        for anotherRecipe in similarRecipeList where anotherRecipe.id != selfRecipe.id{
            var point : Float = 0
            var maxWeight : Float = 0.0
            var weight : Float = 0.0
            
            for selfIng in selfRecipe.ingredientList{
                maxWeight += selfIng.weight
                for anotherIng in anotherRecipe.ingredientList where anotherIng.name == selfIng.name{
                    weight += selfIng.weight
                    break
                }
            }
            for anotherIng in anotherRecipe.ingredientList{
                maxWeight += anotherIng.weight
                for selfIng in selfRecipe.ingredientList where anotherIng.name == selfIng.name{
                    weight += anotherIng.weight
                    break
                }
            }

            point = maxWeight == 0.0 ? 0.0 : (weight / maxWeight)
            point = point - 0.05 * (maxWeight - weight) //異なる材料の数だけペナルティ
            if selfRecipe.method != 4 && anotherRecipe.method == selfRecipe.method {
                point += 0.1
                if anotherRecipe.method == 3{
                    point += 0.05 //ブレンドはボーナスポイント
                }
            }
            if selfRecipe.style != 3 &&  anotherRecipe.style == selfRecipe.style {
                point += 0.1
                if anotherRecipe.style == 2{
                    point += 0.05 //ホットはボーナスポイント
                }
            }
            
            if selfRecipe.strength == 0 && anotherRecipe.strength == 0{
                point += 0.2 //ノンアルはボーナスポイント
            }else if anotherRecipe.strength != 0 && anotherRecipe.strength != 4 && selfRecipe.strength != 0 && selfRecipe.strength != 4 {
                point += 0.01 //どちらもアルコールならボーナスポイント（主に並べ替え用）
            }
            
            if point >= 0.61{
                displaySimilarRecipeList.append(SimilarRecipeBasic(
                    id: anotherRecipe.id,
                    name: anotherRecipe.name,
                    isBookmarked: anotherRecipe.isBookmarked,
                    canMake: anotherRecipe.canMake,
                    style: 0,
                    method: 0,
                    strength: 0,
                    imageFileName: anotherRecipe.imageFileName,
                    point: point
                ))
            }
        }
        
        displaySimilarRecipeList.sort { (a:SimilarRecipeBasic, b:SimilarRecipeBasic) -> Bool in
            return a.point == b.point ? a.name < b.name : a.point > b.point
        }
    }
    
    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(displaySimilarRecipeList.count, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 86, height: 126)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "RecipeDetail", bundle:nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
        vc.recipeId = displaySimilarRecipeList[indexPath.row].id
        selectedRecipeId = displaySimilarRecipeList[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? SimilarRecipeCollectionViewCell {
            if UchicockStyle.isBackgroundDark{
                cell.highlightView.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3)
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SimilarRecipeCollectionViewCell {
            if UchicockStyle.isBackgroundDark{
                cell.highlightView.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SimilarRecipeCollectionViewCell {
            cell.highlightView.backgroundColor  = UIColor.clear
        }
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let previewProvider: () -> RecipeDetailTableViewController? = {
                let vc = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
                vc.fromContextualMenu = true
                vc.recipeId = self.displaySimilarRecipeList[indexPath.row].id
                return vc
            }
        return UIContextMenuConfiguration(identifier: self.displaySimilarRecipeList[indexPath.row].id as NSCopying, previewProvider: previewProvider, actionProvider: nil)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let recipeId = configuration.identifier as? String else { return nil }
        var row: Int? = nil
        for i in 0 ..< displaySimilarRecipeList.count where displaySimilarRecipeList[i].id == recipeId {
            row = i
            break
        }
        guard row != nil else { return nil }
        let cell = similarRecipeCollectionView.cellForItem(at: IndexPath(row: row!, section: 0)) as! SimilarRecipeCollectionViewCell
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell.backgroundContainer, parameters: parameters)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let recipeId = configuration.identifier as? String else { return nil }
        var row: Int? = nil
        for i in 0 ..< displaySimilarRecipeList.count where displaySimilarRecipeList[i].id == recipeId {
            row = i
            break
        }
        guard row != nil else { return nil }
        let cell = similarRecipeCollectionView.cellForItem(at: IndexPath(row: row!, section: 0)) as! SimilarRecipeCollectionViewCell
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell.backgroundContainer, parameters: parameters)
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let recipeId = configuration.identifier as? String else { return }

        animator.addCompletion {
            let vc = UIStoryboard(name: "RecipeDetail", bundle:nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
            vc.recipeId = recipeId
            self.selectedRecipeId = recipeId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeNameCell", for: indexPath as IndexPath) as! SimilarRecipeCollectionViewCell
        cell.recipe = displaySimilarRecipeList[indexPath.row]
        cell.backgroundContainer.backgroundColor = UchicockStyle.basicBackgroundColorLight

        if selectedRecipeId != nil && displaySimilarRecipeList[indexPath.row].id == selectedRecipeId!{
            if UchicockStyle.isBackgroundDark{
                cell.highlightView.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3)
            }else{
                cell.highlightView.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3)
            }
            highlightSimilarRecipeIndexPath = indexPath
        }else{
            cell.highlightView.backgroundColor = UIColor.clear
        }
        
        return cell
    }

    private func setCollectionBackgroundView(){
        guard displaySimilarRecipeList.count == 0 else {
            similarRecipeCollectionView.backgroundView = nil
            similarRecipeCollectionView.isScrollEnabled = true
            return
        }

        similarRecipeCollectionView.backgroundView = UIView()
        similarRecipeCollectionView.isScrollEnabled = false
        let noDataLabel = UILabel()
        noDataLabel.numberOfLines = 2
        noDataLabel.textColor = UchicockStyle.labelTextColorLight
        noDataLabel.font = UIFont.systemFont(ofSize: 14.0)
        noDataLabel.textAlignment = .center
        noDataLabel.text = "似ているレシピは\n見つかりませんでした..."
        similarRecipeCollectionView.backgroundView?.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false

        let centerXConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerX, relatedBy: .equal, toItem: similarRecipeCollectionView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: noDataLabel, attribute: .centerY, relatedBy: .equal, toItem: similarRecipeCollectionView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
    }
    
    // MARK: - IBAction
    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        let realm = try! Realm()
        let newImageName = recipe.bookmarkDate == nil ? "navigation-recipe-bookmark-on" : "navigation-recipe-bookmark-off"
        let newBookmarkDate : Date? = recipe.bookmarkDate == nil ? Date() : nil
        let message = recipe.bookmarkDate == nil ? "ブックマークしました" : "ブックマークを外しました"

        animateButton(bookmarkButton, with: newImageName)

        try! realm.write { recipe.bookmarkDate = newBookmarkDate }
        MessageHUD.show(message, for: 2.0, withCheckmark: true, isCenter: true)
    }
    
    @IBAction func star1Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        switch recipe.favorites {
        case 0:
            try! realm.write { recipe.favorites = 1 }
            animateButton(star1Button, with: "button-star-filled")
        case 1:
            try! realm.write { recipe.favorites = 0 }
            animateButton(star1Button, with: "button-star-empty")
        case 2:
            try! realm.write { recipe.favorites = 1 }
            animateButton(star2Button, with: "button-star-empty")
        case 3:
            try! realm.write { recipe.favorites = 1 }
            animateButton(star2Button, with: "button-star-empty")
            animateButton(star3Button, with: "button-star-empty")
        default:
            break
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        switch recipe.favorites {
        case 0:
            try! realm.write { recipe.favorites = 2 }
            animateButton(star1Button, with: "button-star-filled")
            animateButton(star2Button, with: "button-star-filled")
        case 1:
            try! realm.write { recipe.favorites = 2 }
            animateButton(star2Button, with: "button-star-filled")
        case 2:
            try! realm.write { recipe.favorites = 0 }
            animateButton(star1Button, with: "button-star-empty")
            animateButton(star2Button, with: "button-star-empty")
        case 3:
            try! realm.write { recipe.favorites = 2 }
            animateButton(star3Button, with: "button-star-empty")
        default:
            break
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        switch recipe.favorites {
        case 0:
            try! realm.write { recipe.favorites = 3 }
            animateButton(star1Button, with: "button-star-filled")
            animateButton(star2Button, with: "button-star-filled")
            animateButton(star3Button, with: "button-star-filled")
        case 1:
            try! realm.write { recipe.favorites = 3 }
            animateButton(star2Button, with: "button-star-filled")
            animateButton(star3Button, with: "button-star-filled")
        case 2:
            try! realm.write { recipe.favorites = 3 }
            animateButton(star3Button, with: "button-star-filled")
        case 3:
            try! realm.write { recipe.favorites = 0 }
            animateButton(star1Button, with: "button-star-empty")
            animateButton(star2Button, with: "button-star-empty")
            animateButton(star3Button, with: "button-star-empty")
        default:
            break
        }
    }
    
    private func animateButton(_ button: UIButton, with imageName: String){
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            button.transform = .init(scaleX: 1.15, y: 1.15)
        }) { (finished: Bool) -> Void in
            button.setImage(UIImage(named: imageName), for: .normal)
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                button.transform = .identity
            })
        }
    }
    
    @IBAction func tipButtonTapped(_ sender: UIButton) {
        var id = "StyleTipNavigationController"
        if sender.tag == 1{
            id = "MethodTipNavigationController"
        }else if sender.tag == 2{
            id = "StrengthTipNavigationController"
        }

        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: id) as! BasicNavigationController
        var vc: TipViewController? = nil
        if sender.tag == 0{
            vc = nvc.visibleViewController as! StyleTipViewController
        }else if sender.tag == 1{
            vc = nvc.visibleViewController as! MethodTipViewController
        }else if sender.tag == 2{
            vc = nvc.visibleViewController as! StrengthTipViewController
        }

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .formSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc!.interactor = interactor
        }
        present(nvc, animated: true)
    }
    
    @IBAction func madeNumPlusButtonTapped(_ sender: UIButton) {
        if recipe.madeNum < 9999 {
            let realm = try! Realm()
            try! realm.write { recipe.madeNum += 1 }
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.madeNumCountUpLabel.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.madeNumCountUpLabel.text = String(self.recipe.madeNum) + "回"
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.madeNumCountUpLabel.transform = .identity
                })
            }
        }
        setMadeNumButton()
    }
    
    @IBAction func madeNumMinusButtonTapped(_ sender: UIButton) {
        if recipe.madeNum > 0 {
            madeNumCountUpLabel.text = String(recipe.madeNum) + "回"
            let realm = try! Realm()
            try! realm.write { recipe.madeNum -= 1 }
        }
        setMadeNumButton()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PushEditRecipe", sender: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let shareText = createShareText()
        var items: [Any] = [shareText]
        if recipe.imageFileName != nil, let image = photoImageView.image {
            items.append(image)
        }
        
        let activityVC = CustomActivityController(activityItems: items, applicationActivities: nil)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            activityVC.overrideUserInterfaceStyle = .dark
        }
        activityVC.excludedActivityTypes = excludedActivityTypes
        activityVC.activityStatusBarStyle = UchicockStyle.statusBarStyle
        activityVC.modalPresentationCapturesStatusBarAppearance = true
        activityVC.popoverPresentationController?.sourceView = sender
        activityVC.popoverPresentationController?.sourceRect = sender.frame
        self.present(activityVC, animated: true, completion: nil)
    }
    
    private func createShareText() -> String{
        var message = "【カクテルレシピ】" + recipe.recipeName + "\n"
        switch recipe.style{
        case 0: message += "スタイル：ロング\n"
        case 1: message += "スタイル：ショート\n"
        case 2: message += "スタイル：ホット\n"
        default: break
        }
        switch recipe.method{
        case 0: message += "技法：ビルド\n"
        case 1: message += "技法：ステア\n"
        case 2: message += "技法：シェイク\n"
        case 3: message += "技法：ブレンド\n"
        default: break
        }
        switch recipe.strength{
        case 0: message += "アルコール度数：ノンアルコール\n"
        case 1: message += "アルコール度数：弱い\n"
        case 2: message += "アルコール度数：やや強い\n"
        case 3: message += "アルコール度数：強い\n"
        default: break
        }
        message += "\n材料：\n"
        for recipeIngredient in recipeIngredientList{
            message += recipeIngredient.ingredientName + " " + recipeIngredient.amount + "\n"
        }
        if recipe.memo != "" {
            message += "\n" + recipe.memo
        }
        return message
    }
    
    @IBAction func openInSafariButtonTapped(_ sender: UIButton) {
        let urlStr : String = "https://www.google.co.jp/search?q=" + recipe.recipeName + "+カクテル"
        let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alertView = CustomAlertController(title: "このレシピを本当に削除しますか？", message: "自作レシピは復元できません。", preferredStyle: .alert)
        if #available(iOS 13.0, *),UchicockStyle.isBackgroundDark {
            alertView.overrideUserInterfaceStyle = .dark
        }
        let deleteAction = UIAlertAction(title: "削除",style: .destructive){action in
            let realm = try! Realm()
            ImageUtil.remove(imageFileName: self.recipe.imageFileName)
            try! realm.write{
                for ri in self.recipe.recipeIngredients{
                    let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                    for i in 0 ..< ingredient.recipeIngredients.count where i < ingredient.recipeIngredients.count{
                        if ingredient.recipeIngredients[i].id == ri.id{
                            ingredient.recipeIngredients.remove(at: i)
                        }
                    }
                }
                for ri in self.recipe.recipeIngredients{
                    realm.delete(ri)
                }
                realm.delete(self.recipe)
            }
            self.navigationController?.popViewController(animated: true)
        }
        if #available(iOS 13.0, *){ deleteAction.setValue(UchicockStyle.alertColor, forKey: "titleTextColor") }
        alertView.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(cancelAction)
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentedNVC = presented as? BasicNavigationController
        let VC = presentedNVC?.visibleViewController!
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)

        if let VC = VC, VC.isKind(of: TipViewController.self){
            pc.leftMargin = 30
            pc.rightMargin = 30
            pc.topMargin = 80
            pc.bottomMargin = 80
            pc.canDismissWithOverlayViewTouch = true
            return pc
        }
        pc.leftMargin = 10
        pc.rightMargin = 10
        pc.topMargin = 20
        pc.bottomMargin = 20
        pc.canDismissWithOverlayViewTouch = false
        return pc
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissedNVC = dismissed as? BasicNavigationController
        let VC = dismissedNVC?.visibleViewController!
        let animator = DismissModalAnimator()

        if let VC = VC, VC.isKind(of: TipViewController.self){
            animator.leftMargin = 30
            animator.rightMargin = 30
            animator.topMargin = 80
            animator.bottomMargin = 80
            return animator
        }
        animator.leftMargin = 10
        animator.rightMargin = 10
        animator.topMargin = 20
        animator.bottomMargin = 20
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destination as! IngredientDetailTableViewController
            if let ingredientId = sender as? String{
                selectedIngredientId = ingredientId
                vc.ingredientId = ingredientId
            }
        }else if segue.identifier == "PushEditRecipe" {
            let enc = segue.destination as! BasicNavigationController
            let evc = enc.visibleViewController as! RecipeEditTableViewController
            evc.recipe = self.recipe
        }
    }
    
    func closeEditVC(_ editVC: RecipeEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
    }    
}
