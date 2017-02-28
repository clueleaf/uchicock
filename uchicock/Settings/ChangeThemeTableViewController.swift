//
//  ChangeThemeTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class ChangeThemeTableViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ChangeThemeTableViewController.cancelButtonTapped))
        cancelButton.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
        navigationItem.leftBarButtonItem = cancelButton
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ChangeThemeTableViewController.doneButtonTapped))
        doneButton.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
        navigationItem.rightBarButtonItem = doneButton
        
        self.tableView.backgroundColor = Style.basicBackgroundColor

        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .checkmark
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .checkmark
        }
        switch indexPath.row{
        case 0:
            Style.tequilaSunriseLight()
        case 1:
            Style.tequilaSunriseDark()
        case 2: break
        case 3: break
        default: break
        }
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: ContrastColorOf(Style.primaryColor, returnFlat: true)]
        navigationController?.navigationBar.barTintColor = Style.primaryColor        
        navigationController?.loadView()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at:indexPath) {
            cell.accessoryType = .none
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = Style.basicBackgroundColor
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    // MARK: IBAction
    func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
