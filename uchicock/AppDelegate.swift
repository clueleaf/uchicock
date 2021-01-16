
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

        let manager = FileManager.default
        let realmPath = GlobalConstants.DocumentDir.appendingPathComponent("default.realm")
        // first time to launch this app
        if manager.fileExists(atPath: realmPath.path) == false{
            let seedFilePath = Bundle.main.path(forResource: "default", ofType: "realm")
            do{
                try manager.copyItem(atPath: seedFilePath!, toPath: realmPath.path)
            }catch{
                LaunchControl.shared.copyFailure = true
            }
        }

        var config = Realm.Configuration(
            schemaVersion: GlobalConstants.RealmSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 3) {
                    migration.enumerateObjects(ofType: Ingredient.className()) { oldObject, newObject in
                        let ingredientName = oldObject!["ingredientName"] as! String
                        newObject!["category"] = ingredientName.withoutMiddleSpaceAndMiddleDot().categoryNumber()
                    }
                }
                if (oldSchemaVersion < 7) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let recipeName = oldObject!["recipeName"] as! String
                        newObject!["style"] = recipeName.withoutMiddleSpaceAndMiddleDot().cocktailStyleNumber()
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
                if (oldSchemaVersion < 11) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let recipeName = oldObject!["recipeName"] as! String
                        newObject!["strength"] = recipeName.withoutMiddleSpaceAndMiddleDot().cocktailStrengthNumber()
                    }
                }
                if (oldSchemaVersion < 12) {
                    migration.enumerateObjects(ofType: RecipeIngredientLink.className()) { oldObject, newObject in
                        newObject!["displayOrder"] = -1
                    }
                }
                if (oldSchemaVersion < 13) {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        let yomi = (oldObject!["recipeName"] as! String).convertToYomi()
                        newObject!["recipeNameYomi"] = yomi
                        newObject!["katakanaLowercasedNameForSearch"] = yomi.katakanaLowercasedForSearch()
                    }
                    migration.enumerateObjects(ofType: Ingredient.className()) { oldObject, newObject in
                        let yomi = (oldObject!["ingredientName"] as! String).convertToYomi()
                        newObject!["ingredientNameYomi"] = yomi
                        newObject!["katakanaLowercasedNameForSearch"] = yomi.katakanaLowercasedForSearch()
                    }
                }
            },
            shouldCompactOnLaunch: { totalBytes, usedBytes in
            let fiveMB = 5 * 1024 * 1024
            if (totalBytes > fiveMB) && (Float(usedBytes) / Float(totalBytes)) < 0.5{
                return true
            }
            return false
        })
        
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        var config = Realm.Configuration(schemaVersion: GlobalConstants.RealmSchemaVersion)
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config

        var launchVC = getLaunchViewController()
        if launchVC == nil{
            launchVC = UIStoryboard(name: "Launch", bundle:nil).instantiateViewController(withIdentifier: "launch") as? LaunchViewController
            self.window!.rootViewController = launchVC
        }else if isLaunchViewControllerCurrentViewController() == false {
            launchVC!.dismiss(animated: false, completion: nil)
        }
        launchVC!.shortcutItemType = shortcutItem.type
    }
    
    private func getLaunchViewController() -> LaunchViewController? {
        let rootVC = self.window!.rootViewController!
        return rootVC as? LaunchViewController
    }
    
    private func isLaunchViewControllerCurrentViewController() -> Bool{
        let rootVC = self.window!.rootViewController!
        return rootVC.presentedViewController == nil ? rootVC.isKind(of: LaunchViewController.self) : false
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
