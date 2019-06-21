//
//  MethodTipViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/22.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class MethodTipViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var buildTitleLabel: UILabel!
    @IBOutlet weak var buildDescriptionLabel: UILabel!
    @IBOutlet weak var firstSeparator: UIView!
    @IBOutlet weak var stirTitleLabel: UILabel!
    @IBOutlet weak var stirDescriptionLabel: UILabel!
    @IBOutlet weak var secondSeparator: UIView!
    @IBOutlet weak var shakeTitleLabel: UILabel!
    @IBOutlet weak var shakeDescriptionLabel: UILabel!
    @IBOutlet weak var thirdSeparator: UIView!
    @IBOutlet weak var blendTitleLabel: UILabel!
    @IBOutlet weak var blendDescriptionLabel: UILabel!
    
    var interactor: Interactor!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    var onDoneBlock = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.backgroundColor = Style.basicBackgroundColor
        scrollView.indicatorStyle = Style.isBackgroundDark ? .white : .black
        backgroundView.backgroundColor = Style.basicBackgroundColor
        buildTitleLabel.textColor = Style.labelTextColor
        buildDescriptionLabel.textColor = Style.labelTextColor
        stirTitleLabel.textColor = Style.labelTextColor
        stirDescriptionLabel.textColor = Style.labelTextColor
        shakeTitleLabel.textColor = Style.labelTextColor
        shakeDescriptionLabel.textColor = Style.labelTextColor
        blendTitleLabel.textColor = Style.labelTextColor
        blendDescriptionLabel.textColor = Style.labelTextColor
        
        firstSeparator.backgroundColor = Style.labelTextColor
        secondSeparator.backgroundColor = Style.labelTextColor
        thirdSeparator.backgroundColor = Style.labelTextColor
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
    
    // MARK: - IBAction
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
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
    
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
