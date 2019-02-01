
//
//  AppDelegate.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import SVProgressHUD
import M13Checkbox
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UILabel.appearance().textColor = FlatBlack() // ActivityViewControllerのボタンの色のために必要
        Style.loadTheme()
        UIButton.appearance(whenContainedInInstancesOf: [UITableView.self]).backgroundColor = UIColor.clear
        UIButton.appearance().tintColor = Style.secondaryColor // テーマ変更画面のCheckboxの色のために必要
        setSVProgressHUD()
        
        let manager = FileManager()
        let documentDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let realmPath = documentDir.appending("/default.realm")
        // first time to launch this app
        if manager.fileExists(atPath: realmPath) == false{
            let seedFilePath = Bundle.main.path(forResource: "default", ofType: "realm")
            try! FileManager.default.copyItem(atPath: seedFilePath!, toPath: realmPath)
        }

        var config = Realm.Configuration(
            schemaVersion: 5,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let recipeName = oldObject!["recipeName"] as! String
                        newObject!["japaneseDictionaryOrder"] = "\(recipeName.japaneseDictionaryOrder())"
                    }
                    migration.enumerateObjects(ofType: Ingredient.className()) { oldObject, newObject in
                        let ingredientName = oldObject!["ingredientName"] as! String
                        newObject!["japaneseDictionaryOrder"] = "\(ingredientName.japaneseDictionaryOrder())"
                    }
                }
                if (oldSchemaVersion < 3) {
                    migration.enumerateObjects(ofType: Ingredient.className()) { oldObject, newObject in
                        let ingredientName = oldObject!["ingredientName"] as! String
                        newObject!["category"] = ingredientName.categoryNumber()
                    }
                }
                if (oldSchemaVersion < 5) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        if oldObject!["imageData"] != nil {
                            newObject!["imageData"] = oldObject!["imageData"] as! Data
                        }
                        newObject!["madeNum"] = 0
                    }
                }
            },
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                let oneHundredMB = 100 * 1024 * 1024
                let fiveHundredMB = 500 * 1024 * 1024
                if (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5{
                    return true
                }else if (totalBytes > fiveHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.7{
                    return true
                }
                return false
        })
        
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        
        correct_v_2_2()
        correct_v_2_3()
        correct_v_3_2()
        correct_v_4_1()
        fixNilImage()
        
        requestReview()
        
        return true
    }
    
    func requestReview(){
        let defaults = UserDefaults.standard
        let hasReviewed = defaults.bool(forKey: "FirstRequestReview")
        let launchDateAfterReview: NSDate? = defaults.object(forKey: "LaunchDateAfterReview") as? NSDate
        let launchCountAfterReview: Int? = defaults.object(forKey: "LaunchCountAfterReview") as? Int
        
        if launchDateAfterReview == nil{
            defaults.set(NSDate(), forKey: "LaunchDateAfterReview")
            defaults.set(1, forKey: "LaunchCountAfterReview")
        }else{
            if launchCountAfterReview == nil{
                defaults.set(1, forKey: "LaunchCountAfterReview")
            }else{
                defaults.set(launchCountAfterReview! + 1, forKey: "LaunchCountAfterReview")
            }
            
            let daySpan = NSDate().timeIntervalSince(launchDateAfterReview! as Date) / 60 / 60 / 24
            if hasReviewed{
                if daySpan > 270 && launchCountAfterReview! > 30{
                    defaults.set(NSDate(), forKey: "LaunchDateAfterReview")
                    defaults.set(0, forKey: "LaunchCountAfterReview")
                    defaults.set(true, forKey: "FirstRequestReview")
                    SKStoreReviewController.requestReview()
                }
            }else{
                if daySpan > 7 && launchCountAfterReview! > 7{
                    defaults.set(NSDate(), forKey: "LaunchDateAfterReview")
                    defaults.set(0, forKey: "LaunchCountAfterReview")
                    defaults.set(true, forKey: "FirstRequestReview")
                    SKStoreReviewController.requestReview()
                }
            }
        }
    }
    
    func correct_v_2_2(){
        let defaults = UserDefaults.standard
        let dic = ["corrected_v2.2": false]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "corrected_v2.2") == false {
            let realm = try! Realm()
            let rec1 = realm.objects(Recipe.self).filter("recipeName == %@", "ハバナピーチ")
            if rec1.count > 0 {
                let rec2 = realm.objects(Recipe.self).filter("recipeName == %@", "ハバナビーチ")
                if rec2.count < 1 {
                    let recipe = realm.objects(Recipe.self).filter("recipeName == %@", "ハバナピーチ").first!
                    try! realm.write{
                        recipe.recipeName = "ハバナビーチ"
                        recipe.japaneseDictionaryOrder = "ハバナビーチ".japaneseDictionaryOrder()
                    }
                }
            }
            defaults.set(true, forKey: "corrected_v2.2")
        }
    }

    func correct_v_2_3(){
        let defaults = UserDefaults.standard
        let dic = ["corrected_v2.3": false]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "corrected_v2.3") == false {
            let realm = try! Realm()
            let rec = realm.objects(Recipe.self).filter("recipeName == %@", "アプリコットコラーダ")
            if rec.count > 0{
                for ri in rec.first!.recipeIngredients{
                    if ri.ingredient.ingredientName == "牛乳" && ri.amount == "45"{
                        try! realm.write{
                            ri.amount = "45ml"
                        }
                    }
                }
            }
            defaults.set(true, forKey: "corrected_v2.3")
        }
    }
    
    func correct_v_3_2(){
        let defaults = UserDefaults.standard
        let dic = ["corrected_v3.2": false]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "corrected_v3.2") == false {
            let realm = try! Realm()
            let rillist = realm.objects(RecipeIngredientLink.self)
            for ril in rillist.reversed() {
                if ril.recipe.recipeName == "ブルドッグ"
                    && (ril.ingredient.ingredientName == "食塩"
                    || ril.ingredient.ingredientName == "レモン"){
                    try! realm.write {
                        realm.delete(ril)
                    }
                }
            }
            let rec = realm.objects(Recipe.self).filter("recipeName == %@", "ソルティドッグ")
            if rec.count > 0{
                for ri in rec.first!.recipeIngredients{
                    if ri.ingredient.ingredientName == "食塩"
                        || ri.mustFlag == false{
                        try! realm.write{
                            ri.mustFlag = true
                        }
                    }
                }
            }
            defaults.set(true, forKey: "corrected_v3.2")
        }
    }
    
    func correct_v_4_1(){
        let defaults = UserDefaults.standard
        let dic = ["corrected_v4.1": false]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "corrected_v4.1") == false {
            let realm = try! Realm()
            let recipeCount = realm.objects(Recipe.self).filter("favorites == 0").count
            if recipeCount == 0{
                let recipeList = realm.objects(Recipe.self).filter("favorites == 1")
                try! realm.write{
                    for recipe in recipeList{
                        recipe.favorites = 0
                    }
                }
            }
            defaults.set(true, forKey: "corrected_v4.1")
        }
    }

    func fixNilImage(){
        let defaults = UserDefaults.standard
        let dic = ["fixNilImage": false]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: "fixNilImage") == false {
            let realm = try! Realm()
            let recipeList = realm.objects(Recipe.self).filter("imageData != nil")
            for recipe in recipeList{
                try! realm.write {
                    recipe.fixNilImage()
                }
            }
            defaults.set(true, forKey: "fixNilImage")
        }
    }

    func setSVProgressHUD(){
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setMinimumSize(CGSize(width: 150, height: 100))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

