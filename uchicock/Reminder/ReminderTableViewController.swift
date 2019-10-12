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

    @IBOutlet weak var reminderTitle: CustomLabel!
    @IBOutlet weak var reminderType: CustomSegmentedControl!
    @IBOutlet weak var dateFlag: CircularCheckbox!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var ingredientName = ""
    
    var interactor: Interactor?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    var onDoneBlock = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        if interactor != nil{
            tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }
        
        self.navigationItem.title = "リマインダー"
        reminderTitle.text = ingredientName + "を買う"
        dateFlag.setCheckState(.unchecked, animated: true)
        dateFlag.boxLineWidth = 1.0
        dateFlag.stateChangeAnimation = .expand
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ja_JP")
        datePicker.setDate(Date(timeInterval: 60*60, since: Date()), animated: true)
        
        self.tableView.separatorColor = UIColor.gray
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.backgroundColor = Style.basicBackgroundColor
        self.tableView.indicatorStyle = Style.isBackgroundDark ? .white : .black

        if #available(iOS 13.0, *) {
        }else{
            reminderType.layer.cornerRadius = 14.0
        }
        reminderType.layer.borderColor = Style.primaryColor.cgColor
        reminderType.layer.borderWidth = 1.0
        reminderType.layer.masksToBounds = true
        dateFlag.secondaryTintColor = Style.primaryColor
        dateFlag.secondaryCheckmarkTintColor = Style.labelTextColorOnBadge
        datePicker.setValue(Style.labelTextColor, forKey: "textColor")
        datePicker.setValue(false, forKey: "highlightsToday")
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock()
    }
    
    private func showError(_ type: String){
        let alertView = CustomAlertController(title: "\(type)への登録に失敗しました", message: "「設定」→「うちカク！」にて\(type)へのアクセス許可を確認してください", preferredStyle: .alert)
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
            ProgressHUD.showSuccess(with: "リマインダーへ登録しました", duration: 1.5)
            self.dismiss(animated: true, completion: nil)
        } catch {
            DispatchQueue.main.async {
                self.showError("リマインダー")
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
            ProgressHUD.showSuccess(with: "カレンダーへ登録しました", duration: 1.5)
            self.dismiss(animated: true, completion: nil)
        } catch {
            DispatchQueue.main.async{
                self.showError("カレンダー")
            }
        }
    }

    // MARK: - UITableView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if interactor != nil{
            if interactor!.hasStarted {
                tableView.contentOffset.y = 0.0
            }
        }
    }
    
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
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        guard let interactor = interactor else { return }
        let percentThreshold: CGFloat = 0.3
        
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        if tableView.contentOffset.y <= 0 || interactor.hasStarted{
            switch sender.state {
            case .began:
                interactor.hasStarted = true
                dismiss(animated: true, completion: nil)
            case .changed:
                interactor.shouldFinish = progress > percentThreshold
                interactor.update(progress)
                break
            case .cancelled:
                interactor.hasStarted = false
                interactor.cancel()
            case .ended:
                interactor.hasStarted = false
                interactor.shouldFinish
                    ? interactor.finish()
                    : interactor.cancel()
            default:
                break
            }
        }
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
            dateFlag.tintColor = Style.primaryColor
            dateFlag.secondaryCheckmarkTintColor = Style.labelTextColorOnBadge
        }else if reminderType.selectedSegmentIndex == 1{
            if dateFlag.checkState == .unchecked{
                dateFlag.setCheckState(.checked, animated: true)
                tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
            }
            dateFlag.isEnabled = false
            dateFlag.tintColor = Style.labelTextColorLight
            dateFlag.secondaryCheckmarkTintColor = Style.basicBackgroundColor
        }
    }
    
    @IBAction func dateFlagTapped(_ sender: CircularCheckbox) {
        if dateFlag.checkState == .checked{
            tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
        }else{
            tableView.deleteRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
        }
    }
    
}
