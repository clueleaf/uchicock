//
//  RecoverPreviewTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecoverPreviewTableViewController: UITableViewController {

    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var method: UISegmentedControl!
    
    var recipe = Recipe()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RecoverPreviewIngredientTableViewCell.self, forCellReuseIdentifier: "RecoverPreviewIngredient")
        self.navigationItem.title = "プレビュー"

        recipeName.text = recipe.recipeName
        if recipe.method >= 0 && recipe.method < 5 {
            method.selectedSegmentIndex = recipe.method
        } else {
            method.selectedSegmentIndex = 4
        }

        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recipeName.textColor = Style.labelTextColor
        
        self.tableView.backgroundColor = Style.basicBackgroundColor
        method.tintColor = Style.secondaryColor
        method.backgroundColor = Style.basicBackgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                return UITableViewAutomaticDimension
            }else{
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }else if indexPath.section == 1{
            return super.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 1))
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "材料(" + String(recipe.recipeIngredients.count) + ")"
        }else{
            return nil
        }
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
            cell.backgroundColor = Style.basicBackgroundColor
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
            cell.option.textColor = Style.labelTextColor
            cell.option.layer.cornerRadius = 4
            cell.option.clipsToBounds = true
            cell.option.textAlignment = NSTextAlignment.center
            
            cell.ingredientName.textColor = Style.labelTextColor
            cell.amount.textColor = Style.labelTextColor
            cell.amount.text = recipe.recipeIngredients[indexPath.row].amount
            cell.selectionStyle = .none
            cell.backgroundColor = Style.basicBackgroundColor
            return cell
        default:
            return UITableViewCell()
        }
    }
}
