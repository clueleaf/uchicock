//
//  PhotoFilterViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/12/26.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class PhotoFilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    var selectingImageIndex = 0
    var image : UIImage?
    var smallImage : UIImage?
    let queue = DispatchQueue(label: "queue")
    var filterImages : [UIImage?] = []
    var originalImageView: UIImageView?
    var transitionHandler: PhotoFilterDismissalTransitioningHandler?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var CIFilterNames = [
        "Original",
        "Clarendon",
        "Toaster",
        "1977",
        "CIPhotoEffectTransfer",
        "Nashville",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectProcess",
        "CILinearToSRGBToneCurve",
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageScrollView.delegate = self
        
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 17.5
        button.tintColor = UIColor.white

        titleLabel.textColor = UIColor.white
        
        filterImages = [UIImage?](repeating: nil, count: CIFilterNames.count)
        self.collectionView.indicatorStyle = .white

        imageView.image = image
        if let im = image{
            smallImage = resizedImage(image: im)
        }
        
        setupScrollView()
        setupGestureRecognizers()
        setupTransitions()
    }
    
    func setupScrollView() {
        imageScrollView.indicatorStyle = .white
        imageScrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        imageScrollView.alwaysBounceVertical = true
        imageScrollView.alwaysBounceHorizontal = true
    }
    
    func setupGestureRecognizers() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer()
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.addTarget(self, action: #selector(imageViewDoubleTapped))
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func setupTransitions() {
        transitionHandler = PhotoFilterDismissalTransitioningHandler(fromImageView: self.imageView, toImageView: originalImageView!)
        self.transitioningDelegate = transitionHandler
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.flashScrollIndicators()
    }
    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let im = self.image else{ return }
        guard let ciim = CIImage(image: im) else{ return }
        DispatchQueue.main.async {
            self.imageView.image = self.filteredImage(filterNumber: indexPath.row, originalImage: ciim)
        }
        selectingImageIndex = indexPath.row
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIFilterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFilterCell", for: indexPath) as! PhotoFilterCollectionViewCell
        cell.imageView.layer.cornerRadius = 10

        cell.imageView.image = filterImages[indexPath.row]
        if filterImages[indexPath.row] == nil{
            if let smim = self.smallImage{
                if let ciim = CIImage(image: smim){
                    queue.async {
                        let filteredImage = self.filteredImage(filterNumber: indexPath.row, originalImage: ciim)
                        self.filterImages[indexPath.row] = filteredImage
                        DispatchQueue.main.async{
                            cell.imageView.image = filteredImage
                        }
                    }
                }
            }
        }
        if indexPath.row == selectingImageIndex{
            cell.imageView.layer.borderColor = UIColor.white.cgColor
            cell.imageView.layer.borderWidth = 2.0
        }else{
            cell.imageView.layer.borderWidth = 0
        }

        return cell
    }
    
    @objc func imageViewDoubleTapped() {
        if imageScrollView.zoomScale > imageScrollView.minimumZoomScale {
            imageScrollView.setZoomScale(imageScrollView.minimumZoomScale, animated: true)
        } else {
            imageScrollView.setZoomScale(imageScrollView.maximumZoomScale, animated: true)
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

    // MARK: - Process Image
    func filteredImage(filterNumber: Int, originalImage: CIImage) -> UIImage{
        let ciContext = CIContext(options: nil)
        var filteredImageData : CIImage? = nil
        
        switch CIFilterNames[filterNumber]{
        case "Original":
            filteredImageData = originalImage
        case "Nashville":
            filteredImageData = applyNashvilleFilter(foregroundImage: originalImage)
        case "Clarendon":
            filteredImageData = applyClarendonFilter(foregroundImage: originalImage)
        case "1977":
            filteredImageData = apply1977Filter(ciImage: originalImage)
        case "Toaster":
            filteredImageData = applyToasterFilter(ciImage: originalImage)
        default:
            let filter = CIFilter(name: "\(CIFilterNames[filterNumber])" )
            if let fil = filter {
                fil.setDefaults()
                fil.setValue(originalImage, forKey: kCIInputImageKey)
                filteredImageData = fil.value(forKey: kCIOutputImageKey) as? CIImage
            }
        }
        
        if let fimg = filteredImageData{
            let filteredImageRef = ciContext.createCGImage(fimg, from: fimg.extent)
            return UIImage(cgImage: filteredImageRef!)
        }else{
            let filteredImageRef = ciContext.createCGImage(originalImage, from: originalImage.extent)
            return UIImage(cgImage: filteredImageRef!)
        }
    }
    
    func resizedImage(image: UIImage) -> UIImage? {
        let maxLongSide : CGFloat = (collectionView.frame.height - 20) * 2
        if  image.size.width <= maxLongSide && image.size.height <= maxLongSide {
            return image
        }
        
        let w = image.size.width / maxLongSide
        let h = image.size.height / maxLongSide
        let ratio = w > h ? w : h
        let rect = CGRect(x: 0, y: 0, width: image.size.width / ratio, height: image.size.height / ratio)
        
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getColorImage( red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0, rect: CGRect) -> CIImage {
        let color = CIColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }

    // MARK: - Original Filters
    func applyNashvilleFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(
            red: 0.97, green: 0.77, blue: 0.72, alpha: 0.56, rect: foregroundImage.extent)
        let backgroundImage2 = getColorImage(
            red: 0.0, green: 0.12, blue: 0.27, alpha: 0.4, rect: foregroundImage.extent)
        return foregroundImage
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
                ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.2,
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.05,
                "inputContrast": 1.1,
                ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage2,
                ])
    }
    
    func applyClarendonFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(
            red: 0.35, green: 0.55, blue: 0.68, alpha: 0.2, rect: foregroundImage.extent)
        return foregroundImage
            .applyingFilter("CIOverlayBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.45,
                "inputBrightness": 0.05,
                "inputContrast": 1.15,
                ])
    }
    
    func apply1977Filter(ciImage: CIImage) -> CIImage? {
        let filterImage = getColorImage(
            red: 0.80, green: 0.35, blue: 0.60, alpha: 0.1, rect: ciImage.extent)
        let backgroundImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.07,
                "inputContrast": 1.05,
                ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.2,
                ])
        return filterImage
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
                ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.17),
                "inputPoint2": CIVector(x: 0.5, y: 0.48),
                "inputPoint3": CIVector(x: 0.75, y: 0.80),
                "inputPoint4": CIVector(x: 1, y: 1),
                ])
    }
    
    func applyToasterFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 4.0, height / 4.0)
        let radius1 = min(width / 1.5, height / 1.5)
        
        let color0 = CIColor(red: 0.3, green: 0.17, blue: 0.03, alpha: 0.8)
        let color1 = CIColor(red: 0.2, green: 0.0, blue: 0.2, alpha: 1.0)
        let circle = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1,
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.0,
                "inputBrightness": 0.01,
                "inputContrast": 1.2,
                ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": circle!,
                ])
    }
    
    // MARK: - IBAction
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        originalImageView?.isHidden = true

        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.imageScrollView.setZoomScale(self.imageScrollView.minimumZoomScale, animated: false)
        }, completion: { _ in
            self.performSegue(withIdentifier: "FilterFinished", sender: self)
        })

    }

}
