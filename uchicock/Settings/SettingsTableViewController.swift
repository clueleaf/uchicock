//
//  SettingsTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            tableView.deselectRow(at: indexPath, animated: true)
//            performSegue(withIdentifier: "PushEditIngredient", sender: indexPath)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = Style.basicBackgroundColor
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
/*        if segue.identifier == "PushEditIngredient" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! RecipeIngredientEditTableViewController
            if let indexPath = sender as? IndexPath{
                if indexPath.row < editingRecipeIngredientList.count{
                    if self.editingRecipeIngredientList[indexPath.row].id == ""{
                        self.editingRecipeIngredientList[indexPath.row].id = NSUUID().uuidString
                    }
                    evc.recipeIngredient = self.editingRecipeIngredientList[indexPath.row]
                    evc.isAddMode = false
                }else if indexPath.row == editingRecipeIngredientList.count{
                    evc.isAddMode = true
                }
            }
        }*/
    }

}
