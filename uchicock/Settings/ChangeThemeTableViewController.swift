//
//  ChangeThemeTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class ChangeThemeTableViewController: UITableViewController {

    var oldThemeNo = Style.no
    var newThemeNo = Style.no
    var hasScrolled = false
    var animationFlag = false
    var oldTableBackgroundColor: UIColor = Style.basicBackgroundColor
    var newTableBackgroundColor: UIColor = Style.basicBackgroundColor

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
        
        var safeAreaBottom: CGFloat = 0.0
        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.tableView.backgroundColor = Style.basicBackgroundColor

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ChangeThemeTableViewController.cancelButtonTapped))
        cancelButton.tintColor = FlatColor.contrastColorOf(Style.navigationBarColor, isFlat: true)
        navigationItem.leftBarButtonItem = cancelButton

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ChangeThemeTableViewController.saveButtonTapped))
        saveButton.tintColor = FlatColor.contrastColorOf(Style.navigationBarColor, isFlat: true)
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasScrolled == false{
            let indexPath = IndexPath(item: Int(Style.no)!, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            hasScrolled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Style.setTheme(themeNo: oldThemeNo)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themeList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        oldTableBackgroundColor = newTableBackgroundColor
        
        Style.setTheme(themeNo: String(indexPath.row))
        newThemeNo = Style.no
        
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .checkmark
        }
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatColor.contrastColorOf(Style.navigationBarColor, isFlat: true)]

        animationFlag = true
        UIView.animate(withDuration: 0.4, animations: {
            self.navigationController?.navigationBar.barTintColor = Style.navigationBarColor
            self.navigationController?.loadView()
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
        
        UIView.transition(with: self.tabBarController!.tabBar, duration: 0.4, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: {
            self.tabBarController?.tabBar.tintColor = Style.tabBarTintColor
            self.tabBarController?.tabBar.barTintColor = Style.tabBarBarTintColor
            self.tabBarController?.tabBar.unselectedItemTintColor = Style.tabBarUnselectedItemTintColor
        }, completion: { _ in
            self.animationFlag = false
        })
        
        tableView.reloadData()
        newTableBackgroundColor = Style.basicBackgroundColor
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .none
        }
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
            UIView.animate(withDuration: 0.4, animations: {
                cell.backgroundColor = Style.basicBackgroundColor
            }, completion: nil)
        }else{
            cell.backgroundColor = Style.basicBackgroundColor
        }

        return cell
    }
    
    // MARK: IBAction
    @objc func cancelButtonTapped() {
        Style.setTheme(themeNo: oldThemeNo)
        self.dismiss(animated: true, completion: nil)
    }

    @objc func saveButtonTapped() {
        Style.saveTheme(themeNo: newThemeNo)
        oldThemeNo = newThemeNo
        Style.setTheme(themeNo: oldThemeNo)
        ProgressHUD.showSuccess(with: "テーマカラーを変更しました", duration: 1.5)

        self.dismiss(animated: true, completion: nil)
    }
}
