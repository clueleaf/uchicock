//
//  AlcoholAmountTipViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-03-15.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class AlcoholAmountTipViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var weightMinusButton: ExpandedButton!
    @IBOutlet weak var weightPlusButton: ExpandedButton!
    @IBOutlet weak var weightLabel: CustomLabel!
    @IBOutlet weak var decompositionSpeedLabel: CustomLabel!
    @IBOutlet weak var alcoholAmountLabel: CustomLabel!
    @IBOutlet weak var decompositionTimeLabel: CustomLabel!
    
    var alcoholAmount = 0
    var weight = 50
    
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
                
        weightMinusButton.minimumHitWidth = 44
        weightMinusButton.minimumHitHeight = 44
        weightMinusButton.layer.cornerRadius = weightPlusButton.frame.size.width / 2
        weightMinusButton.layer.borderWidth = 1.5
        weightPlusButton.minimumHitWidth = 44
        weightPlusButton.minimumHitHeight = 44
        weightPlusButton.layer.cornerRadius = weightPlusButton.frame.size.width / 2
        weightPlusButton.layer.borderWidth = 1.5

        weightLabel.text = String(weight) + "kg"
        updateResultLabel()
        
        alcoholAmountLabel.text = String(alcoholAmount) + "ml"
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.backgroundColor = UchicockStyle.basicBackgroundColor
        scrollView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        backgroundView.backgroundColor = UchicockStyle.basicBackgroundColor
        
        setWeightButtons()
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
    
    private func readUserDefaults(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [GlobalConstants.AlcoholDecompositionWeightKey : 50])

        weight = defaults.integer(forKey: GlobalConstants.AlcoholDecompositionWeightKey)
        weight = weight / 5
        if weight < 6{
            weight = 6
        }
        if weight > 24{
            weight = 24
        }
        weight = weight * 5
    }
    
    private func setWeightButtons(){
        if weight <= 30 {
            weightMinusButton.isEnabled = false
            weightMinusButton.setTitleColor(UchicockStyle.labelTextColorLight, for: .normal)
            weightMinusButton.layer.borderColor = UchicockStyle.labelTextColorLight.cgColor
        } else {
            weightMinusButton.isEnabled = true
            weightMinusButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
            weightMinusButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        }
        if weight >= 120 {
            weightPlusButton.isEnabled = false
            weightPlusButton.setTitleColor(UchicockStyle.labelTextColorLight, for: .normal)
            weightPlusButton.layer.borderColor = UchicockStyle.labelTextColorLight.cgColor
        } else {
            weightPlusButton.isEnabled = true
            weightPlusButton.setTitleColor(UchicockStyle.primaryColor, for: .normal)
            weightPlusButton.layer.borderColor = UchicockStyle.primaryColor.cgColor
        }
    }

    private func updateResultLabel(){
        let speed = Int(floor(Double(weight) * 0.125))
        decompositionSpeedLabel.text = "1時間あたり約" + String(speed) +  "ml"
        let hour = Double(alcoholAmount) / (Double(weight) * 0.125)
        let hourInteger = Int(hour)
        let minute = Int(hour.truncatingRemainder(dividingBy: 1) * 60.0)
        decompositionTimeLabel.text = "約" + String(hourInteger) + "時間" + String(minute) + "分"
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if interactor != nil{
            if interactor!.hasStarted {
                scrollView.contentOffset.y = 0.0
            }
        }
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
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func weightMinumButtonTapped(_ sender: ExpandedButton) {
        if weight > 30 {
            weight -= 5
            weightLabel.text = String(weight) + "kg"
            let defaults = UserDefaults.standard
            defaults.set(weight, forKey: GlobalConstants.AlcoholDecompositionWeightKey)
        }
        setWeightButtons()
        updateResultLabel()
    }
    
    @IBAction func weightPlusButtonTapped(_ sender: ExpandedButton) {
        if weight < 120 {
            weight += 5
            weightLabel.text = String(weight) + "kg"
            let defaults = UserDefaults.standard
            defaults.set(weight, forKey: GlobalConstants.AlcoholDecompositionWeightKey)
        }
        setWeightButtons()
        updateResultLabel()
    }
}
