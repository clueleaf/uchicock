//
//  ChangeImageSizeTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/10/06.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class ChangeImageSizeTableViewController: UITableViewController {

    @IBOutlet weak var sizeExplanationLabel: CustomLabel!
    let defaults = UserDefaults.standard
    
    let middleSizeExplanationText = "全てこのサイズで保存した場合に必要なおおよその容量：\n\n画像10枚で約25MB\n画像50枚で約125MB\n画像100枚で約250MB"
    let largeSizeExplanationText = "全てこのサイズで保存した場合に必要なおおよその容量：\n\n画像10枚で約100MB\n画像50枚で約500MB\n画像100枚で約1GB"
    let selectedCellBackgroundView = UIView()

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
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        selectedCellBackgroundView.backgroundColor = UchicockStyle.tableViewCellSelectedBackgroundColor
        setSizeExplanationText()
    }
    
    // MARK: - Logic functions
    private func setSizeExplanationText(){
        let saveImageSize = defaults.integer(forKey: GlobalConstants.SaveImageSizeKey)
        self.sizeExplanationLabel.text = saveImageSize == 1 ? largeSizeExplanationText : middleSizeExplanationText
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
        if indexPath.row == 0 || indexPath.row == 3 {
            return UITableView.automaticDimension
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let checkmark = UIImage(named: "accesory-checkmark")
        let accesoryImageView = UIImageView(image: checkmark)
        accesoryImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        accesoryImageView.tintColor = UchicockStyle.primaryColor
        if indexPath.row == 1{
            tableView.cellForRow(at:indexPath)?.accessoryView = accesoryImageView
            tableView.cellForRow(at:IndexPath(row: 2, section: 0))?.accessoryView = nil
            defaults.set(0, forKey: GlobalConstants.SaveImageSizeKey)
            setSizeExplanationText()
        }else if indexPath.row == 2{
            tableView.cellForRow(at:indexPath)?.accessoryView = accesoryImageView
            tableView.cellForRow(at:IndexPath(row: 1, section: 0))?.accessoryView = nil
            defaults.set(1, forKey: GlobalConstants.SaveImageSizeKey)
            setSizeExplanationText()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UchicockStyle.basicBackgroundColor

        switch indexPath.row{
        case 0:
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        case 1:
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.textLabel?.text = "中"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
            cell.textLabel?.textColor = UchicockStyle.labelTextColor
            cell.selectedBackgroundView = selectedCellBackgroundView

            if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 0{
                let checkmark = UIImage(named: "accesory-checkmark")
                let accesoryImageView = UIImageView(image: checkmark)
                accesoryImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                accesoryImageView.tintColor = UchicockStyle.primaryColor
                cell.accessoryView = accesoryImageView
            }else{
                cell.accessoryView = nil
            }
        case 2:
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.textLabel?.text = "大"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
            cell.textLabel?.textColor = UchicockStyle.labelTextColor
            cell.selectedBackgroundView = selectedCellBackgroundView

            if defaults.integer(forKey: GlobalConstants.SaveImageSizeKey) == 1{
                let checkmark = UIImage(named: "accesory-checkmark")
                let accesoryImageView = UIImageView(image: checkmark)
                accesoryImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                accesoryImageView.tintColor = UchicockStyle.primaryColor
                cell.accessoryView = accesoryImageView
            }else{
                cell.accessoryView = nil
            }
        case 3:
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        default: break
        }
        return cell
    }
}
