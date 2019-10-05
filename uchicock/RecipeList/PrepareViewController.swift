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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
