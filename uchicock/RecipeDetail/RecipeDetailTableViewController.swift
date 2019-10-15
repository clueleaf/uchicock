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

class RecipeDetailTableViewController: UITableViewController, UIViewControllerTransitioningDelegate{

    @IBOutlet weak var photoBackground: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var recipeName: CopyableLabel!
    @IBOutlet weak var shortageLabel: UILabel!
    @IBOutlet weak var lastViewDateLabel: UILabel!
    @IBOutlet weak var styleTipButton: UIButton!
    @IBOutlet weak var methodTipButton: UIButton!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var style: CustomLabel!
    @IBOutlet weak var method: CustomLabel!
    @IBOutlet weak var memo: CopyableLabel!
    @IBOutlet weak var madeNumPlusButton: UIButton!
    @IBOutlet weak var madeNumMinusButton: UIButton!
    @IBOutlet weak var madeNumCountUpLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var openInSafariButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    
    var headerView: UIView!
    var photoHeight: CGFloat = 0.0
    var minimumPhotoHeight: CGFloat = 0.0
    var recipeId = String()
    var recipe = Recipe()
    var noPhotoFlag = false
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var photoSizeCalcTime = 0
    var firstShow = true
    var fromContextualMenu = false
    var madeNum = 0
    let selectedCellBackgroundView = UIView()
    var selectedIngredientId: String? = nil
    var hasRecipeDeleted = false

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if fromContextualMenu{
            tableView.isScrollEnabled = false
        }
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = UIView()
        tableView.addSubview(headerView)
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

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeDetailTableViewController.photoTapped(_:)))
        photoBackground.addGestureRecognizer(tapRecognizer)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecipeDetailTableViewController.photoLongPressed(_:)))
        longPressRecognizer.allowableMovement = 100
        longPressRecognizer.minimumPressDuration = 0.2
        photoBackground.addGestureRecognizer(longPressRecognizer)
        
        self.tableView.separatorColor = UIColor.gray
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        let indexPathForSelectedRow = tableView.indexPathForSelectedRow
        super.viewWillAppear(animated)

        setupVC()
        if let index = indexPathForSelectedRow {
            if recipe.recipeIngredients.count > index.row{
                let nowIngredientId = recipe.recipeIngredients[index.row].ingredient.id
                if selectedIngredientId != nil{
                    if nowIngredientId == selectedIngredientId!{
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.selectRow(at: indexPathForSelectedRow, animated: false, scrollPosition: .none)
                        }
                    }
                }
            }
        }
    }
    
    private func setupVC(){
        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        photoBackground.backgroundColor = Style.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        lastViewDateLabel.textColor = Style.labelTextColorLight
        deleteButtonLabel.textColor = Style.deleteColor
        
        let realm = try! Realm()
        let rec = realm.object(ofType: Recipe.self, forPrimaryKey: recipeId)
        if rec == nil {
            hasRecipeDeleted = true
        }else{
            hasRecipeDeleted = false
            recipe = rec!
            self.navigationItem.title = recipe.recipeName

            photo.clipsToBounds = true
            if let image = ImageUtil.loadImageOf(recipeId: recipe.id, forList: false), fromContextualMenu == false{
                noPhotoFlag = false
                photo.image = image
                imageWidth = image.size.width
                imageHeight = image.size.height
            }else{
                noPhotoFlag = true
                photo.image = nil
                imageWidth = 0
                imageHeight = 0
                photoBackground.frame = CGRect(x: 0 , y: 0, width: tableView.bounds.width, height: 0)
            }
            photoSizeCalcTime = 5
            calcPhotoSize()

            recipeName.text = recipe.recipeName
            
            switch recipe.shortageNum {
            case 0:
                shortageLabel.text = "すぐ作れる！"
                shortageLabel.textColor = Style.primaryColor
                shortageLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(14))
            case 1:
                var shortageName = ""
                for recipeIngredient in recipe.recipeIngredients{
                    if recipeIngredient.mustFlag && recipeIngredient.ingredient.stockFlag == false {
                        shortageName = recipeIngredient.ingredient.ingredientName
                        break
                    }
                }
                shortageLabel.text = shortageName + "が足りません"
                shortageLabel.textColor = Style.labelTextColorLight
                shortageLabel.font = UIFont.systemFont(ofSize: CGFloat(14))
            default:
                shortageLabel.text = "材料が" + String(recipe.shortageNum) + "個足りません"
                shortageLabel.textColor = Style.labelTextColorLight
                shortageLabel.font = UIFont.systemFont(ofSize: CGFloat(14))
            }
            
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            lastViewDateLabel.text = recipe.lastViewDate == nil ? "最終閲覧：--" : "最終閲覧：" + formatter.string(from: recipe.lastViewDate!)
            
            switch recipe.favorites{
            case 0:
                setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
            case 1:
                setStarTitleOf(star1title: "★", star2title: "☆", star3title: "☆")
            case 2:
                setStarTitleOf(star1title: "★", star2title: "★", star3title: "☆")
            case 3:
                setStarTitleOf(star1title: "★", star2title: "★", star3title: "★")
            default:
                setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
            }
            star1.setTitleColor(Style.primaryColor, for: .normal)
            star2.setTitleColor(Style.primaryColor, for: .normal)
            star3.setTitleColor(Style.primaryColor, for: .normal)
            
            switch recipe.style{
            case 0:
                style.text = "ロング"
            case 1:
                style.text = "ショート"
            case 2:
                style.text = "ホット"
            case 3:
                style.text = "未指定"
            default:
                style.text = "未指定"
            }
            
            switch recipe.method{
            case 0:
                method.text = "ビルド"
            case 1:
                method.text = "ステア"
            case 2:
                method.text = "シェイク"
            case 3:
                method.text = "ブレンド"
            case 4:
                method.text = "その他"
            default:
                method.text = "その他"
            }

            let tipImage = UIImage(named: "tip")
            styleTipButton.setImage(tipImage, for: .normal)
            styleTipButton.tintColor = Style.primaryColor
            methodTipButton.setImage(tipImage, for: .normal)
            methodTipButton.tintColor = Style.primaryColor

            memo.text = recipe.memo
            memo.textColor = Style.labelTextColorLight
            madeNum = recipe.madeNum
            madeNumCountUpLabel.text = String(madeNum) + "回"
            setMadeNumButton()
            
            editButton.backgroundColor = Style.primaryColor
            editButton.tintColor = Style.basicBackgroundColor
            shareButton.backgroundColor = Style.primaryColor
            shareButton.tintColor = Style.basicBackgroundColor
            openInSafariButton.backgroundColor = Style.primaryColor
            openInSafariButton.tintColor = Style.basicBackgroundColor
            deleteButton.backgroundColor = Style.deleteColor
            deleteButton.tintColor = Style.basicBackgroundColor
            
            let urlStr : String = "https://www.google.co.jp/search?q=" + recipe.recipeName + "+カクテル"
            let url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            if UIApplication.shared.canOpenURL(url!) {
                openInSafariButton.isEnabled = true
            }else{
                openInSafariButton.isEnabled = false
                openInSafariButton.backgroundColor = Style.labelTextColorLight
            }
            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableView.automaticDimension
            tableView.reloadData()
            
            if fromContextualMenu == false{
                let realm = try! Realm()
                try! realm.write {
                    recipe.lastViewDate = Date()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        photoSizeCalcTime = 5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calcPhotoSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasRecipeDeleted{
            let coverView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
            coverView.backgroundColor = Style.basicBackgroundColor
            self.view.addSubview(coverView)

            let noRecipeAlertView = CustomAlertController(title: "このレシピは削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            noRecipeAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.navigationController?.popViewController(animated: true)
            }))
            noRecipeAlertView.alertStatusBarStyle = Style.statusBarStyle
            noRecipeAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noRecipeAlertView, animated: true, completion: nil)
        }

        if let path = tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: path, animated: true)
        }
        selectedIngredientId = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if recipe.isInvalidated == false, fromContextualMenu == false{
            let realm = try! Realm()
            try! realm.write {
                recipe.lastViewDate = Date()
            }
        }
    }
    
    // MARK: - Set Style
    private func setStarTitleOf(star1title: String, star2title: String, star3title: String){
        star1.setTitle(star1title, for: .normal)
        star2.setTitle(star2title, for: .normal)
        star3.setTitle(star3title, for: .normal)
    }

    private func setMadeNumButton(){
        if madeNum <= 0 {
            madeNumMinusButton.isEnabled = false
            madeNumMinusButton.setTitleColor(Style.labelTextColorLight, for: .normal)
            madeNumMinusButton.layer.borderColor = Style.labelTextColorLight.cgColor
        } else {
            madeNumMinusButton.isEnabled = true
            madeNumMinusButton.setTitleColor(Style.primaryColor, for: .normal)
            madeNumMinusButton.layer.borderColor = Style.primaryColor.cgColor
        }
        if madeNum >= 999 {
            madeNumPlusButton.isEnabled = false
            madeNumPlusButton.setTitleColor(Style.labelTextColorLight, for: .normal)
            madeNumPlusButton.layer.borderColor = Style.labelTextColorLight.cgColor
        } else {
            madeNumPlusButton.isEnabled = true
            madeNumPlusButton.setTitleColor(Style.primaryColor, for: .normal)
            madeNumPlusButton.layer.borderColor = Style.primaryColor.cgColor
        }
    }
    
    // MARK: - Photo Header
    private func calcPhotoSize(){
        if photoSizeCalcTime > 0{
            let minimumShownTableViewHeight: CGFloat = 80.0
            if imageWidth == 0 {
                photoHeight = 0
            }else{
                photoHeight = min(tableView.bounds.width, tableView.bounds.height - minimumShownTableViewHeight, tableView.bounds.width * imageHeight / imageWidth)
            }
            minimumPhotoHeight = min(tableView.bounds.width / 2, (tableView.bounds.height - minimumShownTableViewHeight) / 2, photoHeight)
            photoHeight = floor(photoHeight)
            minimumPhotoHeight = floor(minimumPhotoHeight)
                
            if let tableHeaderView = tableView.tableHeaderView{
                let newTableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: photoHeight))

                // tableViewのスクロールバーが画像に隠れる問題へのワークアラウンド
                tableView.showsVerticalScrollIndicator = false
                self.view.bringSubviewToFront(photoBackground)
                tableView.showsVerticalScrollIndicator = true

                if abs(tableHeaderView.frame.width - newTableHeaderView.frame.width) > 1 || abs(tableHeaderView.frame.height - newTableHeaderView.frame.height) > 1 {
                    tableView.tableHeaderView = newTableHeaderView
                }
            }
                
            if firstShow{
                tableView.contentOffset.y = photoHeight - minimumPhotoHeight
                firstShow = false
            }
                
            updateHeaderView()
            photoSizeCalcTime -= 1
        }
    }
    
    func updateHeaderView(){
        if noPhotoFlag == false{
            var headRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: photoHeight)
            if tableView.contentOffset.y < (photoHeight - minimumPhotoHeight) {
                headRect.origin.y = tableView.contentOffset.y
                headRect.size.height = photoHeight - tableView.contentOffset.y
            }else{
                headRect.origin.y = photoHeight - minimumPhotoHeight
                headRect.size.height = minimumPhotoHeight
            }
            headerView.frame = headRect
        }
    }

    @objc func photoTapped(_ recognizer: UITapGestureRecognizer) {
        if noPhotoFlag == false{
            if ImageUtil.loadImageOf(recipeId: recipe.id, forList: true) != nil {
                let storyboard = UIStoryboard(name: "ImageViewer", bundle: nil)
                let ivc = storyboard.instantiateViewController(withIdentifier: "ImageViewerController") as! ImageViewerController
                ivc.originalImageView = photo
                ivc.captionText = self.recipe.recipeName
                ivc.modalPresentationStyle = .overFullScreen
                ivc.modalTransitionStyle = .crossDissolve
                ivc.modalPresentationCapturesStatusBarAppearance = true
                self.present(ivc, animated: true)
            }
        }
    }
    
    @objc func photoLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        // 画像ファイルが消えた時に変なオブジェクトがクリップボードにコピーされるバグのためのワークアラウンド
        guard let imageFileName = self.recipe.imageFileName else{
            return
        }
        let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName + ".png")
        let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
        
        if loadedImage != nil && noPhotoFlag == false && recognizer.state == UIGestureRecognizer.State.began  {
            let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertView.addAction(UIAlertAction(title: "カメラロールへ保存",style: .default){ action in
                UIImageWriteToSavedPhotosAlbum(loadedImage!, self, #selector(RecipeDetailTableViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                })
            alertView.addAction(UIAlertAction(title: "クリップボードへコピー",style: .default){ action in
                let pasteboard: UIPasteboard = UIPasteboard.general
                pasteboard.image = loadedImage!
                ProgressHUD.showSuccess(with: "クリップボードへコピーしました", duration: 1.5)
                })
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
            alertView.popoverPresentationController?.sourceView = self.view
            alertView.popoverPresentationController?.sourceRect = self.photo.frame
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        if error == nil{
            ProgressHUD.showSuccess(with: "カメラロールへ保存しました", duration: 1.5)
        }else{
            let alertView = CustomAlertController(title: "カメラロールへの保存に失敗しました", message: "「設定」→「うちカク！」にて写真へのアクセス許可を確認してください", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: {action in
            }))
            alertView.addAction(UIAlertAction(title: "設定を開く", style: .default, handler: {action in
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }else if indexPath.section == 1{
            return 70
        }else if indexPath.section == 2{
            return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 2))
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Style.tableViewHeaderBackgroundColor
        
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = Style.tableViewHeaderTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = section == 1 ? "材料(\(String(recipe.recipeIngredients.count)))" : ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 6
        }else if section == 1{
            return recipe.recipeIngredients.count
        }else if section == 2{
            return 1
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            performSegue(withIdentifier: "PushIngredientDetail", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else { return UISwipeActionsConfiguration(actions: []) }
        
        let reminder =  UIContextualAction(style: .normal, title: "リマインダー", handler: { (action,view,completionHandler ) in
            let storyboard = UIStoryboard(name: "Reminder", bundle: nil)
            guard let nvc = storyboard.instantiateViewController(withIdentifier: "ReminderNavigationController") as? BasicNavigationController else{
                return
            }
            guard let vc = nvc.visibleViewController as? ReminderTableViewController else{
                return
            }
            vc.ingredientName = self.recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            vc.onDoneBlock = {
                self.setupVC()
            }

            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
                nvc.modalPresentationStyle = .pageSheet
            }else{
                nvc.modalPresentationStyle = .custom
                nvc.transitioningDelegate = self
                vc.interactor = self.interactor
            }
            self.present(nvc, animated: true)
        })
        reminder.image = UIImage(named: "button-reminder")
        reminder.backgroundColor = Style.primaryColor

        return UISwipeActionsConfiguration(actions: [reminder])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell") as! RecipeIngredientTableViewCell
            
            let disclosureIndicator = UIImage(named: "disclosure-indicator")
            let accesoryImageView = UIImageView(image: disclosureIndicator)
            accesoryImageView.tintColor = Style.labelTextColorLight
            cell.accessoryView = accesoryImageView

            cell.ingredientId = recipe.recipeIngredients[indexPath.row].ingredient.id
            cell.ingredientName = recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            cell.isOption = !recipe.recipeIngredients[indexPath.row].mustFlag
            cell.stock = recipe.recipeIngredients[indexPath.row].ingredient.stockFlag
            cell.amountText = recipe.recipeIngredients[indexPath.row].amount
            cell.selectionStyle = .default
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView

            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            return cell
        case 2:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: - IBAction
    func createLongMessage() -> String{
        var message = "【カクテルレシピ】" + recipe.recipeName + "\n"
        switch recipe.method{
        case 0:
            message += "技法：ビルド\n\n"
        case 1:
            message += "技法：ステア\n\n"
        case 2:
            message += "技法：シェイク\n\n"
        case 3:
            message += "技法：ブレンド\n\n"
        case 4:
            message += "技法：その他\n\n"
        default: break
        }
        message += "材料：\n"
        for recipeIngredient in recipe.recipeIngredients{
            message += recipeIngredient.ingredient.ingredientName + " " + recipeIngredient.amount + "\n"
        }
        if recipe.memo != "" {
            message += "\n" + recipe.memo
        }
        return message
    }
    
    @IBAction func star1Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        if star1.currentTitle == "★" && star2.currentTitle == "☆"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
            try! realm.write {
                recipe.favorites = 0
            }
        }else{
            setStarTitleOf(star1title: "★", star2title: "☆", star3title: "☆")
            try! realm.write {
                recipe.favorites = 1
            }
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        if star2.currentTitle == "★" && star3.currentTitle == "☆"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
            try! realm.write {
                recipe.favorites = 0
            }
        }else{
            setStarTitleOf(star1title: "★", star2title: "★", star3title: "☆")
            try! realm.write {
                recipe.favorites = 2
            }
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        if star3.currentTitle == "★"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
            try! realm.write {
                recipe.favorites = 0
            }
        }else{
            setStarTitleOf(star1title: "★", star2title: "★", star3title: "★")
            try! realm.write {
                recipe.favorites = 3
            }
        }
    }
    
    @IBAction func styleTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "StyleTipNavigationController") as! UINavigationController
        let vc = nvc.visibleViewController as! StyleTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .formSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }
        present(nvc, animated: true)
    }
    
    @IBAction func methodTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "MethodTipNavigationController") as! UINavigationController
        let vc = nvc.visibleViewController as! MethodTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .formSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }
        present(nvc, animated: true)
    }
    
    @IBAction func madeNumPlusButtonTapped(_ sender: UIButton) {
        if madeNum < 999 {
            madeNum += 1
            madeNumCountUpLabel.text = String(madeNum) + "回"
            let realm = try! Realm()
            try! realm.write {
                recipe.madeNum = Int(madeNum)
            }
        }
        setMadeNumButton()
    }
    
    @IBAction func madeNumMinusButtonTapped(_ sender: UIButton) {
        if madeNum > 0 {
            madeNum -= 1
            madeNumCountUpLabel.text = String(madeNum) + "回"
            let realm = try! Realm()
            try! realm.write {
                recipe.madeNum = Int(madeNum)
            }
        }
        setMadeNumButton()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "PushEditRecipe", sender: UIBarButtonItem())
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let excludedActivityTypes = [
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.openInIBooks
        ]
        
        let shareText = createLongMessage()
        if noPhotoFlag == false, let image = photo.image {
            let activityVC = CustomActivityController(activityItems: [shareText, image], applicationActivities: nil)
            activityVC.excludedActivityTypes = excludedActivityTypes
            activityVC.activityStatusBarStyle = Style.statusBarStyle
            activityVC.modalPresentationCapturesStatusBarAppearance = true
            activityVC.popoverPresentationController?.sourceView = sender
            activityVC.popoverPresentationController?.sourceRect = sender.frame
            self.present(activityVC, animated: true, completion: nil)
        }else{
            let activityVC = CustomActivityController(activityItems: [shareText], applicationActivities: nil)
            activityVC.excludedActivityTypes = excludedActivityTypes
            activityVC.activityStatusBarStyle = Style.statusBarStyle
            activityVC.modalPresentationCapturesStatusBarAppearance = true
            activityVC.popoverPresentationController?.sourceView = sender
            activityVC.popoverPresentationController?.sourceRect = sender.frame
            activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                self.setNeedsStatusBarAppearanceUpdate()
            }
            self.present(activityVC, animated: true, completion: nil)
        }        
    }
    
    @IBAction func openInSafariButtonTapped(_ sender: UIButton) {
        let urlStr : String = "https://www.google.co.jp/search?q=" + recipe.recipeName + "+カクテル"
        let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        if UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alertView = CustomAlertController(title: nil, message: "本当に削除しますか？", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "削除",style: .destructive){
            action in
            let realm = try! Realm()
            let deletingRecipeIngredientList = List<RecipeIngredientLink>()
            for i in 0 ..< self.recipe.recipeIngredients.count {
                let recipeIngredient = realm.object(ofType: RecipeIngredientLink.self, forPrimaryKey: self.recipe.recipeIngredients[i].id)!
                deletingRecipeIngredientList.append(recipeIngredient)
            }
            
            ImageUtil.remove(imageFileName: self.recipe.imageFileName)
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
                realm.delete(self.recipe)
            }
            _ = self.navigationController?.popViewController(animated: true)
        })
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
        alertView.alertStatusBarStyle = Style.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentedNVC = presented as? BasicNavigationController
        let VC = presentedNVC?.visibleViewController!
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)

        if let VC = VC{
            if VC.isKind(of: StyleTipViewController.self) || VC.isKind(of: MethodTipViewController.self){
                pc.xMargin = 60
                pc.yMargin = 160
                pc.canDismissWithOverlayViewTouch = true
                return pc
            }
        }
        
        pc.xMargin = 20
        pc.yMargin = 40
        pc.canDismissWithOverlayViewTouch = false
        return pc
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissedNVC = dismissed as? BasicNavigationController
        let VC = dismissedNVC?.visibleViewController!
        let animator = DismissModalAnimator()

        if let VC = VC {
            if VC.isKind(of: StyleTipViewController.self) || VC.isKind(of: MethodTipViewController.self){
                animator.xMargin = 60
                animator.yMargin = 160
                return animator
            }
        }

        animator.xMargin = 20
        animator.yMargin = 40
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destination as! IngredientDetailTableViewController
            if let indexPath = sender as? IndexPath{
                selectedIngredientId = recipe.recipeIngredients[indexPath.row].ingredient.id
                vc.ingredientId = recipe.recipeIngredients[indexPath.row].ingredient.id
            }
        }else if segue.identifier == "PushEditRecipe" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! RecipeEditTableViewController
            evc.recipe = self.recipe
        }
    }
    
    func closeEditVC(_ editVC: RecipeEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
    }    
}
