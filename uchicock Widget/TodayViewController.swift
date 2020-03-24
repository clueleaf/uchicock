//
//  TodayViewController.swift
//  uchicock Widget
//
//  Created by Kou Kinyo on 2020-03-22.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var bookmarkLabel: UILabel!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var calcButton: UIButton!
    @IBOutlet weak var calcLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOSApplicationExtension 13.0, *) {
            bookmarkButton.backgroundColor = UIColor(named: "buttonBackground")
            bookmarkButton.tintColor = UIColor.label
            bookmarkButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            bookmarkLabel.textColor = UIColor.label

            reminderButton.backgroundColor = UIColor(named: "buttonBackground")
            reminderButton.tintColor = UIColor.label
            reminderButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            reminderLabel.textColor = UIColor.label

            albumButton.backgroundColor = UIColor(named: "buttonBackground")
            albumButton.tintColor = UIColor.label
            albumButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            albumLabel.textColor = UIColor.label

            calcButton.backgroundColor = UIColor(named: "buttonBackground")
            calcButton.tintColor = UIColor.label
            calcButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            calcLabel.textColor = UIColor.label
        }else{
            bookmarkButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            bookmarkButton.tintColor = UIColor.black
            bookmarkButton.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.6).cgColor
            bookmarkLabel.textColor = UIColor.black

            reminderButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            reminderButton.tintColor = UIColor.black
            reminderButton.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.6).cgColor
            reminderLabel.textColor = UIColor.black

            albumButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            albumButton.tintColor = UIColor.black
            albumButton.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.6).cgColor
            albumLabel.textColor = UIColor.black

            calcButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            calcButton.tintColor = UIColor.black
            calcButton.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.6).cgColor
            calcLabel.textColor = UIColor.black
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bookmarkButton.layer.cornerRadius = bookmarkButton.frame.size.width / 2
        bookmarkButton.clipsToBounds = true
        bookmarkButton.layer.borderWidth = bookmarkButton.frame.size.width / 30
        
        reminderButton.layer.cornerRadius = reminderButton.frame.size.width / 2
        reminderButton.clipsToBounds = true
        reminderButton.layer.borderWidth = reminderButton.frame.size.width / 30

        albumButton.layer.cornerRadius = albumButton.frame.size.width / 2
        albumButton.clipsToBounds = true
        albumButton.layer.borderWidth = albumButton.frame.size.width / 30

        calcButton.layer.cornerRadius = calcButton.frame.size.width / 2
        calcButton.clipsToBounds = true
        calcButton.layer.borderWidth = calcButton.frame.size.width / 30
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.noData)
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        let url = URL(string: "uchicock://bookmark")!
        extensionContext?.open(url, completionHandler: nil)
    }
    
    @IBAction func reminderButtonTapped(_ sender: UIButton) {
        let url = URL(string: "uchicock://reminder")!
        extensionContext?.open(url, completionHandler: nil)
    }
    
    @IBAction func albumButtonTapped(_ sender: UIButton) {
        let url = URL(string: "uchicock://album")!
        extensionContext?.open(url, completionHandler: nil)
    }
    
    @IBAction func calcButtonTapped(_ sender: UIButton) {
        let url = URL(string: "uchicock://calc")!
        extensionContext?.open(url, completionHandler: nil)
    }
    
}
