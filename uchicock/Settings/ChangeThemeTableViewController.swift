//
//  ChangeThemeTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class ChangeThemeTableViewController: UITableViewController {

    let animationDuration = 0.4
    var hasScrolled = false
    var shouldAnimate = false
    var previousTableViewBackgroundColor: UIColor = UchicockStyle.basicBackgroundColor
    let cellHeight: CGFloat = 44

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }

    let themeList: [String] = [
        "テキーラサンライズ - ライト",
        "テキーラサンライズ - ダーク",
        "シーブリーズ - ライト",
        "シーブリーズ - ダーク",
        "チャイナブルー - ライト",
        "チャイナブルー - ダーク",
        "グラスホッパー - ライト",
        "アイリッシュコーヒー - ダーク",
        "モヒート - ライト",
        "レッドアイ - ライト",
        "キューバリバー - ダーク",
        "シルバーウィング - ライト",
        "アメリカンレモネード - ダーク",
        "ブルーラグーン - ライト",
        "ブルーラグーン - ダーク",
        "ミモザ - ライト",
        "ミモザ - ダーク",
        "ピンクレディ - ライト",
        "ピンクレディ - ダーク",
        "ブラックルシアン - ダーク",
        "照葉樹林 - ライト",
        "照葉樹林 - ダーク",
        "ユニオンジャック - ライト",
        "ユニオンジャック - ダーク",
        "ブルームーン - ライト",
        "ブラッディメアリー - ダーク",
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if hasScrolled == false{
            tableView.contentOffset.y = (CGFloat((Int(UchicockStyle.no)!) + 1) * cellHeight) - (tableView.frame.height / 2)
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
        UchicockStyle.saveTheme(themeNo: String(themeNo))
        
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
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themeList.count
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeTheme(themeNo: indexPath.row, shouldScroll: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = themeList[indexPath.row]

        if String(indexPath.row) == UchicockStyle.no{
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
    @IBAction func shuffleButtonTapped(_ sender: UIBarButtonItem) {
        let alertView = CustomAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shuffleAction = UIAlertAction(title: "おまかせで選ぶ", style: .default){action in
            var themeNo = Int(UchicockStyle.no)!
            while themeNo == Int(UchicockStyle.no)!{
                themeNo = Int.random(in: 0 ..< self.themeList.count)
            }
            self.changeTheme(themeNo: themeNo, shouldScroll: true)
        }
        if #available(iOS 13.0, *){ shuffleAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(shuffleAction)
        let lightShuffleAction = UIAlertAction(title: "ライトテーマからおまかせ", style: .default){action in
            var themeNo = Int(UchicockStyle.no)!
            while themeNo == Int(UchicockStyle.no)!{
                themeNo = [0,2,4,6,8,9,11,13,15,17,20,22,24].randomElement()!
            }
            self.changeTheme(themeNo: themeNo, shouldScroll: true)
        }
        if #available(iOS 13.0, *){ lightShuffleAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(lightShuffleAction)
        let darkShuffleAction = UIAlertAction(title: "ダークテーマからおまかせ", style: .default){action in
            var themeNo = Int(UchicockStyle.no)!
            while themeNo == Int(UchicockStyle.no)!{
                themeNo = [1,3,5,7,10,12,14,16,18,19,21,23,25].randomElement()!
            }
            self.changeTheme(themeNo: themeNo, shouldScroll: true)
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
