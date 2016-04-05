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
        var message = "アルバムへ保存しました"
        if error != nil {
            message = "アルバムへの保存に失敗しました"
        }
        let alertView = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
        }))
        presentViewController(alertView, animated: true, completion: nil)
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
        let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertView.addAction(UIAlertAction(title: "アルバムへ保存する",style: .Default){ action in
            UIImageWriteToSavedPhotosAlbum(self.photo.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
            })
        alertView.addAction(UIAlertAction(title: "キャンセル", style: .Cancel){action in})
        presentViewController(alertView, animated: true, completion: nil)
    }
}
