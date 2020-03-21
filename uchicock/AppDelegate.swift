
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
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void){
        var config = Realm.Configuration(schemaVersion: GlobalConstants.RealmSchemaVersion)
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = config
        
        var tabBarC = getTabBarController()
        if tabBarC == nil{
            tabBarC = UIStoryboard(name: "Launch", bundle:nil).instantiateViewController(withIdentifier: "tabBar") as? UITabBarController
            self.window!.rootViewController = tabBarC
        }else{
            let currentVC = getVisibleViewController(nil)
            if currentVC != nil{
                if currentVC!.isKind(of: RecipeListViewController.self) ||
                    currentVC!.isKind(of: IngredientListViewController.self) ||
                    currentVC!.isKind(of: ReverseLookupTableViewController.self) ||
                    currentVC!.isKind(of: AlbumCollectionViewController.self) ||
                    currentVC!.isKind(of: SettingsTableViewController.self) ||
                    currentVC!.isKind(of: RecipeDetailTableViewController.self) ||
                    currentVC!.isKind(of: IngredientDetailTableViewController.self) ||
                    currentVC!.isKind(of: ChangeThemeTableViewController.self) ||
                    currentVC!.isKind(of: ChangeImageSizeTableViewController.self) ||
                    currentVC!.isKind(of: AlcoholCalcViewController.self)
                    {
                    
                }else{
                    tabBarC!.selectedViewController!.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        switch shortcutItem.type{
        case "ReverseLookup":
            tabBarC!.selectedIndex = 2
            let navC = tabBarC!.viewControllers![2] as! UINavigationController
            navC.popToRootViewController(animated: false)
            let reverseVC = navC.visibleViewController as? ReverseLookupTableViewController
            if reverseVC != nil{
                reverseVC!.selectedRecipeId = nil
            }
        case "Album":
            tabBarC!.selectedIndex = 3
            let navC = tabBarC!.viewControllers![3] as! UINavigationController
            navC.popToRootViewController(animated: false)
            let albumVC = navC.visibleViewController as? AlbumCollectionViewController
            if albumVC != nil{
                albumVC!.selectedRecipeId = nil
            }
        case "Calc":
            tabBarC!.selectedIndex = 4
            let navC = tabBarC!.viewControllers![4] as! UINavigationController
            navC.popToRootViewController(animated: false)
            let settingsVC = navC.visibleViewController as? SettingsTableViewController
            if settingsVC != nil{
                settingsVC!.selectedIndexPath = IndexPath(row: 4, section: 0)
            }
            
            let calcVC = UIStoryboard(name: "AlcoholCalc", bundle:nil).instantiateViewController(withIdentifier: "calc") as! AlcoholCalcViewController
            navC.pushViewController(calcVC, animated: false)

        default:
            break
        }
        
    }
    
    private func getTabBarController() -> UITabBarController? {
        let rootVC = self.window!.rootViewController!
        
        if rootVC.isKind(of: UITabBarController.self){
            return rootVC as? UITabBarController
        }else if rootVC.isKind(of: LaunchViewController.self) == false{
            return nil
        }
        
        if rootVC.presentedViewController == nil {
            return nil
        }

        if let presented = rootVC.presentedViewController {
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController
            }
        }
        return nil
    }
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = self.window!.rootViewController!
        }
        
        if rootVC!.isKind(of: UINavigationController.self){
            let nav = rootVC as! UINavigationController
            rootVC = nav.viewControllers.last!
        }

        if rootVC?.presentedViewController == nil {
            return rootVC
        }

        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return getVisibleViewController(navigationController.viewControllers.last!)
            }

            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return getVisibleViewController(tabBarController.selectedViewController!)
            }

            return getVisibleViewController(presented)
        }
        return nil
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

