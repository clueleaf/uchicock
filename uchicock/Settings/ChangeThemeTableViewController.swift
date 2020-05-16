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
    var animationFlag = false
    var oldTableBackgroundColor: UIColor = UchicockStyle.basicBackgroundColor
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
            if tableView.contentOffset.y < 0 {
                tableView.contentOffset.y = 0
            }
            let maximumOffset = max(-tableView.contentInset.top, tableView.contentSize.height - tableView.bounds.size.height + tableView.contentInset.bottom)
            if tableView.contentOffset.y > maximumOffset{
                tableView.contentOffset.y = maximumOffset
            }
            tableView.reloadData()
            hasScrolled = true
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
        oldTableBackgroundColor = UchicockStyle.basicBackgroundColor
        
        UchicockStyle.setTheme(themeNo: String(indexPath.row))
        UchicockStyle.saveTheme(themeNo: String(indexPath.row))
        
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .checkmark
        }
        if UchicockStyle.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }
        
        animationFlag = true
        UIView.animate(withDuration: animationDuration, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
            self.tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        }, completion: nil)

        UIView.transition(with: self.navigationController!.navigationBar, duration: animationDuration, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            self.navigationController?.navigationBar.tintColor = FlatColor.contrastColorOf(UchicockStyle.navigationBarColor, isFlat: false)
            self.navigationController?.navigationBar.barTintColor = UchicockStyle.navigationBarColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatColor.contrastColorOf(UchicockStyle.navigationBarColor, isFlat: true)]
        }, completion: nil)
        
        UIView.transition(with: self.tabBarController!.tabBar, duration: animationDuration, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            self.tabBarController?.tabBar.tintColor = UchicockStyle.tabBarTintColor
            self.tabBarController?.tabBar.barTintColor = UchicockStyle.tabBarBarTintColor
            self.tabBarController?.tabBar.unselectedItemTintColor = UchicockStyle.tabBarUnselectedItemTintColor
            self.tabBarController?.tabBar.items?[1].badgeColor = UchicockStyle.badgeBackgroundColor
            self.tabBarController?.tabBar.items?[4].badgeColor = UchicockStyle.badgeBackgroundColor
        }, completion: { _ in
            self.animationFlag = false
        })
        
        tableView.reloadData()
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
        
        cell.tintColor = UchicockStyle.labelTextColor
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if animationFlag{
            cell.backgroundColor = oldTableBackgroundColor
            UIView.animate(withDuration: animationDuration, animations: {
                cell.backgroundColor = UchicockStyle.basicBackgroundColor
            }, completion: nil)
        }else{
            cell.backgroundColor = UchicockStyle.basicBackgroundColor
        }

        return cell
    }
}
