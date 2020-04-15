//
//  RecipeEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class RecipeEditTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var recipeNameTableViewCell: UITableViewCell!
    @IBOutlet weak var recipeName: CustomTextField!
    @IBOutlet weak var recipeNameCounter: UILabel!
    @IBOutlet weak var star1: ExpandedButton!
    @IBOutlet weak var star2: ExpandedButton!
    @IBOutlet weak var star3: ExpandedButton!
    @IBOutlet weak var styleTipButton: ExpandedButton!
    @IBOutlet weak var methodTipButton: ExpandedButton!
    @IBOutlet weak var strengthTipButton: ExpandedButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var selectPhoto: UILabel!
    @IBOutlet weak var favoriteTableViewCell: UITableViewCell!
    @IBOutlet weak var styleTableViewCell: UITableViewCell!
    @IBOutlet weak var methodTableViewCell: UITableViewCell!
    @IBOutlet weak var strengthTableViewCell: UITableViewCell!
    @IBOutlet weak var style: CustomSegmentedControl!
    @IBOutlet weak var method: CustomSegmentedControl!
    @IBOutlet weak var strength: CustomSegmentedControl!
    @IBOutlet weak var memoTableViewCell: UITableViewCell!
    @IBOutlet weak var memo: CustomTextView!
    @IBOutlet weak var memoCounter: UILabel!
    @IBOutlet weak var addIngredientLabel: UILabel!
    
    weak var mainNavigationController : BasicNavigationController?
    var ipc = UIImagePickerController()

    var recipe = Recipe()
    var recipeIngredientList = Array<RecipeIngredientBasic>()
    var duplicatedIngredientList = Array<String>()
    var needUpdateCellIndexList = Array<IndexPath>()

    var recipeFavorite = 0
    let recipeNameMaximum = 30
    let memoMaximum = 1000

    var isAddMode = true
    var focusRecipeNameFlag = false
    var showCancelAlert = false

    let selectedCellBackgroundView = UIView()
    var selectedIndexPath: IndexPath? = nil

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientCell")

        star1.minimumHitWidth = 36
        star1.minimumHitHeight = 36
        star2.minimumHitWidth = 36
        star2.minimumHitHeight = 36
        star3.minimumHitWidth = 36
        star3.minimumHitHeight = 36
        styleTipButton.minimumHitWidth = 50
        styleTipButton.minimumHitHeight = 36
        methodTipButton.minimumHitWidth = 50
        methodTipButton.minimumHitHeight = 36
        strengthTipButton.minimumHitWidth = 50
        strengthTipButton.minimumHitHeight = 36
        star1.tintColor = UchicockStyle.primaryColor
        star2.tintColor = UchicockStyle.primaryColor
        star3.tintColor = UchicockStyle.primaryColor

        recipeName.text = recipe.recipeName
        recipeName.delegate = self
        recipeName.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        recipeName.layer.cornerRadius = 5.0
        recipeName.layer.borderWidth = 1
        recipeName.attributedPlaceholder = NSAttributedString(string: "レシピ名", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        recipeName.adjustClearButtonColor(with: 4)

        if let image = ImageUtil.loadImageOf(recipeId: recipe.id, forList: false){
            photo.image = image
        }
        if photo.image == nil{
            selectPhoto.text = "写真を追加"
            photo.isHidden = true
        }else{
            selectPhoto.text = "写真を変更"
            photo.isHidden = false
        }
        selectPhoto.textColor = UchicockStyle.primaryColor

        let photoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeEditTableViewController.photoTapped))
        self.photo.addGestureRecognizer(photoTapGestureRecognizer)
        
        ipc.delegate = self
        
        if #available(iOS 13.0, *) {
        }else{
            style.layer.cornerRadius = 14.0
            method.layer.cornerRadius = 14.0
            strength.layer.cornerRadius = 14.0
        }
        style.layer.borderColor = UchicockStyle.primaryColor.cgColor
        style.layer.borderWidth = 1.0
        style.layer.masksToBounds = true
        method.layer.borderColor = UchicockStyle.primaryColor.cgColor
        method.layer.borderWidth = 1.0
        method.layer.masksToBounds = true
        strength.layer.borderColor = UchicockStyle.primaryColor.cgColor
        strength.layer.borderWidth = 1.0
        strength.layer.masksToBounds = true

        if recipe.recipeName == "" {
            self.navigationItem.title = "レシピ登録"
            setStarImageOf(star1isFilled: false, star2isFilled: false, star3isFilled: false)
            recipeFavorite = 0
            style.selectedSegmentIndex = 3
            method.selectedSegmentIndex = 0
            strength.selectedSegmentIndex = 4
            isAddMode = true
        } else {
            self.navigationItem.title = "レシピ編集"
            switch recipe.favorites{
            case 0:
                setStarImageOf(star1isFilled: false, star2isFilled: false, star3isFilled: false)
                recipeFavorite = 0
            case 1:
                setStarImageOf(star1isFilled: true, star2isFilled: false, star3isFilled: false)
                recipeFavorite = 1
            case 2:
                setStarImageOf(star1isFilled: true, star2isFilled: true, star3isFilled: false)
                recipeFavorite = 2
            case 3:
                setStarImageOf(star1isFilled: true, star2isFilled: true, star3isFilled: true)
                recipeFavorite = 3
            default:
                setStarImageOf(star1isFilled: false, star2isFilled: false, star3isFilled: false)
                recipeFavorite = 0
            }
            style.selectedSegmentIndex = recipe.style
            method.selectedSegmentIndex = recipe.method
            strength.selectedSegmentIndex = recipe.strength
            isAddMode = false
        }
        
        memo.text = recipe.memo
        memo.delegate = self
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        memo.layer.borderColor = UchicockStyle.textFieldBorderColor.cgColor
        memo.keyboardAppearance = UchicockStyle.isDark ? .dark : .light

        var needInitializeDisplayOrder = false
        for ri in recipe.recipeIngredients {
            recipeIngredientList.append(RecipeIngredientBasic(recipeIngredientId: ri.id, ingredientId: ri.ingredient.id, ingredientName: ri.ingredient.ingredientName, amount: ri.amount, mustFlag: ri.mustFlag, category: ri.ingredient.category, displayOrder: ri.displayOrder, stockFlag: false))
            if ri.displayOrder < 0{
                needInitializeDisplayOrder = true
                break
            }
        }
        
        if needInitializeDisplayOrder{
            initializeDisplayOrder()
        }
        
        recipeIngredientList.sort(by: { $0.displayOrder < $1.displayOrder })
        
        focusRecipeNameFlag = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeEditTableViewController.textFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.recipeName)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeEditTableViewController.textFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.recipeName)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.labelTextColorLight
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        
        addIngredientLabel.textColor = UchicockStyle.primaryColor
        addIngredientLabel.font = UIFont.boldSystemFont(ofSize: 20.0)

        let tipImage = UIImage(named: "button-tip")
        styleTipButton.setImage(tipImage, for: .normal)
        styleTipButton.tintColor = UchicockStyle.primaryColor
        methodTipButton.setImage(tipImage, for: .normal)
        methodTipButton.tintColor = UchicockStyle.primaryColor
        strengthTipButton.setImage(tipImage, for: .normal)
        strengthTipButton.tintColor = UchicockStyle.primaryColor
        
        updateRecipeNameCounter()
        updateMemoCounter()
    }
    
    private func initializeDisplayOrder(){
        let realm = try! Realm()
        try! realm.write{
            for i in 0 ..< recipe.recipeIngredients.count {
                recipe.recipeIngredients[i].displayOrder = i
            }
        }
        
        recipeIngredientList.removeAll()
        for ri in recipe.recipeIngredients {
            recipeIngredientList.append(RecipeIngredientBasic(recipeIngredientId: ri.id, ingredientId: ri.ingredient.id, ingredientName: ri.ingredient.ingredientName, amount: ri.amount, mustFlag: ri.mustFlag, category: ri.ingredient.category, displayOrder: ri.displayOrder, stockFlag: false))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAddMode && focusRecipeNameFlag{
            recipeName.becomeFirstResponder()
            focusRecipeNameFlag = false
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Set Style
    private func setStarImageOf(star1isFilled: Bool, star2isFilled: Bool, star3isFilled: Bool){
        if star1isFilled {
            star1.setImage(UIImage(named: "button-star-filled"), for: .normal)
        }else{
            star1.setImage(UIImage(named: "button-star-empty"), for: .normal)
        }
        if star2isFilled {
            star2.setImage(UIImage(named: "button-star-filled"), for: .normal)
        }else{
            star2.setImage(UIImage(named: "button-star-empty"), for: .normal)
        }
        if star3isFilled {
            star3.setImage(UIImage(named: "button-star-filled"), for: .normal)
        }else{
            star3.setImage(UIImage(named: "button-star-empty"), for: .normal)
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        recipeName.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ notification: Notification){
        recipeName.adjustClearButtonColor(with: 4)
        showCancelAlert = true
        updateRecipeNameCounter()
    }
    
    private func updateRecipeNameCounter(){
        let num = recipeName.text!.withoutSpace().count
        recipeNameCounter.text = String(num) + "/" + String(recipeNameMaximum)
        
        if num > recipeNameMaximum{
            recipeNameCounter.textColor = UchicockStyle.deleteColor
        }else{
            recipeNameCounter.textColor = UchicockStyle.labelTextColorLight
        }
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        showCancelAlert = true
        updateMemoCounter()
    }
    
    private func updateMemoCounter(){
        let num = memo.text.count
        memoCounter.text = String(num) + "/" + String(memoMaximum)
            
        if num > memoMaximum{
            memoCounter.textColor = UchicockStyle.deleteColor
        }else{
            memoCounter.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    // MARK: - Manage Data
    private func isIngredientDuplicated() -> Bool {
        if recipeIngredientList.count == 0 { return false }
        for i in 0 ..< recipeIngredientList.count - 1{
            for j in i+1 ..< recipeIngredientList.count{
                if recipeIngredientList[i].ingredientName == recipeIngredientList[j].ingredientName{
                    return true
                }
            }
        }
        return false
    }
    
    private func updateDuplicatedIngredientList(){
        duplicatedIngredientList.removeAll()

        if recipeIngredientList.count == 0 { return }
        for i in 0 ..< recipeIngredientList.count - 1{
            for j in i+1 ..< recipeIngredientList.count{
                if recipeIngredientList[i].ingredientName == recipeIngredientList[j].ingredientName{
                    duplicatedIngredientList.append(recipeIngredientList[i].ingredientName)
                    break
                }
            }
        }
    }
    
    private func createNeedUpdateCellIndexList(){
        self.needUpdateCellIndexList.removeAll()
        
        if recipeIngredientList.count == 0 { return }
        for i in 0 ..< recipeIngredientList.count - 1 {
            if needUpdateCellIndexList.contains(IndexPath(row: i, section: 1)) { continue }
            for j in i+1 ..< recipeIngredientList.count{
                if needUpdateCellIndexList.contains(IndexPath(row: j, section: 1)) { continue }
                if recipeIngredientList[i].ingredientName == recipeIngredientList[j].ingredientName{
                    if needUpdateCellIndexList.contains(IndexPath(row: i, section: 1)) == false {
                        needUpdateCellIndexList.append(IndexPath(row: i, section: 1))
                    }
                    if needUpdateCellIndexList.contains(IndexPath(row: j, section: 1)) == false {
                        needUpdateCellIndexList.append(IndexPath(row: j, section: 1))
                    }
                }
            }
        }
    }
    
    @objc func photoTapped(){
        if let image = photo.image{
            if let repre = image.pngData(){
                let browsePhoto = UIImage(data: repre)
                if browsePhoto != nil{
                    let storyboard = UIStoryboard(name: "ImageViewer", bundle: nil)
                    let ivc = storyboard.instantiateViewController(withIdentifier: "ImageViewerController") as! ImageViewerController
                    ivc.originalImageView = photo
                    ivc.captionText = nil
                    ivc.modalPresentationStyle = .overFullScreen
                    ivc.modalTransitionStyle = .crossDissolve
                    ivc.modalPresentationCapturesStatusBarAppearance = true
                    self.present(ivc, animated: true)
                }
            }
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 30 : 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.tableViewHeaderBackgroundColor
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.tableViewHeaderTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = section == 1 ? "材料編集" : ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < recipeIngredientList.count{
                return 70
            } else if indexPath.row == recipeIngredientList.count{
                return super.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 1))
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        } else if section == 1{
            return recipeIngredientList.count + 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1{
            tableView.deselectRow(at: indexPath, animated: true)
            addPhoto()
        }else if indexPath.section == 1{
            let storyboard = UIStoryboard(name: "RecipeEdit", bundle: nil)
            let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeIngredientEditNavigationController") as! BasicNavigationController
            let vc = nvc.visibleViewController as! RecipeIngredientEditTableViewController

            vc.onDoneBlock = { isCancel, deleteFlag, isAddMode, ingredientName, amount, category, mustFlag, recipeIngredientId in
                if isCancel == false{
                    if isAddMode{
                        if deleteFlag == false{
                            // 材料新規追加
                            let recipeIngredient = RecipeIngredientBasic(recipeIngredientId: "", ingredientId: "", ingredientName: ingredientName, amount: amount, mustFlag: mustFlag, category: category, displayOrder: -1, stockFlag: false)
                            self.recipeIngredientList.append(recipeIngredient)
                            if self.selectedIndexPath != nil{
                                self.selectedIndexPath = IndexPath(row: self.selectedIndexPath!.row + 1, section: self.selectedIndexPath!.section)
                            }
                            self.showCancelAlert = true
                            self.updateDuplicatedIngredientList()
                            self.tableView.insertRows(at: [IndexPath(row: self.recipeIngredientList.count - 1, section: indexPath.section)], with: .middle)
                            self.createNeedUpdateCellIndexList()
                            self.tableView.reloadRows(at: self.needUpdateCellIndexList, with: .none)
                        }
                    }else{
                        if deleteFlag{
                            // 既存材料削除
                            self.showCancelAlert = true
                            self.createNeedUpdateCellIndexList()
                            self.recipeIngredientList[self.selectedIndexPath!.row].ingredientName = ""
                            self.updateDuplicatedIngredientList()
                            for i in 0 ..< self.needUpdateCellIndexList.count {
                                if self.needUpdateCellIndexList[i].row != self.selectedIndexPath!.row {
                                    self.tableView.reloadRows(at: [self.needUpdateCellIndexList[i]], with: .none)
                                }
                            }
                            self.recipeIngredientList.remove(at: self.selectedIndexPath!.row)
                            self.tableView.deleteRows(at: [self.selectedIndexPath!], with: .middle)
                            self.selectedIndexPath = nil
                        }else{
                            // 既存材料編集
                            for i in 0 ..< self.recipeIngredientList.count where self.recipeIngredientList[i].recipeIngredientId == recipeIngredientId{
                                self.recipeIngredientList[i].ingredientName = ingredientName
                                self.recipeIngredientList[i].amount = amount
                                self.recipeIngredientList[i].mustFlag = mustFlag
                                self.recipeIngredientList[i].category = category
                                self.recipeIngredientList[i].displayOrder = -1
                                self.showCancelAlert = true
                            }
                            self.updateDuplicatedIngredientList()
                            self.tableView.reloadData()
                        }
                    }
                }
                
                if let path = self.selectedIndexPath {
                    if self.tableView.numberOfRows(inSection: 1) > path.row{
                        self.tableView.selectRow(at: path, animated: false, scrollPosition: .none)
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.tableView.deselectRow(at: path, animated: true)
                        }
                    }
                }
            }
            
            if indexPath.row < recipeIngredientList.count{
                if self.recipeIngredientList[indexPath.row].recipeIngredientId == ""{
                    self.recipeIngredientList[indexPath.row].recipeIngredientId = NSUUID().uuidString
                }
                vc.recipeIngredient = self.recipeIngredientList[indexPath.row]
                vc.isAddMode = false
            }else if indexPath.row == recipeIngredientList.count{
                vc.isAddMode = true
            }
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
                nvc.modalPresentationStyle = .pageSheet
            }else{
                nvc.modalPresentationStyle = .custom
                nvc.transitioningDelegate = self
                vc.interactor = interactor
            }

            recipeName.resignFirstResponder()
            memo.resignFirstResponder()
            selectedIndexPath = indexPath
            present(nvc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 && indexPath.row < recipeIngredientList.count else { return UISwipeActionsConfiguration(actions: []) }
        
        let del =  UIContextualAction(style: .destructive, title: "削除", handler: { (action,view,completionHandler ) in
            self.showCancelAlert = true
            if indexPath.section == 1 && indexPath.row < self.recipeIngredientList.count{
                self.createNeedUpdateCellIndexList()
                self.recipeIngredientList[indexPath.row].ingredientName = ""
                self.updateDuplicatedIngredientList()
                for i in 0 ..< self.needUpdateCellIndexList.count {
                    if self.needUpdateCellIndexList[i].row != indexPath.row {
                        self.tableView.reloadRows(at: [self.needUpdateCellIndexList[i]], with: .none)
                    }
                }
                self.recipeIngredientList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .middle)
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        })
        del.image = UIImage(named: "button-delete")
        del.backgroundColor = UchicockStyle.deleteColor

        return UISwipeActionsConfiguration(actions: [del])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            if indexPath.row < 2{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
            }
            return cell
        } else if indexPath.section == 1{
            if indexPath.row < recipeIngredientList.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell") as! RecipeIngredientTableViewCell
                if duplicatedIngredientList.contains(recipeIngredientList[indexPath.row].ingredientName){
                    cell.isDuplicated = true
                }else{
                    cell.isDuplicated = false
                }
                cell.shouldDisplayStock = false
                cell.isNameTextViewSelectable = false
                cell.recipeIngredient = RecipeIngredientBasic(recipeIngredientId: "", ingredientId: "", ingredientName: recipeIngredientList[indexPath.row].ingredientName, amount: recipeIngredientList[indexPath.row].amount, mustFlag: recipeIngredientList[indexPath.row].mustFlag, category: recipeIngredientList[indexPath.row].category, displayOrder: -1, stockFlag: false)

                let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")
                let accesoryImageView = UIImageView(image: disclosureIndicator)
                accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
                accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                cell.accessoryView = accesoryImageView

                cell.selectionStyle = .default
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                if indexPath.row == recipeIngredientList.count - 1{
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }else{
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                }
                return cell
            }else if indexPath.row == recipeIngredientList.count{
                let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ipc.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let infoDic = Dictionary(uniqueKeysWithValues: info.map {key, value in (key.rawValue, value)})

        let defaults = UserDefaults.standard
        var imageMaxLongSide = GlobalConstants.MiddleImageMaxLongSide
        if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
            imageMaxLongSide = GlobalConstants.LargeImageMaxLongSide
        }

        if let image = infoDic[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage{
            if let img = image.resizedUIImage(maxLongSide: imageMaxLongSide){
                self.photo.isHidden = true
                ipc.dismiss(animated: false, completion: nil)
                self.showCancelAlert = true
                let storyboard = UIStoryboard(name: "RecipeEdit", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "PhotoFilter") as! PhotoFilterViewController
                vc.image = img
                vc.originalImageView = self.photo
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .coverVertical
                vc.modalPresentationCapturesStatusBarAppearance = true
                self.present(vc, animated: true)
            }
        }
    }
    
    func addPhoto() {
        let alert = CustomAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if UIImagePickerController.isSourceTypeAvailable(.camera) && status != .restricted {
            alert.addAction(UIAlertAction(title: "写真を撮る", style: .default,handler:{
                action in
                if status == .denied{
                    let alertView = CustomAlertController(title: "カメラの起動に失敗しました", message: "「設定」→「うちカク！」にてカメラへのアクセス許可を確認してください", preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: {action in
                    }))
                    alertView.addAction(UIAlertAction(title: "設定を開く", style: .default, handler: {action in
                        if let url = URL(string:UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }))
                    alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    self.present(alertView, animated: true, completion: nil)
                }else{
                    self.ipc.sourceType = .camera
                    self.ipc.allowsEditing = false
                    self.ipc.modalPresentationStyle = .fullScreen
                    self.present(self.ipc, animated: true, completion: nil)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "写真を選択",style: .default, handler:{
            action in
            self.ipc.sourceType = .photoLibrary
            self.ipc.allowsEditing = false
            self.ipc.modalPresentationStyle = .fullScreen
            self.present(self.ipc, animated: true, completion: nil)
        }))
        let pasteboard: UIPasteboard = UIPasteboard.general
        let pasteImage: UIImage? = pasteboard.image
        if let image = pasteImage{
            let defaults = UserDefaults.standard
            var imageMaxLongSide = GlobalConstants.MiddleImageMaxLongSide
            if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
                imageMaxLongSide = GlobalConstants.LargeImageMaxLongSide
            }

            if let img = image.resizedUIImage(maxLongSide: imageMaxLongSide){
                alert.addAction(UIAlertAction(title: "クリップボードからペースト",style: .default, handler:{
                    action in
                    self.showCancelAlert = true
                    let storyboard = UIStoryboard(name: "RecipeEdit", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PhotoFilter") as! PhotoFilterViewController
                    vc.image = img
                    vc.originalImageView = self.photo
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .coverVertical
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    self.present(vc, animated: true)
                }))
            }
        }
        if self.photo.image != nil{
            alert.addAction(UIAlertAction(title: "写真を削除",style: .destructive){
                action in
                self.showCancelAlert = true
                self.selectPhoto.text = "写真を追加"
                self.photo.image = nil
                self.photo.isHidden = true
                })
        }
        alert.addAction(UIAlertAction(title:"キャンセル",style: .cancel, handler:nil))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.frame
        alert.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alert.modalPresentationCapturesStatusBarAppearance = true
        present(alert, animated: true, completion: nil)
    }


    // MARK: - IBAction
    @IBAction func star1Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        switch recipeFavorite {
        case 0:
            recipeFavorite = 1
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star1.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star1.setImage(UIImage(named: "button-star-filled"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star1.transform = .identity
                })
            }
        case 1:
            recipeFavorite = 0
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star1.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star1.setImage(UIImage(named: "button-star-empty"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star1.transform = .identity
                })
            }
        case 2:
            recipeFavorite = 1
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star2.setImage(UIImage(named: "button-star-empty"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star2.transform = .identity
                })
            }
        case 3:
            recipeFavorite = 1
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
                self.star3.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star2.setImage(UIImage(named: "button-star-empty"), for: .normal)
                self.star3.setImage(UIImage(named: "button-star-empty"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star2.transform = .identity
                    self.star3.transform = .identity
                })
            }
        default:
            break
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        switch recipeFavorite {
        case 0:
            recipeFavorite = 2
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star1.transform = .init(scaleX: 1.15, y: 1.15)
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star1.setImage(UIImage(named: "button-star-filled"), for: .normal)
                self.star2.setImage(UIImage(named: "button-star-filled"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star1.transform = .identity
                    self.star2.transform = .identity
                })
            }
        case 1:
            recipeFavorite = 2
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star2.setImage(UIImage(named: "button-star-filled"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star2.transform = .identity
                })
            }
        case 2:
            recipeFavorite = 0
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star1.transform = .init(scaleX: 1.15, y: 1.15)
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star1.setImage(UIImage(named: "button-star-empty"), for: .normal)
                self.star2.setImage(UIImage(named: "button-star-empty"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star1.transform = .identity
                    self.star2.transform = .identity
                })
            }
        case 3:
            recipeFavorite = 2
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star3.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star3.setImage(UIImage(named: "button-star-empty"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star3.transform = .identity
                })
            }
        default:
            break
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        switch recipeFavorite {
        case 0:
            recipeFavorite = 3
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star1.transform = .init(scaleX: 1.15, y: 1.15)
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
                self.star3.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star1.setImage(UIImage(named: "button-star-filled"), for: .normal)
                self.star2.setImage(UIImage(named: "button-star-filled"), for: .normal)
                self.star3.setImage(UIImage(named: "button-star-filled"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star1.transform = .identity
                    self.star2.transform = .identity
                    self.star3.transform = .identity
                })
            }
        case 1:
            recipeFavorite = 3
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
                self.star3.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star2.setImage(UIImage(named: "button-star-filled"), for: .normal)
                self.star3.setImage(UIImage(named: "button-star-filled"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star2.transform = .identity
                    self.star3.transform = .identity
                })
            }
        case 2:
            recipeFavorite = 3
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star3.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star3.setImage(UIImage(named: "button-star-filled"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star3.transform = .identity
                })
            }
        case 3:
            recipeFavorite = 0
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.star1.transform = .init(scaleX: 1.15, y: 1.15)
                self.star2.transform = .init(scaleX: 1.15, y: 1.15)
                self.star3.transform = .init(scaleX: 1.15, y: 1.15)
            }) { (finished: Bool) -> Void in
                self.star1.setImage(UIImage(named: "button-star-empty"), for: .normal)
                self.star2.setImage(UIImage(named: "button-star-empty"), for: .normal)
                self.star3.setImage(UIImage(named: "button-star-empty"), for: .normal)
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.star1.transform = .identity
                    self.star2.transform = .identity
                    self.star3.transform = .identity
                })
            }
        default:
            break
        }    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if showCancelAlert {
            let alertView = CustomAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "はい",style: .default){
                action in
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(UIAlertAction(title: "いいえ", style: .cancel){action in})
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func presentAlert(_ message: String){
        let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
        alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if recipeName.text == nil || recipeName.text!.withoutSpace() == ""{
            presentAlert("レシピ名を入力してください")
        }else if recipeName.text!.withoutSpace().count > recipeNameMaximum{
            presentAlert("レシピ名を" + String(recipeNameMaximum) + "文字以下にしてください")
        }else if memo.text.count > memoMaximum {
            presentAlert("メモを" + String(memoMaximum) + "文字以下にしてください")
        }else if recipeIngredientList.count == 0{
            presentAlert("材料を一つ以上追加してください")
        }else if recipeIngredientList.count > 30{
            presentAlert("材料を30個以下にしてください")
        } else if isIngredientDuplicated() {
            presentAlert("重複している材料があります")
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameRecipe = realm.objects(Recipe.self).filter("recipeName == %@",recipeName.text!.withoutSpace())
                if sameNameRecipe.count != 0{
                    presentAlert("同じ名前のレシピが既に登録されています")
                }else{
                    let detailVC = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
                    try! realm.write{
                        let newRecipe = Recipe()
                        newRecipe.recipeName = recipeName.text!.withoutSpace()
                        newRecipe.katakanaLowercasedNameForSearch = recipeName.text!.katakanaLowercasedForSearch()

                        newRecipe.favorites = recipeFavorite

                        if let image = photo.image{
                            let imageFileName = NSUUID().uuidString
                            if ImageUtil.save(image: image, toFileName: imageFileName){
                                newRecipe.imageFileName = imageFileName
                            }
                        }else{
                            newRecipe.imageFileName = nil
                        }
                        
                        newRecipe.style = style.selectedSegmentIndex
                        newRecipe.method = method.selectedSegmentIndex
                        newRecipe.strength = strength.selectedSegmentIndex
                        newRecipe.memo = memo.text
                        realm.add(newRecipe)
                        
                        for i in 0 ..< recipeIngredientList.count {
                            let recipeIngredientLink = RecipeIngredientLink()
                            recipeIngredientLink.amount = recipeIngredientList[i].amount
                            recipeIngredientLink.mustFlag = recipeIngredientList[i].mustFlag
                            recipeIngredientLink.displayOrder = i
                            realm.add(recipeIngredientLink)

                            let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",recipeIngredientList[i].ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)

                            let recipe = realm.objects(Recipe.self).filter("recipeName == %@",newRecipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                        detailVC.recipeId = newRecipe.id
                        newRecipe.updateShortageNum()
                        MessageHUD.show("レシピを登録しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                   
                    if mainNavigationController != nil{
                        mainNavigationController!.pushViewController(detailVC, animated: false)
                        detailVC.closeEditVC(self)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }else{
                let sameNameRecipe = realm.objects(Recipe.self).filter("recipeName == %@",recipeName.text!.withoutSpace())
                if sameNameRecipe.count != 0 && recipe.recipeName != recipeName.text!.withoutSpace(){
                    presentAlert("同じ名前のレシピが既に登録されています")
                }else{
                    let detailVC = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController
                    try! realm.write {
                        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
                        for ri in recipe.recipeIngredients{
                            let recipeIngredient = realm.object(ofType: RecipeIngredientLink.self, forPrimaryKey: ri.id)!
                            deletingRecipeIngredientList.append(recipeIngredient)
                        }
                        
                        for ri in deletingRecipeIngredientList{
                            let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                            for i in 0 ..< ingredient.recipeIngredients.count where i < ingredient.recipeIngredients.count {
                                if ingredient.recipeIngredients[i].id == ri.id{
                                    ingredient.recipeIngredients.remove(at: i)
                                }
                            }
                        }
                        let editingRecipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipe.id)!
                        editingRecipe.recipeIngredients.removeAll()
                        for ri in deletingRecipeIngredientList{
                            realm.delete(ri)
                        }

                        recipe.recipeName = recipeName.text!.withoutSpace()
                        recipe.katakanaLowercasedNameForSearch = recipeName.text!.katakanaLowercasedForSearch()
                        
                        recipe.favorites = recipeFavorite
                        
                        let oldImageFileName = recipe.imageFileName
                        if let image = photo.image{
                            let newImageFileName = NSUUID().uuidString
                            if ImageUtil.save(image: image, toFileName: newImageFileName){
                                recipe.imageFileName = newImageFileName
                            }
                        }else{
                            recipe.imageFileName = nil
                        }
                        ImageUtil.remove(imageFileName: oldImageFileName)

                        recipe.style = style.selectedSegmentIndex
                        recipe.method = method.selectedSegmentIndex
                        recipe.strength = strength.selectedSegmentIndex
                        recipe.memo = memo.text
                        
                        for i in 0 ..< recipeIngredientList.count{
                            let recipeIngredientLink = RecipeIngredientLink()
                            recipeIngredientLink.amount = recipeIngredientList[i].amount
                            recipeIngredientLink.mustFlag = recipeIngredientList[i].mustFlag
                            recipeIngredientLink.displayOrder = i
                            realm.add(recipeIngredientLink)
                            
                            let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",recipeIngredientList[i].ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)
                            
                            let recipe = realm.objects(Recipe.self).filter("recipeName == %@",self.recipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                        detailVC.recipeId = recipe.id
                        recipe.updateShortageNum()
                        MessageHUD.show("レシピを保存しました", for: 2.0, withCheckmark: true, isCenter: true)
                    }
                    
                    if mainNavigationController != nil {
                        mainNavigationController?.pushViewController(detailVC, animated: false)
                        detailVC.closeEditVC(self)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func styleTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "StyleTipNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! StyleTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .formSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }

        recipeName.resignFirstResponder()
        memo.resignFirstResponder()
        present(nvc, animated: true)
    }
    
    @IBAction func methodTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "MethodTipNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! MethodTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .formSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }

        recipeName.resignFirstResponder()
        memo.resignFirstResponder()
        present(nvc, animated: true)
    }
    
    @IBAction func strengthTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "StrengthTipNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! StrengthTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .formSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }

        recipeName.resignFirstResponder()
        memo.resignFirstResponder()
        present(nvc, animated: true)
    }
    
    @IBAction func styleSegmentedControlTapped(_ sender: CustomSegmentedControl) {
        self.showCancelAlert = true
    }
    
    @IBAction func methodSegmentedControlTapped(_ sender: CustomSegmentedControl) {
        self.showCancelAlert = true
    }
    
    @IBAction func strengthSegmentedControlTapped(_ sender: CustomSegmentedControl) {
        self.showCancelAlert = true
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - GestureRecognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if touch.view!.isDescendant(of: recipeNameTableViewCell) {
            return true
        }else if touch.view!.isDescendant(of: favoriteTableViewCell){
            return true
        }else if touch.view!.isDescendant(of: styleTableViewCell){
            return true
        }else if touch.view!.isDescendant(of: methodTableViewCell){
            return true
        }else if touch.view!.isDescendant(of: strengthTableViewCell){
            return true
        }else if touch.view!.isDescendant(of: memoTableViewCell){
            return true
        }
        return false
    }
    
    @IBAction func unwindToRecipeEdit(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        if fromViewController is PhotoFilterViewController{
            let pfvc = fromViewController as! PhotoFilterViewController
            let img = pfvc.imageView.image!

            let defaults = UserDefaults.standard
            var imageMaxLongSide = GlobalConstants.MiddleImageMaxLongSide
            if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
                imageMaxLongSide = GlobalConstants.LargeImageMaxLongSide
            }

            self.photo.image = img.resizedUIImage(maxLongSide: imageMaxLongSide)
            self.selectPhoto.text = "写真を変更"
            return true
        }
        return false
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentedNVC = presented as? BasicNavigationController
        let VC = presentedNVC?.visibleViewController!
        let pc = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        
        if let VC = VC{
            if VC.isKind(of: StyleTipViewController.self) || VC.isKind(of: MethodTipViewController.self) || VC.isKind(of: StrengthTipViewController.self){
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
            if VC.isKind(of: StyleTipViewController.self) || VC.isKind(of: MethodTipViewController.self) || VC.isKind(of: StrengthTipViewController.self){
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
}
