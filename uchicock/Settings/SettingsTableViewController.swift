//
//  SettingsTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, ScrollableToTop {

    @IBOutlet weak var introductionImage: UIImageView!
    @IBOutlet weak var recoverImage: UIImageView!
    @IBOutlet weak var changeThemeImage: UIImageView!
    @IBOutlet weak var imageSizeImage: UIImageView!
    @IBOutlet weak var alcoholCalcImage: UIImageView!
    @IBOutlet weak var reviewImage: UIImageView!
    @IBOutlet weak var currentImageSizeLabel: UILabel!
    @IBOutlet weak var newRecipeLabel: UILabel!
    
    var selectedIndexPath: IndexPath? = nil
    let defaults = UserDefaults.standard
    var firstRequestReview = false
    var alreadyWrittenReview = false
    let appStoreReviewURL = URL(string: "itms-apps://apps.apple.com/jp/app/id1097924299?action=write-review")
    
    let selectedCellBackgroundView = UIView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        firstRequestReview = defaults.bool(forKey: GlobalConstants.FirstRequestReviewKey)
        alreadyWrittenReview = defaults.bool(forKey: GlobalConstants.AlreadyWrittenReviewKey)

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.labelTextColorLight

        introductionImage.tintColor = UchicockStyle.primaryColor
        recoverImage.tintColor = UchicockStyle.primaryColor
        changeThemeImage.tintColor = UchicockStyle.primaryColor
        imageSizeImage.tintColor = UchicockStyle.primaryColor
        alcoholCalcImage.tintColor = UchicockStyle.primaryColor
        reviewImage.tintColor = UchicockStyle.primaryColor

        currentImageSizeLabel.textColor = UchicockStyle.labelTextColorLight
        let saveImageSize = defaults.integer(forKey: GlobalConstants.SaveImageSizeKey)
        if saveImageSize == 1{
            currentImageSizeLabel.text = "大"
        }else{
            currentImageSizeLabel.text = "中"
        }
        
        setNewRecipeBadge()
        
        tableView.reloadData()
        
        if let path = selectedIndexPath{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.tableView.selectRow(at: path, animated: false, scrollPosition: .none)
            }
        }
    }
    
    private func setNewRecipeBadge(){
        let defaults = UserDefaults.standard
        let version74newRecipeViewed = defaults.bool(forKey: GlobalConstants.Version74NewRecipeViewedKey)
        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[4]
            tabItem.badgeColor = UchicockStyle.badgeBackgroundColor
            if version74newRecipeViewed{
                tabItem.badgeValue = nil
                newRecipeLabel.isHidden = true
            }else{
                tabItem.badgeValue = "N"
                newRecipeLabel.isHidden = false
                newRecipeLabel.backgroundColor = UIColor.clear
                newRecipeLabel.layer.cornerRadius = 8
                newRecipeLabel.clipsToBounds = true
                newRecipeLabel.textAlignment = NSTextAlignment.center
                newRecipeLabel.layer.borderWidth = 1
                newRecipeLabel.layer.borderColor = UchicockStyle.alertColor.cgColor
                newRecipeLabel.textColor = UIColor.white
                newRecipeLabel.layer.backgroundColor = UchicockStyle.alertColor.cgColor
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let path = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: path, animated: true)
        }
        selectedIndexPath = nil
    }
    
    func scrollToTop() {
        tableView?.setContentOffset(CGPoint.zero, animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if firstRequestReview == true, alreadyWrittenReview == false, let url = appStoreReviewURL, UIApplication.shared.canOpenURL(url) {
            return 6
        }else{
            return 5
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            selectedIndexPath = indexPath
            performSegue(withIdentifier: "usage", sender: nil)
        case 1:
            selectedIndexPath = indexPath
            performSegue(withIdentifier: "PushRecoverRecipe", sender: nil)
        case 2:
            selectedIndexPath = indexPath
            performSegue(withIdentifier: "ChangeTheme", sender: nil)
        case 3:
            selectedIndexPath = indexPath
            performSegue(withIdentifier: "ChangeImageSize", sender: nil)
        case 4:
            selectedIndexPath = indexPath
            performSegue(withIdentifier: "AlcoholCalc", sender: nil)
        case 5:
            self.tableView.deselectRow(at: indexPath, animated: true)
            let message = "「うちカク！」開発のモチベーションはみなさんの応援です。\n「使いやすい」と感じていただけたら、これからも継続して提供していけるように、ぜひ暖かい応援をお願いします！\n「星評価だけ」でも構いません！\nm(_ _)m"
            let alertView = CustomAlertController(title: "", message: message, preferredStyle: .alert)
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
                self.tableView.deleteRows(at: [indexPath], with: .middle)
            }))
            alertView.addAction(UIAlertAction(title: "また今度", style: .cancel){action in})
            alertView.alertStatusBarStyle = UchicockStyle.statusBarStyle
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let disclosureIndicator = UIImage(named: "accesory-disclosure-indicator")
        let accesoryImageView = UIImageView(image: disclosureIndicator)
        accesoryImageView.tintColor = UchicockStyle.labelTextColorLight
        accesoryImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        cell.accessoryView = accesoryImageView
        cell.selectedBackgroundView = selectedCellBackgroundView
        cell.backgroundColor = UchicockStyle.basicBackgroundColor
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "usage" {
            let vc = segue.destination as! IntroductionPageViewController
            vc.introductions = introductions()
        }
    }
    
    private func introductions() -> [introductionInfo]{
        var infos: [introductionInfo] = []

        let info1 = introductionInfo(title: "レシピ",
                                     description: GlobalConstants.IntroductionDescriptionRecipe,
                                     image: UIImage(named:"screen-recipe"))
        let info2 = introductionInfo(title: "材料",
                                     description: GlobalConstants.IntroductionDescriptionIngredient,
                                     image: UIImage(named:"screen-ingredient"))
        let info3 = introductionInfo(title: "逆引き",
                                     description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                     image: UIImage(named:"screen-reverse-lookup"))
        let info4 = introductionInfo(title: "アルバム",
                                    description: GlobalConstants.IntroductionDescriptionAlbum,
                                    image: UIImage(named:"screen-album"))
        infos.append(info1)
        infos.append(info2)
        infos.append(info3)
        infos.append(info4)
        return infos
    }
}
