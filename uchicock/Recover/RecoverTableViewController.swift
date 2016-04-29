//
//  RecoverTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/30.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework
import M13Checkbox

class RecoverTableViewController: UITableViewController {

    @IBOutlet weak var recoverTarget: M13Checkbox!
    @IBOutlet weak var nonRecoverTarget: M13Checkbox!
    @IBOutlet weak var unableRecover: M13Checkbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recoverTarget.stateChangeAnimation = .Expand(.Fill)
        recoverTarget.enabled = false
        recoverTarget.setCheckState(.Checked, animated: true)
        recoverTarget.backgroundColor = UIColor.clearColor()
        recoverTarget.tintColor = FlatSkyBlueDark()
        recoverTarget.boxLineWidth = 1.0
        recoverTarget.markType = .Checkmark
        recoverTarget.boxType = .Circle
        
        nonRecoverTarget.stateChangeAnimation = .Expand(.Fill)
        nonRecoverTarget.enabled = false
        nonRecoverTarget.setCheckState(.Unchecked, animated: true)
        nonRecoverTarget.backgroundColor = UIColor.clearColor()
        nonRecoverTarget.tintColor = FlatSkyBlueDark()
        nonRecoverTarget.boxLineWidth = 1.0
        nonRecoverTarget.markType = .Checkmark
        nonRecoverTarget.boxType = .Circle

        unableRecover.stateChangeAnimation = .Expand(.Fill)
        unableRecover.enabled = false
        unableRecover.setCheckState(.Mixed, animated: true)
        unableRecover.backgroundColor = UIColor.clearColor()
        unableRecover.tintColor = FlatWhiteDark()
        unableRecover.boxLineWidth = 1.0
        unableRecover.markType = .Checkmark
        unableRecover.boxType = .Circle

        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 30
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "復元したいレシピを選んでください"
        }else{
            return nil
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
            return cell
        case 1:
            let cell = super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
            return cell
        default:
            return UITableViewCell()
        }
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func recoverButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
