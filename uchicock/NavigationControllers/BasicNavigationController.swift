//
//  BasicNavigationController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/12/26.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class BasicNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }

}
