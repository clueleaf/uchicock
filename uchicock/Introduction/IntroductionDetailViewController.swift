//
//  IntroductionDetailViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class IntroductionDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var skipButton: UIButton!
    
    var titleString: String?
    var descriptionString: String?
    var image: UIImage?
    var number: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleString
        titleLabel.alpha = 0.0
        descriptionLabel.text = descriptionString
        descriptionLabel.alpha = 0.0
        imageView.image = image
        imageView.alpha = 0.0
        skipButton.alpha = 0.0
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateViews(withDuration: 0.3)
    }
    
    func animateViews(withDuration duration: Double){
        if titleLabel.alpha < 1.0{
            UIView.animate(withDuration: duration, animations: {
                self.titleLabel.alpha = 1.0
            })
        }
        if descriptionLabel.alpha < 1.0{
            UIView.animate(withDuration: duration, delay: duration, animations: {
                self.descriptionLabel.alpha = 1.0
            })
        }
        if imageView.alpha < 1.0{
            UIView.animate(withDuration: duration, delay: duration, animations: {
                self.imageView.alpha = 1.0
            })
        }
        if skipButton.alpha < 1.0{
            UIView.animate(withDuration: duration, delay: duration, animations: {
                self.skipButton.alpha = 1.0
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        titleLabel.alpha = 0.0
        descriptionLabel.alpha = 0.0
        imageView.alpha = 0.0
        skipButton.alpha = 0.0
        
        super.viewDidDisappear(animated)
    }
    
    // MARK: - IBAction
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
