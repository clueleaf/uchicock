//
//  RecipeDetailViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/13.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var method: UISegmentedControl!
    @IBOutlet weak var procedure: UITextView!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    
    var recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeName.text = recipe.recipeName
        procedure.text = recipe.procedure
        memo.text = recipe.memo
        
        switch recipe.method{
        case 1:
            method.selectedSegmentIndex = 0
        case 2:
            method.selectedSegmentIndex = 1
        case 3:
            method.selectedSegmentIndex = 2
        case 4:
            method.selectedSegmentIndex = 3
        default:
            method.selectedSegmentIndex = 4
        }
        
        switch recipe.favorites{
        case 1:
            star1.setTitle("★", forState: .Normal)
            star2.setTitle("☆", forState: .Normal)
            star3.setTitle("☆", forState: .Normal)
        case 2:
            star1.setTitle("★", forState: .Normal)
            star2.setTitle("★", forState: .Normal)
            star3.setTitle("☆", forState: .Normal)
        case 3:
            star1.setTitle("★", forState: .Normal)
            star2.setTitle("★", forState: .Normal)
            star3.setTitle("★", forState: .Normal)
        default:
            star1.setTitle("★", forState: .Normal)
            star2.setTitle("☆", forState: .Normal)
            star3.setTitle("☆", forState: .Normal)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
