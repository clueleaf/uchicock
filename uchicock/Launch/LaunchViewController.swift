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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let dic = [GlobalConstants.FirstLaunchKey: true]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: GlobalConstants.FirstLaunchKey) {
            prepareMessage.alpha = 0.0
            shouldShowIntroduction = true
            defaults.set(false, forKey: GlobalConstants.FirstLaunchKey)
        }else{
            prepareMessage.alpha = 1.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSearchUserDefaults()
    }
    
    private func loadSearchUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.RecipeSortPrimaryKey : 1])
        defaults.register(defaults: [GlobalConstants.RecipeSortSecondaryKey : 0])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar0Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar1Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar2Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStar3Key : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterLongKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterShortKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterHotKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStyleNoneKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterBuildKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStirKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterShakeKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterBlendKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterOthersKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterNonAlcoholKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterWeakKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterMediumKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStrongKey : true])
        defaults.register(defaults: [GlobalConstants.RecipeFilterStrengthNoneKey : true])
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
    
    func prepareToShowRecipeList(){
        prepareMessage.alpha = 1.0
        
        let realm = try! Realm()

        // アルコール度数計算オブジェクトを追加する処理
        calcIngredientList = realm.objects(CalculatorIngredient.self)
        if calcIngredientList == nil || calcIngredientList!.count == 0{
            addSampleCalcIngredient()
        }

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
        for actualImageFileName in actualImageFileNames ?? [] {
            if dbFileNameList.contains(actualImageFileName) == false{
                let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(actualImageFileName + ".png")
                try? fileManager.removeItem(at: imageFilePath)
            }
        }
        
        var actualThumbnailFileNames = try? fileManager.contentsOfDirectory(at: GlobalConstants.ThumbnailFolderPath, includingPropertiesForKeys: nil).map{ $0.deletingPathExtension().lastPathComponent }
        for actualThumbnailFileName in actualThumbnailFileNames ?? [] {
            if dbFileNameList.contains(actualThumbnailFileName) == false{
                let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(actualThumbnailFileName + ".png")
                try? fileManager.removeItem(at: thumbnailFilePath)
            }
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

        // 念のためにレシピの不足材料数を一括更新
        try! realm.write {
            for recipe in recipeList!{
                recipe.updateShortageNum()
            }
        }
        
        BasicNavigationController.initializeFullScreenPopGesture()
        
        performSegue(withIdentifier: "ShowRecipeList", sender: nil)
    }
    
    private func addSampleCalcIngredient(){
        addCalcIngredient(id: "0", degree: 40, amount: 45, valid: true)
        addCalcIngredient(id: "1", degree: 0, amount: 90, valid: true)
        addCalcIngredient(id: "2", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "3", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "4", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "5", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "6", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "7", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "8", degree: 0, amount: 0, valid: false)
        addCalcIngredient(id: "9", degree: 0, amount: 0, valid: false)
    }
        
    private func addCalcIngredient(id: String, degree: Int, amount: Int, valid: Bool){
        let realm = try! Realm()
        let ing = realm.object(ofType: CalculatorIngredient.self, forPrimaryKey: id)
        if ing == nil {
            let ingredient = CalculatorIngredient()
            ingredient.id = id
            ingredient.degree = degree
            ingredient.amount = amount
            ingredient.valid = valid
            try! realm.write{
                realm.add(ingredient)
            }
        }
    }

    func dismissIntroductionAndPrepareToShowRecipeList(_ introduction: IntroductionPageViewController){
        introduction.dismiss(animated: true, completion: {
            self.prepareToShowRecipeList()
        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "usage" {
            let vc = segue.destination as! IntroductionPageViewController
            vc.launchVC = self
            vc.introductions = introductions()
        }
    }
    
    func introductions() -> [introductionInfo]{
        var infos: [introductionInfo] = []

        let info1 = introductionInfo(title: "Thank you for downloading!!",
                                     description: GlobalConstants.IntroductionDescriptionThanks,
                                    image: nil)
        let info2 = introductionInfo(title: "レシピ",
                                     description: GlobalConstants.IntroductionDescriptionRecipe,
                                     image: UIImage(named:"screen-recipe"))
        let info3 = introductionInfo(title: "材料",
                                     description: GlobalConstants.IntroductionDescriptionIngredient,
                                     image: UIImage(named:"screen-ingredient"))
        let info4 = introductionInfo(title: "逆引き",
                                     description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                     image: UIImage(named:"screen-reverse-lookup"))
        let info5 = introductionInfo(title: "アルバム",
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
