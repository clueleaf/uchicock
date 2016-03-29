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
        addIngredient("アップルジュース", stockFlag: false, memo: "")
        addIngredient("アマレット", stockFlag: false, memo: "")
        addIngredient("ウィスキー", stockFlag: false, memo: "")
        addIngredient("ウォッカ", stockFlag: false, memo: "")
        addIngredient("オレンジ", stockFlag: false, memo: "")
        addIngredient("オレンジ・キュラソー", stockFlag: false, memo: "")
        addIngredient("オレンジジュース", stockFlag: false, memo: "")
        addIngredient("カルーア", stockFlag: false, memo: "")
        addIngredient("カンパリ", stockFlag: false, memo: "")
        addIngredient("クレーム・ド・カカオ", stockFlag: false, memo: "")
        addIngredient("クレーム・ド・カシス", stockFlag: false, memo: "")
        addIngredient("グレープジュース", stockFlag: false, memo: "")
        addIngredient("グレープフルーツジュース", stockFlag: false, memo: "")
        addIngredient("グレナデンシロップ", stockFlag: false, memo: "")
        addIngredient("クローブ", stockFlag: false, memo: "")
        addIngredient("コアントロー", stockFlag: false, memo: "")
        addIngredient("コーラ", stockFlag: false, memo: "")
        addIngredient("シュガーシロップ", stockFlag: false, memo: "")
        addIngredient("ジンジャエール", stockFlag: false, memo: "")
        addIngredient("ソーダ", stockFlag: false, memo: "")
        addIngredient("ディタ", stockFlag: false, memo: "")
        addIngredient("テキーラ", stockFlag: false, memo: "")
        addIngredient("トニックウォーター", stockFlag: false, memo: "")
        addIngredient("トマトジュース", stockFlag: false, memo: "")
        addIngredient("ドライ・ジン", stockFlag: false, memo: "")
        addIngredient("ドライ・ベルモット", stockFlag: false, memo: "")
        addIngredient("ナツメグ", stockFlag: false, memo: "")
        addIngredient("パイナップルジュース", stockFlag: false, memo: "")
        addIngredient("ピーチツリー", stockFlag: false, memo: "")
        addIngredient("ビール", stockFlag: false, memo: "")
        addIngredient("ブランデー", stockFlag: false, memo: "")
        addIngredient("ブルー・キュラソー", stockFlag: false, memo: "")
        addIngredient("ベイリーズ", stockFlag: false, memo: "")
        addIngredient("ホワイト・キュラソー", stockFlag: false, memo: "")
        addIngredient("ホワイト・ラム", stockFlag: false, memo: "")
        addIngredient("マンゴヤン", stockFlag: false, memo: "")
        addIngredient("ミドリ", stockFlag: false, memo: "")
        addIngredient("ミネラルウォーター", stockFlag: false, memo: "")
        addIngredient("ミントの葉", stockFlag: false, memo: "")
        addIngredient("ライム", stockFlag: false, memo: "")
        addIngredient("ライムジュース", stockFlag: false, memo: "")
        addIngredient("レモン", stockFlag: false, memo: "")
        addIngredient("レモンジュース", stockFlag: false, memo: "")
        addIngredient("烏龍茶", stockFlag: false, memo: "")
        addIngredient("お湯", stockFlag: false, memo: "")
        addIngredient("日本酒", stockFlag: false, memo: "")
        addIngredient("牛乳", stockFlag: false, memo: "")
        addIngredient("赤ワイン", stockFlag: false, memo: "")
        addIngredient("白ワイン", stockFlag: false, memo: "")
        addIngredient("生クリーム", stockFlag: false, memo: "")
        addIngredient("食塩", stockFlag: false, memo: "")
        addIngredient("角砂糖", stockFlag: false, memo: "")
        addIngredient("はちみつ", stockFlag: false, memo: "")
    }
    
    func addIngredient(ingredientName: String, stockFlag: Bool, memo: String){
        let realm = try! Realm()
        let ing = realm.objects(Ingredient).filter("ingredientName == %@",ingredientName)
        if ing.count < 1 {
            let ingredient = Ingredient()
            ingredient.ingredientName = ingredientName
            ingredient.stockFlag = stockFlag
            ingredient.memo = memo
            realm.add(ingredient)
        }
    }
    
    func addSampleRecipe() {
        addRecipe("アイスブレーカー", favorites: 1, memo: "", method: 2)
        addRecipe("アメリカンレモネード", favorites: 1, memo: "", method: 0)
        addRecipe("アレキサンダー", favorites: 1, memo: "", method: 2)
        addRecipe("イエローフェロー", favorites: 1, memo: "", method: 2)
        addRecipe("ウィスキーフロート", favorites: 1, memo: "", method: 0)
        addRecipe("ウイニングラン", favorites: 1, memo: "", method: 2)
        addRecipe("ウォッカアップル", favorites: 1, memo: "", method: 1)
        addRecipe("エル・ディアブロ", favorites: 1, memo: "", method: 0)
        addRecipe("オリンピック", favorites: 1, memo: "", method: 2)
        addRecipe("オレンジフィズ", favorites: 1, memo: "", method: 2)
        addRecipe("オレンジブロッサム", favorites: 1, memo: "", method: 2)
        addRecipe("カウボーイ", favorites: 1, memo: "", method: 0)
        addRecipe("カシスオレンジ", favorites: 1, memo: "", method: 0)
        addRecipe("カミカゼ", favorites: 1, memo: "", method: 2)
        addRecipe("カルーアミルク", favorites: 1, memo: "", method: 0)
        addRecipe("カンパリオレンジ", favorites: 1, memo: "", method: 0)
        addRecipe("カンパリソーダ", favorites: 1, memo: "", method: 0)
        addRecipe("カンパリビア", favorites: 1, memo: "", method: 0)
        addRecipe("キール", favorites: 1, memo: "", method: 0)
        addRecipe("キティ", favorites: 1, memo: "", method: 0)
        addRecipe("ギムレット", favorites: 1, memo: "", method: 2)
        addRecipe("キューバリバー", favorites: 1, memo: "", method: 0)
        addRecipe("ケーブルグラム", favorites: 1, memo: "", method: 2)
        addRecipe("ゴッドファーザー", favorites: 1, memo: "", method: 0)
        addRecipe("サイドカー", favorites: 1, memo: "", method: 2)
        addRecipe("サムライロック", favorites: 1, memo: "", method: 0)
        addRecipe("シャーリーテンプル", favorites: 1, memo: "", method: 0)
        addRecipe("シャンディガフ", favorites: 1, memo: "", method: 0)
        addRecipe("ジンデイジー", favorites: 1, memo: "", method: 2)
        addRecipe("ジントニック", favorites: 1, memo: "", method: 0)
        addRecipe("ジンバック", favorites: 1, memo: "", method: 0)
        addRecipe("ジンフィズ", favorites: 1, memo: "", method: 2)
        addRecipe("ジンリッキー", favorites: 1, memo: "", method: 0)
        addRecipe("スクリュードライバー", favorites: 1, memo: "", method: 0)
        addRecipe("スプモーニ", favorites: 1, memo: "", method: 0)
        addRecipe("スリーミラーズ", favorites: 1, memo: "", method: 2)
        addRecipe("ソルティブル", favorites: 1, memo: "", method: 0)
        addRecipe("ダイキリ", favorites: 1, memo: "", method: 2)
        addRecipe("チャイナブルー", favorites: 1, memo: "", method: 2)
        addRecipe("チャロネロ", favorites: 1, memo: "", method: 0)
        addRecipe("テキーラサンライズ", favorites: 1, memo: "", method: 1)
        addRecipe("パープルパッション", favorites: 1, memo: "", method: 0)
        addRecipe("ハイボール", favorites: 1, memo: "", method: 0)
        addRecipe("ハバナピーチ", favorites: 1, memo: "", method: 2)
        addRecipe("ビアモーニ", favorites: 1, memo: "", method: 0)
        addRecipe("ファジーネーブル", favorites: 1, memo: "", method: 0)
        addRecipe("ブラッディメアリー", favorites: 1, memo: "", method: 0)
        addRecipe("ブリザード", favorites: 1, memo: "", method: 2)
        addRecipe("ブルーハワイ", favorites: 1, memo: "", method: 2)
        addRecipe("ブルーマンデー", favorites: 1, memo: "", method: 1)
        addRecipe("ブルドッグ", favorites: 1, memo: "", method: 0)
        addRecipe("ブレインヘモレージ", favorites: 1, memo: "", method: 0)
        addRecipe("フレンチエメラルド", favorites: 1, memo: "", method: 0)
        addRecipe("ベイリーズミルク", favorites: 1, memo: "", method: 1)
        addRecipe("ホットウィスキー・トディ", favorites: 1, memo: "", method: 0)
        addRecipe("ホットカンパリ", favorites: 1, memo: "", method: 0)
        addRecipe("ホワイトレディ", favorites: 1, memo: "", method: 2)
        addRecipe("マイアミ", favorites: 1, memo: "", method: 2)
        addRecipe("マティーニ", favorites: 1, memo: "", method: 1)
        addRecipe("マンゴヤンオレンジ", favorites: 1, memo: "", method: 0)
        addRecipe("マンゴヤンミルク", favorites: 1, memo: "", method: 0)
        addRecipe("ミドリミルク", favorites: 1, memo: "", method: 0)
        addRecipe("メキシカン", favorites: 1, memo: "", method: 2)
        addRecipe("メロンボール", favorites: 1, memo: "", method: 0)
        addRecipe("モスコミュール", favorites: 1, memo: "", method: 0)
        addRecipe("モヒート", favorites: 1, memo: "", method: 0)
        addRecipe("リトルデビル", favorites: 1, memo: "", method: 2)
        addRecipe("レゲエパンチ", favorites: 1, memo: "", method: 0)
        addRecipe("レッドアイ", favorites: 1, memo: "", method: 0)
        addRecipe("ロングアイランド・アイスティー", favorites: 1, memo: "", method: 0)
    }
    
    func addRecipe(recipeName:String, favorites:Int, memo:String, method:Int){
        let realm = try! Realm()
        let rec = realm.objects(Recipe).filter("recipeName == %@",recipeName)
        if rec.count < 1 {
            let recipe = Recipe()
            recipe.recipeName = recipeName
            recipe.favorites = favorites
            recipe.memo = memo
            recipe.method = method
            realm.add(recipe)
        }
    }
    
    func addSampleRecipeToIngredientLink(){
        addRecipeToIngredientLink("1", recipeName: "アイスブレーカー", ingredientName: "テキーラ", amount: "40ml", mustFlag: true)
        addRecipeToIngredientLink("2", recipeName: "アイスブレーカー", ingredientName: "ホワイト・キュラソー", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("3", recipeName: "アイスブレーカー", ingredientName: "グレープフルーツジュース", amount: "40ml", mustFlag: true)
        addRecipeToIngredientLink("4", recipeName: "アイスブレーカー", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("5", recipeName: "アメリカンレモネード", ingredientName: "赤ワイン", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("6", recipeName: "アメリカンレモネード", ingredientName: "レモンジュース", amount: "40ml", mustFlag: true)
        addRecipeToIngredientLink("7", recipeName: "アメリカンレモネード", ingredientName: "ミネラルウォーター", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("8", recipeName: "アメリカンレモネード", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("9", recipeName: "アレキサンダー", ingredientName: "ブランデー", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("10", recipeName: "アレキサンダー", ingredientName: "クレーム・ド・カカオ", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("11", recipeName: "アレキサンダー", ingredientName: "生クリーム", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("12", recipeName: "アレキサンダー", ingredientName: "ナツメグ", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("13", recipeName: "イエローフェロー", ingredientName: "ウォッカ", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("14", recipeName: "イエローフェロー", ingredientName: "ホワイト・キュラソー", amount: "10ml", mustFlag: true)
        addRecipeToIngredientLink("15", recipeName: "イエローフェロー", ingredientName: "パイナップルジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("16", recipeName: "ウィスキーフロート", ingredientName: "ウィスキー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("17", recipeName: "ウィスキーフロート", ingredientName: "ミネラルウォーター", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("18", recipeName: "ウイニングラン", ingredientName: "ピーチツリー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("19", recipeName: "ウイニングラン", ingredientName: "グレープフルーツジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("20", recipeName: "ウイニングラン", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("21", recipeName: "ウイニングラン", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("22", recipeName: "ウォッカアップル", ingredientName: "ウォッカ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("23", recipeName: "ウォッカアップル", ingredientName: "アップルジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("24", recipeName: "エル・ディアブロ", ingredientName: "テキーラ", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("25", recipeName: "エル・ディアブロ", ingredientName: "クレーム・ド・カシス", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("26", recipeName: "エル・ディアブロ", ingredientName: "ジンジャエール", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("27", recipeName: "エル・ディアブロ", ingredientName: "ライム", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("28", recipeName: "オリンピック", ingredientName: "ブランデー", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("29", recipeName: "オリンピック", ingredientName: "オレンジ・キュラソー", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("30", recipeName: "オリンピック", ingredientName: "オレンジジュース", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("31", recipeName: "オレンジフィズ", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("32", recipeName: "オレンジフィズ", ingredientName: "オレンジジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("33", recipeName: "オレンジフィズ", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("34", recipeName: "オレンジフィズ", ingredientName: "ソーダ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("35", recipeName: "オレンジフィズ", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("36", recipeName: "オレンジブロッサム", ingredientName: "ドライ・ジン", amount: "40ml", mustFlag: true)
        addRecipeToIngredientLink("37", recipeName: "オレンジブロッサム", ingredientName: "オレンジジュース", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("38", recipeName: "カウボーイ", ingredientName: "ウィスキー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("39", recipeName: "カウボーイ", ingredientName: "牛乳", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("40", recipeName: "カシスオレンジ", ingredientName: "クレーム・ド・カシス", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("41", recipeName: "カシスオレンジ", ingredientName: "オレンジジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("42", recipeName: "カミカゼ", ingredientName: "ウォッカ", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("43", recipeName: "カミカゼ", ingredientName: "ホワイト・キュラソー", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("44", recipeName: "カミカゼ", ingredientName: "ライムジュース", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("45", recipeName: "カルーアミルク", ingredientName: "カルーア", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("46", recipeName: "カルーアミルク", ingredientName: "牛乳", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("47", recipeName: "カンパリオレンジ", ingredientName: "カンパリ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("48", recipeName: "カンパリオレンジ", ingredientName: "オレンジジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("49", recipeName: "カンパリソーダ", ingredientName: "カンパリ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("50", recipeName: "カンパリソーダ", ingredientName: "ソーダ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("51", recipeName: "カンパリビア", ingredientName: "カンパリ", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("52", recipeName: "カンパリビア", ingredientName: "ビール", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("53", recipeName: "キール", ingredientName: "クレーム・ド・カシス", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("54", recipeName: "キール", ingredientName: "白ワイン", amount: "60ml", mustFlag: true)
        addRecipeToIngredientLink("55", recipeName: "キティ", ingredientName: "赤ワイン", amount: "60ml", mustFlag: true)
        addRecipeToIngredientLink("56", recipeName: "キティ", ingredientName: "ジンジャエール", amount: "60ml", mustFlag: true)
        addRecipeToIngredientLink("57", recipeName: "ギムレット", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("58", recipeName: "ギムレット", ingredientName: "ライムジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("59", recipeName: "ギムレット", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("60", recipeName: "キューバリバー", ingredientName: "ホワイト・ラム", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("61", recipeName: "キューバリバー", ingredientName: "コーラ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("62", recipeName: "キューバリバー", ingredientName: "ライム", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("63", recipeName: "ケーブルグラム", ingredientName: "ウィスキー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("64", recipeName: "ケーブルグラム", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("65", recipeName: "ケーブルグラム", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("66", recipeName: "ケーブルグラム", ingredientName: "ジンジャエール", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("67", recipeName: "ゴッドファーザー", ingredientName: "ウィスキー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("68", recipeName: "ゴッドファーザー", ingredientName: "アマレット", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("69", recipeName: "サイドカー", ingredientName: "ブランデー", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("70", recipeName: "サイドカー", ingredientName: "ホワイト・キュラソー", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("71", recipeName: "サイドカー", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("72", recipeName: "サムライロック", ingredientName: "日本酒", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("73", recipeName: "サムライロック", ingredientName: "ライムジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("74", recipeName: "サムライロック", ingredientName: "ライム", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("75", recipeName: "シャーリーテンプル", ingredientName: "ジンジャエール", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("76", recipeName: "シャーリーテンプル", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("77", recipeName: "シャーリーテンプル", ingredientName: "レモン", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("78", recipeName: "シャンディガフ", ingredientName: "ビール", amount: "1/2", mustFlag: true)
        addRecipeToIngredientLink("79", recipeName: "シャンディガフ", ingredientName: "ジンジャエール", amount: "1/2", mustFlag: true)
        addRecipeToIngredientLink("80", recipeName: "ジンデイジー", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("81", recipeName: "ジンデイジー", ingredientName: "レモンジュース", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("82", recipeName: "ジンデイジー", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("83", recipeName: "ジンデイジー", ingredientName: "レモン", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("84", recipeName: "ジントニック", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("85", recipeName: "ジントニック", ingredientName: "トニックウォーター", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("86", recipeName: "ジントニック", ingredientName: "ライム", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("87", recipeName: "ジンバック", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("88", recipeName: "ジンバック", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("89", recipeName: "ジンバック", ingredientName: "ジンジャエール", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("90", recipeName: "ジンバック", ingredientName: "ライム", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("91", recipeName: "ジンフィズ", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("92", recipeName: "ジンフィズ", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("93", recipeName: "ジンフィズ", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("94", recipeName: "ジンフィズ", ingredientName: "ソーダ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("95", recipeName: "ジンリッキー", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("96", recipeName: "ジンリッキー", ingredientName: "ソーダ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("97", recipeName: "ジンリッキー", ingredientName: "ライム", amount: "1/2個", mustFlag: true)
        addRecipeToIngredientLink("98", recipeName: "スクリュードライバー", ingredientName: "ウォッカ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("99", recipeName: "スクリュードライバー", ingredientName: "オレンジジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("100", recipeName: "スプモーニ", ingredientName: "カンパリ", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("101", recipeName: "スプモーニ", ingredientName: "グレープフルーツジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("102", recipeName: "スプモーニ", ingredientName: "トニックウォーター", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("103", recipeName: "スリーミラーズ", ingredientName: "ブランデー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("104", recipeName: "スリーミラーズ", ingredientName: "ホワイト・ラム", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("105", recipeName: "スリーミラーズ", ingredientName: "レモンジュース", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("106", recipeName: "スリーミラーズ", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("107", recipeName: "ソルティブル", ingredientName: "テキーラ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("108", recipeName: "ソルティブル", ingredientName: "グレープフルーツジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("109", recipeName: "ソルティブル", ingredientName: "食塩", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("110", recipeName: "ダイキリ", ingredientName: "ホワイト・ラム", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("111", recipeName: "ダイキリ", ingredientName: "ライムジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("112", recipeName: "ダイキリ", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("113", recipeName: "チャイナブルー", ingredientName: "ディタ", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("114", recipeName: "チャイナブルー", ingredientName: "ブルー・キュラソー", amount: "10ml", mustFlag: true)
        addRecipeToIngredientLink("115", recipeName: "チャイナブルー", ingredientName: "グレープフルーツジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("116", recipeName: "チャロネロ", ingredientName: "テキーラ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("117", recipeName: "チャロネロ", ingredientName: "レモンジュース", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("118", recipeName: "チャロネロ", ingredientName: "コーラ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("119", recipeName: "テキーラサンライズ", ingredientName: "テキーラ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("120", recipeName: "テキーラサンライズ", ingredientName: "オレンジジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("121", recipeName: "テキーラサンライズ", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("122", recipeName: "パープルパッション", ingredientName: "ウォッカ", amount: "40ml", mustFlag: true)
        addRecipeToIngredientLink("123", recipeName: "パープルパッション", ingredientName: "グレープジュース", amount: "60ml", mustFlag: true)
        addRecipeToIngredientLink("124", recipeName: "パープルパッション", ingredientName: "グレープフルーツジュース", amount: "60ml", mustFlag: true)
        addRecipeToIngredientLink("125", recipeName: "ハイボール", ingredientName: "ウィスキー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("126", recipeName: "ハイボール", ingredientName: "ソーダ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("127", recipeName: "ハバナピーチ", ingredientName: "ホワイト・ラム", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("128", recipeName: "ハバナピーチ", ingredientName: "パイナップルジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("129", recipeName: "ハバナピーチ", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("130", recipeName: "ビアモーニ", ingredientName: "ビール", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("131", recipeName: "ビアモーニ", ingredientName: "カンパリ", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("132", recipeName: "ビアモーニ", ingredientName: "グレープフルーツジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("133", recipeName: "ファジーネーブル", ingredientName: "ピーチツリー", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("134", recipeName: "ファジーネーブル", ingredientName: "オレンジジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("135", recipeName: "ファジーネーブル", ingredientName: "オレンジ", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("136", recipeName: "ブラッディメアリー", ingredientName: "ウォッカ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("137", recipeName: "ブラッディメアリー", ingredientName: "トマトジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("138", recipeName: "ブラッディメアリー", ingredientName: "レモン", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("139", recipeName: "ブリザード", ingredientName: "ウォッカ", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("140", recipeName: "ブリザード", ingredientName: "ピーチツリー", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("141", recipeName: "ブリザード", ingredientName: "カンパリ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("142", recipeName: "ブリザード", ingredientName: "グレープフルーツジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("143", recipeName: "ブリザード", ingredientName: "レモンジュース", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("144", recipeName: "ブルーハワイ", ingredientName: "ホワイト・ラム", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("145", recipeName: "ブルーハワイ", ingredientName: "ブルー・キュラソー", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("146", recipeName: "ブルーハワイ", ingredientName: "パイナップルジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("147", recipeName: "ブルーハワイ", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("148", recipeName: "ブルーマンデー", ingredientName: "ウォッカ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("149", recipeName: "ブルーマンデー", ingredientName: "コアントロー", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("150", recipeName: "ブルーマンデー", ingredientName: "ブルー・キュラソー", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("151", recipeName: "ブルドッグ", ingredientName: "ウォッカ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("152", recipeName: "ブルドッグ", ingredientName: "グレープフルーツジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("153", recipeName: "ブルドッグ", ingredientName: "食塩", amount: "少々", mustFlag: false)
        addRecipeToIngredientLink("154", recipeName: "ブルドッグ", ingredientName: "レモン", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("155", recipeName: "ブレインヘモレージ", ingredientName: "ピーチツリー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("156", recipeName: "ブレインヘモレージ", ingredientName: "ベイリーズ", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("157", recipeName: "ブレインヘモレージ", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("158", recipeName: "フレンチエメラルド", ingredientName: "ブランデー", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("159", recipeName: "フレンチエメラルド", ingredientName: "ブルー・キュラソー", amount: "10ml", mustFlag: true)
        addRecipeToIngredientLink("160", recipeName: "フレンチエメラルド", ingredientName: "トニックウォーター", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("161", recipeName: "ベイリーズミルク", ingredientName: "ベイリーズ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("162", recipeName: "ベイリーズミルク", ingredientName: "牛乳", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("163", recipeName: "ホットウィスキー・トディ", ingredientName: "ウィスキー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("164", recipeName: "ホットウィスキー・トディ", ingredientName: "お湯", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("165", recipeName: "ホットウィスキー・トディ", ingredientName: "角砂糖", amount: "1個", mustFlag: true)
        addRecipeToIngredientLink("166", recipeName: "ホットウィスキー・トディ", ingredientName: "レモン", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("167", recipeName: "ホットウィスキー・トディ", ingredientName: "クローブ", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("168", recipeName: "ホットカンパリ", ingredientName: "カンパリ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("169", recipeName: "ホットカンパリ", ingredientName: "お湯", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("170", recipeName: "ホットカンパリ", ingredientName: "はちみつ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("171", recipeName: "ホワイトレディ", ingredientName: "ドライ・ジン", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("172", recipeName: "ホワイトレディ", ingredientName: "ホワイト・キュラソー", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("173", recipeName: "ホワイトレディ", ingredientName: "レモンジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("174", recipeName: "マイアミ", ingredientName: "ホワイト・ラム", amount: "40ml", mustFlag: true)
        addRecipeToIngredientLink("175", recipeName: "マイアミ", ingredientName: "コアントロー", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("176", recipeName: "マイアミ", ingredientName: "レモンジュース", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("177", recipeName: "マティーニ", ingredientName: "ドライ・ジン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("178", recipeName: "マティーニ", ingredientName: "ドライ・ベルモット", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("179", recipeName: "マンゴヤンオレンジ", ingredientName: "マンゴヤン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("180", recipeName: "マンゴヤンオレンジ", ingredientName: "オレンジジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("181", recipeName: "マンゴヤンミルク", ingredientName: "マンゴヤン", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("182", recipeName: "マンゴヤンミルク", ingredientName: "牛乳", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("183", recipeName: "ミドリミルク", ingredientName: "ミドリ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("184", recipeName: "ミドリミルク", ingredientName: "牛乳", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("185", recipeName: "メキシカン", ingredientName: "テキーラ", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("186", recipeName: "メキシカン", ingredientName: "パイナップルジュース", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("187", recipeName: "メキシカン", ingredientName: "グレナデンシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("188", recipeName: "メロンボール", ingredientName: "ミドリ", amount: "40ml", mustFlag: true)
        addRecipeToIngredientLink("189", recipeName: "メロンボール", ingredientName: "ウォッカ", amount: "20ml", mustFlag: true)
        addRecipeToIngredientLink("190", recipeName: "メロンボール", ingredientName: "オレンジジュース", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("191", recipeName: "モスコミュール", ingredientName: "ウォッカ", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("192", recipeName: "モスコミュール", ingredientName: "ライムジュース", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("193", recipeName: "モスコミュール", ingredientName: "ジンジャエール", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("194", recipeName: "モヒート", ingredientName: "ホワイト・ラム", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("195", recipeName: "モヒート", ingredientName: "ソーダ", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("196", recipeName: "モヒート", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("197", recipeName: "モヒート", ingredientName: "ライム", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("198", recipeName: "モヒート", ingredientName: "ミントの葉", amount: "適量", mustFlag: false)
        addRecipeToIngredientLink("199", recipeName: "リトルデビル", ingredientName: "ホワイト・ラム", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("200", recipeName: "リトルデビル", ingredientName: "ドライ・ジン", amount: "30ml", mustFlag: true)
        addRecipeToIngredientLink("201", recipeName: "レゲエパンチ", ingredientName: "ピーチツリー", amount: "45ml", mustFlag: true)
        addRecipeToIngredientLink("202", recipeName: "レゲエパンチ", ingredientName: "烏龍茶", amount: "適量", mustFlag: true)
        addRecipeToIngredientLink("203", recipeName: "レッドアイ", ingredientName: "ビール", amount: "1/2", mustFlag: true)
        addRecipeToIngredientLink("204", recipeName: "レッドアイ", ingredientName: "トマトジュース", amount: "1/2", mustFlag: true)
        addRecipeToIngredientLink("205", recipeName: "ロングアイランド・アイスティー", ingredientName: "ウォッカ", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("206", recipeName: "ロングアイランド・アイスティー", ingredientName: "ドライ・ジン", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("207", recipeName: "ロングアイランド・アイスティー", ingredientName: "テキーラ", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("208", recipeName: "ロングアイランド・アイスティー", ingredientName: "ホワイト・ラム", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("209", recipeName: "ロングアイランド・アイスティー", ingredientName: "ホワイト・キュラソー", amount: "15ml", mustFlag: true)
        addRecipeToIngredientLink("210", recipeName: "ロングアイランド・アイスティー", ingredientName: "シュガーシロップ", amount: "少々", mustFlag: true)
        addRecipeToIngredientLink("211", recipeName: "ロングアイランド・アイスティー", ingredientName: "コーラ", amount: "適量", mustFlag: true)
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

