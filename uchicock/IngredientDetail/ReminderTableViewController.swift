//
//  ReminderTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/19.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import EventKit

class ReminderTableViewController: UITableViewController {

    @IBOutlet weak var reminderTitle: UILabel!
    @IBOutlet weak var reminderType: UISegmentedControl!
    @IBOutlet weak var dateFlag: UISwitch!
    @IBOutlet weak var date: UITextField!
    
    var ingredientName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "リマインダーへ登録"
        reminderTitle.text = ingredientName + "を買う"
        dateFlag.on = false
        date.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createReminder(eventStore: EKEventStore, title: String) {
        let reminder = EKReminder(eventStore: eventStore)
        
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        do {
            try eventStore.saveReminder(reminder, commit: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            let favoriteAlertView = UIAlertController(title: "リマインダーへの保存に失敗しました", message: "「設定」→「うちカク！」にてリマインダーへのアクセス許可を確認してください", preferredStyle: .Alert)
            favoriteAlertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            }))
            self.presentViewController(favoriteAlertView, animated: true, completion: nil)
        }
    }

    // MARK: - UITableView
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        let eventStore = EKEventStore()
        if (EKEventStore.authorizationStatusForEntityType(.Reminder) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Reminder, completion: {
                granted, error in
                self.createReminder(eventStore, title: self.reminderTitle.text!)
            })
        } else {
            createReminder(eventStore, title: reminderTitle.text!)
        }
    }

    @IBAction func reminderTypeTapped(sender: UISegmentedControl) {
        if reminderType.selectedSegmentIndex == 0{
            dateFlag.enabled = true
        }else if reminderType.selectedSegmentIndex == 1{
            dateFlag.on = true
            dateFlag.enabled = false
        }
    }
    
    @IBAction func dateFlagTapped(sender: UISwitch) {
        if dateFlag.on{
            date.enabled = true
        }else{
            date.enabled = false
        }
    }
    
}
