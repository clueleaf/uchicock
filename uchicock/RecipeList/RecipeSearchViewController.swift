//
//  RecipeSearchViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/18.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import M13Checkbox

class RecipeSearchViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollBackgroundView: UIView!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var sortExplanationLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var nameOrderLabel: UILabel!
    @IBOutlet weak var shortageOrderLabel: UILabel!
    @IBOutlet weak var madeNumOrderLabel: UILabel!
    @IBOutlet weak var favoriteOrderLabel: UILabel!
    @IBOutlet weak var lastViewedOrderLabel: UILabel!
    
    @IBOutlet weak var nameOrderPrimaryCheckbox: M13Checkbox!
    @IBOutlet weak var nameOrderSecondaryCheckbox: M13Checkbox!
    @IBOutlet weak var shortageOrderPrimaryCheckbox: M13Checkbox!
    @IBOutlet weak var shortageOrderSecondaryCheckbox: M13Checkbox!
    @IBOutlet weak var madeNumOrderPrimaryCheckbox: M13Checkbox!
    @IBOutlet weak var madeNumOrderSecondaryCheckbox: M13Checkbox!
    @IBOutlet weak var favoriteOrderPrimaryCheckbox: M13Checkbox!
    @IBOutlet weak var favoriteOrderSecondaryCheckbox: M13Checkbox!
    @IBOutlet weak var lastViewedOrderPrimaryCheckbox: M13Checkbox!
    @IBOutlet weak var lastViewedOrderSecondaryCheckbox: M13Checkbox!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    var onDoneBlock = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCheckbox(nameOrderPrimaryCheckbox, with: .checked)
        initCheckbox(nameOrderSecondaryCheckbox, with: .mixed)
        initCheckbox(shortageOrderPrimaryCheckbox, with: .unchecked)
        initCheckbox(shortageOrderSecondaryCheckbox, with: .mixed)
        initCheckbox(madeNumOrderPrimaryCheckbox, with: .unchecked)
        initCheckbox(madeNumOrderSecondaryCheckbox, with: .mixed)
        initCheckbox(favoriteOrderPrimaryCheckbox, with: .unchecked)
        initCheckbox(favoriteOrderSecondaryCheckbox, with: .mixed)
        initCheckbox(lastViewedOrderPrimaryCheckbox, with: .unchecked)
        initCheckbox(lastViewedOrderSecondaryCheckbox, with: .mixed)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.backgroundColor = Style.basicBackgroundColor
        scrollBackgroundView.backgroundColor = Style.basicBackgroundColor
        sortLabel.textColor = Style.labelTextColor
        sortExplanationLabel.textColor = Style.labelTextColorLight
        primaryLabel.textColor = Style.labelTextColor
        secondaryLabel.textColor = Style.labelTextColor
        nameOrderLabel.textColor = Style.labelTextColor
        shortageOrderLabel.textColor = Style.labelTextColor
        madeNumOrderLabel.textColor = Style.labelTextColor
        favoriteOrderLabel.textColor = Style.labelTextColor
        lastViewedOrderLabel.textColor = Style.labelTextColor
        
    }
    
    // MARK: - M13Checkbox
    private func initCheckbox(_ checkbox: M13Checkbox, with checkState: M13Checkbox.CheckState){
        checkbox.boxLineWidth = 1.0
        checkbox.markType = .checkmark
        checkbox.boxType = .circle
        checkbox.stateChangeAnimation = .fade(.fill)
        checkbox.animationDuration = 0
        checkbox.setCheckState(checkState, animated: true)
        checkbox.animationDuration = 0.3
        checkbox.stateChangeAnimation = .expand(.fill)
//        checkbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        checkbox.contentHorizontalAlignment = .center
    }
    
//    private func updateMethodFilterColorOf(_ checkbox: M13Checkbox, and button: UIButton){
//        checkbox.secondaryTintColor = Style.checkboxSecondaryTintColor
//        if checkbox.checkState == .checked{
//            button.tintColor = Style.secondaryColor
//            if Style.no == "6" {
//                button.tintColor = Style.labelTextColor
//            }
//        }else if checkbox.checkState == .unchecked{
//            button.tintColor = Style.labelTextColorLight
//            if Style.no == "6" {
//                button.tintColor = FlatColor.white
//            }
//        }
//    }
    
    
    // MARK: - IBAction
    @IBAction func searchBarButtonTapped(_ sender: UIBarButtonItem) {
        self.onDoneBlock()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        self.onDoneBlock()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nameOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func nameOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func shortageOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func shortageOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func madeNumOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func madeNumOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func favoriteOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func favoriteOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func lastViewedOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    @IBAction func lastViewedOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
    }
    
    
//    @IBAction func buildCheckboxTapped(_ sender: M13Checkbox) {
//        updateMethodFilterColorOf(buildCheckbox, and: buildFilterButton)
//        reloadRecipeBasicList()
//        tableView.reloadData()
//    }

    
}
