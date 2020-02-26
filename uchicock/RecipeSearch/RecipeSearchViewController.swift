//
//  RecipeSearchViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/18.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class RecipeSearchViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollBackgroundView: UIView!

    @IBOutlet weak var sortExplanationLabel: UILabel!
    
    @IBOutlet weak var nameOrderPrimaryCheckbox: CircularCheckbox!
    @IBOutlet weak var nameOrderSecondaryCheckbox: CircularCheckbox!
    @IBOutlet weak var shortageOrderPrimaryCheckbox: CircularCheckbox!
    @IBOutlet weak var shortageOrderSecondaryCheckbox: CircularCheckbox!
    @IBOutlet weak var madeNumOrderPrimaryCheckbox: CircularCheckbox!
    @IBOutlet weak var madeNumOrderSecondaryCheckbox: CircularCheckbox!
    @IBOutlet weak var favoriteOrderPrimaryCheckbox: CircularCheckbox!
    @IBOutlet weak var favoriteOrderSecondaryCheckbox: CircularCheckbox!
    @IBOutlet weak var lastViewedOrderPrimaryCheckbox: CircularCheckbox!
    @IBOutlet weak var lastViewedOrderSecondaryCheckbox: CircularCheckbox!
    
    @IBOutlet weak var firstSeparator: UIView!
    
    @IBOutlet weak var filterExplanationLabel: UILabel!
    
    @IBOutlet weak var favoriteDeselectAllButton: UIButton!
    @IBOutlet weak var favoriteSelectAllButton: UIButton!
    @IBOutlet weak var favorite0Checkbox: CircularCheckbox!
    @IBOutlet weak var favorite1Checkbox: CircularCheckbox!
    @IBOutlet weak var favorite2Checkbox: CircularCheckbox!
    @IBOutlet weak var favorite3Checkbox: CircularCheckbox!
    @IBOutlet weak var favoriteWarningImage: UIImageView!
    @IBOutlet weak var favoriteWarningLabel: UILabel!
    
    @IBOutlet weak var styleDeselectAllButton: UIButton!
    @IBOutlet weak var styleSelectAllButton: UIButton!
    @IBOutlet weak var styleLongCheckbox: CircularCheckbox!
    @IBOutlet weak var styleShortCheckbox: CircularCheckbox!
    @IBOutlet weak var styleHotCheckbox: CircularCheckbox!
    @IBOutlet weak var styleNoneCheckbox: CircularCheckbox!
    @IBOutlet weak var styleWarningImage: UIImageView!
    @IBOutlet weak var styleWarningLabel: UILabel!
    
    @IBOutlet weak var methodDeselectAllButton: UIButton!
    @IBOutlet weak var methodSelectAllButton: UIButton!
    @IBOutlet weak var methodBuildCheckbox: CircularCheckbox!
    @IBOutlet weak var methodStirCheckbox: CircularCheckbox!
    @IBOutlet weak var methodShakeCheckbox: CircularCheckbox!
    @IBOutlet weak var methodBlendCheckbox: CircularCheckbox!
    @IBOutlet weak var methodOthersCheckbox: CircularCheckbox!
    @IBOutlet weak var methodWarningImage: UIImageView!
    @IBOutlet weak var methodWarningLabel: UILabel!
    
    @IBOutlet weak var strengthDeselectAllbutton: UIButton!
    @IBOutlet weak var strengthSelectAllButton: UIButton!
    @IBOutlet weak var strengthNonAlcoholCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthWeakCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthMediumCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthStrongCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthNoneCheckbox: CircularCheckbox!
    @IBOutlet weak var strengthWarningImage: UIImageView!
    @IBOutlet weak var strengthWarningLabel: UILabel!
    
    @IBOutlet weak var secondSeparator: UIView!
    @IBOutlet weak var searchButtonBackgroundView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    var userDefaultsPrefix = "recipe-"
    var recipeSortPrimary = 1
    var recipeSortSecondary = 0
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

    var interactor: Interactor?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UchicockStyle.statusBarStyle
    }
    
    var onDoneBlock = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        if interactor != nil{
            scrollView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        }

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
    }
    
    private func readUserDefaults(){
        let defaults = UserDefaults.standard

        recipeSortPrimary = defaults.integer(forKey: userDefaultsPrefix + GlobalConstants.SortPrimaryKey)
        recipeSortSecondary = defaults.integer(forKey: userDefaultsPrefix + GlobalConstants.SortSecondaryKey)
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
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UchicockStyle.basicBackgroundColor
        scrollView.backgroundColor = UchicockStyle.basicBackgroundColor
        scrollView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        scrollBackgroundView.backgroundColor = UchicockStyle.basicBackgroundColor

        sortExplanationLabel.textColor = UchicockStyle.labelTextColorLight
        firstSeparator.backgroundColor = UchicockStyle.labelTextColor
        
        filterExplanationLabel.textColor = UchicockStyle.labelTextColorLight

        favoriteSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        favoriteDeselectAllButton.setTitleColor(UchicockStyle.deleteColor, for: .normal)
        favoriteWarningImage.tintColor = UchicockStyle.deleteColor
        favoriteWarningLabel.textColor = UchicockStyle.deleteColor
        setFavoriteWarningVisibility()

        styleSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        styleDeselectAllButton.setTitleColor(UchicockStyle.deleteColor, for: .normal)
        styleWarningImage.tintColor = UchicockStyle.deleteColor
        styleWarningLabel.textColor = UchicockStyle.deleteColor
        setStyleWarningVisibility()

        methodSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        methodDeselectAllButton.setTitleColor(UchicockStyle.deleteColor, for: .normal)
        methodWarningImage.tintColor = UchicockStyle.deleteColor
        methodWarningLabel.textColor = UchicockStyle.deleteColor
        setMethodWarningVisibility()
        
        strengthSelectAllButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
        strengthDeselectAllbutton.setTitleColor(UchicockStyle.deleteColor, for: .normal)
        strengthWarningImage.tintColor = UchicockStyle.deleteColor
        strengthWarningLabel.textColor = UchicockStyle.deleteColor
        setStrengthWarningVisibility()

        secondSeparator.backgroundColor = UchicockStyle.labelTextColor
        searchButtonBackgroundView.backgroundColor = UchicockStyle.basicBackgroundColor
        searchButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        searchButton.layer.borderWidth = 1.5
        searchButton.layer.cornerRadius = 20
        searchButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
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
    private func initPrimaryCheckBox(nameState: CircularCheckbox.CheckState, shortageState:  CircularCheckbox.CheckState,
                                     madeNumState:  CircularCheckbox.CheckState, favoriteState: CircularCheckbox.CheckState, lastViewedState: CircularCheckbox.CheckState){
        initCheckbox(nameOrderPrimaryCheckbox, with: nameState)
        initCheckbox(shortageOrderPrimaryCheckbox, with: shortageState)
        initCheckbox(madeNumOrderPrimaryCheckbox, with: madeNumState)
        initCheckbox(favoriteOrderPrimaryCheckbox, with: favoriteState)
        initCheckbox(lastViewedOrderPrimaryCheckbox, with: lastViewedState)
    }
    
    private func initSecondaryCheckBox(nameState: CircularCheckbox.CheckState, shortageState:  CircularCheckbox.CheckState,
                                       madeNumState:  CircularCheckbox.CheckState, favoriteState: CircularCheckbox.CheckState, lastViewedState: CircularCheckbox.CheckState){
        initCheckbox(nameOrderSecondaryCheckbox, with: nameState)
        initCheckbox(shortageOrderSecondaryCheckbox, with: shortageState)
        initCheckbox(madeNumOrderSecondaryCheckbox, with: madeNumState)
        initCheckbox(favoriteOrderSecondaryCheckbox, with: favoriteState)
        initCheckbox(lastViewedOrderSecondaryCheckbox, with: lastViewedState)
    }
    
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
        if checkState == .mixed{
            checkbox.isEnabled = false
            checkbox.tintColor = UchicockStyle.labelTextColorLight
            checkbox.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
        }else{
            checkbox.isEnabled = true
            checkbox.tintColor = UchicockStyle.primaryColor
            checkbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        }
        checkbox.animationDuration = 0.3
        checkbox.stateChangeAnimation = .expand
        checkbox.secondaryTintColor = UchicockStyle.primaryColor
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
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        self.saveUserDefaults()
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
        
        defaults.set(primarySort, forKey: userDefaultsPrefix + GlobalConstants.SortPrimaryKey)
        defaults.set(secondarySort, forKey: userDefaultsPrefix + GlobalConstants.SortSecondaryKey)
        
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
    
    @IBAction func nameOrderPrimaryCheckboxTapped(_ sender: CircularCheckbox) {
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
    
    @IBAction func nameOrderSecondaryCheckboxTapped(_ sender: CircularCheckbox) {
        setCheckboxChecked(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func shortageOrderPrimaryCheckboxTapped(_ sender: CircularCheckbox) {
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
    
    @IBAction func shortageOrderSecondaryCheckboxTapped(_ sender: CircularCheckbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxChecked(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func madeNumOrderPrimaryCheckboxTapped(_ sender: CircularCheckbox) {
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
    
    @IBAction func madeNumOrderSecondaryCheckboxTapped(_ sender: CircularCheckbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxChecked(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func favoriteOrderPrimaryCheckboxTapped(_ sender: CircularCheckbox) {
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
    
    @IBAction func favoriteOrderSecondaryCheckboxTapped(_ sender: CircularCheckbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxChecked(favoriteOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(lastViewedOrderSecondaryCheckbox)
    }
    
    @IBAction func lastViewedOrderPrimaryCheckboxTapped(_ sender: CircularCheckbox) {
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
    
    @IBAction func lastViewedOrderSecondaryCheckboxTapped(_ sender: CircularCheckbox) {
        setCheckboxUncheckedIfNotMixed(nameOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(shortageOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(madeNumOrderSecondaryCheckbox)
        setCheckboxUncheckedIfNotMixed(favoriteOrderSecondaryCheckbox)
        setCheckboxChecked(lastViewedOrderSecondaryCheckbox)
    }
    
    private func setCheckboxChecked(_ checkbox: CircularCheckbox){
        checkbox.setCheckState(.checked, animated: true)
        checkbox.isEnabled = true
        checkbox.tintColor = UchicockStyle.primaryColor
        checkbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
    }

    private func setCheckboxUnchecked(_ checkbox: CircularCheckbox){
        checkbox.setCheckState(.unchecked, animated: true)
        checkbox.isEnabled = true
        checkbox.tintColor = UchicockStyle.primaryColor
    }
    
    private func setCheckboxUncheckedIfNotMixed(_ checkbox: CircularCheckbox){
        if checkbox.checkState != .mixed{
            checkbox.setCheckState(.unchecked, animated: true)
            checkbox.isEnabled = true
            checkbox.tintColor = UchicockStyle.primaryColor
            checkbox.secondaryCheckmarkTintColor = UchicockStyle.labelTextColorOnBadge
        }
    }
    
    private func setCheckboxMixed(_ checkbox: CircularCheckbox){
        checkbox.setCheckState(.mixed, animated: true)
        checkbox.isEnabled = false
        checkbox.tintColor = UchicockStyle.labelTextColorLight
        checkbox.secondaryCheckmarkTintColor = UchicockStyle.basicBackgroundColor
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
    
    @IBAction func favorite0CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func favorite1CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func favorite2CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func favorite3CheckboxTapped(_ sender: CircularCheckbox) {
        setFavoriteWarningVisibility()
    }
    
    @IBAction func styleDeselctAllButtonTapped(_ sender: UIButton) {
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
    
    @IBAction func styleLongCheckboxTapped(_ sender: CircularCheckbox) {
        setStyleWarningVisibility()
    }
    
    @IBAction func styleShortCheckboxTapped(_ sender: CircularCheckbox) {
        setStyleWarningVisibility()
    }
    
    @IBAction func styleHotCheckboxTapped(_ sender: CircularCheckbox) {
        setStyleWarningVisibility()
    }
    
    @IBAction func styleNoneCheckboxTapped(_ sender: CircularCheckbox) {
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
    
    @IBAction func methodBuildCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodStirCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodShakeCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodBlendCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func methodOthersCheckboxTapped(_ sender: CircularCheckbox) {
        setMethodWarningVisibility()
    }
    
    @IBAction func strengthDeselectAllButtonTapped(_ sender: Any) {
        setCheckboxUnchecked(strengthNonAlcoholCheckbox)
        setCheckboxUnchecked(strengthWeakCheckbox)
        setCheckboxUnchecked(strengthMediumCheckbox)
        setCheckboxUnchecked(strengthStrongCheckbox)
        setCheckboxUnchecked(strengthNoneCheckbox)
        setStrengthWarningVisibility()
    }
    
    @IBAction func strengthSelectAllButtonTapped(_ sender: Any) {
        setCheckboxChecked(strengthNonAlcoholCheckbox)
        setCheckboxChecked(strengthWeakCheckbox)
        setCheckboxChecked(strengthMediumCheckbox)
        setCheckboxChecked(strengthStrongCheckbox)
        setCheckboxChecked(strengthNoneCheckbox)
        setStrengthWarningVisibility()
    }
    
    @IBAction func strengthNonAlcoholCheckboxTapped(_ sender: Any) {
        setStrengthWarningVisibility()
    }
    
    @IBAction func strengthWeakCheckboxTapped(_ sender: Any) {
        setStrengthWarningVisibility()
    }
    
    @IBAction func strengthMediumCheckboxTapped(_ sender: Any) {
        setStrengthWarningVisibility()
    }
    
    @IBAction func strengthStrongCheckboxTapped(_ sender: Any) {
        setStrengthWarningVisibility()
    }
    
    @IBAction func strengthNoneCheckboxTapped(_ sender: Any) {
        setStrengthWarningVisibility()
    }
    
}
