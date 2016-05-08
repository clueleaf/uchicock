//
//  ReminderTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/19.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import EventKit
import ChameleonFramework
import SVProgressHUD
import M13Checkbox

class ReminderTableViewController: UITableViewController{

    @IBOutlet weak var reminderTitle: UILabel!
    @IBOutlet weak var reminderType: UISegmentedControl!
    @IBOutlet weak var dateFlag: M13Checkbox!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var ingredientName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "リマインダーへ登録"
        reminderTitle.text = ingredientName + "を買う"
        dateFlag.setCheckState(.Unchecked, animated: true)
        dateFlag.backgroundColor = UIColor.clearColor()
        dateFlag.tintColor = FlatSkyBlueDark()
        dateFlag.secondaryTintColor = FlatGray()
        dateFlag.boxLineWidth = 1.0
        dateFlag.markType = .Checkmark
        dateFlag.boxType = .Circle
        dateFlag.stateChangeAnimation = .Expand(.Fill)
        
        datePicker.datePickerMode = .DateAndTime
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP")
        datePicker.setDate(NSDate(timeInterval: 60*60, sinceDate: NSDate()), animated: true)
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createReminder(eventStore: EKEventStore, title: String) {
        let reminder = EKReminder(eventStore: eventStore)
        
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        if dateFlag.checkState == .Checked {
            let calendarUnit: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
            reminder.dueDateComponents = NSCalendar.currentCalendar().components(calendarUnit, fromDate: datePicker.date)
            reminder.addAlarm(EKAlarm(absoluteDate: datePicker.date))
        }
        
        do {
            try eventStore.saveReminder(reminder, commit: true)
            SVProgressHUD.showSuccessWithStatus("リマインダーへ登録しました")
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            let alertView = UIAlertController(title: "リマインダーへの登録に失敗しました", message: "「設定」→「うちカク！」にてリマインダーへのアクセス許可を確認してください", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            }))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(absoluteDate: startDate))
        
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            SVProgressHUD.showSuccessWithStatus("カレンダーへ登録しました")
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            let alertView = UIAlertController(title: "カレンダーへの登録に失敗しました", message: "「設定」→「うちカク！」にてカレンダーへのアクセス許可を確認してください", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            }))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }

    // MARK: - UITableView
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UITableViewAutomaticDimension
        }else{
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dateFlag.checkState == .Checked{
            return 4
        }else{
            return 3
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.backgroundColor = FlatWhite()
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        let eventStore = EKEventStore()
        
        if reminderType.selectedSegmentIndex == 0{
            if (EKEventStore.authorizationStatusForEntityType(.Reminder) != EKAuthorizationStatus.Authorized) {
                eventStore.requestAccessToEntityType(.Reminder, completion: {
                    granted, error in
                    self.createReminder(eventStore, title: self.reminderTitle.text!)
                })
            } else {
                createReminder(eventStore, title: reminderTitle.text!)
            }
        }else if reminderType.selectedSegmentIndex == 1{
            let startDate = datePicker.date
            let endDate = datePicker.date
            if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
                eventStore.requestAccessToEntityType(.Event, completion: {
                    granted, error in
                    self.createEvent(eventStore, title: self.reminderTitle.text!, startDate: startDate, endDate: endDate)
                })
            } else {
                createEvent(eventStore, title: reminderTitle.text!, startDate: startDate, endDate: endDate)
            }
        }
    }

    @IBAction func reminderTypeTapped(sender: UISegmentedControl) {
        if reminderType.selectedSegmentIndex == 0{
            dateFlag.enabled = true
            dateFlag.tintColor = FlatSkyBlueDark()
        }else if reminderType.selectedSegmentIndex == 1{
            if dateFlag.checkState == .Unchecked{
                dateFlag.setCheckState(.Checked, animated: true)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 3,inSection: 0)], withRowAnimation: .Middle)
            }
            dateFlag.enabled = false
            dateFlag.tintColor = FlatWhiteDark()
        }
    }
    
    @IBAction func dateFlagTapped(sender: M13Checkbox) {
        if dateFlag.checkState == .Checked{
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 3,inSection: 0)], withRowAnimation: .Middle)
        }else{
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 3,inSection: 0)], withRowAnimation: .Middle)
        }
    }
    
}
