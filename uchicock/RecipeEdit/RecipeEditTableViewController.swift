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
    @IBOutlet weak var recipeNameTextField: CustomTextField!
    @IBOutlet weak var recipeNameCounterLabel: UILabel!
    @IBOutlet weak var recipeNameYomiLabel: UILabel!
    @IBOutlet weak var recipeNameYomiTextField: CustomTextField!
    @IBOutlet weak var recipeNameYomiCounterLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var favoriteTableViewCell: UITableViewCell!
    @IBOutlet weak var star1Button: ExpandedButton!
    @IBOutlet weak var star2Button: ExpandedButton!
    @IBOutlet weak var star3Button: ExpandedButton!
    @IBOutlet weak var segmentedControlTableViewCell: UITableViewCell!
    @IBOutlet weak var styleTipButton: ExpandedButton!
    @IBOutlet weak var methodTipButton: ExpandedButton!
    @IBOutlet weak var strengthTipButton: ExpandedButton!
    @IBOutlet weak var styleSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var methodSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var strengthSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var memoTableViewCell: UITableViewCell!
    @IBOutlet weak var memoTextView: CustomTextView!
    @IBOutlet weak var memoCounterLabel: UILabel!
    @IBOutlet weak var addIngredientLabel: UILabel!
    
    weak var mainNavigationController : BasicNavigationController?
    var ipc = UIImagePickerController()

    var recipe = Recipe()
    var recipeIngredientList = Array<RecipeIngredientBasic>()
    var duplicatedIngredientIndexPathList = Array<IndexPath>()

    var recipeFavorite = 0
    let recipeNameMaximum = 30
    let recipeNameYomiMaximum = 50
    let memoMaximum = 1000
    let ingredientMaximum = 30

    var isAddMode = true
    var focusRecipeNameFlag = false
    var showCancelAlert = false
    var canTapPhoto = false

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

        star1Button.minimumHitWidth = 36
        star1Button.minimumHitHeight = 36
        star2Button.minimumHitWidth = 36
        star2Button.minimumHitHeight = 36
        star3Button.minimumHitWidth = 36
        star3Button.minimumHitHeight = 36
        styleTipButton.minimumHitWidth = 50
        styleTipButton.minimumHitHeight = 36
        methodTipButton.minimumHitWidth = 50
        methodTipButton.minimumHitHeight = 36
        strengthTipButton.minimumHitWidth = 50
        strengthTipButton.minimumHitHeight = 36
        star1Button.tintColor = UchicockStyle.primaryColor
        star2Button.tintColor = UchicockStyle.primaryColor
        star3Button.tintColor = UchicockStyle.primaryColor

        recipeNameTextField.text = recipe.recipeName
        recipeNameTextField.layer.cornerRadius = recipeNameTextField.frame.size.height / 2
        recipeNameTextField.attributedPlaceholder = NSAttributedString(string: "レシピ名", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        recipeNameTextField.adjustClearButtonColor()
        recipeNameTextField.setLeftPadding()
        
        recipeNameYomiLabel.textColor = UchicockStyle.labelTextColorLight
        recipeNameYomiTextField.text = recipe.recipeNameYomi
        recipeNameYomiTextField.layer.cornerRadius = recipeNameYomiTextField.frame.size.height / 2
        recipeNameYomiTextField.attributedPlaceholder = NSAttributedString(string: "レシピ名（ヨミガナ）", attributes: [NSAttributedString.Key.foregroundColor: UchicockStyle.labelTextColorLight])
        recipeNameYomiTextField.setLeftPadding()
        recipeNameYomiTextField.setRightPadding()

        if let image = ImageUtil.loadImageOf(recipeId: recipe.id, imageFileName: recipe.imageFileName, forList: false){
            photoImageView.image = image
        }
        if photoImageView.image == nil{
            photoLabel.text = "写真を追加"
            photoImageView.isHidden = true
            canTapPhoto = false
        }else{
            photoLabel.text = "写真を変更"
            photoImageView.isHidden = false
            canTapPhoto = true
        }
        photoLabel.textColor = UchicockStyle.primaryColor

        let photoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeEditTableViewController.photoTapped))
        self.photoImageView.addGestureRecognizer(photoTapGestureRecognizer)
        
        ipc.delegate = self
        
        if recipe.recipeName == "" {
            self.navigationItem.title = "レシピ登録"
            isAddMode = true
            focusRecipeNameFlag = true
        }else{
            self.navigationItem.title = "レシピ編集"
            isAddMode = false
        }
        initStarImage()
        recipeFavorite = recipe.favorites
        styleSegmentedControl.selectedSegmentIndex = recipe.style
        methodSegmentedControl.selectedSegmentIndex = recipe.method
        strengthSegmentedControl.selectedSegmentIndex = recipe.strength

        memoTextView.text = recipe.memo
        memoTextView.backgroundColor = UchicockStyle.basicBackgroundColorLight
        memoTextView.layer.masksToBounds = true
        memoTextView.layer.cornerRadius = 12
        memoTextView.layer.borderWidth = 0
        memoTextView.keyboardAppearance = UchicockStyle.keyboardAppearance
        memoTextView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        let realm = try! Realm()
        for ri in recipe.recipeIngredients where ri.displayOrder < 0{
            try! realm.write{
                for i in 0 ..< recipe.recipeIngredients.count {
                    recipe.recipeIngredients[i].displayOrder = i
                }
            }
            break
        }
        
        for ri in recipe.recipeIngredients {
            recipeIngredientList.append(RecipeIngredientBasic(
                ingredientId: "",
                ingredientName: ri.ingredient.ingredientName,
                ingredientNameYomi: "",
                katakanaLowercasedNameForSearch: "",
                amount: ri.amount,
                mustFlag: ri.mustFlag,
                category: ri.ingredient.category,
                displayOrder: ri.displayOrder,
                stockFlag: false
            ))
        }
        recipeIngredientList.sort { $0.displayOrder < $1.displayOrder }
        setAddIngredientLabel()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        
        styleTipButton.tintColor = UchicockStyle.primaryColor
        methodTipButton.tintColor = UchicockStyle.primaryColor
        strengthTipButton.tintColor = UchicockStyle.primaryColor
        
        setTextFieldColor(textField: recipeNameTextField, maximum: recipeNameMaximum)
        setTextFieldColor(textField: recipeNameYomiTextField, maximum: recipeNameYomiMaximum)
        setTextViewColor(textView: memoTextView, maximum: memoMaximum)
        updateRecipeNameCounter()
        updateRecipeNameYomiCounter()
        updateMemoCounter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 12のiPadではアプリのスクリーンサイズによってTipやレシピ材料編集を表示するとviewDidDisappearが呼ばれるので、viewWillAppearに以下の処理が必要
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeEditTableViewController.recipeNameTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.recipeNameTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeEditTableViewController.recipeNameTextFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.recipeNameTextField)
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeEditTableViewController.recipeNameYomiTextFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.recipeNameYomiTextField)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if focusRecipeNameFlag{
            recipeNameTextField.becomeFirstResponder()
            focusRecipeNameFlag = false
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Logic functions
    private func initStarImage(){
        switch recipe.favorites{
        case 0:
            star1Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
            star2Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
            star3Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
        case 1:
            star1Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
            star2Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
            star3Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
        case 2:
            star1Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
            star2Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
            star3Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
        case 3:
            star1Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
            star2Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
            star3Button.setImage(UIImage(named: "button-star-filled"), for: .normal)
        default:
            star1Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
            star2Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
            star3Button.setImage(UIImage(named: "button-star-empty"), for: .normal)
        }
    }

    private func setAddIngredientLabel(){
        if recipeIngredientList.count >= ingredientMaximum {
            addIngredientLabel.text = "これ以上材料を追加できません"
            addIngredientLabel.textColor = UchicockStyle.labelTextColorLight
        }else{
            addIngredientLabel.text = "材料を追加"
            addIngredientLabel.textColor = UchicockStyle.primaryColor
        }
    }
    
    private func createDuplicatedIngredientIndexPathList() -> Array<IndexPath>{
        var list = Array<IndexPath>()
        
        if recipeIngredientList.count == 0 { return list }
        for i in 0 ..< recipeIngredientList.count - 1{
            for j in i+1 ..< recipeIngredientList.count{
                if recipeIngredientList[i].ingredientName == recipeIngredientList[j].ingredientName{
                    list.append(IndexPath(row: i, section: 1))
                    list.append(IndexPath(row: j, section: 1))
                }
            }
        }
        return Array(Set(list)) // 重複をなくす
    }
    
    @objc func photoTapped(){
        if let image = photoImageView.image, canTapPhoto, let pngData = image.pngData(){
            if UIImage(data: pngData) != nil{
                let storyboard = UIStoryboard(name: "ImageViewer", bundle: nil)
                let ivc = storyboard.instantiateViewController(withIdentifier: "ImageViewerController") as! ImageViewerController
                ivc.originalImageView = photoImageView
                ivc.captionText = nil
                ivc.modalPresentationStyle = .overFullScreen
                ivc.modalTransitionStyle = .crossDissolve
                ivc.modalPresentationCapturesStatusBarAppearance = true
                self.present(ivc, animated: true)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        recipeNameTextField.resignFirstResponder()
        recipeNameYomiTextField.resignFirstResponder()
        return true
    }
    
    @objc func recipeNameTextFieldDidChange(_ notification: Notification){
        showCancelAlert = true
        recipeNameTextField.adjustClearButtonColor()
        recipeNameYomiTextField.text = recipeNameTextField.text!.convertToYomi()
        updateRecipeNameCounter()
        updateRecipeNameYomiCounter()
        setTextFieldColor(textField: recipeNameTextField, maximum: recipeNameMaximum)
        setTextFieldColor(textField: recipeNameYomiTextField, maximum: recipeNameYomiMaximum)
    }
    
    @objc func recipeNameYomiTextFieldDidChange(_ notification: Notification){
        showCancelAlert = true
        updateRecipeNameYomiCounter()
        setTextFieldColor(textField: recipeNameYomiTextField, maximum: recipeNameYomiMaximum)
    }
    
    private func updateRecipeNameCounter(){
        let num = recipeNameTextField.text!.withoutEndsSpace().count
        recipeNameCounterLabel.text = String(num) + "/" + String(recipeNameMaximum)
        
        if num > recipeNameMaximum{
            recipeNameCounterLabel.textColor = UchicockStyle.alertColor
        }else{
            recipeNameCounterLabel.textColor = UchicockStyle.labelTextColorLight
        }
    }

    private func updateRecipeNameYomiCounter(){
        let num = recipeNameYomiTextField.text!.withoutEndsSpace().count
        recipeNameYomiCounterLabel.text = String(num) + "/" + String(recipeNameYomiMaximum)
        
        if num > recipeNameYomiMaximum{
            recipeNameYomiCounterLabel.textColor = UchicockStyle.alertColor
        }else{
            recipeNameYomiCounterLabel.textColor = UchicockStyle.labelTextColorLight
        }
    }

    private func setTextFieldColor(textField: UITextField, maximum: Int){
        if textField.text!.withoutEndsSpace().count > maximum {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UchicockStyle.alertColor.cgColor
            textField.textColor = UchicockStyle.alertColor
        }else{
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.textColor = UchicockStyle.labelTextColor
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        showCancelAlert = true
        updateMemoCounter()
        setTextViewColor(textView: textView, maximum: memoMaximum)
    }
    
    private func updateMemoCounter(){
        let num = memoTextView.text.count
        memoCounterLabel.text = String(num) + "/" + String(memoMaximum)
            
        if num > memoMaximum{
            memoCounterLabel.textColor = UchicockStyle.alertColor
        }else{
            memoCounterLabel.textColor = UchicockStyle.labelTextColorLight
        }
    }
    
    private func setTextViewColor(textView: UITextView, maximum: Int){
        if textView.text!.count > maximum {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UchicockStyle.alertColor.cgColor
            textView.textColor = UchicockStyle.alertColor
        }else{
            textView.layer.borderWidth = 0
            textView.layer.borderColor = UIColor.clear.cgColor
            textView.textColor = UchicockStyle.labelTextColor
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 30 : 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UchicockStyle.basicBackgroundColorLight
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = UchicockStyle.labelTextColor
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        header?.textLabel?.text = section == 1 ? "材料編集" : ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < recipeIngredientList.count{
                return 70
            }else if indexPath.row == recipeIngredientList.count{
                return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        }else if section == 1{
            return recipeIngredientList.count + 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 1, section: 0){
            tableView.deselectRow(at: indexPath, animated: true)
            addPhoto()
        }else if indexPath.section == 1{
            if indexPath.row == recipeIngredientList.count && recipeIngredientList.count >= ingredientMaximum {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            presentRecipeIngredientEditModal(didSelectRowAt: indexPath)
        }
    }
    
    private func presentRecipeIngredientEditModal(didSelectRowAt indexPath: IndexPath){
        let storyboard = UIStoryboard(name: "RecipeEdit", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "RecipeIngredientEditNavigationController") as! BasicNavigationController
        let vc = nvc.visibleViewController as! RecipeIngredientEditTableViewController

        if indexPath.row < recipeIngredientList.count{
            vc.recipeIngredient = self.recipeIngredientList[indexPath.row]
        }

        vc.onDoneBlock = { editType, ingredientName, amount, category, mustFlag in
            switch editType {
            case .add:
                // 材料新規追加
                self.showCancelAlert = true
                let recipeIngredient = RecipeIngredientBasic(
                    ingredientId: "",
                    ingredientName: ingredientName,
                    ingredientNameYomi: "",
                    katakanaLowercasedNameForSearch: "",
                    amount: amount,
                    mustFlag: mustFlag,
                    category: category,
                    displayOrder: -1,
                    stockFlag: false
                )
                self.recipeIngredientList.append(recipeIngredient)
                self.duplicatedIngredientIndexPathList = self.createDuplicatedIngredientIndexPathList()
                self.tableView.insertRows(at: [IndexPath(row: self.recipeIngredientList.count - 1, section: indexPath.section)], with: .middle)
                self.tableView.reloadRows(at: self.duplicatedIngredientIndexPathList, with: .none)
                    
                self.tableView.scrollToRow(at: IndexPath(row: self.recipeIngredientList.count, section: indexPath.section), at: .bottom, animated: true)
                self.selectedIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                self.setAddIngredientLabel()
                    
            case .remove:
                // 既存材料削除
                self.showCancelAlert = true
                let list = self.createDuplicatedIngredientIndexPathList()
                self.recipeIngredientList[indexPath.row].ingredientName = ""
                self.duplicatedIngredientIndexPathList = self.createDuplicatedIngredientIndexPathList()
                for i in 0 ..< list.count where list[i] != indexPath {
                    self.tableView.reloadRows(at: [list[i]], with: .none)
                }
                self.recipeIngredientList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .middle)
                    
                self.selectedIndexPath = nil
                self.setAddIngredientLabel()
                    
            case .edit:
                // 既存材料編集
                if indexPath.row < self.recipeIngredientList.count{
                    self.showCancelAlert = true
                    self.recipeIngredientList[indexPath.row].ingredientName = ingredientName
                    self.recipeIngredientList[indexPath.row].amount = amount
                    self.recipeIngredientList[indexPath.row].mustFlag = mustFlag
                    self.recipeIngredientList[indexPath.row].category = category
                }
                self.duplicatedIngredientIndexPathList = self.createDuplicatedIngredientIndexPathList()
                self.tableView.reloadData()
                
            case .cancel: break
            }
            
            if let path = self.selectedIndexPath, self.tableView.numberOfRows(inSection: 1) > path.row{
                self.tableView.selectRow(at: path, animated: false, scrollPosition: .none)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.tableView.deselectRow(at: path, animated: true)
                }
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .pageSheet
        }else{
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            vc.interactor = interactor
        }

        recipeNameTextField.resignFirstResponder()
        recipeNameYomiTextField.resignFirstResponder()
        memoTextView.resignFirstResponder()
        selectedIndexPath = indexPath
        present(nvc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 && indexPath.row < recipeIngredientList.count else { return nil }
        
        let del =  UIContextualAction(style: .destructive, title: "削除"){ action,view,completionHandler in
            self.showCancelAlert = true
            let list = self.createDuplicatedIngredientIndexPathList()
            self.recipeIngredientList[indexPath.row].ingredientName = ""
            self.duplicatedIngredientIndexPathList = self.createDuplicatedIngredientIndexPathList()
            for i in 0 ..< list.count where list[i] != indexPath {
                self.tableView.reloadRows(at: [list[i]], with: .none)
            }
            self.recipeIngredientList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .middle)
            self.setAddIngredientLabel()
            completionHandler(true)
        }
        del.image = UIImage(named: "button-delete")
        del.backgroundColor = UchicockStyle.alertColor

        return UISwipeActionsConfiguration(actions: [del])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath{
        case let path where path.section == 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            if indexPath.row < 2{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
            }
            return cell
        case let path where path.section == 1 && path.row < recipeIngredientList.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell") as! RecipeIngredientTableViewCell
            cell.isDuplicated = duplicatedIngredientIndexPathList.contains(indexPath)
            cell.shouldDisplayStock = false
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
                stockFlag: false
            )

            let accesoryImageView = UIImageView(image: UIImage(named: "accesory-disclosure-indicator"))
            accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            cell.accessoryView = accesoryImageView

            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            if indexPath.row == recipeIngredientList.count - 1{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            }
            return cell
        case let path where path.section == 1 && path.row == recipeIngredientList.count:
            let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ipc.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let infoDic = Dictionary(uniqueKeysWithValues: info.map {key, value in (key.rawValue, value)})

        var imageMaxLongSide = GlobalConstants.MiddleImageMaxLongSide
        if UserDefaults.standard.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
            imageMaxLongSide = GlobalConstants.LargeImageMaxLongSide
        }

        if let image = infoDic[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage{
            if let img = image.resizedUIImage(maxLongSide: imageMaxLongSide){
                self.showCancelAlert = true
                self.photoImageView.isHidden = true
                let storyboard = UIStoryboard(name: "RecipeEdit", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "PhotoFilter") as! PhotoFilterViewController
                vc.image = img
                vc.originalImageView = self.photoImageView
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .coverVertical
                vc.modalPresentationCapturesStatusBarAppearance = true
                ipc.dismiss(animated: false, completion: nil)
                self.present(vc, animated: true)
            }
        }
    }
    
    private func addPhoto() {
        let alert = CustomAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if UIImagePickerController.isSourceTypeAvailable(.camera) && status != .restricted {
            let takePhotoAction = UIAlertAction(title: "写真を撮る", style: .default){action in
                if status == .denied{
                    let alertView = CustomAlertController(title: "カメラの起動に失敗しました", message: "「設定」→「うちカク！」にてカメラへのアクセス許可を確認してください", preferredStyle: .alert)
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
                    alertView.modalPresentationCapturesStatusBarAppearance = true
                    self.present(alertView, animated: true, completion: nil)
                }else{
                    self.ipc.sourceType = .camera
                    self.ipc.allowsEditing = false
                    self.ipc.modalPresentationStyle = .fullScreen
                    self.present(self.ipc, animated: true, completion: nil)
                }
            }
            if #available(iOS 13.0, *){ takePhotoAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
            alert.addAction(takePhotoAction)
        }
        
        let selectPhotoAction = UIAlertAction(title: "写真を選択",style: .default){action in
            self.ipc.sourceType = .photoLibrary
            self.ipc.allowsEditing = false
            self.ipc.modalPresentationStyle = .fullScreen
            self.present(self.ipc, animated: true, completion: nil)
        }
        if #available(iOS 13.0, *){ selectPhotoAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alert.addAction(selectPhotoAction)
        
        if let image = UIPasteboard.general.image{
            var imageMaxLongSide = GlobalConstants.MiddleImageMaxLongSide
            if UserDefaults.standard.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
                imageMaxLongSide = GlobalConstants.LargeImageMaxLongSide
            }

            if let img = image.resizedUIImage(maxLongSide: imageMaxLongSide){
                let pasteAction = UIAlertAction(title: "クリップボードからペースト",style: .default){action in
                    self.showCancelAlert = true
                    let storyboard = UIStoryboard(name: "RecipeEdit", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PhotoFilter") as! PhotoFilterViewController
                    vc.image = img
                    vc.originalImageView = self.photoImageView
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .coverVertical
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    self.present(vc, animated: true)
                }
                if #available(iOS 13.0, *){ pasteAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
                alert.addAction(pasteAction)
            }
        }
        
        if canTapPhoto{
            let deleteAction = UIAlertAction(title: "写真を削除",style: .destructive){action in
                self.showCancelAlert = true
                self.canTapPhoto = false
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.photoImageView.alpha = 0.0
                    self.photoImageView.transform = .init(scaleX: 0.1, y: 0.1)
                }) { (finished: Bool) -> Void in
                    self.photoLabel.text = "写真を追加"
                    self.photoImageView.isHidden = true
                    self.photoImageView.image = nil
                    self.photoImageView.alpha = 1.0
                    self.photoImageView.transform = .identity
                }
            }
            if #available(iOS 13.0, *){ deleteAction.setValue(UchicockStyle.alertColor, forKey: "titleTextColor") }
            alert.addAction(deleteAction)
        }
        
        let alertAction = UIAlertAction(title:"キャンセル",style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ alertAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alert.addAction(alertAction)

        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))!.frame
        alert.modalPresentationCapturesStatusBarAppearance = true
        present(alert, animated: true, completion: nil)
    }

    // MARK: - IBAction
    @IBAction func star1Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        switch recipeFavorite {
        case 0:
            recipeFavorite = 1
            animateButton(star1Button, with: "button-star-filled")
        case 1:
            recipeFavorite = 0
            animateButton(star1Button, with: "button-star-empty")
        case 2:
            recipeFavorite = 1
            animateButton(star2Button, with: "button-star-empty")
        case 3:
            recipeFavorite = 1
            animateButton(star2Button, with: "button-star-empty")
            animateButton(star3Button, with: "button-star-empty")
        default:
            break
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        switch recipeFavorite {
        case 0:
            recipeFavorite = 2
            animateButton(star1Button, with: "button-star-filled")
            animateButton(star2Button, with: "button-star-filled")
        case 1:
            recipeFavorite = 2
            animateButton(star2Button, with: "button-star-filled")
        case 2:
            recipeFavorite = 0
            animateButton(star1Button, with: "button-star-empty")
            animateButton(star2Button, with: "button-star-empty")
        case 3:
            recipeFavorite = 2
            animateButton(star3Button, with: "button-star-empty")
        default:
            break
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        switch recipeFavorite {
        case 0:
            recipeFavorite = 3
            animateButton(star1Button, with: "button-star-filled")
            animateButton(star2Button, with: "button-star-filled")
            animateButton(star3Button, with: "button-star-filled")
        case 1:
            recipeFavorite = 3
            animateButton(star2Button, with: "button-star-filled")
            animateButton(star3Button, with: "button-star-filled")
        case 2:
            recipeFavorite = 3
            animateButton(star3Button, with: "button-star-filled")
        case 3:
            recipeFavorite = 0
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
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        guard showCancelAlert else{
            self.dismiss(animated: true, completion: nil)
            return
        }

        let alertView = CustomAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "はい",style: .default){action in
            self.dismiss(animated: true, completion: nil)
        }
        if #available(iOS 13.0, *){ yesAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(yesAction)
        let noAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ noAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(noAction)
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    private func presentAlert(title: String, message: String?, action: (() -> Void)?){
        let alertView = CustomAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default){_ in
            action?()
        }
        if #available(iOS 13.0, *){ alertAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(alertAction)
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        recipeNameTextField.resignFirstResponder()
        recipeNameYomiTextField.resignFirstResponder()
        memoTextView.resignFirstResponder()
        
        guard recipeNameTextField.text != nil && recipeNameTextField.text!.withoutEndsSpace() != "" else{
            presentAlert(title: "レシピ名を入力してください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.recipeNameTextField.becomeFirstResponder()
            })
            return
        }
        guard recipeNameTextField.text!.withoutEndsSpace().count <= recipeNameMaximum else{
            presentAlert(title: "レシピ名を" + String(recipeNameMaximum) + "文字以下にしてください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.recipeNameTextField.becomeFirstResponder()
            })
            return
        }
        guard recipeNameYomiTextField.text != nil && recipeNameYomiTextField.text!.withoutEndsSpace() != "" else{
            presentAlert(title: "ヨミガナを入力してください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.recipeNameYomiTextField.becomeFirstResponder()
            })
            return
        }
        guard recipeNameYomiTextField.text!.withoutEndsSpace().count <= recipeNameYomiMaximum else{
            presentAlert(title: "ヨミガナを" + String(recipeNameYomiMaximum) + "文字以下にしてください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.recipeNameYomiTextField.becomeFirstResponder()
            })
            return
        }
        guard memoTextView.text.count <= memoMaximum else{
            presentAlert(title: "メモを" + String(memoMaximum) + "文字以下にしてください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 6, section: 0), at: .middle, animated: true)
                self.memoTextView.becomeFirstResponder()
            })
            return
        }
        guard recipeIngredientList.count != 0 else{
            presentAlert(title: "材料を一つ以上追加してください", message: nil, action: {
                self.tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: true, scrollPosition: .bottom)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.tableView.deselectRow(at: IndexPath(row: 0, section: 1), animated: true)
                }
            })
            return
        }
        guard recipeIngredientList.count <= ingredientMaximum else{
            presentAlert(title: "材料を" + String(ingredientMaximum) + "個以下にしてください", message: nil, action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
            })
            return
        }
        var list = createDuplicatedIngredientIndexPathList()
        guard list.count == 0 else{
            list.sort {$0.row < $1.row}
            presentAlert(title: "重複している材料があります", message: nil, action: {
                self.tableView.selectRow(at: list[0], animated: true, scrollPosition: .middle)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.tableView.deselectRow(at: list[0], animated: true)
                }
            })
            return
        }
        
        let realm = try! Realm()
        let sameNameRecipe = realm.objects(Recipe.self).filter("recipeName == %@",recipeNameTextField.text!.withoutEndsSpace())
        guard recipeNameTextField.text!.withoutEndsSpace() != "" && (
            sameNameRecipe.count == 0 || recipe.recipeName == recipeNameTextField.text!.withoutEndsSpace()) else{
            presentAlert(title: "同じ名前のレシピが既に登録されています", message: "レシピ名を変更してください", action: {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.recipeNameTextField.becomeFirstResponder()
            })
            return
        }

        saveRecipe()
    }
    
    private func saveRecipe(){
        let realm = try! Realm()
        try! realm.write {
            if isAddMode { realm.add(recipe) }
            
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
            recipe.recipeIngredients.removeAll()
            for ri in deletingRecipeIngredientList{
                realm.delete(ri)
            }

            recipe.recipeName = recipeNameTextField.text!.withoutEndsSpace()
            recipe.recipeNameYomi = recipeNameYomiTextField.text!.withoutEndsSpace()
            recipe.katakanaLowercasedNameForSearch = recipeNameYomiTextField.text!.katakanaLowercasedForSearch()
            recipe.favorites = recipeFavorite
            recipe.style = styleSegmentedControl.selectedSegmentIndex
            recipe.method = methodSegmentedControl.selectedSegmentIndex
            recipe.strength = strengthSegmentedControl.selectedSegmentIndex
            recipe.memo = memoTextView.text
            
            let oldImageFileName = recipe.imageFileName
            if let image = photoImageView.image{
                let newImageFileName = NSUUID().uuidString
                if ImageUtil.save(image: image, toFileName: newImageFileName){
                    recipe.imageFileName = newImageFileName
                }
            }else{
                recipe.imageFileName = nil
            }
            ImageUtil.remove(imageFileName: oldImageFileName)

            for i in 0 ..< recipeIngredientList.count{
                let recipeIngredientLink = RecipeIngredientLink()
                recipeIngredientLink.amount = recipeIngredientList[i].amount
                recipeIngredientLink.mustFlag = recipeIngredientList[i].mustFlag
                recipeIngredientLink.displayOrder = i
                realm.add(recipeIngredientLink)
                
                let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",recipeIngredientList[i].ingredientName).first!
                ingredient.recipeIngredients.append(recipeIngredientLink)
                recipe.recipeIngredients.append(recipeIngredientLink)
            }
            recipe.updateShortageNum()
            
            if isAddMode{
                MessageHUD.show("レシピを登録しました", for: 2.0, withCheckmark: true, isCenter: true)
            }else{
                MessageHUD.show("レシピを保存しました", for: 2.0, withCheckmark: true, isCenter: true)
            }
        }
        
        let detailVC = UIStoryboard(name: "RecipeDetail", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetail") as! RecipeDetailTableViewController        
        detailVC.recipeId = recipe.id
        
        if mainNavigationController != nil {
            mainNavigationController?.pushViewController(detailVC, animated: false)
            detailVC.closeEditVC(self)
        }else{
            self.dismiss(animated: true, completion: nil)
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
        recipeNameTextField.resignFirstResponder()
        recipeNameYomiTextField.resignFirstResponder()
        memoTextView.resignFirstResponder()
        present(nvc, animated: true)
    }

    @IBAction func segmentedControlTapped(_ sender: CustomSegmentedControl) {
        self.showCancelAlert = true
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        if touch.view!.isDescendant(of: recipeNameTableViewCell) ||
            touch.view!.isDescendant(of: favoriteTableViewCell) ||
            touch.view!.isDescendant(of: segmentedControlTableViewCell) ||
            touch.view!.isDescendant(of: memoTableViewCell){
            return true
        }
        return false
    }
    
    // MARK: - Navigation
    @IBAction func unwindToRecipeEdit(_ segue: UIStoryboardSegue) {
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        if fromViewController is PhotoFilterViewController{
            let pfvc = fromViewController as! PhotoFilterViewController
            let img = pfvc.imageView.image!

            var imageMaxLongSide = GlobalConstants.MiddleImageMaxLongSide
            if UserDefaults.standard.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
                imageMaxLongSide = GlobalConstants.LargeImageMaxLongSide
            }

            self.photoImageView.image = img.resizedUIImage(maxLongSide: imageMaxLongSide)
            self.canTapPhoto = true
            self.photoLabel.text = "写真を変更"
            return true
        }
        return false
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
}
