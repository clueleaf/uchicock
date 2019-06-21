//
//  RecipeEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeEditTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var recipeNameTableViewCell: UITableViewCell!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var styleLabel: UILabel!
    @IBOutlet weak var styleTipButton: UIButton!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var methodTipButton: UIButton!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var selectPhoto: UILabel!
    @IBOutlet weak var favoriteTableViewCell: UITableViewCell!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var styleTableViewCell: UITableViewCell!
    @IBOutlet weak var methodTableViewCell: UITableViewCell!
    @IBOutlet weak var style: UISegmentedControl!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var memoTableViewCell: UITableViewCell!
    @IBOutlet weak var memo: UITextView!
    
    weak var detailVC : RecipeDetailTableViewController?
    var recipe = Recipe()
    var isAddMode = true
    var recipeIngredientList = Array<RecipeIngredientBasic>()
    var ipc = UIImagePickerController()
    var focusRecipeNameFlag = false
    let selectedCellBackgroundView = UIView()
    let openTime = Date()
    
    let interactor = Interactor()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientCell")

        recipeName.text = recipe.recipeName
        recipeName.delegate = self
        
        if let image = recipe.imageData{
            if let img = UIImage(data: image as Data){
                photo.image = resizedImage(image: img)
            }
        }
        if photo.image == nil{
            selectPhoto.text = "写真を追加"
            photo.isUserInteractionEnabled = false
        }else{
            selectPhoto.text = "写真を変更"
            photo.isUserInteractionEnabled = true
        }
        let photoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeEditTableViewController.photoTapped))
        self.photo.addGestureRecognizer(photoTapGestureRecognizer)
        
        ipc.delegate = self
        
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
        
        var safeAreaBottom: CGFloat = 0.0
        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVC()
    }
    
    private func setupVC(){
        self.tableView.backgroundColor = Style.basicBackgroundColor
        recipeNameLabel.textColor = Style.labelTextColor
        starLabel.textColor = Style.labelTextColor
        styleLabel.textColor = Style.labelTextColor
        methodLabel.textColor = Style.labelTextColor
        memoLabel.textColor = Style.labelTextColor
        recipeName.layer.borderColor = Style.memoBorderColor.cgColor
        star1.tintColor = Style.secondaryColor
        star2.tintColor = Style.secondaryColor
        star3.tintColor = Style.secondaryColor
        selectPhoto.textColor = Style.secondaryColor
        memo.layer.borderColor = Style.memoBorderColor.cgColor
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        memo.keyboardAppearance = Style.isDark ? .dark : .default
        
        let tipImage = UIImage(named: "tip")?.withRenderingMode(.alwaysTemplate)
        styleTipButton.setImage(tipImage, for: .normal)
        styleTipButton.tintColor = Style.secondaryColor
        methodTipButton.setImage(tipImage, for: .normal)
        methodTipButton.tintColor = Style.secondaryColor

        self.tableView.reloadData()
        
        if photo.alpha < 1.0{
            UIView.animate(withDuration: 0.5, animations: {self.photo.alpha = 1.0}, completion: nil)
        }

        if let index = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
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
    
    // MARK: - Set Style
    private func setStarTitleOf(star1title: String, star2title: String, star3title: String){
        star1.setTitle(star1title, for: .normal)
        star2.setTitle(star2title, for: .normal)
        star3.setTitle(star3title, for: .normal)
    }

    func textWithoutSpace(text: String) -> String{
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        recipeName.resignFirstResponder()
        return true
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
                    let imageViewerController = ImageViewerController(originalImageView: photo, captionText: nil)
                    self.present(imageViewerController, animated: true)
                }
            }
        }
    }
    
    func resizedImage(image: UIImage) -> UIImage? {
        let maxLongSide : CGFloat = 1024
        if  image.size.width <= maxLongSide && image.size.height <= maxLongSide {
            return image
        }
        
        let w = image.size.width / maxLongSide
        let h = image.size.height / maxLongSide
        let ratio = w > h ? w : h
        let rect = CGRect(x: 0, y: 0, width: image.size.width / ratio, height: image.size.height / ratio)
        
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = section == 1 ? "  材料編集" : nil
        return label
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
            nvc.modalPresentationStyle = .custom
            nvc.transitioningDelegate = self
            let vc = nvc.visibleViewController as! RecipeIngredientEditTableViewController
            vc.onDoneBlock = { isCancel, deleteFlag, isAddMode, ingredientName, amount, mustFlag, recipeIngredientId in
                if isCancel == false{
                    if isAddMode{
                        if deleteFlag == false{
                            let recipeIngredient = RecipeIngredientBasic(id: "", ingredientName: ingredientName, amount: amount, mustFlag: mustFlag, category: -1)
                            self.recipeIngredientList.append(recipeIngredient)
                        }
                    }else{
                        if deleteFlag{
                            for i in 0 ..< self.recipeIngredientList.count where i < self.recipeIngredientList.count {
                                if self.recipeIngredientList[i].id == recipeIngredientId{
                                    self.recipeIngredientList.remove(at: i)
                                }
                            }
                        }else{
                            for i in 0 ..< self.recipeIngredientList.count where self.recipeIngredientList[i].id == recipeIngredientId{
                                self.recipeIngredientList[i].ingredientName = ingredientName
                                self.recipeIngredientList[i].amount = amount
                                self.recipeIngredientList[i].mustFlag = mustFlag
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
            vc.interactor = interactor
            recipeName.resignFirstResponder()
            memo.resignFirstResponder()
            present(nvc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let del = UITableViewRowAction(style: .default, title: "削除") {
            (action, indexPath) in
            if indexPath.section == 1 && indexPath.row < self.recipeIngredientList.count{
                self.recipeIngredientList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        del.backgroundColor = Style.deleteColor
        
        return [del]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row < recipeIngredientList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            if indexPath.row < 2{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            }
            return cell
        } else if indexPath.section == 1{
            if indexPath.row < recipeIngredientList.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientCell") as! RecipeIngredientTableViewCell
                cell.ingredientName = recipeIngredientList[indexPath.row].ingredientName
                cell.amountText = recipeIngredientList[indexPath.row].amount
                cell.isOption = !recipeIngredientList[indexPath.row].mustFlag
                cell.stock = nil

                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
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
                cell.textLabel?.textColor = Style.secondaryColor
                cell.textLabel?.text = "材料を追加"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
                cell.textLabel?.textAlignment = .center
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

        if let image = infoDic[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage{
            if let img = resizedImage(image: image){
                ipc.dismiss(animated: false, completion: nil)
                performSegue(withIdentifier: "ShowPhotoFilter", sender: resizedImage(image: img))
            }
        }else if let image = infoDic[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage{
            if let img = resizedImage(image: image){
                ipc.dismiss(animated: false, completion: nil)
                performSegue(withIdentifier: "ShowPhotoFilter", sender: resizedImage(image: img))
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
                self.present(self.ipc, animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "写真を選択",style: .default, handler:{
            action in
            self.ipc.sourceType = .photoLibrary
            self.ipc.allowsEditing = true
            self.present(self.ipc, animated: true, completion: nil)
        }))
        let pasteboard: UIPasteboard = UIPasteboard.general
        let pasteImage: UIImage? = pasteboard.image
        if let image = pasteImage{
            if let img = self.resizedImage(image: image){
                alert.addAction(UIAlertAction(title: "クリップボードからペースト",style: .default, handler:{
                    action in
                    self.performSegue(withIdentifier: "ShowPhotoFilter", sender: img)
                }))
            }
        }
        if self.photo.image != nil{
            alert.addAction(UIAlertAction(title: "写真を削除",style: .destructive){
                action in
                self.selectPhoto.text = "写真を追加"
                self.photo.image = nil
                self.photo.isUserInteractionEnabled = false
                })
        }
        alert.addAction(UIAlertAction(title:"キャンセル",style: .cancel, handler:{
            action in
        }))
        alert.alertStatusBarStyle = Style.statusBarStyle
        alert.modalPresentationCapturesStatusBarAppearance = true
        present(alert, animated: true, completion: nil)
    }


    // MARK: - IBAction
    @IBAction func star1Tapped(_ sender: UIButton) {
        if star1.currentTitle == "★" && star2.currentTitle == "☆"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
        }else{
            setStarTitleOf(star1title: "★", star2title: "☆", star3title: "☆")
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        if star2.currentTitle == "★" && star3.currentTitle == "☆"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
        }else{
            setStarTitleOf(star1title: "★", star2title: "★", star3title: "☆")
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        if star3.currentTitle == "★"{
            setStarTitleOf(star1title: "☆", star2title: "☆", star3title: "☆")
        }else{
            setStarTitleOf(star1title: "★", star2title: "★", star3title: "★")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if Date().timeIntervalSince(openTime) < 3 {
            _ = detailVC?.navigationController?.popViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
        }else{
            let alertView = CustomAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "はい",style: .default){
                action in
                _ = self.detailVC?.navigationController?.popViewController(animated: false)
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(UIAlertAction(title: "いいえ", style: .cancel){action in})
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
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
        if recipeName.text == nil || textWithoutSpace(text: recipeName.text!) == ""{
            presentAlert("レシピ名を入力してください")
        }else if textWithoutSpace(text: recipeName.text!).count > 30{
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
                let sameNameRecipe = realm.objects(Recipe.self).filter("recipeName == %@",textWithoutSpace(text: recipeName.text!))
                if sameNameRecipe.count != 0{
                    presentAlert("同じ名前のレシピが既に登録されています")
                }else{
                    try! realm.write{
                        let newRecipe = Recipe()
                        newRecipe.recipeName = textWithoutSpace(text: recipeName.text!)

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
                            newRecipe.imageData = image.pngData() as Data?
                        }else{
                            newRecipe.imageData = nil
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
                        detailVC?.recipeId = newRecipe.id
                        newRecipe.updateShortageNum()
                        SVProgressHUD.showSuccess(withStatus: "レシピを登録しました")
                    }
                    if detailVC == nil{
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        detailVC!.closeEditVC(self)
                    }
                }
            }else{
                let sameNameRecipe = realm.objects(Recipe.self).filter("recipeName == %@",textWithoutSpace(text: recipeName.text!))
                if sameNameRecipe.count != 0 && recipe.recipeName != textWithoutSpace(text: recipeName.text!){
                    presentAlert("同じ名前のレシピが既に登録されています")
                }else{
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

                        recipe.recipeName = textWithoutSpace(text: recipeName.text!)
                        if star3.currentTitle == "★" {
                            recipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            recipe.favorites = 2
                        }else if star1.currentTitle == "★"{
                            recipe.favorites = 1
                        }else{
                            recipe.favorites = 0
                        }
                        
                        if let image = photo.image{
                            recipe.imageData = image.pngData() as Data?
                        }else{
                            recipe.imageData = nil
                        }
                        
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
                        detailVC?.recipeId = recipe.id
                        recipe.updateShortageNum()
                        SVProgressHUD.showSuccess(withStatus: "レシピを保存しました")
                    }
                    if detailVC == nil{
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        detailVC!.closeEditVC(self)
                    }
                }
            }
        }
    }
    
    @IBAction func styleTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "StyleTipNavigationController") as! UINavigationController
        nvc.modalPresentationStyle = .custom
        nvc.transitioningDelegate = self
        let vc = nvc.visibleViewController as! StyleTipViewController
        vc.interactor = interactor
        present(nvc, animated: true)
    }
    
    @IBAction func methodTipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tip", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "MethodTipNavigationController") as! UINavigationController
        nvc.modalPresentationStyle = .custom
        nvc.transitioningDelegate = self
        let vc = nvc.visibleViewController as! MethodTipViewController
        vc.interactor = interactor
        present(nvc, animated: true)
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
            self.photo.image = self.resizedImage(image: img)
            self.selectPhoto.text = "写真を変更"
            self.photo.isUserInteractionEnabled = true
            self.photo.alpha = 0.0
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

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoFilter"{
            let vc = segue.destination as! PhotoFilterViewController
            vc.image = (sender as! UIImage)
        }
    }
    
}

// ImagePicker終了時にStatus Barの色が黒になる問題へのワークアラウンド
extension UIImagePickerController {
    open override var childForStatusBarHidden: UIViewController? {
        return nil
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
