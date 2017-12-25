//
//  RecipeEditNavigationController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/12/25.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit
import ChameleonFramework

class RecipeEditNavigationController: UINavigationController {

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
