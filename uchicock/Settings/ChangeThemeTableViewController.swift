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
    var oldTableBackgroundColor: UIColor = Style.basicBackgroundColor
    let cellHeight: CGFloat = 44

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
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
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = UIColor.gray
        tableView.tableFooterView = UIView(frame: CGRect.zero)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.tableView.backgroundColor = Style.basicBackgroundColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if hasScrolled == false{
            tableView.contentOffset.y = (CGFloat((Int(Style.no)!) + 1) * cellHeight) - (tableView.frame.height / 2)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        oldTableBackgroundColor = Style.basicBackgroundColor
        
        Style.setTheme(themeNo: String(indexPath.row))
        Style.saveTheme(themeNo: String(indexPath.row))
        
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .checkmark
        }
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }
        
        animationFlag = true
        UIView.animate(withDuration: animationDuration, animations: {
            self.navigationController?.loadView()
            self.setNeedsStatusBarAppearanceUpdate()
            self.tableView.backgroundColor = Style.basicBackgroundColor
        }, completion: nil)

        UIView.transition(with: self.navigationController!.navigationBar, duration: animationDuration, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            self.navigationController?.navigationBar.barTintColor = Style.navigationBarColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatColor.contrastColorOf(Style.navigationBarColor, isFlat: true)]
        }, completion: nil)
        
        UIView.transition(with: self.tabBarController!.tabBar, duration: animationDuration, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            self.tabBarController?.tabBar.tintColor = Style.tabBarTintColor
            self.tabBarController?.tabBar.barTintColor = Style.tabBarBarTintColor
            self.tabBarController?.tabBar.unselectedItemTintColor = Style.tabBarUnselectedItemTintColor
        }, completion: { _ in
            self.animationFlag = false
        })
        
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = themeList[indexPath.row]

        if String(indexPath.row) == Style.no{
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = Style.primaryColor
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        }else{
            cell.accessoryType = .none
            cell.textLabel?.textColor = Style.labelTextColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }
        
        cell.tintColor = Style.labelTextColor
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if animationFlag{
            cell.backgroundColor = oldTableBackgroundColor
            UIView.animate(withDuration: animationDuration, animations: {
                cell.backgroundColor = Style.basicBackgroundColor
            }, completion: nil)
        }else{
            cell.backgroundColor = Style.basicBackgroundColor
        }

        return cell
    }
    
}
