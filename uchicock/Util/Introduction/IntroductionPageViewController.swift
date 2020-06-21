//
//  IntroductionPageViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class IntroductionPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    var sb: UIStoryboard!
    var windowWidth = UIApplication.shared.keyWindow!.bounds.size.width
    weak var launchVC : LaunchViewController?

    var lastPendingViewControllerIndex = 0
    var isEnd = false
    var introductions: [introductionInfo] = []
    var VCs: [IntroductionDetailViewController] = []
    var backgroundImage: UIImage? = nil
    var isTextColorBlack = false
    var isPageControlBlack = false
    var hasFinishedLayoutSubviews = true

    var currentStatusBarStyle: UIStatusBarStyle = .lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStatusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch UchicockStyle.no{
        case "0":
            backgroundImage = UIImage(named:"background-tequila-sunrise")
            isTextColorBlack = false
            isPageControlBlack = false
        case "7":
            backgroundImage = UIImage(named:"background-irish-coffee")
            isTextColorBlack = false
            isPageControlBlack = false
        case "8":
            backgroundImage = UIImage(named:"background-mojito")
            isTextColorBlack = true
            isPageControlBlack = true
        case "9":
            backgroundImage = UIImage(named:"background-red-eye")
            isTextColorBlack = true
            isPageControlBlack = false
        case "12":
            backgroundImage = UIImage(named:"background-american-lemonade")
            isTextColorBlack = false
            isPageControlBlack = true
        case "17":
            backgroundImage = UIImage(named:"background-pink-lady")
            isTextColorBlack = true
            isPageControlBlack = false
        case "1","3","5","10":
            backgroundImage = getUIImage(from: UchicockStyle.basicBackgroundColor)
            isTextColorBlack = FlatColor.isContractColorBlack(primeColor: UchicockStyle.basicBackgroundColor)
            isPageControlBlack = FlatColor.isContractColorBlack(primeColor: UchicockStyle.basicBackgroundColor)
        case "13","15","20","22":
            backgroundImage = getUIImage(from: UchicockStyle.primaryColor)
            isTextColorBlack = FlatColor.isContractColorBlack(primeColor: UchicockStyle.primaryColor)
            isPageControlBlack = FlatColor.isContractColorBlack(primeColor: UchicockStyle.primaryColor)
        default:
            backgroundImage = getUIImage(from: UchicockStyle.navigationBarColor)
            isTextColorBlack = FlatColor.isContractColorBlack(primeColor: UchicockStyle.navigationBarColor)
            isPageControlBlack = FlatColor.isContractColorBlack(primeColor: UchicockStyle.navigationBarColor)
        }
        if ["2","10"].contains(UchicockStyle.no) {
            isTextColorBlack = false
            isPageControlBlack = false
        }
        if backgroundImage == nil{
            backgroundImage = UIImage(named:"background-tequila-sunrise")
        }        
        
        currentStatusBarStyle = isTextColorBlack ? .default : .lightContent

        UIGraphicsBeginImageContext(self.view.frame.size)
        backgroundImage!.draw(in: self.view.bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image!)
        self.dataSource = self
        self.delegate = self
        sb = UIStoryboard(name: "Introduction", bundle: nil)
        
        for (index, introduction) in introductions.enumerated(){
            let VC = setupVC(number: index, infoTitle: introduction.title, description: introduction.description, image: introduction.image, isTextColorBlack: isTextColorBlack, isSkipButtonBlack: isPageControlBlack)
            VCs.append(VC)
        }
        
        self.setViewControllers([VCs[0]], direction: .forward, animated: true, completion: nil)
        
        for v in self.view.subviews where v.isKind(of: UIScrollView.self){
            (v as! UIScrollView).delegate = self
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        UIGraphicsBeginImageContext(size)
        backgroundImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        hasFinishedLayoutSubviews = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for subview in self.view.subviews where subview is UIPageControl {
            let pageControl = subview as! UIPageControl
            pageControl.currentPageIndicatorTintColor = isPageControlBlack ? FlatColor.black : FlatColor.white
            pageControl.pageIndicatorTintColor = isPageControlBlack ? FlatColor.black.withAlphaComponent(0.3) : FlatColor.white.withAlphaComponent(0.3)
        }
        windowWidth = UIApplication.shared.keyWindow!.bounds.size.width
        hasFinishedLayoutSubviews = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 元のVCに戻るときにStatus Barの色をテーマに合わせるために必要
        currentStatusBarStyle = UchicockStyle.statusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupVC(number: Int, infoTitle: String, description: String, image: UIImage?, isTextColorBlack: Bool, isSkipButtonBlack: Bool) -> IntroductionDetailViewController{
        let infoVC = sb.instantiateViewController(withIdentifier: "IntroductionDetail") as! IntroductionDetailViewController
        infoVC.number = number
        infoVC.titleString = infoTitle
        infoVC.descriptionString = description
        infoVC.image = image
        infoVC.isTextColorBlack = isTextColorBlack
        infoVC.isSkipButtonBlack = isSkipButtonBlack
        infoVC.introductionVC = self
        infoVC.launchVC = self.launchVC
        return infoVC
    }
    
    func getUIImage(from: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(from.cgColor)
        contextRef?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasFinishedLayoutSubviews { // 画面回転でもdidScrollするため、回転して勝手にdismissされてしまうことを防ぐ
            if isEnd && scrollView.contentOffset.x > windowWidth + 20{
                if launchVC != nil{
                    launchVC!.dismissIntroductionAndPrepareToShowRecipeList(self)
                }else{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        if let vc = pendingViewControllers[0] as? IntroductionDetailViewController {
            self.lastPendingViewControllerIndex = vc.number!
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        if completed{
            if self.lastPendingViewControllerIndex == VCs.count - 1{
                isEnd = true
            }else{
                isEnd = false
            }
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroductionDetailViewController
        if vc.number! > 0{
            return VCs[vc.number! - 1]
        }else{
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroductionDetailViewController
        if vc.number! < VCs.count - 1{
            return VCs[vc.number! + 1]
        }else{
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

struct introductionInfo{
    var title: String
    var description: String
    var image: UIImage?
}
