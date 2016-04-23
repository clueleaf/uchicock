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
import SCLAlertView

class ReminderTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var reminderTitle: UILabel!
    @IBOutlet weak var reminderType: UISegmentedControl!
    @IBOutlet weak var dateFlag: UISwitch!
    @IBOutlet weak var date: UITextField!
    
    var ingredientName = ""
    var registerDate = NSDate(timeInterval: 60*60, sinceDate: NSDate())
    let dateFormat = NSDateFormatter()
    let datePicker = UIDatePicker()
    let cal: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "リマインダーへ登録"
        reminderTitle.text = ingredientName + "を買う"
        dateFlag.on = false
        date.enabled = false
        
        dateFormat.locale = NSLocale(localeIdentifier: "ja")
        
        datePicker.datePickerMode = .DateAndTime
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP")
        datePicker.setDate(registerDate, animated: true)
        date.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = .BlackTranslucent
        let spaceBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: self, action: nil)
        let toolBarButton = UIBarButtonItem(title: "完了", style: .Done, target: self, action: #selector(ReminderTableViewController.toolBarButtonPush(_:)))
        toolBar.items = [spaceBarButton,toolBarButton]
        date.inputAccessoryView = toolBar

        setTextField()
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createReminder(eventStore: EKEventStore, title: String) {
        let reminder = EKReminder(eventStore: eventStore)
        
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        if dateFlag.on {
            let calendarUnit: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
            reminder.dueDateComponents = NSCalendar.currentCalendar().components(calendarUnit, fromDate: registerDate)
            reminder.addAlarm(EKAlarm(absoluteDate: registerDate))
        }
        
        do {
            try eventStore.saveReminder(reminder, commit: true)
            let alertView = SCLAlertView()
            alertView.showCloseButton = false
            alertView.showSuccess("", subTitle: "リマインダーへ登録しました", colorStyle: 0x3498DB, duration: 2.0)
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
            let alertView = SCLAlertView()
            alertView.showCloseButton = false
            alertView.showSuccess("", subTitle: "カレンダーへ登録しました", colorStyle: 0x3498DB, duration: 2.0)
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            let alertView = UIAlertController(title: "カレンダーへの登録に失敗しました", message: "「設定」→「うちカク！」にてカレンダーへのアクセス許可を確認してください", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            }))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }

    func toolBarButtonPush(sender: UIBarButtonItem){
        registerDate = datePicker.date

        let comp: NSDateComponents = cal.components([NSCalendarUnit.Weekday], fromDate: registerDate)
        let weekdaySymbolIndex: Int = comp.weekday - 1
        dateFormat.dateFormat = "yyyy/MM/dd(\(dateFormat.shortWeekdaySymbols[weekdaySymbolIndex])) HH:mm"
        date.text = dateFormat.stringFromDate(registerDate)
        
        self.view.endEditing(true)
    }
    
    func setTextField(){
        if dateFlag.on{
            date.enabled = true
            date.backgroundColor = UIColor.whiteColor()
            date.textColor = UIColor.blackColor()
            if date.text == ""{
                registerDate = NSDate(timeInterval: 60*60, sinceDate: NSDate())
                let comp: NSDateComponents = cal.components([NSCalendarUnit.Weekday], fromDate: registerDate)
                let weekdaySymbolIndex: Int = comp.weekday - 1
                dateFormat.dateFormat = "yyyy/MM/dd(\(dateFormat.shortWeekdaySymbols[weekdaySymbolIndex])) HH:mm"
                date.text = dateFormat.stringFromDate(registerDate)
            }
        }else{
            date.enabled = false
            date.backgroundColor = FlatWhiteDark()
            date.textColor = FlatGray()
        }
    }
    
    func dismissView(){
        self.dismissViewControllerAnimated(true, completion: nil)
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
        return 3
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
            let startDate = registerDate
            let endDate = registerDate
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
            setTextField()
        }else if reminderType.selectedSegmentIndex == 1{
            dateFlag.on = true
            dateFlag.enabled = false
            setTextField()
        }
    }
    
    @IBAction func dateFlagTapped(sender: UISwitch) {
        setTextField()
    }
    
    @IBAction func tableTapped(sender: UITapGestureRecognizer) {
        date?.resignFirstResponder()
    }

}
