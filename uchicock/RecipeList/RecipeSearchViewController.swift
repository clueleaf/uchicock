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
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterExplanationLabel: UILabel!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var deselectAllButton: UIButton!
    
    @IBOutlet weak var favoriteFilterLabel: UILabel!
    @IBOutlet weak var favorite0Label: UILabel!
    @IBOutlet weak var favorite1Label: UILabel!
    @IBOutlet weak var favorite2Label: UILabel!
    @IBOutlet weak var favorite3Label: UILabel!
    @IBOutlet weak var favorite0Checkbox: M13Checkbox!
    @IBOutlet weak var favorite1Checkbox: M13Checkbox!
    @IBOutlet weak var favorite2Checkbox: M13Checkbox!
    @IBOutlet weak var favorite3Checkbox: M13Checkbox!
    @IBOutlet weak var favoriteWarningImage: UIImageView!
    @IBOutlet weak var favoriteWarningLabel: UILabel!
    
    @IBOutlet weak var typeFilterLabel: UILabel!
    @IBOutlet weak var typeLongLabel: UILabel!
    @IBOutlet weak var typeShortLabel: UILabel!
    @IBOutlet weak var typeLongCheckbox: M13Checkbox!
    @IBOutlet weak var typeShortCheckbox: M13Checkbox!
    @IBOutlet weak var typeWarningImage: UIImageView!
    @IBOutlet weak var typeWarningLabel: UILabel!
    
    @IBOutlet weak var methodFilterLabel: UILabel!
    @IBOutlet weak var methodBuildLabel: UILabel!
    @IBOutlet weak var methodStirLabel: UILabel!
    @IBOutlet weak var methodShakeLabel: UILabel!
    @IBOutlet weak var methodBlendLabel: UILabel!
    @IBOutlet weak var methodOthersLabel: UILabel!
    @IBOutlet weak var methodBuildCheckbox: M13Checkbox!
    @IBOutlet weak var methodStirCheckbox: M13Checkbox!
    @IBOutlet weak var methodShakeCheckbox: M13Checkbox!
    @IBOutlet weak var methodBlendCheckbox: M13Checkbox!
    @IBOutlet weak var methodOthersCheckbox: M13Checkbox!
    @IBOutlet weak var methodWarningImage: UIImageView!
    @IBOutlet weak var methodWarningLabel: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    var recipeSortPrimary = 1
    var recipeSortSecondary = 0
    var recipeFilterStar0 = true
    var recipeFilterStar1 = true
    var recipeFilterStar2 = true
    var recipeFilterStar3 = true
    var recipeFilterLong = true
    var recipeFilterShort = true
    var recipeFilterBuild = true
    var recipeFilterStir = true
    var recipeFilterShake = true
    var recipeFilterBlend = true
    var recipeFilterOthers = true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    var onDoneBlock = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        readUserDefaults()
        
        switch recipeSortPrimary{
        case 1:
            initPrimaryCheckBox(nameState: .checked, shortageState: .unchecked, madeNumState: .unchecked, favoriteState: .unchecked, lastViewedState: .unchecked)
            initSecondaryCheckBox(nameState: .mixed, shortageState: .mixed, madeNumState: .mixed, favoriteState: .mixed, lastViewedState: .mixed)
        case 2:
            initPrimaryCheckBox(nameState: .unchecked, shortageState: .checked, madeNumState: .unchecked, favoriteState: .unchecked, lastViewedState: .unchecked)
            switch recipeSortSecondary{
            case 1:
                initSecondaryCheckBox(nameState: .checked, shortageState: .mixed, madeNumState: .unchecked, favoriteState: .unchecked, lastViewedState: .unchecked)
            case 3:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .mixed, madeNumState: .checked, favoriteState: .unchecked, lastViewedState: .unchecked)
            case 4:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .mixed, madeNumState: .unchecked, favoriteState: .checked, lastViewedState: .unchecked)
            case 5:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .mixed, madeNumState: .unchecked, favoriteState: .unchecked, lastViewedState: .checked)
            default:
                initSecondaryCheckBox(nameState: .checked, shortageState: .mixed, madeNumState: .unchecked, favoriteState: .unchecked, lastViewedState: .unchecked)
            }
        case 3:
            initPrimaryCheckBox(nameState: .unchecked, shortageState: .unchecked, madeNumState: .checked, favoriteState: .unchecked, lastViewedState: .unchecked)
            switch recipeSortSecondary{
            case 1:
                initSecondaryCheckBox(nameState: .checked, shortageState: .unchecked, madeNumState: .mixed, favoriteState: .unchecked, lastViewedState: .unchecked)
            case 2:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .checked, madeNumState: .mixed, favoriteState: .unchecked, lastViewedState: .unchecked)
            case 4:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .unchecked, madeNumState: .mixed, favoriteState: .checked, lastViewedState: .unchecked)
            case 5:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .unchecked, madeNumState: .mixed, favoriteState: .unchecked, lastViewedState: .checked)
            default:
                initSecondaryCheckBox(nameState: .checked, shortageState: .unchecked, madeNumState: .mixed, favoriteState: .unchecked, lastViewedState: .unchecked)
            }
        case 4:
            initPrimaryCheckBox(nameState: .unchecked, shortageState: .unchecked, madeNumState: .unchecked, favoriteState: .checked, lastViewedState: .unchecked)
            switch recipeSortSecondary{
            case 1:
                initSecondaryCheckBox(nameState: .checked, shortageState: .unchecked, madeNumState: .unchecked, favoriteState: .mixed, lastViewedState: .unchecked)
            case 2:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .checked, madeNumState: .unchecked, favoriteState: .mixed, lastViewedState: .unchecked)
            case 3:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .unchecked, madeNumState: .checked, favoriteState: .mixed, lastViewedState: .unchecked)
            case 5:
                initSecondaryCheckBox(nameState: .unchecked, shortageState: .unchecked, madeNumState: .unchecked, favoriteState: .mixed, lastViewedState: .checked)
            default:
                initSecondaryCheckBox(nameState: .checked, shortageState: .unchecked, madeNumState: .unchecked, favoriteState: .mixed, lastViewedState: .unchecked)
            }
        case 5:
            initPrimaryCheckBox(nameState: .unchecked, shortageState: .unchecked, madeNumState: .unchecked, favoriteState: .unchecked, lastViewedState: .checked)
            initSecondaryCheckBox(nameState: .mixed, shortageState: .mixed, madeNumState: .mixed, favoriteState: .mixed, lastViewedState: .mixed)
        default:
            initPrimaryCheckBox(nameState: .checked, shortageState: .unchecked, madeNumState: .unchecked, favoriteState: .unchecked, lastViewedState: .unchecked)
            initSecondaryCheckBox(nameState: .mixed, shortageState: .mixed, madeNumState: .mixed, favoriteState: .mixed, lastViewedState: .mixed)
        }
        
        initFilterCheckbox(favorite0Checkbox, shouldBeChecked: recipeFilterStar0)
        initFilterCheckbox(favorite1Checkbox, shouldBeChecked: recipeFilterStar1)
        initFilterCheckbox(favorite2Checkbox, shouldBeChecked: recipeFilterStar2)
        initFilterCheckbox(favorite3Checkbox, shouldBeChecked: recipeFilterStar3)
        initFilterCheckbox(typeLongCheckbox, shouldBeChecked: recipeFilterLong)
        initFilterCheckbox(typeShortCheckbox, shouldBeChecked: recipeFilterShort)
        initFilterCheckbox(methodBuildCheckbox, shouldBeChecked: recipeFilterBuild)
        initFilterCheckbox(methodStirCheckbox, shouldBeChecked: recipeFilterStir)
        initFilterCheckbox(methodShakeCheckbox, shouldBeChecked: recipeFilterShake)
        initFilterCheckbox(methodBlendCheckbox, shouldBeChecked: recipeFilterBlend)
        initFilterCheckbox(methodOthersCheckbox, shouldBeChecked: recipeFilterOthers)
    }
    
    private func readUserDefaults(){
        let defaults = UserDefaults.standard

        recipeSortPrimary = defaults.integer(forKey: "recipe-sort-primary")
        recipeSortSecondary = defaults.integer(forKey: "recipe-sort-secondary")
        recipeFilterStar0 = defaults.bool(forKey: "recipe-filter-star0")
        recipeFilterStar1 = defaults.bool(forKey: "recipe-filter-star1")
        recipeFilterStar2 = defaults.bool(forKey: "recipe-filter-star2")
        recipeFilterStar3 = defaults.bool(forKey: "recipe-filter-star3")
        recipeFilterLong = defaults.bool(forKey: "recipe-filter-long")
        recipeFilterShort = defaults.bool(forKey: "recipe-filter-short")
        recipeFilterBuild = defaults.bool(forKey: "recipe-filter-build")
        recipeFilterStir = defaults.bool(forKey: "recipe-filter-stir")
        recipeFilterShake = defaults.bool(forKey: "recipe-filter-shake")
        recipeFilterBlend = defaults.bool(forKey: "recipe-filter-blend")
        recipeFilterOthers = defaults.bool(forKey: "recipe-filter-others")
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
        
        filterLabel.textColor = Style.labelTextColor
        filterExplanationLabel.textColor = Style.labelTextColorLight
        selectAllButton.tintColor = Style.secondaryColor
        deselectAllButton.tintColor = Style.secondaryColor

        favoriteFilterLabel.textColor = Style.labelTextColor
        favorite0Label.textColor = Style.labelTextColor
        favorite1Label.textColor = Style.labelTextColor
        favorite2Label.textColor = Style.labelTextColor
        favorite3Label.textColor = Style.labelTextColor
        favoriteWarningImage.image = favoriteWarningImage.image!.withRenderingMode(.alwaysTemplate)
        favoriteWarningImage.tintColor = Style.secondaryColor
        favoriteWarningLabel.textColor = Style.secondaryColor
        setFavoriteWarningVisibility()

        typeFilterLabel.textColor = Style.labelTextColor
        typeLongLabel.textColor = Style.labelTextColor
        typeShortLabel.textColor = Style.labelTextColor
        typeWarningImage.image = typeWarningImage.image!.withRenderingMode(.alwaysTemplate)
        typeWarningImage.tintColor = Style.secondaryColor
        typeWarningLabel.textColor = Style.secondaryColor
        setTypeWarningVisibility()

        methodFilterLabel.textColor = Style.labelTextColor
        methodBuildLabel.textColor = Style.labelTextColor
        methodStirLabel.textColor = Style.labelTextColor
        methodShakeLabel.textColor = Style.labelTextColor
        methodBlendLabel.textColor = Style.labelTextColor
        methodOthersLabel.textColor = Style.labelTextColor
        methodWarningImage.image = methodWarningImage.image!.withRenderingMode(.alwaysTemplate)
        methodWarningImage.tintColor = Style.secondaryColor
        methodWarningLabel.textColor = Style.secondaryColor
        setMethodWarningVisibility()
    }
    
    private func setFavoriteWarningVisibility(){
        if favorite0Checkbox.checkState == .unchecked &&
           favorite1Checkbox.checkState == .unchecked &&
           favorite2Checkbox.checkState == .unchecked &&
            favorite3Checkbox.checkState == .unchecked {
            favoriteWarningImage.isHidden = false
            favoriteWarningLabel.isHidden = false
        }else{
            favoriteWarningImage.isHidden = true
            favoriteWarningLabel.isHidden = true
        }
    }
    
    private func setTypeWarningVisibility(){
        if typeLongCheckbox.checkState == .unchecked &&
            typeShortCheckbox.checkState == .unchecked{
            typeWarningImage.isHidden = false
            typeWarningLabel.isHidden = false
        }else{
            typeWarningImage.isHidden = true
            typeWarningLabel.isHidden = true
        }
    }
    
    private func setMethodWarningVisibility(){
        if methodBuildCheckbox.checkState == .unchecked &&
           methodStirCheckbox.checkState == .unchecked &&
           methodShakeCheckbox.checkState == .unchecked &&
           methodBlendCheckbox.checkState == .unchecked &&
            methodOthersCheckbox.checkState == .unchecked {
            methodWarningImage.isHidden = false
            methodWarningLabel.isHidden = false
        }else{
            methodWarningImage.isHidden = true
            methodWarningLabel.isHidden = true
        }
    }

    // MARK: - M13Checkbox
    private func initPrimaryCheckBox(nameState: M13Checkbox.CheckState, shortageState:  M13Checkbox.CheckState,
                                     madeNumState:  M13Checkbox.CheckState, favoriteState: M13Checkbox.CheckState, lastViewedState: M13Checkbox.CheckState){
        initCheckbox(nameOrderPrimaryCheckbox, with: nameState)
        initCheckbox(shortageOrderPrimaryCheckbox, with: shortageState)
        initCheckbox(madeNumOrderPrimaryCheckbox, with: madeNumState)
        initCheckbox(favoriteOrderPrimaryCheckbox, with: favoriteState)
        initCheckbox(lastViewedOrderPrimaryCheckbox, with: lastViewedState)
    }
    
    private func initSecondaryCheckBox(nameState: M13Checkbox.CheckState, shortageState:  M13Checkbox.CheckState,
                                       madeNumState:  M13Checkbox.CheckState, favoriteState: M13Checkbox.CheckState, lastViewedState: M13Checkbox.CheckState){
        initCheckbox(nameOrderSecondaryCheckbox, with: nameState)
        initCheckbox(shortageOrderSecondaryCheckbox, with: shortageState)
        initCheckbox(madeNumOrderSecondaryCheckbox, with: madeNumState)
        initCheckbox(favoriteOrderSecondaryCheckbox, with: favoriteState)
        initCheckbox(lastViewedOrderSecondaryCheckbox, with: lastViewedState)
    }
    
    private func initFilterCheckbox(_ checkbox: M13Checkbox, shouldBeChecked: Bool){
        if shouldBeChecked{
            initCheckbox(checkbox, with: .checked)
        }else{
            initCheckbox(checkbox, with: .unchecked)
        }
    }
    
    private func initCheckbox(_ checkbox: M13Checkbox, with checkState: M13Checkbox.CheckState){
        checkbox.boxLineWidth = 1.0
        checkbox.markType = .checkmark
        checkbox.boxType = .circle
        checkbox.stateChangeAnimation = .fade(.fill)
        checkbox.animationDuration = 0
        checkbox.setCheckState(checkState, animated: true)
        if checkState == .mixed{
            checkbox.isEnabled = false
            checkbox.tintColor = Style.badgeDisableBackgroundColor
        }else{
            checkbox.isEnabled = true
            checkbox.tintColor = Style.secondaryColor
        }
        checkbox.animationDuration = 0.3
        checkbox.stateChangeAnimation = .expand(.fill)
        checkbox.secondaryTintColor = Style.checkboxSecondaryTintColor
        checkbox.contentHorizontalAlignment = .center
    }
    
    // MARK: - IBAction
    @IBAction func searchBarButtonTapped(_ sender: UIBarButtonItem) {
        self.saveUserDefaults()
        self.onDoneBlock()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        self.saveUserDefaults()
        self.onDoneBlock()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func saveUserDefaults(){
        let defaults = UserDefaults.standard
        var primarySort = 1
        var secondarySort = 0
        
        if nameOrderPrimaryCheckbox.checkState == .checked{
            primarySort = 1
        }else if shortageOrderPrimaryCheckbox.checkState == .checked{
            primarySort = 2
        }else if madeNumOrderPrimaryCheckbox.checkState == .checked{
            primarySort = 3
        }else if favoriteOrderPrimaryCheckbox.checkState == .checked{
            primarySort = 4
        }else if lastViewedOrderPrimaryCheckbox.checkState == .checked{
            primarySort = 5
        }
        
        if nameOrderSecondaryCheckbox.checkState == .checked {
            secondarySort = 1
        }else if shortageOrderSecondaryCheckbox.checkState == .checked{
            secondarySort = 2
        }else if madeNumOrderSecondaryCheckbox.checkState == .checked{
            secondarySort = 3
        }else if favoriteOrderSecondaryCheckbox.checkState == .checked{
            secondarySort = 4
        }else if lastViewedOrderSecondaryCheckbox.checkState == .checked{
            secondarySort = 5
        }
        
        defaults.set(primarySort, forKey: "recipe-sort-primary")
        defaults.set(secondarySort, forKey: "recipe-sort-secondary")
        
        setFilterUserDefaults(with: favorite0Checkbox, forKey: "recipe-filter-star0")
        setFilterUserDefaults(with: favorite1Checkbox, forKey: "recipe-filter-star1")
        setFilterUserDefaults(with: favorite2Checkbox, forKey: "recipe-filter-star2")
        setFilterUserDefaults(with: favorite3Checkbox, forKey: "recipe-filter-star3")
        setFilterUserDefaults(with: typeLongCheckbox, forKey: "recipe-filter-long")
        setFilterUserDefaults(with: typeShortCheckbox, forKey: "recipe-filter-short")
        setFilterUserDefaults(with: methodBuildCheckbox, forKey: "recipe-filter-build")
        setFilterUserDefaults(with: methodStirCheckbox, forKey: "recipe-filter-stir")
        setFilterUserDefaults(with: methodShakeCheckbox, forKey: "recipe-filter-shake")
        setFilterUserDefaults(with: methodBlendCheckbox, forKey: "recipe-filter-blend")
        setFilterUserDefaults(with: methodOthersCheckbox, forKey: "recipe-filter-others")
    }
    
    private func setFilterUserDefaults(with checkbox: M13Checkbox, forKey key: String){
        let defaults = UserDefaults.standard
        if checkbox.checkState == .checked{
            defaults.set(true, forKey: key)
        }else{
            defaults.set(false, forKey: key)
        }
    }
    
    @IBAction func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        self.onDoneBlock()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nameOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxChecked(nameOrderPrimaryCheckbox)
        setCheckboxMixed(nameOrderSecondaryCheckbox)
        setCheckboxUnchecked(shortageOrderPrimaryCheckbox)
        setCheckboxMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUnchecked(madeNumOrderPrimaryCheckbox)
        setCheckboxMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUnchecked(favoriteOrderPrimaryCheckbox)
        setCheckboxMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUnchecked(lastViewedOrderPrimaryCheckbox)
        setCheckboxMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func nameOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxChecked(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func shortageOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUnchecked(nameOrderPrimaryCheckbox)
        setCheckboxChecked(nameOrderSecondaryCheckbox)
        setCheckboxChecked(shortageOrderPrimaryCheckbox)
        setCheckboxMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUnchecked(madeNumOrderPrimaryCheckbox)
        setCheckboxUnchecked(madeNumOrderSecondaryCheckbox)
        setCheckboxUnchecked(favoriteOrderPrimaryCheckbox)
        setCheckboxUnchecked(favoriteOrderSecondaryCheckbox)
        setCheckboxUnchecked(lastViewedOrderPrimaryCheckbox)
        setCheckboxUnchecked(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func shortageOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxChecked(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func madeNumOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUnchecked(nameOrderPrimaryCheckbox)
        setCheckboxChecked(nameOrderSecondaryCheckbox)
        setCheckboxUnchecked(shortageOrderPrimaryCheckbox)
        setCheckboxUnchecked(shortageOrderSecondaryCheckbox)
        setCheckboxChecked(madeNumOrderPrimaryCheckbox)
        setCheckboxMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUnchecked(favoriteOrderPrimaryCheckbox)
        setCheckboxUnchecked(favoriteOrderSecondaryCheckbox)
        setCheckboxUnchecked(lastViewedOrderPrimaryCheckbox)
        setCheckboxUnchecked(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func madeNumOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxChecked(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func favoriteOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUnchecked(nameOrderPrimaryCheckbox)
        setCheckboxChecked(nameOrderSecondaryCheckbox)
        setCheckboxUnchecked(shortageOrderPrimaryCheckbox)
        setCheckboxUnchecked(shortageOrderSecondaryCheckbox)
        setCheckboxUnchecked(madeNumOrderPrimaryCheckbox)
        setCheckboxUnchecked(madeNumOrderSecondaryCheckbox)
        setCheckboxChecked(favoriteOrderPrimaryCheckbox)
        setCheckboxMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUnchecked(lastViewedOrderPrimaryCheckbox)
        setCheckboxUnchecked(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func favoriteOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxChecked(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func lastViewedOrderPrimaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUnchecked(nameOrderPrimaryCheckbox)
        setCheckboxMixed(nameOrderSecondaryCheckbox)
        setCheckboxUnchecked(shortageOrderPrimaryCheckbox)
        setCheckboxMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUnchecked(madeNumOrderPrimaryCheckbox)
        setCheckboxMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUnchecked(favoriteOrderPrimaryCheckbox)
        setCheckboxMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxChecked(lastViewedOrderPrimaryCheckbox)
        setCheckboxMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func lastViewedOrderSecondaryCheckboxTapped(_ sender: M13Checkbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxChecked(lastViewedOrderSecondaryCheckbox)
    }
    
    private func setCheckboxChecked(_ checkbox: M13Checkbox){
        checkbox.setCheckState(.checked, animated: true)
        checkbox.isEnabled = true
        checkbox.tintColor = Style.secondaryColor
    }

    private func setCheckboxUnchecked(_ checkbox: M13Checkbox){
        checkbox.setCheckState(.unchecked, animated: true)
        checkbox.isEnabled = true
        checkbox.tintColor = Style.secondaryColor
    }

    
    private func setCheckboxUncheckedIfNotMixed(_ checkbox: M13Checkbox){
        if checkbox.checkState != .mixed{
            checkbox.setCheckState(.unchecked, animated: true)
            checkbox.isEnabled = true
            checkbox.tintColor = Style.secondaryColor
        }
    }
    
    private func setCheckboxMixed(_ checkbox: M13Checkbox){
        checkbox.setCheckState(.mixed, animated: true)
        checkbox.isEnabled = false
        checkbox.tintColor = Style.badgeDisableBackgroundColor
    }
    
    @IBAction func selectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(favorite0Checkbox)
        setCheckboxChecked(favorite1Checkbox)
        setCheckboxChecked(favorite2Checkbox)
        setCheckboxChecked(favorite3Checkbox)
        setCheckboxChecked(typeLongCheckbox)
        setCheckboxChecked(typeShortCheckbox)
        setCheckboxChecked(methodBuildCheckbox)
        setCheckboxChecked(methodStirCheckbox)
        setCheckboxChecked(methodShakeCheckbox)
        setCheckboxChecked(methodBlendCheckbox)
        setCheckboxChecked(methodOthersCheckbox)
        setFavoriteWarningVisibility()
        setTypeWarningVisibility()
        setMethodWarningVisibility()
    }
    
    @IBAction func deselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(favorite0Checkbox)
        setCheckboxUnchecked(favorite1Checkbox)
        setCheckboxUnchecked(favorite2Checkbox)
        setCheckboxUnchecked(favorite3Checkbox)
        setCheckboxUnchecked(typeLongCheckbox)
        setCheckboxUnchecked(typeShortCheckbox)
        setCheckboxUnchecked(methodBuildCheckbox)
        setCheckboxUnchecked(methodStirCheckbox)
        setCheckboxUnchecked(methodShakeCheckbox)
        setCheckboxUnchecked(methodBlendCheckbox)
        setCheckboxUnchecked(methodOthersCheckbox)
        setFavoriteWarningVisibility()
        setTypeWarningVisibility()
        setMethodWarningVisibility()
    }
    
    @IBAction func favorite0CheckboxTapped(_ sender: M13Checkbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func favorite1CheckboxTapped(_ sender: M13Checkbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func favorite2CheckboxTapped(_ sender: M13Checkbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func favorite3CheckboxTapped(_ sender: M13Checkbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func typeLongCheckboxTapped(_ sender: M13Checkbox) {
        setTypeWarningVisibility()
    }
    
    @IBAction func typeShortCheckboxTapped(_ sender: M13Checkbox) {
        setTypeWarningVisibility()
    }
    
    @IBAction func methodBuildCheckboxTapped(_ sender: M13Checkbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodStirCheckboxTapped(_ sender: M13Checkbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodShakeCheckboxTapped(_ sender: M13Checkbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodBlendCheckboxTapped(_ sender: M13Checkbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodOthersCheckboxTapped(_ sender: M13Checkbox) {
        setMethodWarningVisibility()
    }
    
}
