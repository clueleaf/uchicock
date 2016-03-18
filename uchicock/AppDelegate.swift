//
//  AppDelegate.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        // first time to launch this app
        let defaults = NSUserDefaults.standardUserDefaults()
        let dic = ["firstLaunch": true]
        defaults.registerDefaults(dic)
        if defaults.boolForKey("firstLaunch") {
            self.addSampleIngredient()
            self.addSampleRecipe()
            defaults.setBool(false, forKey: "firstLaunch")
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func addSampleIngredient(){
        let realm = try! Realm()

        let ingredient1 = Ingredient()
        ingredient1.ingredientName = "テキーラ"
        ingredient1.stockFlag = false
        ingredient1.memo = "メキシコ産"
        try! realm.write {
            realm.add(ingredient1)
        }
        
        let ingredient2 = Ingredient()
        ingredient2.ingredientName = "オレンジジュース"
        ingredient2.stockFlag = false
        ingredient2.memo = "オレンジジュースです"
        try! realm.write {
            realm.add(ingredient2)
        }
        
        let ingredient3 = Ingredient()
        ingredient3.ingredientName = "グレナデンシロップ"
        ingredient3.stockFlag = false
        ingredient3.memo = "シロップです"
        try! realm.write {
            realm.add(ingredient3)
        }
        
        let ingredient4 = Ingredient()
        ingredient4.ingredientName = "クリーム・ド・カシス"
        ingredient4.stockFlag = false
        ingredient4.memo = ""
        try! realm.write {
            realm.add(ingredient4)
        }

        let ingredient5 = Ingredient()
        ingredient5.ingredientName = "ジン"
        ingredient5.stockFlag = false
        ingredient5.memo = ""
        try! realm.write {
            realm.add(ingredient5)
        }

        let ingredient6 = Ingredient()
        ingredient6.ingredientName = "トニックウォーター"
        ingredient6.stockFlag = false
        ingredient6.memo = ""
        try! realm.write {
            realm.add(ingredient6)
        }

        let ingredient7 = Ingredient()
        ingredient7.ingredientName = "カルーア"
        ingredient7.stockFlag = false
        ingredient7.memo = ""
        try! realm.write {
            realm.add(ingredient7)
        }

        let ingredient8 = Ingredient()
        ingredient8.ingredientName = "牛乳"
        ingredient8.stockFlag = false
        ingredient8.memo = ""
        try! realm.write {
            realm.add(ingredient8)
        }
}
    
    func addSampleRecipe() {
        let realm = try! Realm()
        
        let recipe1 = Recipe()
        recipe1.recipeName = "テキーラサンライズ"
        recipe1.favorites = 1
        recipe1.memo="きれいな色です"
        recipe1.method=1
        try! realm.write {
            realm.add(recipe1)
        }
        
        let recipe2 = Recipe()
        recipe2.recipeName = "カシスオレンジ"
        recipe2.favorites = 1
        recipe2.memo="ソフトドリンクみたい"
        recipe2.method=1
        try! realm.write {
            realm.add(recipe2)
        }

        let recipe3 = Recipe()
        recipe3.recipeName = "ジントニック"
        recipe3.favorites = 1
        recipe3.memo="定番"
        recipe3.method=1
        try! realm.write {
            realm.add(recipe3)
        }

        let recipe4 = Recipe()
        recipe4.recipeName = "カルーアミルク"
        recipe4.favorites = 1
        recipe4.memo="飲みやすい"
        recipe4.method=1
        try! realm.write {
            realm.add(recipe4)
        }
    
    }

}

