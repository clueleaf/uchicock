//
//  RecipeDetailTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/08.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
import Accounts

class RecipeDetailTableViewController: UITableViewController{

    @IBOutlet weak var photoBackground: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var recipeName: CopyableLabel!
    @IBOutlet weak var lastViewDateLabel: UILabel!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var madeNumLabel: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var method: UILabel!
    @IBOutlet weak var memo: CopyableLabel!
    @IBOutlet weak var madeNumPlusButton: UIButton!
    @IBOutlet weak var madeNumMinusButton: UIButton!
    @IBOutlet weak var madeNumCountUpLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var openInSafariButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButtonLabel: UILabel!
    @IBOutlet weak var shareButtonLabel: UILabel!
    @IBOutlet weak var openInSafariButtonLabel: UILabel!
    @IBOutlet weak var deleteButtonLabel: UILabel!
    
    var editVC : RecipeEditTableViewController!
    var headerView: UIView!
    var photoHeight: CGFloat = 0.0
    var recipeId = String()
    var recipe = Recipe()
    var noPhotoFlag = false
    var madeNum = 0
    let selectedCellBackgroundView = UIView()
    var selectedIngredientId: String? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.width))
        tableView.addSubview(headerView)
        
        madeNumPlusButton.layer.cornerRadius = madeNumPlusButton.frame.size.width / 2
        madeNumPlusButton.layer.borderWidth = 1.5
        madeNumMinusButton.layer.cornerRadius = madeNumMinusButton.frame.size.width / 2
        madeNumMinusButton.layer.borderWidth = 1.5
        
        editButton.layer.cornerRadius = editButton.frame.size.width / 2
        editButton.clipsToBounds = true
        let editImage = UIImage(named: "edit")?.withRenderingMode(.alwaysTemplate)
        editButton.setImage(editImage, for: .normal)
        shareButton.layer.cornerRadius = shareButton.frame.size.width / 2
        let shareImage = UIImage(named: "share")?.withRenderingMode(.alwaysTemplate)
        shareButton.setImage(shareImage, for: .normal)
        shareButton.clipsToBounds = true
        openInSafariButton.layer.cornerRadius = openInSafariButton.frame.size.width / 2
        let openInSafariImage = UIImage(named: "safari")?.withRenderingMode(.alwaysTemplate)
        openInSafariButton.setImage(openInSafariImage, for: .normal)
        openInSafariButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = deleteButton.frame.size.width / 2
        let deleteImage = UIImage(named: "delete")?.withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.clipsToBounds = true

        tableView.register(RecipeIngredientListTableViewCell.self, forCellReuseIdentifier: "RecipeIngredientList")
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeDetailTableViewController.photoTapped(_:)))
        photoBackground.addGestureRecognizer(tapRecognizer)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecipeDetailTableViewController.photoLongPressed(_:)))
        longPressRecognizer.allowableMovement = 100
        longPressRecognizer.minimumPressDuration = 0.2
        photoBackground.addGestureRecognizer(longPressRecognizer)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        let indexPathForSelectedRow = tableView.indexPathForSelectedRow
        super.viewWillAppear(animated)

        lastViewDateLabel.textColor = Style.labelTextColorLight
        starLabel.textColor = Style.labelTextColor
        methodLabel.textColor = Style.labelTextColor
        memoLabel.textColor = Style.labelTextColor
        method.textColor = Style.labelTextColor
        madeNumLabel.textColor = Style.labelTextColor
        madeNumCountUpLabel.textColor = Style.labelTextColor
        editButtonLabel.textColor = Style.labelTextColor
        shareButtonLabel.textColor = Style.labelTextColor
        openInSafariButtonLabel.textColor = Style.labelTextColor
        deleteButtonLabel.textColor = Style.deleteColor

        photoBackground.backgroundColor = Style.basicBackgroundColor
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }

        let realm = try! Realm()
        let rec = realm.object(ofType: Recipe.self, forPrimaryKey: recipeId)
        if rec == nil {
            let noRecipeAlertView = CustomAlertController(title: "このレシピは削除されました", message: "元の画面に戻ります", preferredStyle: .alert)
            noRecipeAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            noRecipeAlertView.alertStatusBarStyle = Style.statusBarStyle
            noRecipeAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noRecipeAlertView, animated: true, completion: nil)
        }else{
            recipe = rec!
            self.navigationItem.title = recipe.recipeName
            
            noPhotoFlag = false
            if let image = recipe.imageData{
                photo.image = UIImage(data: image as Data)
                //レシピ削除のバグに対するワークアラウンド
                if let im = photo.image {
                    if im.size.width > im.size.height{
                        photoHeight = tableView.bounds.width * im.size.height / im.size.width
                    }else{
                        photoHeight = tableView.bounds.width
                    }
                    photo.clipsToBounds = true
                    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: photoHeight))
                    self.view.bringSubviewToFront(photoBackground)
                }else{
                    tableView.tableHeaderView = nil
                    noPhotoFlag = true
                    photoBackground.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0)
                    photoHeight = 0.0
                }
            }else{
                tableView.tableHeaderView = nil
                noPhotoFlag = true
                photoBackground.frame = CGRect(x: 0 , y: 0, width: tableView.bounds.width, height: 0)
                photoHeight = 0.0
            }
            updateHeaderView()

            recipeName.text = recipe.recipeName
            recipeName.textColor = Style.labelTextColor
            if recipe.lastViewDate == nil{
                lastViewDateLabel.text = "最終閲覧：--"
            }else{
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                lastViewDateLabel.text = "最終閲覧：" + formatter.string(from: recipe.lastViewDate!)
            }

            switch recipe.favorites{
            case 0:
                star1.setTitle("☆", for: .normal)
                star2.setTitle("☆", for: .normal)
                star3.setTitle("☆", for: .normal)
            case 1:
                star1.setTitle("★", for: .normal)
                star2.setTitle("☆", for: .normal)
                star3.setTitle("☆", for: .normal)
            case 2:
                star1.setTitle("★", for: .normal)
                star2.setTitle("★", for: .normal)
                star3.setTitle("☆", for: .normal)
            case 3:
                star1.setTitle("★", for: .normal)
                star2.setTitle("★", for: .normal)
                star3.setTitle("★", for: .normal)
            default:
                star1.setTitle("☆", for: .normal)
                star2.setTitle("☆", for: .normal)
                star3.setTitle("☆", for: .normal)
            }
            star1.tintColor = Style.secondaryColor
            star2.tintColor = Style.secondaryColor
            star3.tintColor = Style.secondaryColor
            
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

            memo.text = recipe.memo
            memo.textColor = Style.labelTextColorLight
            madeNum = recipe.madeNum
            madeNumCountUpLabel.text = String(madeNum) + "回"
            setMadeNumButton()

            editButton.backgroundColor = Style.secondaryColor
            editButton.tintColor = Style.basicBackgroundColor
            shareButton.backgroundColor = Style.secondaryColor
            shareButton.tintColor = Style.basicBackgroundColor
            openInSafariButton.backgroundColor = Style.secondaryColor
            openInSafariButton.tintColor = Style.basicBackgroundColor
            deleteButton.backgroundColor = Style.deleteColor
            deleteButton.tintColor = Style.basicBackgroundColor
            
            let urlStr : String = "https://www.google.co.jp/search?q=" + recipe.recipeName + "+カクテル"
            let url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            if UIApplication.shared.canOpenURL(url!) {
                openInSafariButton.isEnabled = true
            }else{
                openInSafariButton.isEnabled = false
                openInSafariButton.backgroundColor = Style.badgeDisableBackgroundColor
            }

            self.tableView.estimatedRowHeight = 70
            self.tableView.rowHeight = UITableView.automaticDimension
            tableView.reloadData()
            
            if let index = indexPathForSelectedRow {
                if tableView.numberOfRows(inSection: 1) > index.row{
                    let nowIngredientId = (tableView.cellForRow(at: index) as? RecipeIngredientListTableViewCell)?.ingredientId
                    if nowIngredientId != nil && selectedIngredientId != nil{
                        if nowIngredientId! == selectedIngredientId!{
                            tableView.selectRow(at: indexPathForSelectedRow, animated: false, scrollPosition: .none)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.tableView.deselectRow(at: index, animated: true)
                            }
                        }
                    }
                }
            }
            selectedIngredientId = nil
            let realm = try! Realm()
            try! realm.write {
                recipe.lastViewDate = Date()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        if recipe.isInvalidated == false{
            let realm = try! Realm()
            try! realm.write {
                recipe.lastViewDate = Date()
            }
        }
    }
    
    func setMadeNumButton(){
        if madeNum <= 0 {
            madeNumMinusButton.isEnabled = false
            madeNumMinusButton.tintColor = Style.labelTextColorLight
            madeNumMinusButton.layer.borderColor = Style.labelTextColorLight.cgColor
        } else {
            madeNumMinusButton.isEnabled = true
            madeNumMinusButton.tintColor = Style.secondaryColor
            madeNumMinusButton.layer.borderColor = Style.secondaryColor.cgColor
        }
        if madeNum >= 999 {
            madeNumPlusButton.isEnabled = false
            madeNumPlusButton.tintColor = Style.labelTextColorLight
            madeNumPlusButton.layer.borderColor = Style.labelTextColorLight.cgColor
        } else {
            madeNumPlusButton.isEnabled = true
            madeNumPlusButton.tintColor = Style.secondaryColor
            madeNumPlusButton.layer.borderColor = Style.secondaryColor.cgColor
        }
    }
    
    func closeEditVC(_ editVC: RecipeEditTableViewController){
        editVC.dismiss(animated: true, completion: nil)
    }
    
    func updateHeaderView(){
        if noPhotoFlag == false{
            var headRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: photoHeight)
            if tableView.contentOffset.y < 0{
                headRect.origin.y = tableView.contentOffset.y
                headRect.size.height = photoHeight - tableView.contentOffset.y
            }
            headerView.frame = headRect
        }
    }

    @objc func photoTapped(_ recognizer: UITapGestureRecognizer) {
        if noPhotoFlag == false{
            if let image = recipe.imageData {
                //レシピ削除のバグに対するワークアラウンド
                let browsePhoto = UIImage(data: image as Data)
                if browsePhoto != nil{
                    let p = IDMPhoto(image: browsePhoto)
                    p!.caption = self.recipe.recipeName
                    let browser: CustomPhotoBrowser! = CustomPhotoBrowser(photos: [p!], animatedFrom: photo)
                    browser.displayActionButton = false
                    browser.displayArrowButton = false
                    browser.photoBrowserStatusBarStyle = Style.statusBarStyle
                    self.present(browser, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func photoLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        if noPhotoFlag == false && recognizer.state == UIGestureRecognizer.State.began  {
            let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertView.addAction(UIAlertAction(title: "カメラロールへ保存",style: .default){ action in
                if let image = self.photo.image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(RecipeDetailTableViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                })
            alertView.addAction(UIAlertAction(title: "クリップボードへコピー",style: .default){ action in
                if let image = self.photo.image {
                    let pasteboard: UIPasteboard = UIPasteboard.general
                    pasteboard.image = image
                }
                })
            alertView.addAction(UIAlertAction(title: "キャンセル", style: .cancel){action in})
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        if error == nil{
            SVProgressHUD.showSuccess(withStatus: "カメラロールへ保存しました")
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
            return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
        }else if indexPath.section == 2{
            return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 2))
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if section == 1 {
            label.text = "  材料(" + String(recipe.recipeIngredients.count) + ")"
        }else{
            label.text = nil
        }
        return label
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 5
        }else if section == 1{
            return recipe.recipeIngredients.count
        }else if section == 2{
            return 1
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }else if indexPath.section == 1{
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 1))
        }else if indexPath.section == 2{
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 2))
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            performSegue(withIdentifier: "PushIngredientDetail", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let reminder = UITableViewRowAction(style: .normal, title: "リマインダー") {
            (action, indexPath) in
            self.performSegue(withIdentifier: "PushReminder", sender: indexPath)
        }
        reminder.backgroundColor = Style.tableViewCellReminderBackgroundColor
        
        return [reminder]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientList", for: indexPath) as! RecipeIngredientListTableViewCell
            cell.ingredientId = recipe.recipeIngredients[indexPath.row].ingredient.id
            cell.ingredientName.text = recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            cell.ingredientName.backgroundColor = Style.basicBackgroundColor
            cell.ingredientName.clipsToBounds = true
            cell.option.backgroundColor = UIColor.clear
            if recipe.recipeIngredients[indexPath.row].mustFlag{
                cell.option.text = ""
                cell.option.layer.backgroundColor = UIColor.clear.cgColor
            }else{
                cell.option.text = "オプション"
                cell.option.layer.backgroundColor = Style.badgeDisableBackgroundColor.cgColor
            }
            cell.option.textColor = Style.labelTextColorOnDisableBadge
            cell.option.layer.cornerRadius = 4
            cell.option.clipsToBounds = true
            cell.option.textAlignment = NSTextAlignment.center

            cell.stock.backgroundColor = UIColor.clear
            if recipe.recipeIngredients[indexPath.row].ingredient.stockFlag {
                cell.stock.text = "在庫あり"
                cell.stock.textColor = Style.labelTextColorOnBadge
                cell.stock.layer.backgroundColor = Style.secondaryColor.cgColor
                cell.ingredientName.textColor = Style.labelTextColor
                cell.amount.textColor = Style.labelTextColor
            }else{
                cell.stock.text = "在庫なし"
                cell.stock.textColor = Style.labelTextColorOnDisableBadge
                cell.stock.layer.backgroundColor = Style.badgeDisableBackgroundColor.cgColor
                cell.ingredientName.textColor = Style.labelTextColorLight
                cell.amount.textColor = Style.labelTextColorLight
            }
            cell.stock.layer.cornerRadius = 4
            cell.stock.clipsToBounds = true
            cell.stock.textAlignment = NSTextAlignment.center
            cell.amount.text = recipe.recipeIngredients[indexPath.row].amount
            cell.amount.backgroundColor = Style.basicBackgroundColor
            cell.amount.clipsToBounds = true
            
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            cell.selectionStyle = .default
            cell.selectedBackgroundView = selectedCellBackgroundView

            cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            return cell
        case 2:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
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
            star1.setTitle("☆", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
            try! realm.write {
                recipe.favorites = 0
            }
        }else{
            star1.setTitle("★", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
            try! realm.write {
                recipe.favorites = 1
            }
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        if star2.currentTitle == "★" && star3.currentTitle == "☆"{
            star1.setTitle("☆", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
            try! realm.write {
                recipe.favorites = 0
            }
        }else{
            star1.setTitle("★", for: .normal)
            star2.setTitle("★", for: .normal)
            star3.setTitle("☆", for: .normal)
            try! realm.write {
                recipe.favorites = 2
            }
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        let realm = try! Realm()
        if star3.currentTitle == "★"{
            star1.setTitle("☆", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
            try! realm.write {
                recipe.favorites = 0
            }
        }else{
            star1.setTitle("★", for: .normal)
            star2.setTitle("★", for: .normal)
            star3.setTitle("★", for: .normal)
            try! realm.write {
                recipe.favorites = 3
            }
        }
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
            self.present(activityVC, animated: true, completion: nil)
        }else{
            let activityVC = CustomActivityController(activityItems: [shareText], applicationActivities: nil)
            activityVC.excludedActivityTypes = excludedActivityTypes
            activityVC.activityStatusBarStyle = Style.statusBarStyle
            activityVC.modalPresentationCapturesStatusBarAppearance = true
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
        }else if segue.identifier == "PushReminder" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! ReminderTableViewController
            if let indexPath = sender as? IndexPath{
                evc.ingredientName = recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            }
        }
    }
    
}
