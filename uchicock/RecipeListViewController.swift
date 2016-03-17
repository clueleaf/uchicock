//
//  RecipeListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var recipeList: Results<Recipe>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - RealmSettings
    
    //データの保存
//    func save() {
//        do {
//            let realm = try Realm()
//            realm.write {
//                realm.add(self.recipe)
//            }
//        } catch {
//            // Error handling...
//        }
//    }
    
    // データの取得
//    func dataGet() {
//        let realm = try! Realm()
        
//        let dataContent = realm.objects(Recipe)
//        print(dataContent)
//    }
    
    // データの削除
//    func dataDelete() {
//        let realm = try! Realm()
        
//        let user = realm.objects(Recipe).last!
//        realm.write {
            // 最後のデータ
//            realm.delete(user)
            // 全てのデータ
            //          realm.deleteAll()
//        }
//    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushRecipeDetail", sender: indexPath)
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            let realm = try! Realm()
            let dataContent = realm.objects(Recipe)
            return dataContent.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let realm = try! Realm()
        recipeList = realm.objects(Recipe)
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeListItem") as! RecipeListItemTableViewCell
            cell.recipe = recipeList![indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushRecipeDetail" {
            let vc = segue.destinationViewController as! RecipeDetailViewController
            if let indexPath = sender as? NSIndexPath{
                vc.recipe = recipeList![indexPath.row]
            }
        }
    }

}

