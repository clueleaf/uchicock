
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setColor()
        setSVProgressHUD()
        
        let manager = FileManager()
        let documentDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let realmPath = documentDir.appending("/default.realm")
        // first time to launch this app
        if manager.fileExists(atPath: realmPath) == false{
            let seedFilePath = Bundle.main.path(forResource: "default", ofType: "realm")
            try! FileManager.default.copyItem(atPath: seedFilePath!, toPath: realmPath)
        }
        
        var config = Realm.Configuration(schemaVersion: 1)
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        
        correct_v_2_2()
        correct_v_2_3()
        correct_v_3_2()
        fixNilImage()
        
        return true
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

    func fixNilImage(){
        let realm = try! Realm()
        let recipeList = realm.objects(Recipe.self).sorted(byProperty: "recipeName")
        for recipe in recipeList{
            try! realm.write {
                recipe.fixNilImage()
            }
        }
    }

    func setColor(){
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        
        UITableView.appearance().backgroundColor = Style.basicBackgroundColor
        UISearchBar.appearance().backgroundColor = Style.filterContainerBackgroundColor
        UIButton.appearance(whenContainedInInstancesOf: [UITableView.self]).backgroundColor = UIColor.clear
        UITabBar.appearance().tintColor = Style.tabBarTintColor
        UITabBar.appearance().barTintColor = Style.tabBarBarTintColor
        UIButton.appearance().tintColor = Style.secondaryColor
        UISegmentedControl.appearance().tintColor = Style.secondaryColor
        UISegmentedControl.appearance().backgroundColor = Style.basicBackgroundColor
        UILabel.appearance().textColor = Style.labelTextColor
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }
    
    func setSVProgressHUD(){
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
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

