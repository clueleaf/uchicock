//
//  IngredientDetailViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var stock: UISwitch!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var recipeListTableView: UITableView!
    
    var ingredient = Ingredient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        let realm = try! Realm()
        ingredient = realm.objects(Ingredient).filter("id == %@",ingredient.id).first!
        
        self.navigationItem.title = ingredient.ingredientName
        ingredientName.text = ingredient.ingredientName
        memo.text = ingredient.memo
        stock.on = ingredient.stockFlag
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ingredient.recipeIngredients.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientRecipeItem") as! IngredientRecipeListTableViewCell
            cell.recipeIngredient = ingredient.recipeIngredients[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func stockSwitchTapped(sender: UISwitch) {
        if sender.on{
            let realm = try! Realm()
            try! realm.write {
                ingredient.stockFlag = true
            }
        }else{
            let realm = try! Realm()
            try! realm.write {
                ingredient.stockFlag = false
            }
        }
    }
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushEditIngredient", sender: UIBarButtonItem())
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushEditIngredient" {
            let vc = segue.destinationViewController as! IngredientEditViewController
                vc.ingredient = ingredient
        }
    }

}
