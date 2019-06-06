//
//  RecoverPreviewTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecoverPreviewTableViewController: UITableViewController {

    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var method: UILabel!
    
    var recipe = Recipe()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RecoverPreviewIngredientTableViewCell.self, forCellReuseIdentifier: "RecoverPreviewIngredient")
        self.navigationItem.title = "プレビュー"

        recipeName.text = recipe.recipeName
        switch recipe.method{
        case 0:
            method.text = "ビルド"
        case 1:
            method.text = "ステア"
        case 2:
            method.text = "シェイク"
        case 3:
            method.text = "ブレンド"
        case 4:
            method.text = "その他"
        default:
            method.text = "その他"
        }

        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        var safeAreaBottom: CGFloat = 0.0
        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recipeName.textColor = Style.labelTextColor
        methodLabel.textColor = Style.labelTextColor
        
        method.textColor = Style.labelTextColor
        if Style.isBackgroundDark{
            self.tableView.indicatorStyle = .white
        }else{
            self.tableView.indicatorStyle = .black
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }

    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.backgroundColor = Style.tableViewHeaderBackgroundColor
        label.textColor = Style.labelTextColorOnDisableBadge
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if section == 1 {
            label.text = "  材料(" + String(recipe.recipeIngredients.count) + ")"
        }else{
            label.text = nil
        }
        return label
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                return UITableView.automaticDimension
            }else{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }else if indexPath.section == 1{
            return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            return recipe.recipeIngredients.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }else if indexPath.section == 1{
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 1))
        }
        return 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecoverPreviewIngredient", for: indexPath) as! RecoverPreviewIngredientTableViewCell
            cell.ingredientName.text = recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            if recipe.recipeIngredients[indexPath.row].mustFlag{
                cell.option.text = ""
                cell.option.backgroundColor = UIColor.clear
            }else{
                cell.option.text = "オプション"
                cell.option.backgroundColor = Style.badgeDisableBackgroundColor
            }
            cell.option.textColor = Style.labelTextColorOnDisableBadge
            cell.option.layer.cornerRadius = 4
            cell.option.clipsToBounds = true
            cell.option.textAlignment = NSTextAlignment.center
            
            cell.ingredientName.textColor = Style.labelTextColor
            cell.amount.textColor = Style.labelTextColor
            cell.amount.text = recipe.recipeIngredients[indexPath.row].amount
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}
