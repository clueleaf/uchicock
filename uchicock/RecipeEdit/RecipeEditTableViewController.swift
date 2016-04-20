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

class RecipeEditTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var recipeNameTableViewCell: UITableViewCell!
    @IBOutlet weak var recipeName: UITextField!
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
    
    var recipe = Recipe()
    var isAddMode = true
    var editingRecipeIngredientList = Array<EditingRecipeIngredient>()
    var ipc = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(RecipeEditIngredientTableViewCell.self, forCellReuseIdentifier: "RecipeEditIngredient")
        
        recipeName.text = recipe.recipeName
        recipeName.delegate = self
        
        selectPhoto.textColor = FlatSkyBlue()
        if recipe.imageData == nil{
        }else{
            photo.image = UIImage(data: recipe.imageData!)
        }
        if photo.image == nil{
            selectPhoto.text = "写真を追加"
        }else{
            selectPhoto.text = "写真を変更"
        }
        
        ipc.delegate = self
        ipc.allowsEditing = true
        
        if recipe.recipeName == "" {
            self.navigationItem.title = "レシピ登録"
            star1.setTitle("★", forState: .Normal)
            star2.setTitle("☆", forState: .Normal)
            star3.setTitle("☆", forState: .Normal)
            method.selectedSegmentIndex = 0
            isAddMode = true
        } else {
            self.navigationItem.title = "レシピ編集"
            switch recipe.favorites{
            case 1:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("☆", forState: .Normal)
                star3.setTitle("☆", forState: .Normal)
            case 2:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("★", forState: .Normal)
                star3.setTitle("☆", forState: .Normal)
            case 3:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("★", forState: .Normal)
                star3.setTitle("★", forState: .Normal)
            default:
                star1.setTitle("★", forState: .Normal)
                star2.setTitle("☆", forState: .Normal)
                star3.setTitle("☆", forState: .Normal)
            }
            method.selectedSegmentIndex = recipe.method
            isAddMode = false
        }
        
        memo.text = recipe.memo
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        memo.layer.borderColor = FlatWhiteDark().CGColor
        
        for ri in recipe.recipeIngredients {
            let editingRecipeIngredient = EditingRecipeIngredient()
            editingRecipeIngredient.id = ri.id
            editingRecipeIngredient.ingredientName = ri.ingredient.ingredientName
            editingRecipeIngredient.amount = ri.amount
            editingRecipeIngredient.mustFlag = ri.mustFlag
            editingRecipeIngredientList.append(editingRecipeIngredient)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool{
        recipeName.resignFirstResponder()
        return true
    }
    
    func isIngredientDuplicated() -> Bool {
        for var i = 0; i < editingRecipeIngredientList.count - 1; ++i{
            for var j = i+1; j < editingRecipeIngredientList.count; ++j{
                if editingRecipeIngredientList[i].ingredientName == editingRecipeIngredientList[j].ingredientName{
                    return true
                }
            }
        }
        return false
    }
    
    func textWithoutSpace(text: String) -> String{
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    // MARK: - UITableView
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }else {
         return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            } else if indexPath.row == editingRecipeIngredientList.count{
                return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        } else if section == 1{
            return editingRecipeIngredientList.count + 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
        }else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            }else if indexPath.row == editingRecipeIngredientList.count{
                return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            addPhoto()
        }else if indexPath.section == 1{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("PushEditIngredient", sender: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row < editingRecipeIngredientList.count{
            return true
        }else{
            return false
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == 1 && indexPath.row < editingRecipeIngredientList.count{
                editingRecipeIngredientList.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.backgroundColor = FlatWhite()
            return cell
        } else if indexPath.section == 1{
            if indexPath.row < editingRecipeIngredientList.count{
                let cell = tableView.dequeueReusableCellWithIdentifier("RecipeEditIngredient", forIndexPath: indexPath) as! RecipeEditIngredientTableViewCell
                cell.ingredientName.text = editingRecipeIngredientList[indexPath.row].ingredientName
                cell.amount.text = editingRecipeIngredientList[indexPath.row].amount
                if editingRecipeIngredientList[indexPath.row].mustFlag{
                    cell.option.text = ""
                    cell.option.backgroundColor = UIColor.clearColor()
                }else{
                    cell.option.text = "オプション"
                    cell.option.backgroundColor = FlatWhiteDark()
                }
                cell.option.textColor = FlatBlack()
                cell.option.layer.cornerRadius = 4
                cell.option.clipsToBounds = true
                cell.option.textAlignment = NSTextAlignment.Center

                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = .Default
                cell.backgroundColor = FlatWhite()
                return cell
            }else if indexPath.row == editingRecipeIngredientList.count{
                let cell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
                cell.textLabel?.textColor = FlatSkyBlue()
                cell.textLabel?.text = "材料を追加"
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(20.0)
                cell.textLabel?.textAlignment = .Center;
                cell.backgroundColor = FlatWhite()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        ipc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            photo.image = image
            selectPhoto.text = "写真を変更"
        }
        ipc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addPhoto() {
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .ActionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            alert.addAction(UIAlertAction(title: "写真を撮る", style: .Default,handler:{
                action in
                self.ipc.sourceType = .Camera
                self.presentViewController(self.ipc, animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "写真を選択",style: .Default, handler:{
            action in
            self.ipc.sourceType = .PhotoLibrary
            self.presentViewController(self.ipc, animated: true, completion: nil)
        }))
        if self.photo.image != nil{
            alert.addAction(UIAlertAction(title: "写真を削除",style: .Destructive){
                action in
                self.selectPhoto.text = "写真を追加"
                self.photo.image = nil
                })
        }
        alert.addAction(UIAlertAction(title:"キャンセル",style: .Cancel, handler:{
            action in
        }))
        presentViewController(alert, animated: true, completion: nil)
    }


    // MARK: - IBAction
    @IBAction func star1Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("☆", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
    }
    
    @IBAction func star2Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
    }
    
    @IBAction func star3Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("★", forState: .Normal)
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "", message: "編集をやめますか？", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "はい",style: .Default){
            action in
            self.dismissViewControllerAnimated(true, completion: nil)
            })
        alertView.addAction(UIAlertAction(title: "いいえ", style: .Cancel){action in})
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if recipeName.text == nil || textWithoutSpace(recipeName.text!) == ""{
            //レシピ名を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "レシピ名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if textWithoutSpace(recipeName.text!).characters.count > 30{
            //レシピ名が長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "レシピ名を30文字以下にしてください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if memo.text.characters.count > 1000 {
            //メモが長すぎる
            let noNameAlertView = UIAlertController(title: "", message: "メモを1000文字以下にしてください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if editingRecipeIngredientList.count == 0{
            //材料が一つもない
            let noNameAlertView = UIAlertController(title: "", message: "材料を一つ以上入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else if editingRecipeIngredientList.count > 30{
            //材料数が多すぎる
            let noNameAlertView = UIAlertController(title: "", message: "材料を30個以下にしてください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        } else if isIngredientDuplicated() {
            //材料が重複している
            let noNameAlertView = UIAlertController(title: "", message: "重複している材料があります", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            
            if isAddMode {
                let sameNameRecipe = realm.objects(Recipe).filter("recipeName == %@",textWithoutSpace(recipeName.text!))
                if sameNameRecipe.count != 0{
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前のレシピが既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write{
                        let newRecipe = Recipe()
                        newRecipe.recipeName = textWithoutSpace(recipeName.text!)

                        if star3.currentTitle == "★" {
                            newRecipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            newRecipe.favorites = 2
                        }else{
                            newRecipe.favorites = 1
                        }

                        if photo.image != nil{
                            newRecipe.imageData = UIImagePNGRepresentation(photo.image!)
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

                            let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",editingRecipeIngredient.ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)

                            let recipe = realm.objects(Recipe).filter("recipeName == %@",newRecipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }else{
                let sameNameRecipe = realm.objects(Recipe).filter("recipeName == %@",textWithoutSpace(recipeName.text!))
                if sameNameRecipe.count != 0 && recipe.recipeName != textWithoutSpace(recipeName.text!){
                    //同じ名前の材料がすでに登録されている
                    let sameNameAlertView = UIAlertController(title: "", message: "同じ名前のレシピが既に登録されています", preferredStyle: .Alert)
                    sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                    presentViewController(sameNameAlertView, animated: true, completion: nil)
                }else{
                    try! realm.write {
                        let deletingRecipeIngredientList = List<RecipeIngredientLink>()
                        for ri in recipe.recipeIngredients{
                            let recipeIngredient = realm.objects(RecipeIngredientLink).filter("id == %@", ri.id).first!
                            deletingRecipeIngredientList.append(recipeIngredient)
                        }
                        
                        for ri in deletingRecipeIngredientList{
                            let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                            for var i = 0; i < ingredient.recipeIngredients.count; ++i{
                                if ingredient.recipeIngredients[i].id == ri.id{
                                    ingredient.recipeIngredients.removeAtIndex(i)
                                }
                            }
                        }
                        let editingRecipe = realm.objects(Recipe).filter("id == %@",recipe.id).first!
                        editingRecipe.recipeIngredients.removeAll()
                        for ri in deletingRecipeIngredientList{
                            realm.delete(ri)
                        }

                        recipe.recipeName = textWithoutSpace(recipeName.text!)
                        if star3.currentTitle == "★" {
                            recipe.favorites = 3
                        }else if star2.currentTitle == "★" {
                            recipe.favorites = 2
                        }else{
                            recipe.favorites = 1
                        }
                        
                        if photo.image != nil{
                            recipe.imageData = UIImagePNGRepresentation(photo.image!)
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
                            
                            let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",editingRecipeIngredient.ingredientName).first!
                            ingredient.recipeIngredients.append(recipeIngredientLink)
                            
                            let recipe = realm.objects(Recipe).filter("recipeName == %@",self.recipe.recipeName).first!
                            recipe.recipeIngredients.append(recipeIngredientLink)
                        }
                        
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func screenTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func unwindToRecipeEdit(segue: UIStoryboardSegue) {
    }
    
    // MARK: - GestureRecognizer
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        if touch.view!.isDescendantOfView(recipeNameTableViewCell) {
            return true
        }else if touch.view!.isDescendantOfView(favoriteTableViewCell){
            return true
        }else if touch.view!.isDescendantOfView(methodTableViewCell){
            return true
        }else if touch.view!.isDescendantOfView(memoTableViewCell){
            return true
        }
        return false
    }
    
    // MARK: - Navigation
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        let riec = fromViewController as! RecipeIngredientEditTableViewController
        if riec.isAddMode{
            if riec.deleteFlag{
            }else{
                let editingRecipeIngredient = EditingRecipeIngredient()
                editingRecipeIngredient.ingredientName = textWithoutSpace(riec.ingredientName.text!)
                editingRecipeIngredient.amount = riec.amount.text!
                editingRecipeIngredient.mustFlag = !riec.option.on
                editingRecipeIngredientList.append(editingRecipeIngredient)                
            }
        }else{
            if riec.deleteFlag{
                for var i = 0; i < editingRecipeIngredientList.count; ++i{
                    if editingRecipeIngredientList[i].id == riec.recipeIngredient.id{
                        editingRecipeIngredientList.removeAtIndex(i)
                    }
                }
            }else{
                for editingRecipeIngredient in editingRecipeIngredientList{
                    if editingRecipeIngredient.id == riec.recipeIngredient.id{
                        editingRecipeIngredient.ingredientName = textWithoutSpace(riec.ingredientName.text!)
                        editingRecipeIngredient.amount = textWithoutSpace(riec.amount.text!)
                        editingRecipeIngredient.mustFlag = !riec.option.on
                    }
                }
            }
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destinationViewController as! UINavigationController
            let evc = enc.visibleViewController as! RecipeIngredientEditTableViewController
            if let indexPath = sender as? NSIndexPath{
                if indexPath.row < editingRecipeIngredientList.count{
                    if self.editingRecipeIngredientList[indexPath.row].id == ""{
                        self.editingRecipeIngredientList[indexPath.row].id = NSUUID().UUIDString
                    }
                    evc.recipeIngredient = self.editingRecipeIngredientList[indexPath.row]
                    evc.isAddMode = false
                }else if indexPath.row == editingRecipeIngredientList.count{
                    evc.isAddMode = true
                }
            }
        }
    }
    
}
