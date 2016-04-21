//
//  PhotoDetailViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/26.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    
    var image: UIImage = UIImage()
    var recipeName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = recipeName
        photo.alpha = 0
        photo.image = image
    }

    override func viewDidLayoutSubviews() {
        scrollView.contentInset.top = (scrollView.bounds.size.height - photo.bounds.size.height)/2.0
        scrollView.contentInset.bottom = (scrollView.bounds.size.height - photo.bounds.size.height)/2.0
        scrollView.setZoomScale(1, animated: false)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.1, animations: {self.photo.alpha=1})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error == nil{
            let alertView = UIAlertController(title: "カメラロールへ保存しました", message: nil, preferredStyle: .Alert)
            self.presentViewController(alertView, animated: true) { () -> Void in
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }else{
            let alertView = UIAlertController(title: "カメラロールへの保存に失敗しました", message: "「設定」→「うちカク！」にて写真へのアクセス許可を確認してください", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            }))
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photo
    }

    // MARK: - IBAction
    @IBAction func stopButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func organizeButtonTapped(sender: UIBarButtonItem) {
        let excludedActivityTypes = [
            UIActivityTypeMessage,
            UIActivityTypeMail,
            UIActivityTypePrint,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToWeibo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeAirDrop
        ]
        
        let shareImage = photo.image!
        let activityItems = [shareImage, ""]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.excludedActivityTypes = excludedActivityTypes
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
}
