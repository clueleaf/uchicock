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
    let screenWidth = UIScreen.main.bounds.size.width

    var isEnd = false
    var introductions: [introductionInfo] = []
    var VCs: [IntroductionDetailViewController] = []
    var backgroundImage: UIImage!
    
    var currentStatusBarStyle: UIStatusBarStyle = .lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStatusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        backgroundImage.draw(in: self.view.bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image!)
        self.dataSource = self
        sb = UIStoryboard(name: "Introduction", bundle: nil)
        
        for (index, introduction) in introductions.enumerated(){
            let VC = setupVC(number: index, infoTitle: introduction.title, description: introduction.description, image: introduction.image)
            VCs.append(VC)
        }
        
        self.setViewControllers([VCs[0]], direction: .forward, animated: true, completion: nil)
        
        for v in self.view.subviews{
            if v.isKind(of: UIScrollView.self){
                (v as! UIScrollView).delegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 元のVCに戻るときにStatus Barの色をテーマに合わせるために必要
        currentStatusBarStyle = Style.statusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupVC(number: Int, infoTitle: String, description: String, image: UIImage?) -> IntroductionDetailViewController{
        let infoVC = sb.instantiateViewController(withIdentifier: "IntroductionDetail") as! IntroductionDetailViewController
        infoVC.number = number
        infoVC.titleString = infoTitle
        infoVC.descriptionString = description
        infoVC.image = image
        return infoVC
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < screenWidth{
            isEnd = false
        }
        if isEnd && scrollView.contentOffset.x > screenWidth + 20{
            self.dismiss(animated: true, completion: nil)
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
