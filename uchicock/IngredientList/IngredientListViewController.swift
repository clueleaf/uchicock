//
//  IngredientListViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/18.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class IngredientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var stockState: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var ingredientList: Results<Ingredient>?
    var token = NotificationToken()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControlContainer.backgroundColor = FlatSand()
        getTextFieldFromView(searchBar)?.enablesReturnKeyAutomatically = false

        let realm = try! Realm()
        token = realm.objects(Ingredient).addNotificationBlock { results, realm in
            if self.stockState.selectedSegmentIndex != 0 {
                self.reloadIngredientList()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        reloadIngredientList()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTextFieldFromView(view: UIView) -> UITextField?{
        for subview in view.subviews{
            if subview.isKindOfClass(UITextField){
                return subview as? UITextField
            }else{
                let textField = self.getTextFieldFromView(subview)
                if textField != nil{
                    return textField
                }
            }
        }
        return nil
    }
    
    func searchBarTextWithoutSpace() -> String {
        return searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func reloadIngredientList(){
        let realm = try! Realm()
        switch stockState.selectedSegmentIndex{
        case 0:
            ingredientList = realm.objects(Ingredient).filter("ingredientName contains %@", searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())).sorted("ingredientName")
        case 1:
            ingredientList = realm.objects(Ingredient).filter("ingredientName contains %@ and stockFlag == true", searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())).sorted("ingredientName")
        case 2:
            ingredientList = realm.objects(Ingredient).filter("ingredientName contains %@ and stockFlag == false", searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())).sorted("ingredientName")
        default:
            ingredientList = realm.objects(Ingredient).filter("ingredientName contains %@", searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())).sorted("ingredientName")
        }
        self.navigationItem.title = "材料(" + String(ingredientList!.count) + ")"
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadIngredientList()
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableView
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let realm = try! Realm()
            switch stockState.selectedSegmentIndex{
            case 0:
                return realm.objects(Ingredient).filter("ingredientName contains %@", searchBarTextWithoutSpace()).count
            case 1:
                return realm.objects(Ingredient).filter("ingredientName contains %@ and stockFlag == true", searchBarTextWithoutSpace()).count
            case 2:
                return realm.objects(Ingredient).filter("ingredientName contains %@ and stockFlag == false", searchBarTextWithoutSpace()).count
            default:
                return realm.objects(Ingredient).filter("ingredientName contains %@", searchBarTextWithoutSpace()).count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushIngredientDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            if ingredientList![indexPath.row].recipeIngredients.count > 0 {
                let alertView = UIAlertController(title: "", message: "この材料を使っているレシピがあるため、削除できません", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in}))
                presentViewController(alertView, animated: true, completion: nil)
            } else{
                let realm = try! Realm()
                let ingredient = ingredientList![indexPath.row]
                try! realm.write {
                    realm.delete(ingredient)
                }
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IngredientListItem") as! IngredientListItemTableViewCell
            cell.ingredient = ingredientList![indexPath.row]
            cell.backgroundColor = FlatWhite()
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier("PushAddIngredient", sender: UIBarButtonItem())
    }
    
    @IBAction func stockStateTapped(sender: UISegmentedControl) {
        reloadIngredientList()
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushIngredientDetail" {
            let vc = segue.destinationViewController as! IngredientDetailTableViewController
            if let indexPath = sender as? NSIndexPath{
                vc.ingredientId = ingredientList![indexPath.row].id
            }
        } else if segue.identifier == "PushAddIngredient" {
        }
    }
}
