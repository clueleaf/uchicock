//
//  CustomAlertController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/02.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

class CustomAlertController: UIAlertController {
    var alertStatusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return alertStatusBarStyle
    }
}

class CustomActivityController: UIActivityViewController{
    var activityStatusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return activityStatusBarStyle
    }
}

class CustomPhotoBrowser: IDMPhotoBrowser{
    var photoBrowserStatusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return photoBrowserStatusBarStyle
    }
}
