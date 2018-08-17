//
//  RecipeEditTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/23.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import M13Checkbox
import IDMPhotoBrowser

class RecipeEditTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var recipeNameTableViewCell: UITableViewCell!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var selectPhoto: UILabel!
    @IBOutlet weak var favoriteTableViewCell: UITableViewCell!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var methodTableViewCell: UITableViewCell!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var memoTableViewCell: UITableViewCell!
    @IBOutlet weak var memo: UITextView!
    
    weak var detailVC : RecipeDetailTableViewController?
    var recipe = Recipe()
    var isAddMode = true
    var editingRecipeIngredientList = Array<EditingRecipeIngredient>()
    var ipc = UIImagePickerController()
    var focusRecipeNameFlag = false
    let selectedCellBackgroundView = UIView()
    let openTime = Date()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if Style.isStatusBarLight{
            return .lightContent
        }else{
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(RecipeEditIngredientTableViewCell.self, forCellReuseIdentifier: "RecipeEditIngredient")
        
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
        ipc.allowsEditing = true
        
        if recipe.recipeName == "" {
            self.navigationItem.title = "レシピ登録"
            star1.setTitle("☆", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
            method.selectedSegmentIndex = 0
            isAddMode = true
        } else {
            self.navigationItem.title = "レシピ編集"
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
            method.selectedSegmentIndex = recipe.method
            isAddMode = false
        }
        
        memo.text = recipe.memo
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        
        for ri in recipe.recipeIngredients {
            editingRecipeIngredientList.append(EditingRecipeIngredient(id: ri.id, ingredientName: ri.ingredient.ingredientName, amount: ri.amount, mustFlag: ri.mustFlag))
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        focusRecipeNameFlag = true
        
        var safeAreaBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        tableView.contentInset = UIEdgeInsetsMake(0, 0, safeAreaBottom, 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPathForSelectedRow = tableView.indexPathForSelectedRow
        super.viewWillAppear(animated)
        let previousNumOfRowsInSection1 = tableView.numberOfRows(inSection: 1)

        self.tableView.backgroundColor = Style.basicBackgroundColor
        recipeNameLabel.textColor = Style.labelTextColor
        starLabel.textColor = Style.labelTextColor
        methodLabel.textColor = Style.labelTextColor
        memoLabel.textColor = Style.labelTextColor
        recipeName.backgroundColor = Style.textFieldBackgroundColor
        recipeName.textColor = Style.labelTextColor
        method.tintColor = Style.secondaryColor
        method.backgroundColor = Style.basicBackgroundColor
        star1.tintColor = Style.secondaryColor
        star2.tintColor = Style.secondaryColor
        star3.tintColor = Style.secondaryColor
        selectPhoto.textColor = Style.secondaryColor
        memo.backgroundColor = Style.textFieldBackgroundColor
        memo.textColor = Style.labelTextColor
        memo.layer.borderColor = Style.memoBorderColor.cgColor
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }

        if Style.isDark {
            recipeName.keyboardAppearance = .dark
            memo.keyboardAppearance = .dark
        }else{
            recipeName.keyboardAppearance = .default
            memo.keyboardAppearance = .default
        }
        
        if Style.isStatusBarLight{
            ipc.setStatusBarStyle(.lightContent)
        }else{
            ipc.setStatusBarStyle(.default)
        }
        
        self.tableView.reloadData()
        
        switch tableView.numberOfRows(inSection: 1) - previousNumOfRowsInSection1{
        case 0:
            if let index = indexPathForSelectedRow{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.tableView.selectRow(at: indexPathForSelectedRow, animated: false, scrollPosition: .none)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.tableView.deselectRow(at: index, animated: true)
                    }
                }
            }
        case 1:
            let indexPathForAddedRow = IndexPath(row: previousNumOfRowsInSection1 - 1, section: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.selectRow(at: indexPathForAddedRow, animated: false, scrollPosition: .middle)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.tableView.deselectRow(at: indexPathForAddedRow, animated: true)
                }
            }
        default:
            break
        }
        if photo.alpha < 1.0{
            UIView.animate(withDuration: 0.5, animations: {self.photo.alpha = 1.0}, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAddMode && focusRecipeNameFlag{
            recipeName.becomeFirstResponder()
            focusRecipeNameFlag = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        recipeName.resignFirstResponder()
        return true
    }
    
    func isIngredientDuplicated() -> Bool {
        for i in 0 ..< editingRecipeIngredientList.count - 1{
            for j in i+1 ..< editingRecipeIngredientList.count{
                if editingRecipeIngredientList[i].ingredientName == editingRecipeIngredientList[j].ingredientName{
                    return true
                }
            }
        }
        return false
    }
    
    @objc func photoTapped(){
        if let image = photo.image{
            if let repre = UIImagePNGRepresentation(image){
                let browsePhoto = UIImage(data: repre)
                if browsePhoto != nil{
                    let p = IDMPhoto(image: browsePhoto)
                    let browser: IDMPhotoBrowser! = IDMPhotoBrowser(photos: [p!], animatedFrom: photo)
                    browser.displayActionButton = false
                    browser.displayArrowButton = false
                    self.present(browser, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textWithoutSpace(text: String) -> String{
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
        if section == 1 {
            label.text = "  材料編集"
        }else{
            label.text = nil
        }
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
            } else if indexPath.row == editingRecipeIngredientList.count{
                return super.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 1))
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        } else if section == 1{
            return editingRecipeIngredientList.count + 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 1))
            }else if indexPath.row == editingRecipeIngredientList.count{
                return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 1, section: 1))
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1{
            tableView.deselectRow(at: indexPath, animated: true)
            addPhoto()
        }else if indexPath.section == 1{
            performSegue(withIdentifier: "PushEditIngredient", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let del = UITableViewRowAction(style: .default, title: "削除") {
            (action, indexPath) in
            if indexPath.section == 1 && indexPath.row < self.editingRecipeIngredientList.count{
                self.editingRecipeIngredientList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        del.backgroundColor = Style.deleteColor
        
        return [del]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row < editingRecipeIngredientList.count{
            return true
        }else{
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectedBackgroundView = selectedCellBackgroundView
            return cell
        } else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeEditIngredient", for: indexPath) as! RecipeEditIngredientTableViewCell
                cell.ingredientName.text = editingRecipeIngredientList[indexPath.row].ingredientName
                cell.ingredientName.backgroundColor = Style.basicBackgroundColor
                cell.ingredientName.clipsToBounds = true
                cell.amount.text = editingRecipeIngredientList[indexPath.row].amount
                cell.amount.backgroundColor = Style.basicBackgroundColor
                cell.amount.clipsToBounds = true
                cell.option.backgroundColor = UIColor.clear
                if editingRecipeIngredientList[indexPath.row].mustFlag{
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

                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell.selectionStyle = .default
                cell.backgroundColor = Style.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                return cell
            }else if indexPath.row == editingRecipeIngredientList.count{
                let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
                cell.textLabel?.textColor = Style.secondaryColor
                cell.textLabel?.text = "材料を追加"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
                cell.textLabel?.textAlignment = .center
                cell.backgroundColor = Style.basicBackgroundColor
                cell.selectedBackgroundView = selectedCellBackgroundView
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ipc.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            if let img = resizedImage(image: image){
                ipc.dismiss(animated: false, completion: nil)
                performSegue(withIdentifier: "ShowPhotoFilter", sender: resizedImage(image: img))
            }
        }
    }
    
    func addPhoto() {
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(UIAlertAction(title: "写真を撮る", style: .default,handler:{
                action in
                self.ipc.sourceType = .camera
                self.present(self.ipc, animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "写真を選択",style: .default, handler:{
            action in
            self.ipc.sourceType = .photoLibrary
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
        if Style.isStatusBarLight{
            alert.setStatusBarStyle(.lightContent)
        }else{
            alert.setStatusBarStyle(.default)
        }
        alert.modalPresentationCapturesStatusBarAppearance = true
        present(alert, animated: true, completion: nil)
    }


    // MARK: - IBAction
    @IBAction func star1Tapped(_ sender: UIButton) {
        if star1.currentTitle == "★" && star2.currentTitle == "☆"{
            star1.setTitle("☆", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
        }else{
            star1.setTitle("★", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
        }
    }
    
    @IBAction func star2Tapped(_ sender: UIButton) {
        if star2.currentTitle == "★" && star3.currentTitle == "☆"{
            star1.setTitle("☆", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
        }else{
            star1.setTitle("★", for: .normal)
            star2.setTitle("★", for: .normal)
            star3.setTitle("☆", for: .normal)
        }
    }
    
    @IBAction func star3Tapped(_ sender: UIButton) {
        if star3.currentTitle == "★"{
            star1.setTitle("☆", for: .normal)
            star2.setTitle("☆", for: .normal)
            star3.setTitle("☆", for: .normal)
        }else{
            star1.setTitle("★", for: .normal)
            star2.setTitle("★", for: .normal)
            star3.setTitle("★", for: .normal)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if Date().timeIntervalSince(openTime) < 3 {
            _ = detailVC?.navigationController?.popViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
        }else{
            let alertView = UIAlertController(title: nil, message: "編集をやめますか？", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "はい",style: .default){
                action in
                _ = self.detailVC?.navigationController?.popViewController(animated: false)
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(UIAlertAction(title: "いいえ", style: .cancel){action in})
            if Style.isStatusBarLight{
                alertView.setStatusBarStyle(.lightContent)
            }else{
                alertView.setStatusBarStyle(.default)
            }
            alertView.modalPresentationCapturesStatusBarAppearance = true
            present(alertView, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if recipeName.text == nil || textWithoutSpace(text: recipeName.text!) == ""{
            //レシピ名を入れていない
            let noNameAlertView = UIAlertController(title: nil, message: "レシピ名を入力してください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            if Style.isStatusBarLight{
                noNameAlertView.setStatusBarStyle(.lightContent)
            }else{
                noNameAlertView.setStatusBarStyle(.default)
            }
            noNameAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(text: recipeName.text!).count > 30{
            //レシピ名が長すぎる
            let noNameAlertView = UIAlertController(title: nil, message: "レシピ名を30文字以下にしてください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            if Style.isStatusBarLight{
                noNameAlertView.setStatusBarStyle(.lightContent)
            }else{
                noNameAlertView.setStatusBarStyle(.default)
            }
            noNameAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noNameAlertView, animated: true, completion: nil)
        }else if memo.text.count > 1000 {
            //メモが長すぎる
            let noNameAlertView = UIAlertController(title: nil, message: "メモを1000文字以下にしてください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            if Style.isStatusBarLight{
                noNameAlertView.setStatusBarStyle(.lightContent)
            }else{
                noNameAlertView.setStatusBarStyle(.default)
            }
            noNameAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noNameAlertView, animated: true, completion: nil)
        }else if editingRecipeIngredientList.count == 0{
            //材料が一つもない
            let noNameAlertView = UIAlertController(title: nil, message: "材料を一つ以上入力してください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            if Style.isStatusBarLight{
                noNameAlertView.setStatusBarStyle(.lightContent)
            }else{
                noNameAlertView.setStatusBarStyle(.default)
            }
            noNameAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noNameAlertView, animated: true, completion: nil)
        }else if editingRecipeIngredientList.count > 30{
            //材料数が多すぎる
            let noNameAlertView = UIAlertController(title: nil, message: "材料を30個以下にしてください", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            if Style.isStatusBarLight{
                noNameAlertView.setStatusBarStyle(.lightContent)
            }else{
                noNameAlertView.setStatusBarStyle(.default)
            }
            noNameAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noNameAlertView, animated: true, completion: nil)
        } else if isIngredientDuplicated() {
            //材料が重複している
            let noNameAlertView = UIAlertController(title: nil, message: "重複している材料があります", preferredStyle: .alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
            if Style.isStatusBarLight{
                noNameAlertView.setStatusBarStyle(.lightContent)
            }else{
                noNameAlertView.setStatusBarStyle(.default)
            }
            noNameAlertView.modalPresentationCapturesStatusBarAppearance = true
            present(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameRecipe = realm.objects(Recipe.self).filter("recipeName == %@",textWithoutSpace(text: recipeName.text!))
                if sameNameRecipe.count != 0{
                    let sameNameAlertView = UIAlertController(title: nil, message: "同じ名前のレシピが既に登録されています", preferredStyle: .alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                    if Style.isStatusBarLight{
                        sameNameAlertView.setStatusBarStyle(.lightContent)
                    }else{
                        sameNameAlertView.setStatusBarStyle(.default)
                    }
                    sameNameAlertView.modalPresentationCapturesStatusBarAppearance = true
                    present(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write{
                        let newRecipe = Recipe()
                        newRecipe.recipeName = textWithoutSpace(text: recipeName.text!)
                        newRecipe.japaneseDictionaryOrder = textWithoutSpace(text: recipeName.text!).japaneseDictionaryOrder()

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
                            newRecipe.imageData = UIImagePNGRepresentation(image) as Data?
                        }else{
                            newRecipe.imageData = nil
                        }
                        
                        newRecipe.method = method.selectedSegmentIndex
                        newRecipe.memo = memo.text
                        realm.add(newRecipe)
                        
                        for editingRecipeIngredient in editingRecipeIngredientList{
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
                    let sameNameAlertView = UIAlertController(title: nil, message: "同じ名前のレシピが既に登録されています", preferredStyle: .alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in}))
                    if Style.isStatusBarLight{
                        sameNameAlertView.setStatusBarStyle(.lightContent)
                    }else{
                        sameNameAlertView.setStatusBarStyle(.default)
                    }
                    sameNameAlertView.modalPresentationCapturesStatusBarAppearance = true
                    present(sameNameAlertView, animated: true, completion: nil)
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
                        recipe.japaneseDictionaryOrder = textWithoutSpace(text: recipeName.text!).japaneseDictionaryOrder()
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
                            recipe.imageData = UIImagePNGRepresentation(image) as Data?
                        }else{
                            recipe.imageData = nil
                        }
                        
                        recipe.method = method.selectedSegmentIndex
                        recipe.memo = memo.text
                        
                        for editingRecipeIngredient in editingRecipeIngredientList{
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
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func unwindToRecipeEdit(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: - GestureRecognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if touch.view!.isDescendant(of: recipeNameTableViewCell) {
            return true
        }else if touch.view!.isDescendant(of: favoriteTableViewCell){
            return true
        }else if touch.view!.isDescendant(of: methodTableViewCell){
            return true
        }else if touch.view!.isDescendant(of: memoTableViewCell){
            return true
        }
        return false
    }
    
    // MARK: - Navigation
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        if fromViewController is RecipeIngredientEditTableViewController{
            let riec = fromViewController as! RecipeIngredientEditTableViewController
            if riec.isAddMode{
                if riec.deleteFlag{
                }else{
                    var editingRecipeIngredient = EditingRecipeIngredient(id: "", ingredientName: textWithoutSpace(text: riec.ingredientName.text!), amount: riec.amount.text!, mustFlag: true)
                    if riec.option.checkState == .checked{
                        editingRecipeIngredient.mustFlag = false
                    }else{
                        editingRecipeIngredient.mustFlag = true
                    }
                    editingRecipeIngredientList.append(editingRecipeIngredient)
                }
            }else{
                if riec.deleteFlag{
                    for i in 0 ..< editingRecipeIngredientList.count where i < editingRecipeIngredientList.count {
                        if editingRecipeIngredientList[i].id == riec.recipeIngredient.id{
                            editingRecipeIngredientList.remove(at: i)
                        }
                    }
                }else{
                    for i in 0 ..< editingRecipeIngredientList.count where editingRecipeIngredientList[i].id == riec.recipeIngredient.id{
                        editingRecipeIngredientList[i].ingredientName = textWithoutSpace(text: riec.ingredientName.text!)
                        editingRecipeIngredientList[i].amount = textWithoutSpace(text: riec.amount.text!)
                        if riec.option.checkState == .checked{
                            editingRecipeIngredientList[i].mustFlag = false
                        }else{
                            editingRecipeIngredientList[i].mustFlag = true
                        }
                    }
                }
            }
            return true
        }else if fromViewController is PhotoFilterViewController{
            let pfvc = fromViewController as! PhotoFilterViewController
            let img = pfvc.imageView.image!
            self.photo.image = self.resizedImage(image: img)
            self.selectPhoto.text = "写真を変更"
            self.photo.isUserInteractionEnabled = true
            self.photo.alpha = 0.0
            UIView.animate(withDuration: 0.5, animations: {self.photo.alpha = 1.0}, completion: nil)

            return true
        }
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! RecipeIngredientEditTableViewController
            if let indexPath = sender as? IndexPath{
                if indexPath.row < editingRecipeIngredientList.count{
                    if self.editingRecipeIngredientList[indexPath.row].id == ""{
                        self.editingRecipeIngredientList[indexPath.row].id = NSUUID().uuidString
                    }
                    evc.recipeIngredient = self.editingRecipeIngredientList[indexPath.row]
                    evc.isAddMode = false
                }else if indexPath.row == editingRecipeIngredientList.count{
                    evc.isAddMode = true
                }
            }
        }else if segue.identifier == "ShowPhotoFilter"{
            let vc = segue.destination as! PhotoFilterViewController
            vc.image = (sender as! UIImage)
        }
    }
    
}
