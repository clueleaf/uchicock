//
//  ChangeThemeTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class ChangeThemeTableViewController: UITableViewController {

    var oldThemeNo = Style.no
    var newThemeNo = Style.no
    
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
        "アメリカンレモネード - ダーク"
         ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ChangeThemeTableViewController.cancelButtonTapped))
        cancelButton.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
        navigationItem.leftBarButtonItem = cancelButton
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ChangeThemeTableViewController.saveButtonTapped))
        saveButton.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
        navigationItem.rightBarButtonItem = saveButton
        
        self.tableView.backgroundColor = Style.basicBackgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        UIButton.appearance().tintColor = Style.secondaryColor

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(Style.primaryColor, returnFlat: true)]
        navigationController?.navigationBar.barTintColor = Style.primaryColor        
        navigationController?.loadView()
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
        }else{
            cell.accessoryType = .none
        }
        
        cell.backgroundColor = Style.basicBackgroundColor
        cell.textLabel?.textColor = Style.labelTextColor
        cell.tintColor = Style.labelTextColor
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    // MARK: IBAction
    @objc func cancelButtonTapped() {
        Style.setTheme(themeNo: oldThemeNo)
        UIButton.appearance().tintColor = Style.secondaryColor

        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        Style.saveTheme(themeNo: newThemeNo)
        self.dismiss(animated: true, completion: nil)
    }
}
