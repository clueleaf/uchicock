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
    var shouldRequestReview = false
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
        shouldRequestReview = defaults.bool(forKey: GlobalConstants.RequestReviewKey)
        alreadyWrittenReview = defaults.bool(forKey: GlobalConstants.AlreadyWrittenReviewKey)

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor

        introductionImage.tintColor = UchicockStyle.primaryColor
        recoverImage.tintColor = UchicockStyle.primaryColor
        changeThemeImage.tintColor = UchicockStyle.primaryColor
        imageSizeImage.tintColor = UchicockStyle.primaryColor
        alcoholCalcImage.tintColor = UchicockStyle.primaryColor
        reviewImage.tintColor = UchicockStyle.primaryColor

        currentImageSizeLabel.textColor = UchicockStyle.labelTextColorLight
        if UserDefaults.standard.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let path = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: path, animated: true)
        }
        selectedIndexPath = nil
    }
    
    // MARK: - Logic functions
    private func setNewRecipeBadge(){
        let defaults = UserDefaults.standard
        let version80newRecipeViewed = defaults.bool(forKey: GlobalConstants.Version80NewRecipeViewedKey)
        let version81newRecipeViewed = defaults.bool(forKey: GlobalConstants.Version81NewRecipeViewedKey)
        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[4]
            tabItem.badgeColor = UchicockStyle.badgeBackgroundColor
            if version80newRecipeViewed || version81newRecipeViewed{
                tabItem.badgeValue = nil
                newRecipeLabel.isHidden = true
            }else{
                tabItem.badgeValue = "N"
                newRecipeLabel.isHidden = false
                newRecipeLabel.backgroundColor = UIColor.clear
                newRecipeLabel.layer.cornerRadius = 8
                newRecipeLabel.clipsToBounds = true
                newRecipeLabel.layer.borderWidth = 1
                newRecipeLabel.layer.borderColor = UchicockStyle.alertColor.cgColor
                newRecipeLabel.textColor = UIColor.white
                newRecipeLabel.layer.backgroundColor = UchicockStyle.alertColor.cgColor
            }
        }
    }
    
    // MARK: - ScrollableToTop
    func scrollToTop() {
        let xPos = tableView.contentOffset.x
        tableView?.setContentOffset(CGPoint(x: xPos, y: 0), animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldRequestReview == true, alreadyWrittenReview == false, let url = appStoreReviewURL, UIApplication.shared.canOpenURL(url) {
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
            let message = "「うちカク！」開発のモチベーションはみなさんの応援です。\n「使いやすい」と感じていただけたら、これからも継続して提供していけるように、ぜひ温かい応援をお願いします！\n「星評価だけ」でも構いません！\nm(_ _)m"
            let alertView = CustomAlertController(title: nil, message: message, preferredStyle: .alert)
            let writeAction = UIAlertAction(title: "レビューを書く", style: .default){action in
                if let url = self.appStoreReviewURL {
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
            if #available(iOS 13.0, *){ writeAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
            alertView.addAction(writeAction)
            let wroteAction = UIAlertAction(title: "もう書いた", style: .destructive){action in
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: GlobalConstants.AlreadyWrittenReviewKey)
                self.alreadyWrittenReview = true
                self.tableView.deleteRows(at: [indexPath], with: .middle)
            }
            if #available(iOS 13.0, *){ wroteAction.setValue(UchicockStyle.alertColor, forKey: "titleTextColor") }
            alertView.addAction(wroteAction)
            let cancelAction = UIAlertAction(title: "また今度", style: .cancel, handler: nil)
            if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
            alertView.addAction(cancelAction)
            alertView.modalPresentationCapturesStatusBarAppearance = true
            self.present(alertView, animated: true, completion: nil)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let accesoryImageView = UIImageView(image: UIImage(named: "accesory-disclosure-indicator"))
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
    
    private func introductions() -> [IntroductionInfo]{
        var infos: [IntroductionInfo] = []

        let info1 = IntroductionInfo(title: "レシピ",
                                     description: GlobalConstants.IntroductionDescriptionRecipe,
                                     image: UIImage(named:"screen-recipe"))
        let info2 = IntroductionInfo(title: "材料",
                                     description: GlobalConstants.IntroductionDescriptionIngredient,
                                     image: UIImage(named:"screen-ingredient"))
        let info3 = IntroductionInfo(title: "逆引き",
                                     description: GlobalConstants.IntroductionDescriptionReverseLookup,
                                     image: UIImage(named:"screen-reverse-lookup"))
        let info4 = IntroductionInfo(title: "アルバム",
                                    description: GlobalConstants.IntroductionDescriptionAlbum,
                                    image: UIImage(named:"screen-album"))
        infos.append(info1)
        infos.append(info2)
        infos.append(info3)
        infos.append(info4)
        return infos
    }
}
