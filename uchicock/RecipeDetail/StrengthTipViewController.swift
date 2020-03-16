//
//  StrengthTipViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2/16/20.
//  Copyright © 2020 Kou. All rights reserved.
//

import UIKit

class StrengthTipViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    
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
    }
    
    // 下に引っ張ると戻してもviewWillDisappear, viewwWillAppear, viewDidAppearが呼ばれることに注意
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UchicockStyle.basicBackgroundColor
        scrollView.backgroundColor = UchicockStyle.basicBackgroundColor
        scrollView.indicatorStyle = UchicockStyle.isBackgroundDark ? .white : .black
        backgroundView.backgroundColor = UchicockStyle.basicBackgroundColor
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
}
