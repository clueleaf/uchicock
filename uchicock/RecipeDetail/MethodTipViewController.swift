//
//  MethodTipViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/22.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class MethodTipViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var buildTitleLabel: UILabel!
    @IBOutlet weak var buildDescriptionLabel: UILabel!
    @IBOutlet weak var firstSeparator: UIView!
    @IBOutlet weak var stirTitleLabel: UILabel!
    @IBOutlet weak var stirDescriptionLabel: UILabel!
    @IBOutlet weak var secondSeparator: UIView!
    @IBOutlet weak var shakeTitleLabel: UILabel!
    @IBOutlet weak var shakeDescriptionLabel: UILabel!
    @IBOutlet weak var thirdSeparator: UIView!
    @IBOutlet weak var blendTitleLabel: UILabel!
    @IBOutlet weak var blendDescriptionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }    

    // MARK: - IBAction
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
    }
    
}
