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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        setColor()
        // first time to launch this app
        let defaults = NSUserDefaults.standardUserDefaults()
        let dic = ["firstLaunch": true]
        defaults.registerDefaults(dic)
        if defaults.boolForKey("firstLaunch") {
            let realm = try! Realm()
            try! realm.write {
                self.addSampleIngredient()
                self.addSampleRecipe()
                self.addSampleRecipeToIngredientLink()
            }
            defaults.setBool(false, forKey: "firstLaunch")
        }
        return true
    }
    
    func setColor(){
        Chameleon.setGlobalThemeUsingPrimaryColor(FlatYellow(), withSecondaryColor: FlatSkyBlue(), andContentStyle: UIContentStyle.Contrast)
        
        UITableView.appearance().backgroundColor = FlatWhite()
        
        UISearchBar.appearance().backgroundColor = FlatSand()
        
        UIButton.appearanceWhenContainedInInstancesOfClasses([UITableView.self]).backgroundColor = UIColor.clearColor()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = FlatWhiteDark()
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
        UITableViewCell.appearance().backgroundColor = FlatWhite()
        
        UITabBar.appearance().tintColor = FlatOrange()
        
        UIButton.appearance().tintColor = FlatSkyBlueDark()
        
        UISegmentedControl.appearance().tintColor = FlatSkyBlueDark()
        
        UILabel.appearance().textColor = FlatBlack()
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
        addIngredient("1", ingredientName: "テキーラ", stockFlag: false, memo: "メキシコ産")
        addIngredient("2", ingredientName: "オレンジジュース", stockFlag: false, memo: "オレンジジュースです")
        addIngredient("3", ingredientName: "グレナデンシロップ", stockFlag: false, memo: "シロップです")
        addIngredient("4", ingredientName: "クリーム・ド・カシス", stockFlag: false, memo: "")
        addIngredient("5", ingredientName: "ジン", stockFlag: false, memo: "")
        addIngredient("6", ingredientName: "トニックウォーター", stockFlag: false, memo: "")
        addIngredient("7", ingredientName: "カルーア", stockFlag: false, memo: "")
        addIngredient("8", ingredientName: "牛乳", stockFlag: false, memo: "")
        addIngredient("9", ingredientName: "牛乳a", stockFlag: false, memo: "")
        addIngredient("10", ingredientName: "牛乳b", stockFlag: false, memo: "")
        addIngredient("11", ingredientName: "牛乳c", stockFlag: false, memo: "")
        addIngredient("12", ingredientName: "牛乳d", stockFlag: false, memo: "")
        addIngredient("13", ingredientName: "牛乳e", stockFlag: false, memo: "")
        addIngredient("14", ingredientName: "牛乳f", stockFlag: false, memo: "")
        addIngredient("15", ingredientName: "牛乳g", stockFlag: false, memo: "")
        addIngredient("16", ingredientName: "牛乳h", stockFlag: false, memo: "")
        addIngredient("17", ingredientName: "牛乳i", stockFlag: false, memo: "")
        addIngredient("18", ingredientName: "牛乳j", stockFlag: false, memo: "")
    }
    
    func addIngredient(id: String, ingredientName: String, stockFlag: Bool, memo: String){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient).filter("id == %@",id)
        if ing.count < 1 {
            let ingredient = Ingredient()
            ingredient.id = id
            ingredient.ingredientName = ingredientName
            ingredient.stockFlag = stockFlag
            ingredient.memo = memo
            realm.add(ingredient)
        }
    }
    
    func addSampleRecipe() {
        addRecipe("1", recipeName: "テキーラサンライズ", favorites: 1, memo: "きれいな色です", method: 0)
        addRecipe("2", recipeName: "カシスオレンジ", favorites: 1, memo: "ソフトドリンクみたい", method: 0)
        addRecipe("3", recipeName: "ジントニック", favorites: 1, memo: "定番", method: 0)
        addRecipe("4", recipeName: "カルーアミルク", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("5", recipeName: "カルーアミルクa", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("6", recipeName: "カルーアミルクb", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("7", recipeName: "カルーアミルクc", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("8", recipeName: "カルーアミルクd", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("9", recipeName: "カルーアミルクe", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("10", recipeName: "カルーアミルクf", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("11", recipeName: "カルーアミルクg", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("12", recipeName: "カルーアミルクh", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("13", recipeName: "カルーアミルクj", favorites: 1, memo: "飲みやすい", method: 0)
        addRecipe("14", recipeName: "カルーアミルクi", favorites: 1, memo: "飲みやすい", method: 0)
    }
    
    func addRecipe(id:String, recipeName:String, favorites:Int, memo:String, method:Int){
        let realm = try! Realm()
        let rec = realm.objects(Recipe).filter("id == %@",id)
        if rec.count < 1 {
            let recipe = Recipe()
            recipe.id = id
            recipe.recipeName = recipeName
            recipe.favorites = favorites
            recipe.memo = memo
            recipe.method = method
            realm.add(recipe)
        }
    }
    
    func addSampleRecipeToIngredientLink(){
        addRecipeToIngredientLink("1", recipeName: "テキーラサンライズ", ingredientName: "テキーラ", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("2", recipeName: "テキーラサンライズ", ingredientName: "オレンジジュース", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("3", recipeName: "テキーラサンライズ", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("4", recipeName: "カシスオレンジ", ingredientName: "クリーム・ド・カシス", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("5", recipeName: "カシスオレンジ", ingredientName: "オレンジジュース", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("6", recipeName: "ジントニック", ingredientName: "ジン", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("7", recipeName: "ジントニック", ingredientName: "トニックウォーター", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("8", recipeName: "カルーアミルク", ingredientName: "カルーア", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("9", recipeName: "カルーアミルク", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("10", recipeName: "カルーアミルク", ingredientName: "牛乳a", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("11", recipeName: "カルーアミルク", ingredientName: "牛乳b", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("12", recipeName: "カルーアミルク", ingredientName: "牛乳c", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("13", recipeName: "カルーアミルク", ingredientName: "牛乳d", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("14", recipeName: "カルーアミルク", ingredientName: "牛乳e", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("15", recipeName: "カルーアミルク", ingredientName: "牛乳f", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("16", recipeName: "カルーアミルク", ingredientName: "牛乳g", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("17", recipeName: "カルーアミルク", ingredientName: "牛乳h", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("18", recipeName: "カルーアミルク", ingredientName: "牛乳i", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("19", recipeName: "カルーアミルク", ingredientName: "牛乳j", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("20", recipeName: "カルーアミルクa", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("21", recipeName: "カルーアミルクb", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("22", recipeName: "カルーアミルクc", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("23", recipeName: "カルーアミルクd", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("24", recipeName: "カルーアミルクe", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("25", recipeName: "カルーアミルクf", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("26", recipeName: "カルーアミルクg", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("27", recipeName: "カルーアミルクh", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("28", recipeName: "カルーアミルクi", ingredientName: "牛乳", amount: "up", mustFlag: true)
        addRecipeToIngredientLink("29", recipeName: "カルーアミルクj", ingredientName: "牛乳", amount: "up", mustFlag: true)
    }
    
    func addRecipeToIngredientLink(id:String, recipeName:String, ingredientName:String, amount:String, mustFlag:Bool){
        let realm = try! Realm()
        let lin = realm.objects(RecipeIngredientLink).filter("id == %@",id)
        if lin.count < 1 {
            let recipeIngredientLink = RecipeIngredientLink()
            recipeIngredientLink.id = id
            recipeIngredientLink.amount = amount
            recipeIngredientLink.mustFlag = mustFlag
            realm.add(recipeIngredientLink)
            
            let ingredient = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName).first!
            ingredient.recipeIngredients.append(recipeIngredientLink)
            
            let recipe = realm.objects(Recipe).filter("recipeName == %@",recipeName).first!
            recipe.recipeIngredients.append(recipeIngredientLink)
        }
    }

}

