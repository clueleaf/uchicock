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

        tableView.registerClass(RecoverPreviewIngredientTableViewCell.self, forCellReuseIdentifier: "RecoverPreviewIngredient")
        self.navigationItem.title = "プレビュー"

        recipeName.text = recipe.recipeName
        if recipe.method >= 0 && recipe.method < 5 {
            method.selectedSegmentIndex = recipe.method
        } else {
            method.selectedSegmentIndex = 4
        }

        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableView
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        } else {
            return 30
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                return UITableViewAutomaticDimension
            }else{
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            }
        }else if indexPath.section == 1{
            return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "材料(" + String(recipe.recipeIngredients.count) + ")"
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            return recipe.recipeIngredients.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 0 {
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
        }else if indexPath.section == 1{
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        }
        return 0
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.backgroundColor = FlatWhite()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("RecoverPreviewIngredient", forIndexPath: indexPath) as! RecoverPreviewIngredientTableViewCell
            cell.ingredientName.text = recipe.recipeIngredients[indexPath.row].ingredient.ingredientName
            if recipe.recipeIngredients[indexPath.row].mustFlag{
                cell.option.text = ""
                cell.option.backgroundColor = UIColor.clearColor()
            }else{
                cell.option.text = "オプション"
                cell.option.backgroundColor = FlatWhiteDark()
            }
            cell.option.textColor = FlatBlack()
            cell.option.layer.cornerRadius = 4
            cell.option.clipsToBounds = true
            cell.option.textAlignment = NSTextAlignment.Center
            
            cell.ingredientName.textColor = FlatBlack()
            cell.amount.textColor = FlatBlack()
            cell.amount.text = recipe.recipeIngredients[indexPath.row].amount
            cell.selectionStyle = .None
            cell.backgroundColor = FlatWhite()
            return cell
        default:
            return UITableViewCell()
        }
    }
}
