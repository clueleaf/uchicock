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

    @IBOutlet weak var doneButton: UIBarButtonItem!
    var oldThemeNo = Style.no
    var newThemeNo = Style.no
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ChangeThemeTableViewController.cancelButtonTapped))
        cancelButton.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
        navigationItem.leftBarButtonItem = cancelButton
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ChangeThemeTableViewController.doneButtonTapped))
        doneButton.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
        navigationItem.rightBarButtonItem = doneButton
        
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
        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            Style.tequilaSunriseLight()
        case 1:
            Style.tequilaSunriseDark()
        case 2:
            Style.seaBreezeLight()
        case 3:
            Style.seaBreezeDark()
        case 4:
            Style.chinaBlueLight()
        case 5:
            Style.chinaBlueDark()
        case 6:
            Style.grasshopperLight()
        case 7:
            Style.irishCoffeeDark()
        default: break
        }
        newThemeNo = Style.no
        
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .checkmark
        }
        UIButton.appearance().tintColor = Style.secondaryColor

        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ContrastColorOf(Style.primaryColor, returnFlat: true)]
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
        switch indexPath.row{
        case 0:
            cell.textLabel?.text = "テキーラサンライズ - ライト"
        case 1:
            cell.textLabel?.text = "テキーラサンライズ - ダーク"
        case 2:
            cell.textLabel?.text = "シーブリーズ - ライト"
        case 3:
            cell.textLabel?.text = "シーブリーズ - ダーク"
        case 4:
            cell.textLabel?.text = "チャイナブルー - ライト"
        case 5:
            cell.textLabel?.text = "チャイナブルー - ダーク"
        case 6:
            cell.textLabel?.text = "グラスホッパー - ライト"
        case 7:
            cell.textLabel?.text = "アイリッシュコーヒー - ダーク"
        default: break
        }

        if indexPath.row == Style.no{
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
    func cancelButtonTapped() {
        switch oldThemeNo{
        case 0:
            Style.tequilaSunriseLight()
        case 1:
            Style.tequilaSunriseDark()
        case 2:
            Style.seaBreezeLight()
        case 3:
            Style.seaBreezeDark()
        case 4:
            Style.chinaBlueLight()
        case 5:
            Style.chinaBlueDark()
        case 6:
            Style.grasshopperLight()
        case 7:
            Style.irishCoffeeDark()
        default: break
        }
        UIButton.appearance().tintColor = Style.secondaryColor

        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonTapped() {
        Style.saveTheme(themeNo: String(newThemeNo))
        self.dismiss(animated: true, completion: nil)
    }
}
