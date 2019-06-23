//
//  AlbumFilterViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/19.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import M13Checkbox

class AlbumFilterViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollBackgroundView: UIView!
    
    @IBOutlet weak var filterExplanationLabel: UILabel!
    
    @IBOutlet weak var favoriteDeselectAllButton: UIButton!
    @IBOutlet weak var favoriteSelectAllButton: UIButton!
    @IBOutlet weak var favorite0Checkbox: M13Checkbox!
    @IBOutlet weak var favorite1Checkbox: M13Checkbox!
    @IBOutlet weak var favorite2Checkbox: M13Checkbox!
    @IBOutlet weak var favorite3Checkbox: M13Checkbox!
    @IBOutlet weak var favoriteWarningImage: UIImageView!
    @IBOutlet weak var favoriteWarningLabel: UILabel!
    
    @IBOutlet weak var styleDeselectAllButton: UIButton!
    @IBOutlet weak var styleSelectAllButton: UIButton!
    @IBOutlet weak var styleLongCheckbox: M13Checkbox!
    @IBOutlet weak var styleShortCheckbox: M13Checkbox!
    @IBOutlet weak var styleHotCheckbox: M13Checkbox!
    @IBOutlet weak var styleNoneCheckbox: M13Checkbox!
    @IBOutlet weak var styleWarningImage: UIImageView!
    @IBOutlet weak var styleWarningLabel: UILabel!
    
    @IBOutlet weak var methodDeselectAllButton: UIButton!
    @IBOutlet weak var methodSelectAllButton: UIButton!
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
    var recipeFilterHot = true
    var recipeFilterStyleNone = true
    var recipeFilterBuild = true
    var recipeFilterStir = true
    var recipeFilterShake = true
    var recipeFilterBlend = true
    var recipeFilterOthers = true
    
    var interactor: Interactor!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    var onDoneBlock = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))

        readUserDefaults()
        
        initFilterCheckbox(favorite0Checkbox, shouldBeChecked: recipeFilterStar0)
        initFilterCheckbox(favorite1Checkbox, shouldBeChecked: recipeFilterStar1)
        initFilterCheckbox(favorite2Checkbox, shouldBeChecked: recipeFilterStar2)
        initFilterCheckbox(favorite3Checkbox, shouldBeChecked: recipeFilterStar3)
        initFilterCheckbox(styleLongCheckbox, shouldBeChecked: recipeFilterLong)
        initFilterCheckbox(styleShortCheckbox, shouldBeChecked: recipeFilterShort)
        initFilterCheckbox(styleHotCheckbox, shouldBeChecked: recipeFilterHot)
        initFilterCheckbox(styleNoneCheckbox, shouldBeChecked: recipeFilterStyleNone)
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
        recipeFilterHot = defaults.bool(forKey: userDefaultsPrefix + "filter-hot")
        recipeFilterStyleNone = defaults.bool(forKey: userDefaultsPrefix + "filter-stylenone")
        recipeFilterBuild = defaults.bool(forKey: userDefaultsPrefix + "filter-build")
        recipeFilterStir = defaults.bool(forKey: userDefaultsPrefix + "filter-stir")
        recipeFilterShake = defaults.bool(forKey: userDefaultsPrefix + "filter-shake")
        recipeFilterBlend = defaults.bool(forKey: userDefaultsPrefix + "filter-blend")
        recipeFilterOthers = defaults.bool(forKey: userDefaultsPrefix + "filter-others")
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.backgroundColor = Style.basicBackgroundColor
        scrollView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        scrollBackgroundView.backgroundColor = Style.basicBackgroundColor

        filterExplanationLabel.textColor = Style.labelTextColorLight
        
        favoriteDeselectAllButton.tintColor = Style.secondaryColor
        favoriteSelectAllButton.tintColor = Style.secondaryColor
        favoriteWarningImage.image = favoriteWarningImage.image!.withRenderingMode(.alwaysTemplate)
        favoriteWarningImage.tintColor = Style.secondaryColor
        favoriteWarningLabel.textColor = Style.secondaryColor
        setFavoriteWarningVisibility()
        
        styleDeselectAllButton.tintColor = Style.secondaryColor
        styleSelectAllButton.tintColor = Style.secondaryColor
        styleWarningImage.image = styleWarningImage.image!.withRenderingMode(.alwaysTemplate)
        styleWarningImage.tintColor = Style.secondaryColor
        styleWarningLabel.textColor = Style.secondaryColor
        setStyleWarningVisibility()
        
        methodDeselectAllButton.tintColor = Style.secondaryColor
        methodSelectAllButton.tintColor = Style.secondaryColor
        methodWarningImage.image = methodWarningImage.image!.withRenderingMode(.alwaysTemplate)
        methodWarningImage.tintColor = Style.secondaryColor
        methodWarningLabel.textColor = Style.secondaryColor
        setMethodWarningVisibility()
        
        secondSeparator.backgroundColor = Style.labelTextColor
        searchButtonBackgroundView.backgroundColor = Style.basicBackgroundColor
        searchButton.layer.borderColor = Style.secondaryColor.cgColor
        searchButton.layer.borderWidth = 1.0
        searchButton.layer.cornerRadius = 20
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
    
    private func setStyleWarningVisibility(){
        if styleLongCheckbox.checkState == .unchecked &&
            styleShortCheckbox.checkState == .unchecked &&
            styleHotCheckbox.checkState == .unchecked &&
            styleNoneCheckbox.checkState == .unchecked{
            styleWarningImage.isHidden = false
            styleWarningLabel.isHidden = false
        }else{
            styleWarningImage.isHidden = true
            styleWarningLabel.isHidden = true
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
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    // 大事な処理はviewDidDisappearの中でする
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDoneBlock()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if interactor.hasStarted {
            scrollView.contentOffset.y = 0.0
        }
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
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        if scrollView.contentOffset.y <= 0 || interactor.hasStarted{
            switch sender.state {
            case .began:
                interactor.hasStarted = true
                dismiss(animated: true, completion: nil)
            case .changed:
                interactor.shouldFinish = progress > percentThreshold
                interactor.update(progress)
                break
            case .cancelled:
                interactor.hasStarted = false
                interactor.cancel()
            case .ended:
                interactor.hasStarted = false
                interactor.shouldFinish
                    ? interactor.finish()
                    : interactor.cancel()
            default:
                break
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        self.saveUserDefaults()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func saveUserDefaults(){
        setFilterUserDefaults(with: favorite0Checkbox, forKey: userDefaultsPrefix + "filter-star0")
        setFilterUserDefaults(with: favorite1Checkbox, forKey: userDefaultsPrefix + "filter-star1")
        setFilterUserDefaults(with: favorite2Checkbox, forKey: userDefaultsPrefix + "filter-star2")
        setFilterUserDefaults(with: favorite3Checkbox, forKey: userDefaultsPrefix + "filter-star3")
        setFilterUserDefaults(with: styleLongCheckbox, forKey: userDefaultsPrefix + "filter-long")
        setFilterUserDefaults(with: styleShortCheckbox, forKey: userDefaultsPrefix + "filter-short")
        setFilterUserDefaults(with: styleHotCheckbox, forKey: userDefaultsPrefix + "filter-hot")
        setFilterUserDefaults(with: styleNoneCheckbox, forKey: userDefaultsPrefix + "filter-stylenone")
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
    
    @IBAction func favoriteDeselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(favorite0Checkbox)
        setCheckboxUnchecked(favorite1Checkbox)
        setCheckboxUnchecked(favorite2Checkbox)
        setCheckboxUnchecked(favorite3Checkbox)
        setFavoriteWarningVisibility()
    }
    
    @IBAction func favoriteSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(favorite0Checkbox)
        setCheckboxChecked(favorite1Checkbox)
        setCheckboxChecked(favorite2Checkbox)
        setCheckboxChecked(favorite3Checkbox)
        setFavoriteWarningVisibility()
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
    
    @IBAction func styleDeselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(styleLongCheckbox)
        setCheckboxUnchecked(styleShortCheckbox)
        setCheckboxUnchecked(styleHotCheckbox)
        setCheckboxUnchecked(styleNoneCheckbox)
        setStyleWarningVisibility()
    }
    
    @IBAction func styleSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(styleLongCheckbox)
        setCheckboxChecked(styleShortCheckbox)
        setCheckboxChecked(styleHotCheckbox)
        setCheckboxChecked(styleNoneCheckbox)
        setStyleWarningVisibility()
    }
    
    @IBAction func styleLongCheckboxTapped(_ sender: M13Checkbox) {
        setStyleWarningVisibility()
    }
    
    @IBAction func styleShortCheckboxTapped(_ sender: M13Checkbox) {
        setStyleWarningVisibility()
    }

    @IBAction func styleHotCheckboxTapped(_ sender: M13Checkbox) {
        setStyleWarningVisibility()
    }
    
    @IBAction func styleNoneCheckboxTapped(_ sender: M13Checkbox) {
        setStyleWarningVisibility()
    }
    
    @IBAction func methodDeselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(methodBuildCheckbox)
        setCheckboxUnchecked(methodStirCheckbox)
        setCheckboxUnchecked(methodShakeCheckbox)
        setCheckboxUnchecked(methodBlendCheckbox)
        setCheckboxUnchecked(methodOthersCheckbox)
        setMethodWarningVisibility()
    }
    
    @IBAction func methodSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(methodBuildCheckbox)
        setCheckboxChecked(methodStirCheckbox)
        setCheckboxChecked(methodShakeCheckbox)
        setCheckboxChecked(methodBlendCheckbox)
        setCheckboxChecked(methodOthersCheckbox)
        setMethodWarningVisibility()
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
