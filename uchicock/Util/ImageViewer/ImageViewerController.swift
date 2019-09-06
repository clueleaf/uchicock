//
//  ImageViewerController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class ImageViewerController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var captionBackgroundView: UIView!
    @IBOutlet weak var captionLabel: UILabel!
    
    var transitionHandler: ImageViewerTransitioningHandler?
    var originalImageView: UIImageView?
    var captionText: String? = nil
    var isBrowsingMode = false
    var isStatusBarHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Style.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        imageView.image = originalImageView?.image
        doneButton.setTitleColor(UIColor(white: 0.9, alpha: 0.9), for: .normal)
        doneButton.layer.cornerRadius = 13.0
        doneButton.layer.borderColor = UIColor(white: 0.9, alpha: 0.9).cgColor
        doneButton.layer.borderWidth = 1.0
        doneButton.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        
        captionLabel.text = self.captionText
        
        setupScrollView()
        setupGestureRecognizers()
        setupTransitions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCaptionBackground()
        isStatusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupScrollView() {
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
    }
    
    func setupGestureRecognizers() {
        let singleTapGestureRecognizer = UITapGestureRecognizer()
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.addTarget(self, action: #selector(imageViewSingleTapped))
        imageView.addGestureRecognizer(singleTapGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer()
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.addTarget(self, action: #selector(imageViewDoubleTapped))
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(imageViewPanned(_:)))
        panGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(panGestureRecognizer)

        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        let singleTapGestureRecognizer2 = UITapGestureRecognizer()
        singleTapGestureRecognizer2.numberOfTapsRequired = 1
        singleTapGestureRecognizer2.addTarget(self, action: #selector(imageViewSingleTapped))
        captionBackgroundView.addGestureRecognizer(singleTapGestureRecognizer2)

        let doubleTapGestureRecognizer2 = UITapGestureRecognizer()
        doubleTapGestureRecognizer2.numberOfTapsRequired = 2
        doubleTapGestureRecognizer2.addTarget(self, action: #selector(imageViewDoubleTapped))
        captionBackgroundView.addGestureRecognizer(doubleTapGestureRecognizer2)

        let panGestureRecognizer2 = UIPanGestureRecognizer()
        panGestureRecognizer2.addTarget(self, action: #selector(imageViewPanned(_:)))
        panGestureRecognizer2.delegate = self
        captionBackgroundView.addGestureRecognizer(panGestureRecognizer2)

        singleTapGestureRecognizer2.require(toFail: doubleTapGestureRecognizer2)
    }
    
    func setupTransitions() {
        guard let imageView = originalImageView else { return }
        transitionHandler = ImageViewerTransitioningHandler(fromImageView: imageView, toImageView: self.imageView)
        self.transitioningDelegate = transitionHandler
    }
    
    func setupCaptionBackground(){
        // 重複して何重もグラデーションを付けないように、既存のグラデーションを取り除く
        captionBackgroundView.layer.sublayers?.forEach {
            if $0.isKind(of: CustomCAGradientLayer.self){
                $0.removeFromSuperlayer()
            }
        }

        let gradient = CustomCAGradientLayer()
        gradient.frame = captionBackgroundView.bounds
        gradient.colors = [UIColor(white: 0, alpha: 0).cgColor, UIColor(white: 0, alpha: 0.8).cgColor]
        captionBackgroundView.layer.insertSublayer(gradient, at: 0)
        
        if captionText == nil{
            self.captionLabel.alpha = 0.0
            self.captionBackgroundView.alpha = 0.0
            self.captionLabel.isHidden = true
            self.captionBackgroundView.isHidden = true
        }
    }
    
    // MARK: - UIGestureRecognizer
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return scrollView.zoomScale == scrollView.minimumZoomScale
    }
    
    @objc func imageViewSingleTapped() {
        isBrowsingMode.toggle()
        if isBrowsingMode{
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                self.doneButton.alpha = 0.0
                if self.captionText != nil{
                    self.captionLabel.alpha = 0.0
                    self.captionBackgroundView.alpha = 0.0
                }
            }, completion: { _ in
                self.doneButton.isHidden = true
                if self.captionText != nil{
                    self.captionLabel.isHidden = true
                    self.captionBackgroundView.isHidden = true
                }
            })
        }else{
            self.doneButton.isHidden = false
            if self.captionText != nil{
                self.captionLabel.isHidden = false
                self.captionBackgroundView.isHidden = false
            }
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                self.doneButton.alpha = 1.0
                if self.captionText != nil{
                    self.captionLabel.alpha = 1.0
                    self.captionBackgroundView.alpha = 1.0
                }
            }, completion: nil)
        }
    }
    
    @objc func imageViewDoubleTapped() {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc func imageViewPanned(_ recognizer: UIPanGestureRecognizer) {
        guard transitionHandler != nil else { return }
        
        let translation = recognizer.translation(in: imageView)
        let velocity = recognizer.velocity(in: imageView)
        
        switch recognizer.state {
        case .began:
            transitionHandler?.dismissInteractively = true
            dismiss(animated: true)
        case .changed:
            let percentage = abs(translation.y) / imageView.bounds.height
            transitionHandler?.dismissalInteractor.update(percentage: percentage)
            transitionHandler?.dismissalInteractor.update(transform: CGAffineTransform(translationX: translation.x, y: translation.y))
        case .ended, .cancelled:
            transitionHandler?.dismissInteractively = false
            let percentage = abs(3 * translation.y + velocity.y) / imageView.bounds.height
            if percentage > 0.5 {
                transitionHandler?.dismissalInteractor.finish()
            } else {
                transitionHandler?.dismissalInteractor.cancel()
            }
        default: break
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let image = imageView.image else { return }
        let imageViewSize = ImageViewerUtil.aspectFitRect(forSize: image.size, insideRect: imageView.frame)
        let verticalInsets = -(scrollView.contentSize.height - max(imageViewSize.height, scrollView.bounds.height)) / 2
        let horizontalInsets = -(scrollView.contentSize.width - max(imageViewSize.width, scrollView.bounds.width)) / 2
        scrollView.contentInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
    }
    
    // MARK: - IBAction
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}