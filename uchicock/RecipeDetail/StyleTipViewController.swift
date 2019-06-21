//
//  StyleTipViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/22.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class StyleTipViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var longTitleLabel: UILabel!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var firstSeparator: UIView!
    @IBOutlet weak var shortTitleLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var secondSeparator: UIView!
    @IBOutlet weak var hotTitleLabel: UILabel!
    @IBOutlet weak var hotDescriptionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - IBAction
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
    }
    
}
