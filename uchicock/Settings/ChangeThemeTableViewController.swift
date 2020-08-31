//
//  ChangeThemeTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class ChangeThemeTableViewController: UITableViewController {

    @IBOutlet weak var randomBarButton: UIBarButtonItem!
    let animationDuration = 0.4
    var hasScrolled = false
    var shouldAnimate = false
    var previousTableViewBackgroundColor: UIColor = UchicockStyle.basicBackgroundColor
    let cellHeight: CGFloat = 44

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        
        if #available(iOS 14.0, *) {
            setIOS14RandomButtonMenu()
        }else{
            randomBarButton.target = self
            randomBarButton.action = #selector(shuffleButtonTapped(sender:))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if hasScrolled == false{
            
            tableView.contentOffset.y = (CGFloat(ThemeColorType.toInt(from: UchicockStyle.theme) + 1) * cellHeight) - (tableView.frame.height / 2)
            let maximumOffset = max(-tableView.contentInset.top, tableView.contentSize.height - tableView.bounds.size.height + tableView.contentInset.bottom)
            if tableView.contentOffset.y < 0 { tableView.contentOffset.y = 0 }
            if tableView.contentOffset.y > maximumOffset{ tableView.contentOffset.y = maximumOffset }
            tableView.reloadData()
            hasScrolled = true
        }
    }
    
    // MARK: - Logic functions
    private func changeTheme(themeNo: Int, shouldScroll: Bool){
        var willScroll = shouldScroll
        if let visibleRows = tableView.indexPathsForVisibleRows, visibleRows.contains(IndexPath(row: themeNo, section: 0)){
            willScroll = false
        }
        
        previousTableViewBackgroundColor = UchicockStyle.basicBackgroundColor
        
        UchicockStyle.setTheme(themeNo: String(themeNo))
        UchicockStyle.saveTheme(themeNo: themeNo)
        
        self.tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        
        if willScroll == false { shouldAnimate = true }
        UIView.animate(withDuration: animationDuration, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
            self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
            self.tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        }, completion: nil)

        let contentColor = FlatColor.contrastColorOf(UchicockStyle.navigationBarColor, isFlat: false)
        UIView.transition(with: self.navigationController!.navigationBar, duration: animationDuration, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            self.navigationController?.navigationBar.barTintColor = UchicockStyle.navigationBarColor
            self.navigationController?.navigationBar.tintColor = contentColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: contentColor]
        }, completion: nil)
        
        UIView.transition(with: self.tabBarController!.tabBar, duration: animationDuration, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            self.tabBarController?.tabBar.tintColor = UchicockStyle.tabBarTintColor
            self.tabBarController?.tabBar.barTintColor = UchicockStyle.tabBarBarTintColor
            self.tabBarController?.tabBar.unselectedItemTintColor = UchicockStyle.tabBarUnselectedItemTintColor
            self.tabBarController?.tabBar.items?[1].badgeColor = UchicockStyle.badgeBackgroundColor
            self.tabBarController?.tabBar.items?[4].badgeColor = UchicockStyle.badgeBackgroundColor
        }, completion: { _ in
            self.shouldAnimate = false
        })
        
        tableView.reloadData()
        if willScroll{
            tableView.scrollToRow(at: IndexPath(row: themeNo, section: 0), at: .middle, animated: true)
        }
        
        if #available(iOS 14.0, *) {
            setIOS14RandomButtonMenu()
        }
    }
    
    @available(iOS 14.0, *)
    func setIOS14RandomButtonMenu(){
        let shuffleAction = UIAction(title: "全テーマから", image: UIImage(named: "button-tip")) { action in
            var theme = UchicockStyle.theme
            while theme == UchicockStyle.theme{
                theme = ThemeColorType.fromString(String(Int.random(in: 0 ..< ThemeColorType.allCases.count)))
                    
            }
            self.changeTheme(themeNo: ThemeColorType.toInt(from: theme), shouldScroll: true)
        }
        
        var lightImage = UIImage(named: "empty-circle")
        if UchicockStyle.isBackgroundDark{
            lightImage = UIImage(named: "filled-circle")
        }
        let lightShuffleAction = UIAction(title: "ライトテーマから", image: lightImage) { action in
            var theme = UchicockStyle.theme
            while theme == UchicockStyle.theme{
                theme = [.tequilaSunriseLight,
                         .seaBreezeLight,
                         .chinaBlueLight,
                         .grasshopperLight,
                         .mojitoLight,
                         .redEyeLight,
                         .silverWingLight,
                         .blueLagoonLight,
                         .mimosaLight,
                         .pinkLadyLight,
                         .shoyoJulingLight,
                         .unionJackLight,
                         .blueMoonLight].randomElement()!
            }
            self.changeTheme(themeNo: ThemeColorType.toInt(from: theme), shouldScroll: true)
        }
        
        var darkImage = UIImage(named: "filled-circle")
        if UchicockStyle.isBackgroundDark{
            darkImage = UIImage(named: "empty-circle")
        }
        let darkShuffleAction = UIAction(title: "ダークテーマから", image: darkImage) { action in
            var theme = UchicockStyle.theme
            while theme == UchicockStyle.theme{
                theme = [.tequilaSunriseDark,
                         .seaBreezeDark,
                         .chinaBlueDark,
                         .irishCoffeeDark,
                         .cubaLibreDark,
                         .americanLemonadeDark,
                         .blueLagoonDark,
                         .mimosaDark,
                         .pinkLadyDark,
                         .blackRussianDark,
                         .shoyoJulingDark,
                         .unionJackDark,
                         .bloodyMaryDark].randomElement()!
            }
            self.changeTheme(themeNo: ThemeColorType.toInt(from: theme), shouldScroll: true)
        }
        randomBarButton.menu = UIMenu(title: "おまかせで選ぶ", children: [shuffleAction, lightShuffleAction, darkShuffleAction])
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ThemeColorType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeTheme(themeNo: indexPath.row, shouldScroll: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = ThemeColorType.fromString(String(indexPath.row)).rawValue

        if ThemeColorType.fromString(String(indexPath.row)) == UchicockStyle.theme{
            let checkmark = UIImage(named: "accesory-checkmark")
            let accesoryImageView = UIImageView(image: checkmark)
            accesoryImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            accesoryImageView.tintColor = UchicockStyle.primaryColor
            cell.accessoryView = accesoryImageView
            cell.textLabel?.textColor = UchicockStyle.primaryColor
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        }else{
            cell.accessoryView = nil
            cell.textLabel?.textColor = UchicockStyle.labelTextColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if shouldAnimate{
            cell.backgroundColor = previousTableViewBackgroundColor
            UIView.animate(withDuration: animationDuration, animations: {
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
            }, completion: nil)
        }else{
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
        }
        return cell
    }
    
    // MARK: - IBAction
    @objc func shuffleButtonTapped(sender: UIBarButtonItem) {
        // statusbarの時計の色の変化がなぜかおかしくなることがあるので、preferredStyleをalertではなくactionSheetにする必要がある
        let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shuffleAction = UIAlertAction(title: "おまかせで選ぶ", style: .default){action in
            var theme = UchicockStyle.theme
            while theme == UchicockStyle.theme{
                theme = ThemeColorType.fromString(String(Int.random(in: 0 ..< ThemeColorType.allCases.count)))
                    
            }
            self.changeTheme(themeNo: ThemeColorType.toInt(from: theme), shouldScroll: true)
        }
        if #available(iOS 13.0, *){ shuffleAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(shuffleAction)
        let lightShuffleAction = UIAlertAction(title: "ライトテーマからおまかせ", style: .default){action in
            var theme = UchicockStyle.theme
            while theme == UchicockStyle.theme{
                theme = [.tequilaSunriseLight,
                         .seaBreezeLight,
                         .chinaBlueLight,
                         .grasshopperLight,
                         .mojitoLight,
                         .redEyeLight,
                         .silverWingLight,
                         .blueLagoonLight,
                         .mimosaLight,
                         .pinkLadyLight,
                         .shoyoJulingLight,
                         .unionJackLight,
                         .blueMoonLight].randomElement()!
            }
            self.changeTheme(themeNo: ThemeColorType.toInt(from: theme), shouldScroll: true)
        }
        if #available(iOS 13.0, *){ lightShuffleAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(lightShuffleAction)
        let darkShuffleAction = UIAlertAction(title: "ダークテーマからおまかせ", style: .default){action in
            var theme = UchicockStyle.theme
            while theme == UchicockStyle.theme{
                theme = [.tequilaSunriseDark,
                         .seaBreezeDark,
                         .chinaBlueDark,
                         .irishCoffeeDark,
                         .cubaLibreDark,
                         .americanLemonadeDark,
                         .blueLagoonDark,
                         .mimosaDark,
                         .pinkLadyDark,
                         .blackRussianDark,
                         .shoyoJulingDark,
                         .unionJackDark,
                         .bloodyMaryDark].randomElement()!
            }
            self.changeTheme(themeNo: ThemeColorType.toInt(from: theme), shouldScroll: true)
        }
        if #available(iOS 13.0, *){ darkShuffleAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(darkShuffleAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(cancelAction)
        alertView.modalPresentationCapturesStatusBarAppearance = true
        alertView.popoverPresentationController?.barButtonItem = sender
        present(alertView, animated: true, completion: nil)
    }
    
}
