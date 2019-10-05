//
//  PrepareViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/10/05.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import RealmSwift

class PrepareViewController: UIViewController {

    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchConditionLabel: CustomLabel!
    @IBOutlet weak var searchConditionModifyButton: UIButton!
    @IBOutlet weak var containerSeparator: UIView!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var prepareMessage: CustomLabel!
    
    var recipeSortPrimary = 1
    var recipeSortSecondary = 0
    var recipeFilterStar0 = true
    var recipeFilterStar1 = true
    var recipeFilterStar2 = true
    var recipeFilterStar3 = true
    var recipeFilterLong = true
    var recipeFilterShort = true
    var recipeFilterHot = true
    var recipeFilterStyleNone = true
    var recipeFilterBuild = true
    var recipeFilterStir = true
    var recipeFilterShake = true
    var recipeFilterBlend = true
    var recipeFilterOthers = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let dic = [GlobalConstants.FirstLaunchKey: true]
        defaults.register(defaults: dic)
        if defaults.bool(forKey: GlobalConstants.FirstLaunchKey) {
            performSegue(withIdentifier: "usage", sender: nil)
            defaults.set(false, forKey: GlobalConstants.FirstLaunchKey)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVC()
    }
    
    private func setupVC(){
        searchContainer.backgroundColor = Style.filterContainerBackgroundColor
        searchBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.layer.borderColor = Style.textFieldBorderColor.cgColor
            searchBar.searchTextField.layer.borderWidth = 1.0
            searchBar.searchTextField.layer.cornerRadius = 8.0
        }else{
            for view in searchBar.subviews {
                for subview in view.subviews {
                    if subview is UITextField {
                        let textField: UITextField = subview as! UITextField
                        textField.layer.borderColor = Style.textFieldBorderColor.cgColor
                        textField.layer.borderWidth = 1.0
                        textField.layer.cornerRadius = 8.0
                        for subsubview in subview.subviews{
                            if subsubview is UILabel{
                                let placeholderLabel = subsubview as! UILabel
                                placeholderLabel.textColor = Style.labelTextColor
                            }
                        }
                    }
                }
            }
        }
        
        searchConditionModifyButton.layer.borderColor = Style.primaryColor.cgColor
        searchConditionModifyButton.layer.borderWidth = 1.5
        searchConditionModifyButton.layer.cornerRadius = 15
        searchConditionModifyButton.tintColor = Style.primaryColor
        searchConditionModifyButton.backgroundColor = Style.basicBackgroundColor
        
        containerSeparator.backgroundColor = Style.labelTextColor

        self.messageContainer.backgroundColor = Style.basicBackgroundColor
        self.prepareMessage.textColor = Style.labelTextColorLight
        
        loadSearchUserDefaults()
        setSearchConditionLabel()
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

