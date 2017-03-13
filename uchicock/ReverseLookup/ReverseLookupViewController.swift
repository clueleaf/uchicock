//
//  ReverseLookupViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import DZNEmptyDataSet

class ReverseLookupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ingredientTableView: UITableView!
    var firstIngredientLabel = ""
    var secondIngredientLabel = ""
    var thirdIngredientLabel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientTableView.tag = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedPathForIngredientTableView = ingredientTableView.indexPathForSelectedRow
        
        // Userdefaultsからロードする
        firstIngredientLabel = ""
        secondIngredientLabel = ""
        thirdIngredientLabel = ""

        ingredientTableView.reloadData()

        if let path = selectedPathForIngredientTableView{
            ingredientTableView.selectRow(at: path, animated: false, scrollPosition: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.ingredientTableView.deselectRow(at: path, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 0{
            return 4
        }else if tableView.tag == 1{
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            switch indexPath.row{
            case 0,1,2:
                return 50
            case 3:
                return 30
            default:
                return 0
            }
        }else if tableView.tag == 1{
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            performSegue(withIdentifier: "PushSelectIngredient", sender: indexPath)
        }else if tableView.tag == 1{
//            performSegue(withIdentifier: "PushRecipeDetail", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView.tag == 0{
            let clear = UITableViewRowAction(style: .normal, title: "クリア") {
                (action, indexPath) in
                // 材料名をクリアする
            }
            clear.backgroundColor = Style.tableViewCellEditBackgroundColor
            return [clear]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0{
            if indexPath.row < 3{
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 0{
            if indexPath.row < 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReverseLookupIngredient") as! ReverseLookupTableViewCell
                if indexPath.row == 0{
                    cell.ingredientNumberLabel.text = "材料1："
                }else if indexPath.row == 1{
                    cell.ingredientNumberLabel.text = "材料2："
                }else if indexPath.row == 2{
                    cell.ingredientNumberLabel.text = "材料3："
                }
                cell.isUserInteractionEnabled = true
                return cell
            }else if indexPath.row == 3{
                let cell = UITableViewCell()
                cell.textLabel?.text = "材料名は完全一致で検索されます"
                cell.isUserInteractionEnabled = false
                return cell
            }
        }else if tableView.tag == 1{
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func clearButtonTapped(_ sender: Any) {
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushSelectIngredient" {
            let enc = segue.destination as! UINavigationController
            let evc = enc.visibleViewController as! ReverseLookupSelectIngredientViewController
            if let indexPath = sender as? IndexPath{
                evc.ingredientNumber = indexPath.row
            }
        }
    }
}
