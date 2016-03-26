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
        
        photo.alpha = 0
        photo.image = image
        self.navigationItem.title = recipeName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photo
    }

    @IBAction func stopButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