        recipeSortPrimary = defaults.integer(forKey: GlobalConstants.RecipeSortPrimaryKey)
        recipeSortSecondary = defaults.integer(forKey: GlobalConstants.RecipeSortSecondaryKey)
        recipeFilterStar0 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar0Key)
        recipeFilterStar1 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar1Key)
        recipeFilterStar2 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar2Key)
        recipeFilterStar3 = defaults.bool(forKey: GlobalConstants.RecipeFilterStar3Key)
        recipeFilterLong = defaults.bool(forKey: GlobalConstants.RecipeFilterLongKey)
        recipeFilterShort = defaults.bool(forKey: GlobalConstants.RecipeFilterShortKey)
        recipeFilterHot = defaults.bool(forKey: GlobalConstants.RecipeFilterHotKey)
        recipeFilterStyleNone = defaults.bool(forKey: GlobalConstants.RecipeFilterStyleNoneKey)
        recipeFilterBuild = defaults.bool(forKey: GlobalConstants.RecipeFilterBuildKey)
        recipeFilterStir = defaults.bool(forKey: GlobalConstants.RecipeFilterStirKey)
        recipeFilterShake = defaults.bool(forKey: GlobalConstants.RecipeFilterShakeKey)
        recipeFilterBlend = defaults.bool(forKey: GlobalConstants.RecipeFilterBlendKey)
        recipeFilterOthers = defaults.bool(forKey: GlobalConstants.RecipeFilterOthersKey)
    }
    
    private func setSearchConditionLabel(){
        var conditionText = ""
        
        switch recipeSortPrimary{
        case 1:
            conditionText = "名前順"
        case 2:
            conditionText = "作れる順"
        case 3:
            conditionText = "作った回数順"
        case 4:
            conditionText = "お気に入り順"
        case 5:
            conditionText = "最近見た順"
        default:
            conditionText = "名前順"
        }
        
        if recipeSortPrimary > 1 && recipeSortPrimary < 5{
            switch recipeSortSecondary{
            case 1:
                conditionText += " > 名前順"
            case 2:
                conditionText += " > 作れる順"
            case 3:
                conditionText += " > 作った回数順"
            case 4:
                conditionText += " > お気に入り順"
            case 5:
                conditionText += " > 最近見た順"
            default:
                conditionText += " > 名前順"
            }
        }
        
        if recipeFilterStar0 && recipeFilterStar1 && recipeFilterStar2 && recipeFilterStar3 &&
            recipeFilterLong && recipeFilterShort && recipeFilterHot && recipeFilterStyleNone &&
            recipeFilterBuild && recipeFilterStir && recipeFilterShake && recipeFilterBlend && recipeFilterOthers {
        }else{
            conditionText += "、絞り込みあり"
        }

        searchConditionLabel.text = conditionText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    for subsubview in subview.subviews{
                        if subsubview is UILabel{
                            let placeholderLabel = subsubview as! UILabel
                            placeholderLabel.textColor = Style.labelTextColor
                        }
                    }
                }
            }
        }
        performSegue(withIdentifier: "ShowRecipeList", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "usage" {
            let vc = segue.destination as! IntroductionPageViewController
            vc.introductions = introductions()
            vc.backgroundImage = UIImage(named:"launch-background")
        }
    }
    
    func introductions() -> [introductionInfo]{
        var infos: [introductionInfo] = []

        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            let info1 = introductionInfo(title: "Thank you for downloading!!",
                                         description: GlobalConstants.IntroductionDescriptionThanks,
                                        image: nil)
            let info2 = introductionInfo(title: "レシピ",
                                         description: GlobalConstants.IntroductionDescriptionRecipe,
                                         image: UIImage(named:"screen-recipe-ipad"))
            let info3 = introductionInfo(title: "材料",
                                         description: GlobalConstants.IntroductionDescriptionIngredient,
                                         image: UIImage(named:"screen-ingredient-ipad"))
            let info4 = introductionInfo(title: "逆引き",
                                         description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                         image: UIImage(named:"screen-reverse-lookup-ipad"))
            let info5 = introductionInfo(title: "アルバム",
                                         description: GlobalConstants.IntroductionDescriptionAlbum,
                                         image: UIImage(named:"screen-album-ipad"))
            infos.append(info1)
            infos.append(info2)
            infos.append(info3)
            infos.append(info4)
            infos.append(info5)
        }else{
            let info1 = introductionInfo(title: "Thank you for downloading!!",
                                         description: GlobalConstants.IntroductionDescriptionThanks,
                                        image: nil)
            let info2 = introductionInfo(title: "レシピ",
                                         description: GlobalConstants.IntroductionDescriptionRecipe,
                                         image: UIImage(named:"screen-recipe-iphone"))
            let info3 = introductionInfo(title: "材料",
                                         description: GlobalConstants.IntroductionDescriptionIngredient,
                                         image: UIImage(named:"screen-ingredient-iphone"))
            let info4 = introductionInfo(title: "逆引き",
                                         description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                         image: UIImage(named:"screen-reverse-lookup-iphone"))
            let info5 = introductionInfo(title: "アルバム",
                                         description: GlobalConstants.IntroductionDescriptionAlbum,
                                         image: UIImage(named:"screen-album-iphone"))
            infos.append(info1)
            infos.append(info2)
            infos.append(info3)
            infos.append(info4)
            infos.append(info5)
        }
        return infos
    }
}
