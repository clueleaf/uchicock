//
//  ReverseLookupSelectIngredientViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/03/12.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class ReverseLookupSelectIngredientViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ingredientContainer: UIView!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var ingredientNameTextField: UITextField!
    
    var ingredientNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientNameTextField.delegate = self
        ingredientNameTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ingredientNameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        ingredientNameTextField.resignFirstResponder()
        return true
    }

    // MARK: - IBAction
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
