//
//  IngredientEditViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/19.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stock: UISwitch!
    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var memoPlaceholder: UILabel!
    
    var ingredient = Ingredient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memo.layer.masksToBounds = true
        memo.layer.cornerRadius = 5.0
        memo.layer.borderWidth = 1
        memo.layer.borderColor = UIColor.grayColor().CGColor
        
        stock.on = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        ingredientName.resignFirstResponder()
        return true
    }
    
    //textviewがフォーカスされたら、Labelを非表示
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        memoPlaceholder.hidden = true
        return true
    }
    
    //textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
    func textViewDidEndEditing(textView: UITextView) {
        if(memo.text.isEmpty){
            memoPlaceholder.hidden = false
        }
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if ingredientName.text == nil || ingredientName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())==""{
            //名前を入れていない
            let noNameAlertView = UIAlertController(title: "", message: "材料名を入力してください", preferredStyle: .Alert)
            noNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
            presentViewController(noNameAlertView, animated: true, completion: nil)
        }else{
            let realm = try! Realm()
            let sameNameIngredient = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
            if sameNameIngredient.count != 0{
                //同じ名前の材料がすでに登録されている
                let sameNameAlertView = UIAlertController(title: "", message: "同じ名前の材料が既に登録されています", preferredStyle: .Alert)
                sameNameAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                presentViewController(sameNameAlertView, animated: true, completion: nil)
            }else{
                let ingredient = Ingredient()
                ingredient.ingredientName = ingredientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                ingredient.stockFlag = stock.on
                ingredient.memo = memo.text
                try! realm.write {
                    realm.add(ingredient)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
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
