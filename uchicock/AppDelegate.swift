
//
//  AppDelegate.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Style.loadTheme()
        
        let manager = FileManager()
        let documentDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let realmPath = documentDir.appending("/default.realm")
        // first time to launch this app
        if manager.fileExists(atPath: realmPath) == false{
            let seedFilePath = Bundle.main.path(forResource: "default", ofType: "realm")
            try! FileManager.default.copyItem(atPath: seedFilePath!, toPath: realmPath)
        }

        var config = Realm.Configuration(
            schemaVersion: 8,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 3) {
                    migration.enumerateObjects(ofType: Ingredient.className()) { oldObject, newObject in
                        let ingredientName = oldObject!["ingredientName"] as! String
                        newObject!["category"] = ingredientName.withoutMiddleDot().categoryNumber()
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
                if (oldSchemaVersion < 7) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let recipeName = oldObject!["recipeName"] as! String
                        newObject!["style"] = recipeName.withoutMiddleDot().cocktailStyleNumber()
                    }
                }
                if (oldSchemaVersion < 8) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let imageData = oldObject!["imageData"] as! Data?
                        if let imageData = imageData{
                            let imageFileName = NSUUID().uuidString
                            if let uiImage = UIImage(data: imageData){
                                if ImageUtil.save(image: uiImage, toFileName: imageFileName) {
                                    newObject!["imageFileName"] = imageFileName
                                }
                            }
                        }
                    }
                }
            },
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                let tenMB = 10 * 1024 * 1024
                if (totalBytes > tenMB) && (Double(usedBytes) / Double(totalBytes)) < 0.1{
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
        
        requestReview()
        
        return true
    }
    
    func requestReview(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["FirstRequestReview" : false, "LaunchCountAfterReview" : 0])

        let hasReviewed = defaults.bool(forKey: "FirstRequestReview")
        let launchCountAfterReview = defaults.integer(forKey: "LaunchCountAfterReview")
        
        if let launchDateAfterReview = defaults.object(forKey: "LaunchDateAfterReview") as? NSDate {
            if hasReviewed == false{
                defaults.set(launchCountAfterReview + 1, forKey: "LaunchCountAfterReview")

                let daySpan = NSDate().timeIntervalSince(launchDateAfterReview as Date) / 60 / 60 / 24
                if daySpan > 10 && launchCountAfterReview > 7{
                    defaults.set(true, forKey: "FirstRequestReview")
                    SKStoreReviewController.requestReview()
                }
            }
        } else {
            defaults.set(NSDate(), forKey: "LaunchDateAfterReview")
        }
    }
    
    // 「ハバナピーチ」の名前を「ハバナビーチ」に修正
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
                    }
                }
            }
            defaults.set(true, forKey: "corrected_v2.2")
        }
    }

    // 「アプリコットコラーダ」の材料「牛乳」の分量を「45」から「45ml」に修正
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
    
    // 「ブルドッグ」の材料から「食塩」と「レモン」を削除
    // 「ソルティドッグ」の材料の「食塩」を必須材料にする
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
    
    // お気に入りの最小値を星1つから星0個に変更
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

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
}

