
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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UchicockStyle.loadTheme()
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.SaveImageSizeKey : 0])
        
        FullscreenPopGesture.configuration()

        let manager = FileManager.default
        let realmPath = GlobalConstants.DocumentDir.appendingPathComponent("default.realm")
        // first time to launch this app
        if manager.fileExists(atPath: realmPath.path) == false{
            let seedFilePath = Bundle.main.path(forResource: "default", ofType: "realm")
            try! manager.copyItem(atPath: seedFilePath!, toPath: realmPath.path)
        }

        var config = Realm.Configuration(
            schemaVersion: GlobalConstants.RealmSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 3) {
                    migration.enumerateObjects(ofType: Ingredient.className()) { oldObject, newObject in
                        let ingredientName = oldObject!["ingredientName"] as! String
                        newObject!["category"] = ingredientName.withoutSpaceAndMiddleDot().categoryNumber()
                    }
                }
                if (oldSchemaVersion < 7) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let recipeName = oldObject!["recipeName"] as! String
                        newObject!["style"] = recipeName.withoutSpaceAndMiddleDot().cocktailStyleNumber()
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
                if (oldSchemaVersion < 10) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let recipeName = oldObject!["recipeName"] as! String
                        newObject!["katakanaLowercasedNameForSearch"] = recipeName.katakanaLowercasedForSearch()
                    }
                    migration.enumerateObjects(ofType: Ingredient.className()) { oldObject, newObject in
                        let ingredientName = oldObject!["ingredientName"] as! String
                        newObject!["katakanaLowercasedNameForSearch"] = ingredientName.katakanaLowercasedForSearch()
                    }
                }
                if (oldSchemaVersion < 11) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let recipeName = oldObject!["recipeName"] as! String
                        newObject!["strength"] = recipeName.withoutSpaceAndMiddleDot().cocktailStrengthNumber()
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
        
        return true
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

