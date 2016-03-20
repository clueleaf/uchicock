//
//  RecipeDetailViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/13.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var procedure: UITextView!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var ingredientListTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    var recipeId = String()
    var recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        let realm = try! Realm()
        let rec = realm.objects(Recipe).filter("id == %@",recipeId)
        if rec.count < 1 {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            recipe = realm.objects(Recipe).filter("id == %@",recipeId).first!
            
            self.navigationItem.title = recipe.recipeName
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
            
            tableView.reloadData()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushIngredientDetail", sender: indexPath)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return recipe.recipeIngredients.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeIngredientItem") as! RecipeIngredientListTableViewCell
            cell.recipeIngredient = recipe.recipeIngredients[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func star1Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("☆", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)
        
        let realm = try! Realm()
        try! realm.write {
            recipe.favorites = 1
        }
    }

    @IBAction func star2Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("☆", forState: .Normal)

        let realm = try! Realm()
        try! realm.write {
            recipe.favorites = 2
        }
    }
    
    @IBAction func star3Tapped(sender: UIButton) {
        star1.setTitle("★", forState: .Normal)
        star2.setTitle("★", forState: .Normal)
        star3.setTitle("★", forState: .Normal)

        let realm = try! Realm()
        try! realm.write {
            recipe.favorites = 3
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destinationViewController as! IngredientDetailViewController
            if let indexPath = sender as? NSIndexPath{
                vc.ingredientId = recipe.recipeIngredients[indexPath.row].ingredient.id
                
            }
        }
    }

}
