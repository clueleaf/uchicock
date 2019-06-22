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
         ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        var safeAreaBottom: CGFloat = 0.0
        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ChangeThemeTableViewController.cancelButtonTapped))
        cancelButton.tintColor = FlatColor.contrastColorOf(Style.primaryColor, isFlat: true)
        navigationItem.leftBarButtonItem = cancelButton
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ChangeThemeTableViewController.saveButtonTapped))
        saveButton.tintColor = FlatColor.contrastColorOf(Style.primaryColor, isFlat: true)
        self.tableView.backgroundColor = Style.basicBackgroundColor
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

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatColor.contrastColorOf(Style.primaryColor, isFlat: true)]
        navigationController?.navigationBar.barTintColor = Style.primaryColor        
        navigationController?.loadView()
        self.setNeedsStatusBarAppearanceUpdate()
        tableView.reloadData()
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
            cell.textLabel?.textColor = Style.secondaryColor
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        }else{
            cell.accessoryType = .none
            cell.textLabel?.textColor = Style.labelTextColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }
        
        cell.tintColor = Style.labelTextColor
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = Style.basicBackgroundColor
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
        SVProgressHUD.showSuccess(withStatus: "テーマカラーを変更しました")

        self.dismiss(animated: true, completion: nil)
    }
}
