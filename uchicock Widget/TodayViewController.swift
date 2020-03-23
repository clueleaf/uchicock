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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bookmarkButton.layer.cornerRadius = bookmarkButton.frame.size.width / 2
        bookmarkButton.clipsToBounds = true
        bookmarkButton.layer.borderWidth = 1.0
        if #available(iOSApplicationExtension 13.0, *) {
            bookmarkButton.backgroundColor = UIColor(named: "buttonBackground")
            bookmarkButton.tintColor = UIColor.label
            bookmarkButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            bookmarkLabel.textColor = UIColor.label
        }else{
            bookmarkButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            bookmarkButton.tintColor = UIColor.black
            bookmarkButton.layer.borderColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 0.8).cgColor
            bookmarkLabel.textColor = UIColor.black
        }
        
        reminderButton.layer.cornerRadius = reminderButton.frame.size.width / 2
        reminderButton.clipsToBounds = true
        reminderButton.layer.borderWidth = 1.0
        if #available(iOSApplicationExtension 13.0, *) {
            reminderButton.backgroundColor = UIColor(named: "buttonBackground")
            reminderButton.tintColor = UIColor.label
            reminderButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            reminderLabel.textColor = UIColor.label
        }else{
            reminderButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            reminderButton.tintColor = UIColor.black
            reminderButton.layer.borderColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 0.8).cgColor
            reminderLabel.textColor = UIColor.black
        }

        albumButton.layer.cornerRadius = albumButton.frame.size.width / 2
        albumButton.clipsToBounds = true
        albumButton.layer.borderWidth = 1.0
        if #available(iOSApplicationExtension 13.0, *) {
            albumButton.backgroundColor = UIColor(named: "buttonBackground")
            albumButton.tintColor = UIColor.label
            albumButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            albumLabel.textColor = UIColor.label
        }else{
            albumButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            albumButton.tintColor = UIColor.black
            albumButton.layer.borderColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 0.8).cgColor
            albumLabel.textColor = UIColor.black
        }

        calcButton.layer.cornerRadius = calcButton.frame.size.width / 2
        calcButton.clipsToBounds = true
        calcButton.layer.borderWidth = 1.0
        if #available(iOSApplicationExtension 13.0, *) {
            calcButton.backgroundColor = UIColor(named: "buttonBackground")
            calcButton.tintColor = UIColor.label
            calcButton.layer.borderColor = UIColor(named: "buttonBorder")!.cgColor
            calcLabel.textColor = UIColor.label
        }else{
            calcButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            calcButton.tintColor = UIColor.black
            calcButton.layer.borderColor = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 0.8).cgColor
            calcLabel.textColor = UIColor.black
        }
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
