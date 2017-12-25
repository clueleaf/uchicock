//
//  RecipeNavigationController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/28.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar.tintColor = ContrastColorOf(Style.primaryColor, returnFlat: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
}
