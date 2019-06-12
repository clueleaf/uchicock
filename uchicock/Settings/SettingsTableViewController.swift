//
//  SettingsTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var introductionImage: UIImageView!
    @IBOutlet weak var recoverImage: UIImageView!
    @IBOutlet weak var changeThemeImage: UIImageView!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var recoverLabel: UILabel!
    @IBOutlet weak var changeThemeLabel: UILabel!
    
    let selectedCellBackgroundView = UIView()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        introductionImage.image = introductionImage.image!.withRenderingMode(.alwaysTemplate)
        recoverImage.image = recoverImage.image!.withRenderingMode(.alwaysTemplate)
        changeThemeImage.image = changeThemeImage.image!.withRenderingMode(.alwaysTemplate)

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        introductionImage.tintColor = Style.secondaryColor
        recoverImage.tintColor = Style.secondaryColor
        changeThemeImage.tintColor = Style.secondaryColor
        introductionLabel.textColor = Style.labelTextColor
        recoverLabel.textColor = Style.labelTextColor
        changeThemeLabel.textColor = Style.labelTextColor
        selectedCellBackgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        tableView.backgroundColor = Style.basicBackgroundColor

        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            performSegue(withIdentifier: "usage", sender: indexPath)
        case 1:
            performSegue(withIdentifier: "PushRecoverRecipe", sender: indexPath)
        case 2:
            performSegue(withIdentifier: "ChangeTheme", sender: indexPath)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectedBackgroundView = selectedCellBackgroundView
        cell.backgroundColor = Style.basicBackgroundColor
        return cell
    }

}
