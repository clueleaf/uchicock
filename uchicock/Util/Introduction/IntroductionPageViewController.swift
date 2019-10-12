//
//  IntroductionPageViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class IntroductionPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIScrollViewDelegate {

    var sb: UIStoryboard!
    var windowWidth = UIApplication.shared.keyWindow!.bounds.size.width

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
        
        switch Style.no{
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
            backgroundImage = getUIImage(from: Style.basicBackgroundColor)
            isTextColorBlack = FlatColor.isContractColorBlack(primeColor: Style.basicBackgroundColor)
            isPageControlBlack = FlatColor.isContractColorBlack(primeColor: Style.basicBackgroundColor)
        case "13","15","20","22":
            backgroundImage = getUIImage(from: Style.primaryColor)
            isTextColorBlack = FlatColor.isContractColorBlack(primeColor: Style.primaryColor)
            isPageControlBlack = FlatColor.isContractColorBlack(primeColor: Style.primaryColor)
        default:
            backgroundImage = getUIImage(from: Style.navigationBarColor)
            isTextColorBlack = FlatColor.isContractColorBlack(primeColor: Style.navigationBarColor)
            isPageControlBlack = FlatColor.isContractColorBlack(primeColor: Style.navigationBarColor)
        }
        if ["2","10"].contains(Style.no) {
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
        sb = UIStoryboard(name: "Introduction", bundle: nil)
        
        for (index, introduction) in introductions.enumerated(){
            let VC = setupVC(number: index, infoTitle: introduction.title, description: introduction.description, image: introduction.image, isTextColorBlack: isTextColorBlack, isSkipButtonBlack: isPageControlBlack)
            VCs.append(VC)
        }
        
        self.setViewControllers([VCs[0]], direction: .forward, animated: true, completion: nil)
        
        for v in self.view.subviews{
            if v.isKind(of: UIScrollView.self){
                (v as! UIScrollView).delegate = self
            }
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
        for subview in self.view.subviews {
            if subview is UIPageControl {
                let pageControl = subview as! UIPageControl
                if isPageControlBlack {
                    pageControl.currentPageIndicatorTintColor = FlatColor.black
                    pageControl.pageIndicatorTintColor = FlatColor.black.withAlphaComponent(0.3)
                }else{
                    pageControl.currentPageIndicatorTintColor = FlatColor.white
                    pageControl.pageIndicatorTintColor = FlatColor.white.withAlphaComponent(0.3)
                }
            }
        }
        windowWidth = UIApplication.shared.keyWindow!.bounds.size.width
        hasFinishedLayoutSubviews = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 元のVCに戻るときにStatus Barの色をテーマに合わせるために必要
        currentStatusBarStyle = Style.statusBarStyle
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
        if hasFinishedLayoutSubviews { // 画面回転でもdidScrollするため、isEndがfalseに更新されてdismissできなくなる問題への対応
            if scrollView.contentOffset.x < windowWidth{
                isEnd = false
            }
            if isEnd && scrollView.contentOffset.x > windowWidth + 20{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroductionDetailViewController
        if vc.number! > 0{
            isEnd = false
            return VCs[vc.number! - 1]
        }else{
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroductionDetailViewController
        if vc.number! < VCs.count - 1{
            isEnd = false
            return VCs[vc.number! + 1]
        }else if vc.number! == VCs.count - 1{
            isEnd = true
            return nil
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
