
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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setColor()
        setSVProgressHUD()
        
        let manager = NSFileManager()
        let documentDir: NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let realmPath = documentDir.stringByAppendingPathComponent("default.realm")
        // first time to launch this app
        if manager.fileExistsAtPath(realmPath) == false{
            let seedFilePath = NSBundle.mainBundle().pathForResource("default", ofType: "realm")
            try! NSFileManager.defaultManager().copyItemAtPath(seedFilePath!, toPath: realmPath)
        }
        Realm.Configuration.defaultConfiguration = Realm.Configuration(readOnly: false, path: realmPath)
        
        correct_v_2_2()
        correct_v_2_3()
        
        return true
    }
    
    func correct_v_2_2(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let dic = ["corrected_v2.2": false]
        defaults.registerDefaults(dic)
        if defaults.boolForKey("corrected_v2.2") == false {
            let realm = try! Realm()
            let rec1 = realm.objects(Recipe).filter("recipeName == %@", "ハバナピーチ")
            if rec1.count > 0 {
                let rec2 = realm.objects(Recipe).filter("recipeName == %@", "ハバナビーチ")
                if rec2.count < 1 {
                    let recipe = realm.objects(Recipe).filter("recipeName == %@", "ハバナピーチ").first!
                    try! realm.write{
                        recipe.recipeName = "ハバナビーチ"
                    }
                }
            }
            defaults.setBool(true, forKey: "corrected_v2.2")
        }
    }

    func correct_v_2_3(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let dic = ["corrected_v2.3": false]
        defaults.registerDefaults(dic)
        if defaults.boolForKey("corrected_v2.3") == false {
            let realm = try! Realm()
            let ril = realm.objects(RecipeIngredientLink).filter("id == %@", "219")
            if ril.count > 0 {
                let link = realm.objects(RecipeIngredientLink).filter("id == %@", "219").first!
                if link.amount == "45" {
                    try! realm.write{
                        link.amount = "45ml"
                    }
                }
            }
            defaults.setBool(true, forKey: "corrected_v2.3")
        }
    }

    func setColor(){
        Chameleon.setGlobalThemeUsingPrimaryColor(FlatYellow(), withSecondaryColor: FlatSkyBlue(), andContentStyle: UIContentStyle.Contrast)
        
        UITableView.appearance().backgroundColor = FlatWhite()
        UISearchBar.appearance().backgroundColor = FlatSand()
        UIButton.appearanceWhenContainedInInstancesOfClasses([UITableView.self]).backgroundColor = UIColor.clearColor()
        UITabBar.appearance().tintColor = FlatOrange()
        UIButton.appearance().tintColor = FlatSkyBlueDark()
        UISegmentedControl.appearance().tintColor = FlatSkyBlueDark()
        UISegmentedControl.appearance().backgroundColor = FlatWhite()
        UILabel.appearance().textColor = FlatBlack()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = FlatWhiteDark()
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
        
    }
    
    func setSVProgressHUD(){
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
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
    
}

