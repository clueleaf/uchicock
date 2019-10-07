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
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var skipButton: UIButton!
    
    var titleString: String?
    var descriptionString: String?
    var image: UIImage?
    var number: Int?
    var isTextColorBlack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleString
        titleLabel.alpha = 0.0
        titleLabel.textColor = isTextColorBlack ? FlatColor.black : FlatColor.white
        descriptionLabel.text = descriptionString
        descriptionLabel.alpha = 0.0
        descriptionLabel.textColor = isTextColorBlack ? FlatColor.black : FlatColor.white
        imageView.image = image
        imageView.alpha = 0.0
        skipButton.alpha = 0.0
        skipButton.setTitleColor((isTextColorBlack ? FlatColor.black : FlatColor.white), for: .normal)
        self.view.backgroundColor = UIColor.clear
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            titleLabel.font = UIFont.systemFont(ofSize: 28.0)
            descriptionLabel.font = UIFont.systemFont(ofSize: 21.0)
            skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
        }else{
            titleLabel.font = UIFont.systemFont(ofSize: 21.0)
            descriptionLabel.font = UIFont.systemFont(ofSize: 14.0)
            skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        }
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
