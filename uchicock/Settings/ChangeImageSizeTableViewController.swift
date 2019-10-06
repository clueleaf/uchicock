//
//  ChangeImageSizeTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/10/06.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class ChangeImageSizeTableViewController: UITableViewController {

    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var sizeExplanationLabel: UILabel!
    let defaults = UserDefaults.standard
    
    let middleSizeExplanationText = "全てこのサイズで保存した場合に必要なおおよその容量：\n画像10枚で約25MB\n画像50枚で約125MB\n画像100枚で約250MB"
    let largeSizeExplanationText = "全てこのサイズで保存した場合に必要なおおよその容量：\n画像10枚で約100MB\n画像50枚で約500MB\n画像100枚で約1GB"

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = UIColor.gray
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        setSizeExplanationText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension

        explanationLabel.textColor = Style.labelTextColor
        sizeExplanationLabel.textColor = Style.labelTextColor
    }
    
    func setSizeExplanationText(){
        let saveImageSize = defaults.integer(forKey: GlobalConstants.SaveImageSizeKey)
        if saveImageSize == 0{
            self.sizeExplanationLabel.text = middleSizeExplanationText
        }else if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
            self.sizeExplanationLabel.text = largeSizeExplanationText
        }
    }

    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }else if indexPath.row == 3{
            return UITableView.automaticDimension
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            let cell = tableView.cellForRow(at:indexPath)
            cell?.accessoryType = .checkmark
            defaults.set(0, forKey: GlobalConstants.SaveImageSizeKey)
            setSizeExplanationText()
            tableView.reloadData()
        }else if indexPath.row == 2{
            let cell = tableView.cellForRow(at:indexPath)
            cell?.accessoryType = .checkmark
            defaults.set(1, forKey: GlobalConstants.SaveImageSizeKey)
            setSizeExplanationText()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.tintColor = Style.labelTextColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case 1:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.textLabel?.text = "中"
            cell.textLabel?.textColor = Style.labelTextColor

            if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 0{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            return cell
        case 2:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.textLabel?.text = "大"
            cell.textLabel?.textColor = Style.labelTextColor

            if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            return cell
        case 3:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = Style.basicBackgroundColor
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.tintColor = Style.labelTextColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        default:
            return UITableViewCell()
        }
    }

}
