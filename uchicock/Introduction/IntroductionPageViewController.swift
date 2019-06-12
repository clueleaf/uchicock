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

    let description1 = "ダウンロードしていただき、ありがとうございます！\n使い方を簡単に説明します。\n\n※この説明は後からでも確認できます。"
    let description2 = "レシピの検索や新規登録はこの画面から。\nサンプルレシピですら、編集して自前でアレンジ可能！\nカクテルをつくったらぜひ写真を登録してみよう！"
    let description3 = "ワンタップで材料の在庫を登録できます。\n在庫を登録すると、今の手持ちで作れるレシピがわかります。"
    let description4 = "3つまで材料を指定して、それらをすべて使うレシピを逆引きできます。\n「あの材料とあの材料を使うカクテル何だっけ？」\nそんなときに活用しよう！"
    let description5 = "アプリに登録されているレシピの写真だけを取り出して表示します。\n表示順をシャッフルして、気まぐれにカクテルを選んでみては？"
    var VC1: IntroductionDetailViewController!
    var VC2: IntroductionDetailViewController!
    var VC3: IntroductionDetailViewController!
    var VC4: IntroductionDetailViewController!
    var VC5: IntroductionDetailViewController!

    var isEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "launch-background")!.draw(in: self.view.bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image!)
        self.dataSource = self
        sb = UIStoryboard(name: "Introduction", bundle: nil)
        
        VC1 = setVC(number: 1, infoTitle: "Thank you for downloading!!", description: description1, image: nil)
        VC2 = setVC(number: 2, infoTitle: "レシピ", description: description2, image: UIImage(named:"screen-recipe"))
        VC3 = setVC(number: 3, infoTitle: "材料", description: description3, image: UIImage(named:"screen-ingredient"))
        VC4 = setVC(number: 4, infoTitle: "逆引き", description: description4, image: UIImage(named:"screen-reverse-lookup"))
        VC5 = setVC(number: 5, infoTitle: "アルバム", description: description5, image: UIImage(named:"screen-album"))
        self.setViewControllers([VC1], direction: .forward, animated: true, completion: nil)
        
        for v in self.view.subviews{
            if v.isKind(of: UIScrollView.self){
                (v as! UIScrollView).delegate = self
            }
        }
    }
    
    func setVC(number: Int, infoTitle: String, description: String, image: UIImage?) -> IntroductionDetailViewController{
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
        if vc.number == 2 {
            isEnd = false
            return VC1
        } else if vc.number == 3 {
            isEnd = false
            return VC2
        } else if vc.number == 4 {
            isEnd = false
            return VC3
        } else if vc.number == 5 {
            isEnd = false
            return VC4
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroductionDetailViewController
        if vc.number == 1 {
            isEnd = false
            return VC2
        } else if vc.number == 2 {
            isEnd = false
            return VC3
        } else if vc.number == 3 {
            isEnd = false
            return VC4
        } else if vc.number == 4 {
            isEnd = false
            return VC5
        } else if vc.number == 5 {
            isEnd = true
            return nil
        } else {
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 5
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
