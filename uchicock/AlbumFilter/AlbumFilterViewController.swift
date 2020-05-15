//
//  AlbumFilterViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/19.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class AlbumFilterViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollBackgroundView: UIView!
    
    @IBOutlet weak var filterExplanationLabel: UILabel!
    @IBOutlet weak var filterSelectAllButton: UIButton!
    
    @IBOutlet weak var favoriteDeselectAllButton: UIButton!
    @IBOutlet weak var favoriteSelectAllButton: UIButton!
    @IBOutlet weak var favorite0Checkbox: CircularCheckbox!
    @IBOutlet weak var favorite1Checkbox: CircularCheckbox!
    @IBOutlet weak var favorite2Checkbox: CircularCheckbox!
    @IBOutlet weak var favorite3Checkbox: CircularCheckbox!
    @IBOutlet weak var favorite0Button: UIButton!
    @IBOutlet weak var favorite1Button: UIButton!
    @IBOutlet weak var favorite2Button: UIButton!
    @IBOutlet weak var favorite3Button: UIButton!
    @IBOutlet weak var favoriteWarningImage: UIImageView!
    @IBOutlet weak var favoriteWarningLabel: UILabel!
    
    @IBOutlet weak var styleDeselectAllButton: UIButton!
    @IBOutlet weak var styleSelectAllButton: UIButton!
    @IBOutlet weak var styleLongCheckbox: CircularCheckbox!
    @IBOutlet weak var styleShortCheckbox: CircularCheckbox!
    @IBOutlet weak var styleHotCheckbox: CircularCheckbox!
    @IBOutlet weak var styleNoneCheckbox: CircularCheckbox!
    @IBOutlet weak var styleLongButton: UIButton!
    @IBOutlet weak var styleShortButton: UIButton!
    @IBOutlet weak var styleHotButton: UIButton!
    @IBOutlet weak var styleNoneButton: UIButton!
    @IBOutlet weak var styleWarningImage: UIImageView!
    @IBOutlet weak var styleWarningLabel: UILabel!
    
    @IBOutlet weak var methodDeselectAllButton: UIButton!
    @IBOutlet weak var methodSelectAllButton: UIButton!
    @IBOutlet weak var methodBuildCheckbox: CircularCheckbox!
    @IBOutlet weak var methodStirCheckbox: CircularCheckbox!
    @IBOutlet weak var methodShakeCheckbox: CircularCheckbox!
    @IBOutlet weak var methodBlendCheckbox: CircularCheckbox!
    @IBOutlet weak var methodOthersCheckbox: CircularCheckbox!
    @IBOutlet weak var methodBuildButton: UIButton!
    @IBOutlet weak var methodStirButton: UIButton!
    @IBOutlet weak var methodShakeButton: UIButton!
    @IBOutlet weak var methodBlendButton: UIButton!
    @IBOutlet weak var methodOthersButton: UIButton!
    @IBOutlet weak var methodWarningImage: UIImageView!
    @IBOutlet weak var methodWarningLabel: UILabel!
    
    @IBOutlet weak var strengthDeselectAllButton: UIButton!
    @IBOutlet weak var strengthSelectAllButton: UIButton!
    @IBOutlet weak var strengthNonAlcoholCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthWeakCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthMediumCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthStrongCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthNoneCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthNonAlcoholButton: UIButton!
    @IBOutlet weak var strengthWeakButton: UIButton!
    @IBOutlet weak var strengthMediumButton: UIButton!
    @IBOutlet weak var strengthStrongButton: UIButton!
    @IBOutlet weak var strengthNoneButton: UIButton!
    @IBOutlet weak var strengthWarningImage: UIImageView!
    @IBOutlet weak var strengthWarningLabel: UILabel!
    
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
    var recipeFilterNonAlcohol = true
    var recipeFilterWeak = true
    var recipeFilterMedium = true
    var recipeFilterStrong = true
    var recipeFilterStrengthNone = true
    
    var recipeBasicListForFilterModal = Array<RecipeBasic>()
    var filteredRecipeBasic = Array<RecipeBasic>()

    var interactor: Interactor?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    var onDoneBlock = {}
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        if interactor != nil{
            scrollView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }

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
        initFilterCheckbox(strengthNonAlcoholCheckbox, shouldBeChecked: recipeFilterNonAlcohol)
        initFilterCheckbox(strengthWeakCheckbox, shouldBeChecked: recipeFilterWeak)
        initFilterCheckbox(strengthMediumCheckbox, shouldBeChecked: recipeFilterMedium)
        initFilterCheckbox(strengthStrongCheckbox, shouldBeChecked: recipeFilterStrong)
        initFilterCheckbox(strengthNoneCheckbox, shouldBeChecked: recipeFilterStrengthNone)
        
        filterRecipeBasic()
        
        self.view.backgroundColor = UchicockStyle.basicBackgroundColor
        scrollView.backgroundColor = UchicockStyle.basicBackgroundColor
        scrollView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        scrollBackgroundView.backgroundColor = UchicockStyle.basicBackgroundColor

        filterExplanationLabel.textColor = UchicockStyle.labelTextColorLight
        filterSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)

        favoriteDeselectAllButton.setTitleColor(UchicockStyle.alertColor, for: .normal)
        favoriteSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        favorite0Button.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        favorite1Button.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        favorite2Button.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        favorite3Button.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        favoriteWarningImage.tintColor = UchicockStyle.alertColor
        favoriteWarningLabel.textColor = UchicockStyle.alertColor
        setFavoriteWarningVisibility()
        
        styleDeselectAllButton.setTitleColor(UchicockStyle.alertColor, for: .normal)
        styleSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        styleLongButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        styleShortButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        styleHotButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        styleNoneButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        styleWarningImage.tintColor = UchicockStyle.alertColor
        styleWarningLabel.textColor = UchicockStyle.alertColor
        setStyleWarningVisibility()
        
        methodDeselectAllButton.setTitleColor(UchicockStyle.alertColor, for: .normal)
        methodSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        methodBuildButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        methodStirButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        methodShakeButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        methodBlendButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        methodOthersButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        methodWarningImage.tintColor = UchicockStyle.alertColor
        methodWarningLabel.textColor = UchicockStyle.alertColor
        setMethodWarningVisibility()
        
        strengthDeselectAllButton.setTitleColor(UchicockStyle.alertColor, for: .normal)
        strengthSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        strengthNonAlcoholButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        strengthWeakButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        strengthMediumButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        strengthStrongButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        strengthNoneButton.setTitleColor(UchicockStyle.labelTextColor, for: .normal)
        strengthWarningImage.tintColor = UchicockStyle.alertColor
        strengthWarningLabel.textColor = UchicockStyle.alertColor
        setStrengthWarningVisibility()

        secondSeparator.backgroundColor = UchicockStyle.labelTextColor
        searchButtonBackgroundView.backgroundColor = UchicockStyle.basicBackgroundColor
        searchButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        searchButton.layer.borderWidth = 1.5
        searchButton.layer.cornerRadius = 20
        searchButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        searchButton.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 18)
    }
    
    private func readUserDefaults(){
        let defaults = UserDefaults.standard
        
        recipeFilterStar0 = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStar0Key)
        recipeFilterStar1 = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStar1Key)
        recipeFilterStar2 = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStar2Key)
        recipeFilterStar3 = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStar3Key)
        recipeFilterLong = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterLongKey)
        recipeFilterShort = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterShortKey)
        recipeFilterHot = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterHotKey)
        recipeFilterStyleNone = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStyleNoneKey)
        recipeFilterBuild = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterBuildKey)
        recipeFilterStir = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStirKey)
        recipeFilterShake = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterShakeKey)
        recipeFilterBlend = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterBlendKey)
        recipeFilterOthers = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterOthersKey)
        recipeFilterNonAlcohol = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterNonAlcoholKey)
        recipeFilterWeak = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterWeakKey)
        recipeFilterMedium = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterMediumKey)
        recipeFilterStrong = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStrongKey)
        recipeFilterStrengthNone = defaults.bool(forKey: userDefaultsPrefix + GlobalConstants.FilterStrengthNoneKey)
    }
    
    private func filterRecipeBasic(){
        filteredRecipeBasic = recipeBasicListForFilterModal
        
        if favorite0Checkbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.favorites == 0 }
        }
        if favorite1Checkbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.favorites == 1 }
        }
        if favorite2Checkbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.favorites == 2 }
        }
        if favorite3Checkbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.favorites == 3 }
        }
        if styleLongCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.style == 0 }
        }
        if styleShortCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.style == 1 }
        }
        if styleHotCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.style == 2 }
        }
        if styleNoneCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.style == 3 }
        }
        if methodBuildCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.method == 0 }
        }
        if methodStirCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.method == 1 }
        }
        if methodShakeCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.method == 2 }
        }
        if methodBlendCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.method == 3 }
        }
        if methodOthersCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.method == 4 }
        }
        if strengthNonAlcoholCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.strength == 0 }
        }
        if strengthWeakCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.strength == 1 }
        }
        if strengthMediumCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.strength == 2 }
        }
        if strengthStrongCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.strength == 3 }
        }
        if strengthNoneCheckbox.checkState == .unchecked{
            filteredRecipeBasic.removeAll{ $0.strength == 4 }
        }
        
        searchButton.setTitle("決定 (" + String(filteredRecipeBasic.count) +  "レシピ)", for: .normal)
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
    
    private func setStrengthWarningVisibility(){
        if strengthNonAlcoholCheckbox.checkState == .unchecked &&
            strengthWeakCheckbox.checkState == .unchecked &&
            strengthMediumCheckbox.checkState == .unchecked &&
            strengthStrongCheckbox.checkState == .unchecked &&
            strengthNoneCheckbox.checkState == .unchecked {
            strengthWarningImage.isHidden = false
            strengthWarningLabel.isHidden = false
        }else{
            strengthWarningImage.isHidden = true
            strengthWarningLabel.isHidden = true
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
        if interactor != nil{
            if interactor!.hasStarted {
                scrollView.contentOffset.y = 0.0
            }
        }
    }

    // MARK: - CircularCheckbox
    private func initFilterCheckbox(_ checkbox: CircularCheckbox, shouldBeChecked: Bool){
        if shouldBeChecked{
            initCheckbox(checkbox, with: .checked)
        }else{
            initCheckbox(checkbox, with: .unchecked)
        }
    }
    
    private func initCheckbox(_ checkbox: CircularCheckbox, with checkState: CircularCheckbox.CheckState){
        checkbox.boxLineWidth = 1.0
        checkbox.stateChangeAnimation = .fade
        checkbox.animationDuration = 0
        checkbox.setCheckState(checkState, animated: true)
        checkbox.isEnabled = true
        checkbox.tintColor = UchicockStyle.primaryColor
        checkbox.animationDuration = 0.3
        checkbox.stateChangeAnimation = .expand
        checkbox.secondaryTintColor = UchicockStyle.primaryColor
        checkbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        checkbox.contentHorizontalAlignment = .center
    }
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        guard let interactor = interactor else { return }
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
    @IBAction func searchButtonTouchedDown(_ sender: UIButton) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UchicockStyle.primaryColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        sender.setTitleColor(UIColor(red: red, green: green, blue: blue, alpha: 0.3), for: .normal)
    }
    
    @IBAction func searchButtonDraggedInside(_ sender: UIButton) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UchicockStyle.primaryColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        sender.setTitleColor(UIColor(red: red, green: green, blue: blue, alpha: 0.3), for: .normal)

    }
    
    @IBAction func searchButtonDraggedOutside(_ sender: UIButton) {
        sender.setTitleColor(UchicockStyle.primaryColor, for: .normal)
    }
    
    @IBAction func searchButtonTouchedUpInside(_ sender: UIButton) {
        sender.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        self.saveUserDefaults()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func saveUserDefaults(){
        setFilterUserDefaults(with: favorite0Checkbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStar0Key)
        setFilterUserDefaults(with: favorite1Checkbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStar1Key)
        setFilterUserDefaults(with: favorite2Checkbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStar2Key)
        setFilterUserDefaults(with: favorite3Checkbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStar3Key)
        setFilterUserDefaults(with: styleLongCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterLongKey)
        setFilterUserDefaults(with: styleShortCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterShortKey)
        setFilterUserDefaults(with: styleHotCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterHotKey)
        setFilterUserDefaults(with: styleNoneCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStyleNoneKey)
        setFilterUserDefaults(with: methodBuildCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterBuildKey)
        setFilterUserDefaults(with: methodStirCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStirKey)
        setFilterUserDefaults(with: methodShakeCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterShakeKey)
        setFilterUserDefaults(with: methodBlendCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterBlendKey)
        setFilterUserDefaults(with: methodOthersCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterOthersKey)
        setFilterUserDefaults(with: strengthNonAlcoholCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterNonAlcoholKey)
        setFilterUserDefaults(with: strengthWeakCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterWeakKey)
        setFilterUserDefaults(with: strengthMediumCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterMediumKey)
        setFilterUserDefaults(with: strengthStrongCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStrongKey)
        setFilterUserDefaults(with: strengthNoneCheckbox, forKey: userDefaultsPrefix + GlobalConstants.FilterStrengthNoneKey)
    }
    
    private func setFilterUserDefaults(with checkbox: CircularCheckbox, forKey key: String){
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
    
    private func setCheckboxChecked(_ checkbox: CircularCheckbox){
        checkbox.setCheckState(.checked, animated: true)
        checkbox.isEnabled = true
        checkbox.tintColor = UchicockStyle.primaryColor
    }
    
    private func setCheckboxUnchecked(_ checkbox: CircularCheckbox){
        checkbox.setCheckState(.unchecked, animated: true)
        checkbox.isEnabled = true
        checkbox.tintColor = UchicockStyle.primaryColor
    }
    
    @IBAction func filterSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(favorite0Checkbox)
        setCheckboxChecked(favorite1Checkbox)
        setCheckboxChecked(favorite2Checkbox)
        setCheckboxChecked(favorite3Checkbox)
        setFavoriteWarningVisibility()

        setCheckboxChecked(styleLongCheckbox)
        setCheckboxChecked(styleShortCheckbox)
        setCheckboxChecked(styleHotCheckbox)
        setCheckboxChecked(styleNoneCheckbox)
        setStyleWarningVisibility()

        setCheckboxChecked(methodBuildCheckbox)
        setCheckboxChecked(methodStirCheckbox)
        setCheckboxChecked(methodShakeCheckbox)
        setCheckboxChecked(methodBlendCheckbox)
        setCheckboxChecked(methodOthersCheckbox)
        setMethodWarningVisibility()

        setCheckboxChecked(strengthNonAlcoholCheckbox)
        setCheckboxChecked(strengthWeakCheckbox)
        setCheckboxChecked(strengthMediumCheckbox)
        setCheckboxChecked(strengthStrongCheckbox)
        setCheckboxChecked(strengthNoneCheckbox)
        setStrengthWarningVisibility()

        filterRecipeBasic()
    }
    
    @IBAction func favoriteDeselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(favorite0Checkbox)
        setCheckboxUnchecked(favorite1Checkbox)
        setCheckboxUnchecked(favorite2Checkbox)
        setCheckboxUnchecked(favorite3Checkbox)
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favoriteSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(favorite0Checkbox)
        setCheckboxChecked(favorite1Checkbox)
        setCheckboxChecked(favorite2Checkbox)
        setCheckboxChecked(favorite3Checkbox)
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite0CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite1CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite2CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite3CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite0ButtonTapped(_ sender: UIButton) {
        if favorite0Checkbox.checkState == .checked{
            setCheckboxUnchecked(favorite0Checkbox)
        }else if favorite0Checkbox.checkState == .unchecked{
            setCheckboxChecked(favorite0Checkbox)
        }
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite1ButtonTapped(_ sender: UIButton) {
        if favorite1Checkbox.checkState == .checked{
            setCheckboxUnchecked(favorite1Checkbox)
        }else if favorite1Checkbox.checkState == .unchecked{
            setCheckboxChecked(favorite1Checkbox)
        }
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite2ButtonTapped(_ sender: UIButton) {
        if favorite2Checkbox.checkState == .checked{
            setCheckboxUnchecked(favorite2Checkbox)
        }else if favorite2Checkbox.checkState == .unchecked{
            setCheckboxChecked(favorite2Checkbox)
        }
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func favorite3ButtonTapped(_ sender: UIButton) {
        if favorite3Checkbox.checkState == .checked{
            setCheckboxUnchecked(favorite3Checkbox)
        }else if favorite3Checkbox.checkState == .unchecked{
            setCheckboxChecked(favorite3Checkbox)
        }
        setFavoriteWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleDeselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(styleLongCheckbox)
        setCheckboxUnchecked(styleShortCheckbox)
        setCheckboxUnchecked(styleHotCheckbox)
        setCheckboxUnchecked(styleNoneCheckbox)
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(styleLongCheckbox)
        setCheckboxChecked(styleShortCheckbox)
        setCheckboxChecked(styleHotCheckbox)
        setCheckboxChecked(styleNoneCheckbox)
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleLongCheckboxTapped(_ sender: CircularCheckbox) {
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleShortCheckboxTapped(_ sender: CircularCheckbox) {
        setStyleWarningVisibility()
        filterRecipeBasic()
    }

    @IBAction func styleHotCheckboxTapped(_ sender: CircularCheckbox) {
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleNoneCheckboxTapped(_ sender: CircularCheckbox) {
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleLongButtonTapped(_ sender: UIButton) {
        if styleLongCheckbox.checkState == .checked {
            setCheckboxUnchecked(styleLongCheckbox)
        }else if styleLongCheckbox.checkState == .unchecked{
            setCheckboxChecked(styleLongCheckbox)
        }
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleShortButtonTapped(_ sender: UIButton) {
        if styleShortCheckbox.checkState == .checked {
            setCheckboxUnchecked(styleShortCheckbox)
        }else if styleShortCheckbox.checkState == .unchecked{
            setCheckboxChecked(styleShortCheckbox)
        }
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleHotButtonTapped(_ sender: UIButton) {
        if styleHotCheckbox.checkState == .checked {
            setCheckboxUnchecked(styleHotCheckbox)
        }else if styleHotCheckbox.checkState == .unchecked{
            setCheckboxChecked(styleHotCheckbox)
        }
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func styleNoneButtonTapped(_ sender: UIButton) {
        if styleNoneCheckbox.checkState == .checked {
            setCheckboxUnchecked(styleNoneCheckbox)
        }else if styleNoneCheckbox.checkState == .unchecked{
            setCheckboxChecked(styleNoneCheckbox)
        }
        setStyleWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodDeselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(methodBuildCheckbox)
        setCheckboxUnchecked(methodStirCheckbox)
        setCheckboxUnchecked(methodShakeCheckbox)
        setCheckboxUnchecked(methodBlendCheckbox)
        setCheckboxUnchecked(methodOthersCheckbox)
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(methodBuildCheckbox)
        setCheckboxChecked(methodStirCheckbox)
        setCheckboxChecked(methodShakeCheckbox)
        setCheckboxChecked(methodBlendCheckbox)
        setCheckboxChecked(methodOthersCheckbox)
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodBuildCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodStirCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodShakeCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodBlendCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodOthersCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodBuildButtonTapped(_ sender: UIButton) {
        if methodBuildCheckbox.checkState == .checked {
            setCheckboxUnchecked(methodBuildCheckbox)
        }else if methodBuildCheckbox.checkState == .unchecked{
            setCheckboxChecked(methodBuildCheckbox)
        }
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodStirButtonTapped(_ sender: UIButton) {
        if methodStirCheckbox.checkState == .checked {
            setCheckboxUnchecked(methodStirCheckbox)
        }else if methodStirCheckbox.checkState == .unchecked{
            setCheckboxChecked(methodStirCheckbox)
        }
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodShakeButtonTapped(_ sender: UIButton) {
        if methodShakeCheckbox.checkState == .checked {
            setCheckboxUnchecked(methodShakeCheckbox)
        }else if methodShakeCheckbox.checkState == .unchecked{
            setCheckboxChecked(methodShakeCheckbox)
        }
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodBlendButtonTapped(_ sender: UIButton) {
        if methodBlendCheckbox.checkState == .checked {
            setCheckboxUnchecked(methodBlendCheckbox)
        }else if methodBlendCheckbox.checkState == .unchecked{
            setCheckboxChecked(methodBlendCheckbox)
        }
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func methodOthersButtonTapped(_ sender: UIButton) {
        if methodOthersCheckbox.checkState == .checked {
            setCheckboxUnchecked(methodOthersCheckbox)
        }else if methodOthersCheckbox.checkState == .unchecked{
            setCheckboxChecked(methodOthersCheckbox)
        }
        setMethodWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthDeselectAllButtonTapped(_ sender: UIButton) {
        setCheckboxUnchecked(strengthNonAlcoholCheckbox)
        setCheckboxUnchecked(strengthWeakCheckbox)
        setCheckboxUnchecked(strengthMediumCheckbox)
        setCheckboxUnchecked(strengthStrongCheckbox)
        setCheckboxUnchecked(strengthNoneCheckbox)
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthSelectAllButtonTapped(_ sender: UIButton) {
        setCheckboxChecked(strengthNonAlcoholCheckbox)
        setCheckboxChecked(strengthWeakCheckbox)
        setCheckboxChecked(strengthMediumCheckbox)
        setCheckboxChecked(strengthStrongCheckbox)
        setCheckboxChecked(strengthNoneCheckbox)
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthNonAlcoholCheckboxTapped(_ sender: CircularCheckbox) {
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthWeakCheckboxTapped(_ sender: CircularCheckbox) {
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthMediumCheckboxTapped(_ sender: CircularCheckbox) {
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthStrongCheckboxTapped(_ sender: CircularCheckbox) {
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthNoneCheckboxTapped(_ sender: CircularCheckbox) {
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthNonAlcoholButtonTapped(_ sender: UIButton) {
        if strengthNonAlcoholCheckbox.checkState == .checked {
            setCheckboxUnchecked(strengthNonAlcoholCheckbox)
        }else if strengthNonAlcoholCheckbox.checkState == .unchecked{
            setCheckboxChecked(strengthNonAlcoholCheckbox)
        }
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthWeakButtonTapped(_ sender: UIButton) {
        if strengthWeakCheckbox.checkState == .checked {
            setCheckboxUnchecked(strengthWeakCheckbox)
        }else if strengthWeakCheckbox.checkState == .unchecked{
            setCheckboxChecked(strengthWeakCheckbox)
        }
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthMediumButtonTapped(_ sender: UIButton) {
        if strengthMediumCheckbox.checkState == .checked {
            setCheckboxUnchecked(strengthMediumCheckbox)
        }else if strengthMediumCheckbox.checkState == .unchecked{
            setCheckboxChecked(strengthMediumCheckbox)
        }
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthStrongButtonTapped(_ sender: UIButton) {
        if strengthStrongCheckbox.checkState == .checked {
            setCheckboxUnchecked(strengthStrongCheckbox)
        }else if strengthStrongCheckbox.checkState == .unchecked{
            setCheckboxChecked(strengthStrongCheckbox)
        }
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
    
    @IBAction func strengthNoneButtonTapped(_ sender: UIButton) {
        if strengthNoneCheckbox.checkState == .checked {
            setCheckboxUnchecked(strengthNoneCheckbox)
        }else if strengthNoneCheckbox.checkState == .unchecked{
            setCheckboxChecked(strengthNoneCheckbox)
        }
        setStrengthWarningVisibility()
        filterRecipeBasic()
    }
}
