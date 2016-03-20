//
//  RecipeEditViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate  {

    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var procedure: UITextView!
    @IBOutlet weak var procedurePlaceholder: UILabel!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var memoPlaceholder: UILabel!
    
    var recipe = Recipe()
    var isAddMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("recipeNameはこちら")
        print(recipe.recipeName)
        if recipe.recipeName == "" {
            //追加
            star1.setTitle("★", forState: .Normal)
            star2.setTitle("☆", forState: .Normal)
            star3.setTitle("☆", forState: .Normal)
            method.selectedSegmentIndex = 0
            navigation.title = "レシピ登録"
            isAddMode = true
        } else {
            //編集
            recipeName.text = recipe.recipeName
            procedure.text = recipe.procedure
            memo.text = recipe.memo
            
            switch recipe.method{
            case 1:
                method.selectedSegmentIndex = 0
            case 2:
                method.selectedSegmentIndex = 1
            case 3:
                method.selectedSegmentIndex = 2
            case 4:
                method.selectedSegmentIndex = 3
            default:
                method.selectedSegmentIndex = 4
            }
            
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

            if memo.text.isEmpty == false{
                memoPlaceholder.hidden = true
            }
            if procedure.text.isEmpty == false{
                procedurePlaceholder.hidden = true
            }
            navigation.title = "レシピ編集"
            isAddMode = false
        }
        
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        memo.layer.borderColor = UIColor.grayColor().CGColor

        procedure.layer.masksToBounds = true
        procedure.layer.cornerRadius = 5.0
        procedure.layer.borderWidth = 1
        procedure.layer.borderColor = UIColor.grayColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        recipeName.resignFirstResponder()
        return true
    }
    
    //textviewがフォーカスされたら、Labelを非表示
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        procedurePlaceholder.hidden = true
        memoPlaceholder.hidden = true
        return true
    }
    
    //textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
    func textViewDidEndEditing(textView: UITextView) {
        if(procedure.text.isEmpty){
            procedurePlaceholder.hidden = false
        }
        if(memo.text.isEmpty){
            memoPlaceholder.hidden = false
        }
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
