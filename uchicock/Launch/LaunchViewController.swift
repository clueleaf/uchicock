//
//  LaunchViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/10/05.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class LaunchViewController: UIViewController {

    @IBOutlet weak var prepareMessage: UILabel!
    
    var recipeList: Results<Recipe>?
    var calcIngredientList: Results<CalculatorIngredient>?
    var shouldShowIntroduction = false
    var initializedFullScreenPopGesture = false
    var todayWidgetUrl: String? = nil

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        UchicockStyle.loadTheme()

        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.SaveImageSizeKey : 0, GlobalConstants.FirstLaunchKey: true])
        if defaults.bool(forKey: GlobalConstants.FirstLaunchKey) {
            prepareMessage.alpha = 0.0
            shouldShowIntroduction = true
            defaults.set(false, forKey: GlobalConstants.FirstLaunchKey)
        }else{
            prepareMessage.alpha = todayWidgetUrl == nil ? 1.0 : 0.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldShowIntroduction{
            shouldShowIntroduction = false
            performSegue(withIdentifier: "usage", sender: nil)
        }else{
            prepareToShowRecipeList()
        }
    }
    
    // MARK: - Processing
    private func prepareToShowRecipeList(){
        prepareMessage.alpha = todayWidgetUrl == nil ? 1.0 : 0.0

        let realm = try! Realm()

        // DBに名前がないが存在する画像を削除する処理
        var dbFileNameList: [String] = []
        recipeList = realm.objects(Recipe.self)
        for recipe in recipeList!{
            if let imageFileName = recipe.imageFileName{
                dbFileNameList.append(imageFileName)
            }
        }
        
        let fileManager = FileManager.default
        var actualImageFileNames = try? fileManager.contentsOfDirectory(at: GlobalConstants.ImageFolderPath, includingPropertiesForKeys: nil).map{ $0.deletingPathExtension().lastPathComponent }
        for actualImageFileName in actualImageFileNames ?? [] where dbFileNameList.contains(actualImageFileName) == false{
            let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(actualImageFileName + ".png")
            try? fileManager.removeItem(at: imageFilePath)
        }
        
        var actualThumbnailFileNames = try? fileManager.contentsOfDirectory(at: GlobalConstants.ThumbnailFolderPath, includingPropertiesForKeys: nil).map{ $0.deletingPathExtension().lastPathComponent }
        for actualThumbnailFileName in actualThumbnailFileNames ?? [] where dbFileNameList.contains(actualThumbnailFileName) == false{
            let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(actualThumbnailFileName + ".png")
            try? fileManager.removeItem(at: thumbnailFilePath)
        }
        
        // サムネイルがない画像のサムネイルを作成
        try? FileManager.default.createDirectory(atPath: GlobalConstants.ThumbnailFolderPath.path, withIntermediateDirectories: true, attributes: nil)

        actualImageFileNames = try? fileManager.contentsOfDirectory(at: GlobalConstants.ImageFolderPath, includingPropertiesForKeys: nil).map{ $0.deletingPathExtension().lastPathComponent }
        actualThumbnailFileNames = try? fileManager.contentsOfDirectory(at: GlobalConstants.ThumbnailFolderPath, includingPropertiesForKeys: nil).map{ $0.deletingPathExtension().lastPathComponent }
        for actualImageFileName in actualImageFileNames ?? [] {
            if let actualThumbnailFileNames = actualThumbnailFileNames, actualThumbnailFileNames.contains(actualImageFileName) == false{
                let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(actualImageFileName + ".png")
                let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(actualImageFileName + ".png")
                let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
                if let loadedImage = loadedImage{
                    try? loadedImage.resizedUIImage(maxLongSide: GlobalConstants.ThumbnailMaxLongSide)?.pngData()?.write(to: thumbnailFilePath)
                }
            }
        }

        // レシピ修正処理
        correct_v_8_0()
        
        // 念のためにレシピの不足材料数を一括更新
        try! realm.write {
            for recipe in recipeList!{
                recipe.updateShortageNum()
            }
        }
        
        // どこでもスワイプで戻れるようにするための処理
        if initializedFullScreenPopGesture == false{
            BasicNavigationController.initializeFullScreenPopGesture()
            initializedFullScreenPopGesture = true
        }
        
        // 遷移
        let tabBarC = UIStoryboard(name: "Launch", bundle:nil).instantiateViewController(withIdentifier: "tabBar") as! BasicTabBarController
        tabBarC.modalPresentationStyle = .fullScreen
        tabBarC.modalTransitionStyle = .crossDissolve

        var index = 0
        switch todayWidgetUrl{
        case "uchicock://bookmark":
            index = 0
            let navC = tabBarC.viewControllers![0] as! UINavigationController
            let recipeVC = navC.visibleViewController as? RecipeListViewController
            recipeVC?.isBookmarkMode = true
            recipeVC?.shouldShowBookmarkGuide = true
        case "uchicock://reminder":
            index = 1
            let navC = tabBarC.viewControllers![1] as! UINavigationController
            let ingredientVC = navC.visibleViewController as? IngredientListViewController
            ingredientVC?.isReminderMode = true
            ingredientVC?.shouldShowReminderGuide = true
        case "uchicock://album":
            index = 3
        case "uchicock://calc":
            index = 4
            let navC = tabBarC.viewControllers![4] as! UINavigationController
            let settingsVC = navC.visibleViewController as? SettingsTableViewController
            if settingsVC != nil{
                settingsVC!.selectedIndexPath = IndexPath(row: 4, section: 0)
            }
            let calcVC = UIStoryboard(name: "AlcoholCalc", bundle:nil).instantiateViewController(withIdentifier: "calc") as! AlcoholCalcViewController
            navC.pushViewController(calcVC, animated: false)
        default:
            break
        }
        todayWidgetUrl = nil
        tabBarC.selectedIndex = index
        tabBarC.lastSelectedIndex = index

        // tabbarバッジ表示
        let reminderNum = realm.objects(Ingredient.self).filter("reminderSetDate != nil").count
        let defaults = UserDefaults.standard
        let version80newRecipeViewed = defaults.bool(forKey: GlobalConstants.Version80NewRecipeViewedKey)
        let version81newRecipeViewed = defaults.bool(forKey: GlobalConstants.Version81NewRecipeViewedKey)
        if let tabItems = tabBarC.tabBar.items {
            let tabItem1 = tabItems[1]
            tabItem1.badgeColor = UchicockStyle.badgeBackgroundColor
            tabItem1.badgeValue = reminderNum == 0 ? nil : "!"

            let tabItem4 = tabItems[4]
            tabItem4.badgeColor = UchicockStyle.badgeBackgroundColor
            tabItem4.badgeValue = (version80newRecipeViewed || version81newRecipeViewed) ? nil : "N"
        }
        
        self.present(tabBarC, animated: false, completion: nil)
    }
    
    func dismissIntroductionAndPrepareToShowRecipeList(_ introduction: IntroductionPageViewController){
        introduction.dismiss(animated: true, completion: {
            self.prepareToShowRecipeList()
        })
    }
    
    // MARK: - Correction
    // コモドアーはコモドールと一緒なので消す
    private func correct_v_8_0(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.Version80CorrectedKey: false])

        guard defaults.bool(forKey: GlobalConstants.Version80CorrectedKey) == false else { return }

        defaults.set(true, forKey: GlobalConstants.Version80CorrectedKey)

        let realm = try! Realm()
        let rec = realm.objects(Recipe.self).filter("recipeName == %@", "コモドアー")

        guard rec.count > 0 else { return }
        
        ImageUtil.remove(imageFileName: rec.first!.imageFileName)

        try! realm.write{
            for ri in rec.first!.recipeIngredients{
                let ingredient = realm.objects(Ingredient.self).filter("ingredientName == %@",ri.ingredient.ingredientName).first!
                for i in 0 ..< ingredient.recipeIngredients.count where i < ingredient.recipeIngredients.count{
                    if ingredient.recipeIngredients[i].id == ri.id{
                        ingredient.recipeIngredients.remove(at: i)
                    }
                }
            }
            for ri in rec.first!.recipeIngredients{
                realm.delete(ri)
            }
            realm.delete(rec.first!)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "usage" {
            let vc = segue.destination as! IntroductionPageViewController
            vc.launchVC = self
            vc.introductions = introductions()
        }
    }
    
    func introductions() -> [IntroductionInfo]{
        var infos: [IntroductionInfo] = []

        let info1 = IntroductionInfo(title: "Thank you for downloading!!",
                                     description: GlobalConstants.IntroductionDescriptionThanks,
                                     image: nil)
        let info2 = IntroductionInfo(title: "レシピ",
                                     description: GlobalConstants.IntroductionDescriptionRecipe,
                                     image: UIImage(named:"screen-recipe"))
        let info3 = IntroductionInfo(title: "材料",
                                     description: GlobalConstants.IntroductionDescriptionIngredient,
                                     image: UIImage(named:"screen-ingredient"))
        let info4 = IntroductionInfo(title: "逆引き",
                                     description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                     image: UIImage(named:"screen-reverse-lookup"))
        let info5 = IntroductionInfo(title: "アルバム",
                                     description: GlobalConstants.IntroductionDescriptionAlbum,
                                     image: UIImage(named:"screen-album"))
        infos.append(info1)
        infos.append(info2)
        infos.append(info3)
        infos.append(info4)
        infos.append(info5)
        return infos
    }
}
