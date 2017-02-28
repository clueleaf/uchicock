//
//  TabBarController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/27.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.tintColor = Style.tabBarTintColor
        tabBar.barTintColor = Style.tabBarBarTintColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }    
}
