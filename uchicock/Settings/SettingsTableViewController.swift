//
//  SettingsTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var introductionImage: UIImageView!
    @IBOutlet weak var recoverImage: UIImageView!
    @IBOutlet weak var changeThemeImage: UIImageView!
    @IBOutlet weak var reviewImage: UIImageView!
    
    var firstRequestReview = false
    var alreadyWrittenReview = false
    let appStoreReviewURL = URL(string: "itms-apps://apps.apple.com/jp/app/id1097924299?action=write-review")
    
    let selectedCellBackgroundView = UIView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        introductionImage.image = introductionImage.image!.withRenderingMode(.alwaysTemplate)
        recoverImage.image = recoverImage.image!.withRenderingMode(.alwaysTemplate)
        changeThemeImage.image = changeThemeImage.image!.withRenderingMode(.alwaysTemplate)
        reviewImage.image = reviewImage.image!.withRenderingMode(.alwaysTemplate)
        
        let defaults = UserDefaults.standard
        firstRequestReview = defaults.bool(forKey: GlobalConstants.FirstRequestReviewKey)
        alreadyWrittenReview = defaults.bool(forKey: "AlreadyWrittenReview")

        self.tableView.separatorColor = UIColor.gray
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        tableView.backgroundColor = Style.basicBackgroundColor
        
        introductionImage.tintColor = Style.secondaryColor
        recoverImage.tintColor = Style.secondaryColor
        changeThemeImage.tintColor = Style.secondaryColor
        reviewImage.tintColor = Style.secondaryColor

        tableView.reloadData()        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if firstRequestReview == true, alreadyWrittenReview == false, let url = appStoreReviewURL, UIApplication.shared.canOpenURL(url) {
            return 4
        }else{
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            performSegue(withIdentifier: "usage", sender: nil)
        case 1:
            performSegue(withIdentifier: "PushRecoverRecipe", sender: indexPath)
        case 2:
            performSegue(withIdentifier: "ChangeTheme", sender: indexPath)
        case 3:
            self.tableView.deselectRow(at: indexPath, animated: true)
            let message = "「うちカク！」開発のモチベーションはみなさんの応援です。\n「使いやすい」と感じていただけたら、これからも継続して提供していけるように、ぜひ暖かい応援をお願いします！\n「星評価だけ」でも構いません！\nm(_ _)m"
            let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "レビューを書く", style: .default, handler: {action in
                if let url = self.appStoreReviewURL {
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }))
            alertView.addAction(UIAlertAction(title: "もう書いた", style: .destructive, handler: {action in
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "AlreadyWrittenReview")
                self.alreadyWrittenReview = true
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }))
            alertView.addAction(UIAlertAction(title: "今はしない", style: .cancel){action in})
            alertView.alertStatusBarStyle = Style.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let disclosureIndicator = UIImage(named: "disclosure-indicator")?.withRenderingMode(.alwaysTemplate)
        let accesoryImageView = UIImageView(image: disclosureIndicator)
        accesoryImageView.tintColor = Style.labelTextColorLight
        cell.accessoryView = accesoryImageView

        cell.selectedBackgroundView = selectedCellBackgroundView
        cell.backgroundColor = Style.basicBackgroundColor
        return cell
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
            let info1 = introductionInfo(title: "レシピ",
                                         description: GlobalConstants.IntroductionDescriptionRecipe,
                                         image: UIImage(named:"screen-recipe-ipad"))
            let info2 = introductionInfo(title: "材料",
                                         description: GlobalConstants.IntroductionDescriptionIngredient,
                                         image: UIImage(named:"screen-ingredient-ipad"))
            let info3 = introductionInfo(title: "逆引き",
                                         description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                         image: UIImage(named:"screen-reverse-lookup-ipad"))
            let info4 = introductionInfo(title: "アルバム",
                                         description: GlobalConstants.IntroductionDescriptionAlbum,
                                         image: UIImage(named:"screen-album-ipad"))
            infos.append(info1)
            infos.append(info2)
            infos.append(info3)
            infos.append(info4)
        }else{
            let info1 = introductionInfo(title: "レシピ",
                                         description: GlobalConstants.IntroductionDescriptionRecipe,
                                         image: UIImage(named:"screen-recipe-iphone"))
            let info2 = introductionInfo(title: "材料",
                                         description: GlobalConstants.IntroductionDescriptionIngredient,
                                         image: UIImage(named:"screen-ingredient-iphone"))
            let info3 = introductionInfo(title: "逆引き",
                                         description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                         image: UIImage(named:"screen-reverse-lookup-iphone"))
            let info4 = introductionInfo(title: "アルバム",
                                         description: GlobalConstants.IntroductionDescriptionAlbum,
                                         image: UIImage(named:"screen-album-iphone"))
            infos.append(info1)
            infos.append(info2)
            infos.append(info3)
            infos.append(info4)
        }
        return infos
    }

}
