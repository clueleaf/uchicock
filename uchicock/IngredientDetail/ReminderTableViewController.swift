//
//  ReminderTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/19.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import EventKit
import SVProgressHUD
import M13Checkbox

class ReminderTableViewController: UITableViewController{

    @IBOutlet weak var reminderTitleLabel: UILabel!
    @IBOutlet weak var reminderTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reminderTitle: UILabel!
    @IBOutlet weak var reminderType: UISegmentedControl!
    @IBOutlet weak var dateFlag: M13Checkbox!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var ingredientName = ""
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "リマインダーへ登録"
        reminderTitle.text = ingredientName + "を買う"
        dateFlag.setCheckState(.unchecked, animated: true)
        dateFlag.boxLineWidth = 1.0
        dateFlag.markType = .checkmark
        dateFlag.boxType = .circle
        dateFlag.stateChangeAnimation = .expand(.fill)
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ja_JP")
        datePicker.setDate(Date(timeInterval: 60*60, since: Date()), animated: true)
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        var safeAreaBottom: CGFloat = 0.0
        safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.backgroundColor = Style.basicBackgroundColor
        reminderTitleLabel.textColor = Style.labelTextColor
        reminderTypeLabel.textColor = Style.labelTextColor
        dateLabel.textColor = Style.labelTextColor
        dateFlag.secondaryTintColor = Style.checkboxSecondaryTintColor
        reminderTitle.textColor = Style.labelTextColor
        datePicker.setValue(Style.labelTextColor, forKey: "textColor")
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black
    }
    
    func createReminder(eventStore: EKEventStore, title: String) {
        let reminder = EKReminder(eventStore: eventStore)
        
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        if dateFlag.checkState == .checked {
            reminder.dueDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: datePicker.date)
            reminder.addAlarm(EKAlarm(absoluteDate: datePicker.date))
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            SVProgressHUD.showSuccess(withStatus: "リマインダーへ登録しました")
            self.dismiss(animated: true, completion: nil)
        } catch {
            DispatchQueue.main.async {
                let alertView = CustomAlertController(title: "リマインダーへの登録に失敗しました", message: "「設定」→「うちカク！」にてリマインダーへのアクセス許可を確認してください", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: {action in
                }))
                alertView.addAction(UIAlertAction(title: "設定を開く", style: .default, handler: {action in
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                alertView.alertStatusBarStyle = Style.statusBarStyle
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    func createEvent(eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(absoluteDate: startDate))
        
        do {
            try eventStore.save(event, span: .thisEvent)
            SVProgressHUD.showSuccess(withStatus: "カレンダーへ登録しました")
            self.dismiss(animated: true, completion: nil)
        } catch {
            DispatchQueue.main.async{
                let alertView = CustomAlertController(title: "カレンダーへの登録に失敗しました", message: "「設定」→「うちカク！」にてカレンダーへのアクセス許可を確認してください", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "キャンセル", style: .default, handler: {action in
                }))
                alertView.addAction(UIAlertAction(title: "設定を開く", style: .default, handler: {action in
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                alertView.alertStatusBarStyle = Style.statusBarStyle
                alertView.modalPresentationCapturesStatusBarAppearance = true
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }

    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UITableView.automaticDimension
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dateFlag.checkState == .checked{
            return 4
        }else{
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = Style.basicBackgroundColor
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        let eventStore = EKEventStore()
        
        if reminderType.selectedSegmentIndex == 0{
            if (EKEventStore.authorizationStatus(for: .reminder) != EKAuthorizationStatus.authorized) {
                eventStore.requestAccess(to: .reminder, completion: {
                    granted, error in
                    DispatchQueue.main.async {
                        self.createReminder(eventStore: eventStore, title: self.reminderTitle.text!)
                    }
                })
            } else {
                createReminder(eventStore: eventStore, title: reminderTitle.text!)
            }
        }else if reminderType.selectedSegmentIndex == 1{
            let startDate = datePicker.date
            let endDate = datePicker.date
            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                eventStore.requestAccess(to: .event, completion: {
                    granted, error in
                    DispatchQueue.main.async {
                        self.createEvent(eventStore: eventStore, title: self.reminderTitle.text!, startDate: startDate, endDate: endDate)
                    }
                })
            } else {
                createEvent(eventStore: eventStore, title: reminderTitle.text!, startDate: startDate, endDate: endDate)
            }
        }
    }

    @IBAction func reminderTypeTapped(_ sender: UISegmentedControl) {
        if reminderType.selectedSegmentIndex == 0{
            dateFlag.isEnabled = true
            dateFlag.tintColor = Style.secondaryColor
        }else if reminderType.selectedSegmentIndex == 1{
            if dateFlag.checkState == .unchecked{
                dateFlag.setCheckState(.checked, animated: true)
                tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
            }
            dateFlag.isEnabled = false
            dateFlag.tintColor = Style.badgeDisableBackgroundColor
        }
    }
    
    @IBAction func dateFlagTapped(_ sender: M13Checkbox) {
        if dateFlag.checkState == .checked{
            tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
        }else{
            tableView.deleteRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
        }
    }
    
}
