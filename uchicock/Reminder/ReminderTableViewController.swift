//
//  ReminderTableViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/19.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift

class ReminderTableViewController: UITableViewController {

    @IBOutlet weak var titleLabel: CustomLabel!
    @IBOutlet weak var ingredientNameLabel: CustomLabel!
    @IBOutlet weak var reminderTypeSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var reminderTypeDescriptionLabel: UILabel!
    @IBOutlet weak var designateDateCheckbox: CircularCheckbox!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var ingredient = Ingredient()
    
    var previousReminderType = 0

    var interactor: Interactor?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    var onDoneBlock = {}

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if interactor != nil{
            tableView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }
        
        titleLabel.text = "対象材料"
        ingredientNameLabel.text = ingredient.ingredientName
        designateDateCheckbox.checkState = .unchecked
        designateDateCheckbox.secondaryTintColor = UchicockStyle.primaryColor
        designateDateCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge

        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ja_JP")
        datePicker.setDate(Date(timeInterval: 60*60, since: Date()), animated: true)
        datePicker.setValue(UchicockStyle.labelTextColor, forKey: "textColor")
        datePicker.setValue(false, forKey: "highlightsToday")

        tableView.backgroundColor = UchicockStyle.basicBackgroundColor
        tableView.separatorColor = UchicockStyle.tableViewSeparatorColor
        tableView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if ingredient.reminderSetDate == nil{
            reminderTypeDescriptionLabel.font = UIFont.systemFont(ofSize: 12.0)
            reminderTypeDescriptionLabel.text = "このアプリ内の購入リマインダーに登録します"
            reminderTypeDescriptionLabel.textColor = UchicockStyle.labelTextColorLight
        }else{
            reminderTypeDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            reminderTypeDescriptionLabel.text = "アプリ内の購入リマインダーには既に登録されています"
            reminderTypeDescriptionLabel.textColor = UchicockStyle.primaryColor
        }
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock()
    }
    
    // MARK: - Logic functions
    private func showError(type: String){
        let alertView = CustomAlertController(title: "\(type)への登録に失敗しました", message: "「設定」→「うちカク！」にて\(type)へのアクセス許可を確認してください", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        if #available(iOS 13.0, *){ cancelAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(cancelAction)
        let settingAction = UIAlertAction(title: "設定を開く", style: .default){action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        if #available(iOS 13.0, *){ settingAction.setValue(UchicockStyle.primaryColor, forKey: "titleTextColor") }
        alertView.addAction(settingAction)
        alertView.modalPresentationCapturesStatusBarAppearance = true
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func createReminder(eventStore: EKEventStore, title: String) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        if designateDateCheckbox.checkState == .checked {
            reminder.dueDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: datePicker.date)
            reminder.addAlarm(EKAlarm(absoluteDate: datePicker.date))
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            MessageHUD.show("リマインダーへ登録しました", for: 2.0, withCheckmark: true, isCenter: true)
            self.dismiss(animated: true, completion: nil)
        } catch {
            DispatchQueue.main.async {
                self.showError(type: "リマインダー")
            }
        }
    }
    
    private func createEvent(eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(absoluteDate: startDate))
        
        do {
            try eventStore.save(event, span: .thisEvent)
            MessageHUD.show("カレンダーへ登録しました", for: 2.0, withCheckmark: true, isCenter: true)
            self.dismiss(animated: true, completion: nil)
        } catch {
            DispatchQueue.main.async{
                self.showError(type: "カレンダー")
            }
        }
    }

    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let int = interactor, int.hasStarted {
            scrollView.contentOffset.y = 0.0
        }
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
                interactor.shouldFinish ? interactor.finish() : interactor.cancel()
            default:
                break
            }
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return UITableView.automaticDimension
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reminderTypeSegmentedControl.selectedSegmentIndex == 0{
            return 2
        }else if designateDateCheckbox.checkState == .checked{
            return 4
        }else{
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UchicockStyle.basicBackgroundColor
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if reminderTypeSegmentedControl.selectedSegmentIndex == 0{
            let shouldShowHUD = ingredient.reminderSetDate == nil
            let realm = try! Realm()
            try! realm.write {
                ingredient.reminderSetDate = Date()
            }
            if shouldShowHUD{
                MessageHUD.show("リマインダーへ登録しました", for: 2.0, withCheckmark: true, isCenter: true)
            }
            self.dismiss(animated: true, completion: nil)
        }else if reminderTypeSegmentedControl.selectedSegmentIndex == 1{
            let eventStore = EKEventStore()
            if (EKEventStore.authorizationStatus(for: .reminder) != EKAuthorizationStatus.authorized) {
                eventStore.requestAccess(to: .reminder, completion: { granted, error in
                    DispatchQueue.main.async {
                        self.createReminder(eventStore: eventStore, title: self.ingredientNameLabel.text!)
                    }
                })
            }else{
                createReminder(eventStore: eventStore, title: ingredientNameLabel.text!)
            }
        }else if reminderTypeSegmentedControl.selectedSegmentIndex == 2{
            let eventStore = EKEventStore()
            let startDate = datePicker.date
            let endDate = datePicker.date
            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                eventStore.requestAccess(to: .event, completion: { granted, error in
                    DispatchQueue.main.async {
                        self.createEvent(eventStore: eventStore, title: self.ingredientNameLabel.text!, startDate: startDate, endDate: endDate)
                    }
                })
            }else{
                createEvent(eventStore: eventStore, title: ingredientNameLabel.text!, startDate: startDate, endDate: endDate)
            }
        }
    }

    @IBAction func reminderTypeTapped(_ sender: UISegmentedControl) {
        switch reminderTypeSegmentedControl.selectedSegmentIndex{
        case 0:
            titleLabel.text = "対象材料"
            ingredientNameLabel.text = ingredient.ingredientName
            if ingredient.reminderSetDate == nil{
                reminderTypeDescriptionLabel.font = UIFont.systemFont(ofSize: 12.0)
                reminderTypeDescriptionLabel.text = "このアプリ内の購入リマインダーに登録します"
                reminderTypeDescriptionLabel.textColor = UchicockStyle.labelTextColorLight
            }else{
                reminderTypeDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
                reminderTypeDescriptionLabel.text = "アプリ内の購入リマインダーには既に登録されています"
                reminderTypeDescriptionLabel.textColor = UchicockStyle.primaryColor
            }

            if designateDateCheckbox.checkState == .checked{
                tableView.deleteRows(at: [IndexPath(row: 2,section: 0), IndexPath(row: 3,section: 0)], with: .middle)
            }else{
                tableView.deleteRows(at: [IndexPath(row: 2,section: 0)], with: .middle)
            }
            designateDateCheckbox.setCheckState(.unchecked, animated: true)

            designateDateCheckbox.isEnabled = false
            previousReminderType = 0
        case 1:
            titleLabel.text = "タイトル"
            ingredientNameLabel.text = ingredient.ingredientName + "を買う"
            reminderTypeDescriptionLabel.font = UIFont.systemFont(ofSize: 12.0)
            reminderTypeDescriptionLabel.text = "iOSのリマインダーアプリに登録します"
            reminderTypeDescriptionLabel.textColor = UchicockStyle.labelTextColorLight

            if previousReminderType == 0{
                tableView.insertRows(at: [IndexPath(row: 2,section: 0)], with: .middle)
            }

            designateDateCheckbox.isEnabled = true
            designateDateCheckbox.tintColor = UchicockStyle.primaryColor
            designateDateCheckbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
            previousReminderType = 1
        case 2:
            titleLabel.text = "タイトル"
            ingredientNameLabel.text = ingredient.ingredientName + "を買う"
            reminderTypeDescriptionLabel.font = UIFont.systemFont(ofSize: 12.0)
            reminderTypeDescriptionLabel.text = "iOSのカレンダーアプリに登録します"
            reminderTypeDescriptionLabel.textColor = UchicockStyle.labelTextColorLight

            if previousReminderType == 0{
                designateDateCheckbox.setCheckState(.checked, animated: true)
                tableView.insertRows(at: [IndexPath(row: 2,section: 0), IndexPath(row: 3,section: 0)], with: .middle)
            }else if previousReminderType == 1 && designateDateCheckbox.checkState == .unchecked{
                designateDateCheckbox.setCheckState(.checked, animated: true)
                tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
            }

            designateDateCheckbox.isEnabled = false
            designateDateCheckbox.tintColor = UchicockStyle.labelTextColorLight
            designateDateCheckbox.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
            previousReminderType = 2
        default: break
        }
    }
    
    @IBAction func dataCheckboxTapped(_ sender: CircularCheckbox) {
        if designateDateCheckbox.checkState == .checked{
            tableView.insertRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
        }else{
            tableView.deleteRows(at: [IndexPath(row: 3,section: 0)], with: .middle)
        }
    }
}
