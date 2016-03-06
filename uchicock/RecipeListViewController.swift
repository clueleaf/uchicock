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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.AddData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - RealmSettings
    
    func AddData() {

        let recipe = Recipe()
        recipe.recipeName = "テキーラサンライズ"
        recipe.favorites = 2
        recipe.memo="きれいな色です"
        recipe.method=1
        recipe.procedure="なんとかして作ります"
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(recipe)
        }

        //        self.save()
        //        self.dataUpdate()
//        self.dataDelete()
        
//        self.dataGet()
    }
    
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
    
    // データの更新
//    func dataUpdate() {
//        let realm = try! Realm()
        
//        let user = realm.objects(Recipe).last!
//        realm.write {
//            user.recipeName = "Yamasaki Tarou"
//        }
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

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let realm = try! Realm()
        let dataContent = realm.objects(Recipe)
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecipeListItem") as! RecipeListItemTableViewCell
            cell.recipeName.text = dataContent[0].recipeName
            cell.shortage.text = "\(indexPath.row)"
            cell.favorites.text = "★★☆"
            return cell
        }
        return UITableViewCell()
    }

}

