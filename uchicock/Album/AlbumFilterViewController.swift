//
//  AlbumFilterViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/19.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import M13Checkbox

class AlbumFilterViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollBackgroundView: UIView!
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterExplanationLabel: UILabel!
    @IBOutlet weak var deselectAllButton: UIButton!
    @IBOutlet weak var selectAllButton: UIButton!
    
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
    
    @IBOutlet weak var secondSeparator: UIView!
    @IBOutlet weak var searchButtonBackgroundView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    var userDefaultsPrefix = "album-"
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
        
        recipeFilterStar0 = defaults.bool(forKey: userDefaultsPrefix + "filter-star0")
        recipeFilterStar1 = defaults.bool(forKey: userDefaultsPrefix + "filter-star1")
        recipeFilterStar2 = defaults.bool(forKey: userDefaultsPrefix + "filter-star2")
        recipeFilterStar3 = defaults.bool(forKey: userDefaultsPrefix + "filter-star3")
        recipeFilterLong = defaults.bool(forKey: userDefaultsPrefix + "filter-long")
        recipeFilterShort = defaults.bool(forKey: userDefaultsPrefix + "filter-short")
        recipeFilterBuild = defaults.bool(forKey: userDefaultsPrefix + "filter-build")
        recipeFilterStir = defaults.bool(forKey: userDefaultsPrefix + "filter-stir")
        recipeFilterShake = defaults.bool(forKey: userDefaultsPrefix + "filter-shake")
        recipeFilterBlend = defaults.bool(forKey: userDefaultsPrefix + "filter-blend")
        recipeFilterOthers = defaults.bool(forKey: userDefaultsPrefix + "filter-others")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.backgroundColor = Style.basicBackgroundColor
        scrollView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        scrollBackgroundView.backgroundColor = Style.basicBackgroundColor

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
        
        secondSeparator.backgroundColor = Style.labelTextColor
        searchButtonBackgroundView.backgroundColor = Style.basicBackgroundColor
        searchButton.layer.borderColor = Style.secondaryColor.cgColor
        searchButton.layer.borderWidth = 1.0
        searchButton.layer.cornerRadius = 5
        searchButton.tintColor = Style.secondaryColor
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
    }
    
    // MARK: - M13Checkbox
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
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        self.saveUserDefaults()
        self.onDoneBlock()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func saveUserDefaults(){
        setFilterUserDefaults(with: favorite0Checkbox, forKey: userDefaultsPrefix + "filter-star0")
        setFilterUserDefaults(with: favorite1Checkbox, forKey: userDefaultsPrefix + "filter-star1")
        setFilterUserDefaults(with: favorite2Checkbox, forKey: userDefaultsPrefix + "filter-star2")
        setFilterUserDefaults(with: favorite3Checkbox, forKey: userDefaultsPrefix + "filter-star3")
        setFilterUserDefaults(with: typeLongCheckbox, forKey: userDefaultsPrefix + "filter-long")
        setFilterUserDefaults(with: typeShortCheckbox, forKey: userDefaultsPrefix + "filter-short")
        setFilterUserDefaults(with: methodBuildCheckbox, forKey: userDefaultsPrefix + "filter-build")
        setFilterUserDefaults(with: methodStirCheckbox, forKey: userDefaultsPrefix + "filter-stir")
        setFilterUserDefaults(with: methodShakeCheckbox, forKey: userDefaultsPrefix + "filter-shake")
        setFilterUserDefaults(with: methodBlendCheckbox, forKey: userDefaultsPrefix + "filter-blend")
        setFilterUserDefaults(with: methodOthersCheckbox, forKey: userDefaultsPrefix + "filter-others")
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
