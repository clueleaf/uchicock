//
//  RecipeEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeEditTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var recipeNameTableViewCell: UITableViewCell!
    @IBOutlet weak var recipeName: CustomTextField!
    @IBOutlet weak var styleTipButton: UIButton!
    @IBOutlet weak var methodTipButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var selectPhoto: UILabel!
    @IBOutlet weak var favoriteTableViewCell: UITableViewCell!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var styleTableViewCell: UITableViewCell!
    @IBOutlet weak var methodTableViewCell: UITableViewCell!
    @IBOutlet weak var style: CustomSegmentedControl!
    @IBOutlet weak var method: CustomSegmentedControl!
    @IBOutlet weak var memoTableViewCell: UITableViewCell!
    @IBOutlet weak var memo: CustomTextView!
    @IBOutlet weak var addIngredientLabel: UILabel!
    
    weak var mainNavigationController : UINavigationController?
    var recipe = Recipe()
    var isAddMode = true
    var recipeIngredientList = Array<RecipeIngredientBasic>()
    var ipc = UIImagePickerController()
    var focusRecipeNameFlag = false
    let selectedCellBackgroundView = UIView()
    var showCancelAlert = false
    var selectedIndexPath: IndexPath? = nil

    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientCell")

        recipeName.text = recipe.recipeName
        recipeName.delegate = self
        
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
        let photoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeEditTableViewController.photoTapped))
        self.photo.addGestureRecognizer(photoTapGestureRecognizer)
        
        ipc.delegate = self
        
        if #available(iOS 13.0, *) {
        }else{
            style.layer.cornerRadius = 14.0
            method.layer.cornerRadius = 14.0
        }
        style.layer.borderColor = Style.primaryColor.cgColor
        style.layer.borderWidth = 1.0
        style.layer.masksToBounds = true
        method.layer.borderColor = Style.primaryColor.cgColor
        method.layer.borderWidth = 1.0
        method.layer.masksToBounds = true
        
        if recipe.recipeName == "" {
            self.navigationItem.title = "レシピ登録"
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
            style.selectedSegmentIndex = 3
            method.selectedSegmentIndex = 0
            isAddMode = true
        } else {
            self.navigationItem.title = "レシピ編集"
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
            style.selectedSegmentIndex = recipe.style
            method.selectedSegmentIndex = recipe.method
            isAddMode = false
        }
        
        memo.text = recipe.memo
        memo.delegate = self
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        recipeName.layer.cornerRadius = 5.0
        recipeName.layer.borderWidth = 1

        for ri in recipe.recipeIngredients {
            recipeIngredientList.append(RecipeIngredientBasic(id: ri.id, ingredientName: ri.ingredient.ingredientName, amount: ri.amount, mustFlag: ri.mustFlag, category: -1))
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        focusRecipeNameFlag = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(RecipeEditTableViewController.textFieldDidChange(_:)), name: CustomTextField.textDidChangeNotification, object: self.recipeName)
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeEditTableViewController.textFieldDidChange(_:)), name: .textFieldClearButtonTappedNotification, object: self.recipeName)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVC()
    }
    
    private func setupVC(){
        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.separatorColor = Style.labelTextColorLight
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor

        recipeName.layer.borderColor = Style.textFieldBorderColor.cgColor
        recipeName.attributedPlaceholder = NSAttributedString(string: "レシピ名", attributes: [NSAttributedString.Key.foregroundColor: Style.labelTextColorLight])
        recipeName.adjustClearButtonColor(with: 4)
        selectPhoto.textColor = Style.primaryColor
        star1.setTitleColor(Style.primaryColor, for: .normal)
        star2.setTitleColor(Style.primaryColor, for: .normal)
        star3.setTitleColor(Style.primaryColor, for: .normal)
        memo.layer.borderColor = Style.textFieldBorderColor.cgColor
        memo.keyboardAppearance = Style.isDark ? .dark : .light
        addIngredientLabel.textColor = Style.primaryColor
        addIngredientLabel.font = UIFont.boldSystemFont(ofSize: 20.0)

        let tipImage = UIImage(named: "tip")
        styleTipButton.setImage(tipImage, for: .normal)
        styleTipButton.tintColor = Style.primaryColor
        methodTipButton.setImage(tipImage, for: .normal)
        methodTipButton.tintColor = Style.primaryColor

        self.tableView.reloadData()
        
        if let path = selectedIndexPath {
            if tableView.numberOfRows(inSection: 1) > path.row{
                tableView.selectRow(at: path, animated: false, scrollPosition: .none)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.tableView.deselectRow(at: path, animated: true)
                }
            }
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
    private func setStarTitleOf(star1title: String, star2title: String, star3title: String){
        star1.setTitle(star1title, for: .normal)
        star2.setTitle(star2title, for: .normal)
        star3.setTitle(star3title, for: .normal)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        recipeName.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ notification: Notification){
        showCancelAlert = true
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        showCancelAlert = true
    }
    
    func isIngredientDuplicated() -> Bool {
        for i in 0 ..< recipeIngredientList.count - 1{
            for j in i+1 ..< recipeIngredientList.count{
                if recipeIngredientList[i].ingredientName == recipeIngredientList[j].ingredientName{
                    return true
                }
            }
        }
        return false
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
        if section == 1 {
            return 30
        }else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Style.tableViewHeaderBackgroundColor
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = Style.tableViewHeaderTextColor
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

            vc.onDoneBlock = { isCancel, deleteFlag, isAddMode, ingredientName, amount, mustFlag, recipeIngredientId in
                if isCancel == false{
                    if isAddMode{
                        if deleteFlag == false{
                            let recipeIngredient = RecipeIngredientBasic(id: "", ingredientName: ingredientName, amount: amount, mustFlag: mustFlag, category: -1)
                            self.recipeIngredientList.append(recipeIngredient)
                            self.selectedIndexPath = nil
                            self.showCancelAlert = true
                        }
                    }else{
                        if deleteFlag{
                            for i in 0 ..< self.recipeIngredientList.count where i < self.recipeIngredientList.count {
                                if self.recipeIngredientList[i].id == recipeIngredientId{
                                    self.recipeIngredientList.remove(at: i)
                                }
                            }
                            self.selectedIndexPath = nil
                            self.showCancelAlert = true
                        }else{
                            for i in 0 ..< self.recipeIngredientList.count where self.recipeIngredientList[i].id == recipeIngredientId{
                                self.recipeIngredientList[i].ingredientName = ingredientName
                                self.recipeIngredientList[i].amount = amount
                                self.recipeIngredientList[i].mustFlag = mustFlag
                                self.showCancelAlert = true
                            }
                        }
                    }
                }
                self.setupVC()
            }
            if indexPath.row < recipeIngredientList.count{
                if self.recipeIngredientList[indexPath.row].id == ""{
                    self.recipeIngredientList[indexPath.row].id = NSUUID().uuidString
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
            self.selectedIndexPath = indexPath
            present(nvc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 && indexPath.row < recipeIngredientList.count else { return UISwipeActionsConfiguration(actions: []) }
        
        let del =  UIContextualAction(style: .destructive, title: "削除", handler: { (action,view,completionHandler ) in
            self.showCancelAlert = true
            if indexPath.section == 1 && indexPath.row < self.recipeIngredientList.count{
                self.recipeIngredientList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        })
        del.image = UIImage(named: "button-delete")
        del.backgroundColor = Style.deleteColor

        return UISwipeActionsConfiguration(actions: [del])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
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
                cell.ingredientName = recipeIngredientList[indexPath.row].ingredientName
                cell.amountText = recipeIngredientList[indexPath.row].amount
                cell.isOption = !recipeIngredientList[indexPath.row].mustFlag
                cell.stock = nil

                let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")
                let accesoryImageView = UIImageView(image: disclosureIndicator)
                accesoryImageView.tintColor = Style.labelTextColorLight
                accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                cell.accessoryView = accesoryImageView

                cell.selectionStyle = .default
                cell.backgroundColor = Style.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                if indexPath.row == recipeIngredientList.count - 1{
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }else{
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                }
                return cell
            }else if indexPath.row == recipeIngredientList.count{
                let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
                cell.backgroundColor = Style.basicBackgroundColor
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
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(UIAlertAction(title: "写真を撮る", style: .default,handler:{
                action in
                self.ipc.sourceType = .camera
                self.ipc.allowsEditing = false
                self.ipc.modalPresentationStyle = .fullScreen
                self.present(self.ipc, animated: true, completion: nil)
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
        alert.alertStatusBarStyle = Style.statusBarStyle
        alert.modalPresentationCapturesStatusBarAppearance = true
        present(alert, animated: true, completion: nil)
    }


    // MARK: - IBAction
    @IBAction func star1Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        if star1.currentTitle == "★" && star2.currentTitle == "☆"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
        }else{
            setStarTitleOf(star1title: "★", star2title: "☆", star3title: "☆")
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        if star2.currentTitle == "★" && star3.currentTitle == "☆"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
        }else{
            setStarTitleOf(star1title: "★", star2title: "★", star3title: "☆")
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        self.showCancelAlert = true
        if star3.currentTitle == "★"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
        }else{
            setStarTitleOf(star1title: "★", star2title: "★", star3title: "★")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if showCancelAlert {
            let alertView = CustomAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "はい",style: .default){
                action in
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(UIAlertAction(title: "いいえ", style: .cancel){action in})
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func presentAlert(_ message: String){
        let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
        alertView.alertStatusBarStyle = Style.statusBarStyle
        alertView.modalPresentationCapturesStatusBarAppearance = true
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if recipeName.text == nil || recipeName.text!.withoutSpace() == ""{
            presentAlert("レシピ名を入力してください")
        }else if recipeName.text!.withoutSpace().count > 30{
            presentAlert("レシピ名を30文字以下にしてください")
        }else if memo.text.count > 1000 {
            presentAlert("メモを1000文字以下にしてください")
        }else if recipeIngredientList.count == 0{
            presentAlert("材料を一つ以上入力してください")
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

                        if star3.currentTitle == "★" {
                            newRecipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            newRecipe.favorites = 2
                        }else if star1.currentTitle == "★"{
                            newRecipe.favorites = 1
                        }else{
                            newRecipe.favorites = 0
                        }

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
                        newRecipe.memo = memo.text
                        realm.add(newRecipe)
                        
                        for editingRecipeIngredient in recipeIngredientList{
                            let recipeIngredientLink = RecipeIngredientLink()
                            recipeIngredientLink.amount = editingRecipeIngredient.amount
                            recipeIngredientLink.mustFlag = editingRecipeIngredient.mustFlag
                            realm.add(recipeIngredientLink)

                            let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",editingRecipeIngredient.ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)

                            let recipe = realm.objects(Recipe.self).filter("recipeName == %@",newRecipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                        detailVC.recipeId = newRecipe.id
                        newRecipe.updateShortageNum()
                        MessageHUD.show("レシピを登録しました", for: 2.0, withCheckmark: true)
                    }
                   
                    let history = mainNavigationController?.viewControllers
                    if var history = history{
                        history.append(detailVC)
                        mainNavigationController?.setViewControllers(history, animated: false)
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
                        if star3.currentTitle == "★" {
                            recipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            recipe.favorites = 2
                        }else if star1.currentTitle == "★"{
                            recipe.favorites = 1
                        }else{
                            recipe.favorites = 0
                        }
                        
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
                        recipe.memo = memo.text
                        
                        for editingRecipeIngredient in recipeIngredientList{
                            let recipeIngredientLink = RecipeIngredientLink()
                            recipeIngredientLink.amount = editingRecipeIngredient.amount
                            recipeIngredientLink.mustFlag = editingRecipeIngredient.mustFlag
                            realm.add(recipeIngredientLink)
                            
                            let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",editingRecipeIngredient.ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)
                            
                            let recipe = realm.objects(Recipe.self).filter("recipeName == %@",self.recipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                        detailVC.recipeId = recipe.id
                        recipe.updateShortageNum()
                        MessageHUD.show("レシピを保存しました", for: 2.0, withCheckmark: true)
                    }
                    let history = mainNavigationController?.viewControllers
                    if var history = history{
                        history.append(detailVC)
                        mainNavigationController?.setViewControllers(history, animated: false)
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
        let nvc = storyboard.instantiateViewController(withIdentifier: "StyleTipNavigationController") as! UINavigationController
        let vc = nvc.visibleViewController as! StyleTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .pageSheet
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
        let nvc = storyboard.instantiateViewController(withIdentifier: "MethodTipNavigationController") as! UINavigationController
        let vc = nvc.visibleViewController as! MethodTipViewController

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            nvc.modalPresentationStyle = .pageSheet
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
}
