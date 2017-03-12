//
//  ReverseLookupSelectIngredientViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class ReverseLookupSelectIngredientViewController: UIViewController {

    var ingredientNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(ingredientNumber)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
