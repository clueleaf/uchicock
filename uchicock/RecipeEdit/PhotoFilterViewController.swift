//
//  PhotoFilterViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/12/26.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class PhotoFilterViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var image : UIImage!
    var originalImageView: UIImageView!
    var smallCIImage : CIImage?
    var transitionHandler: PhotoFilterDismissalTransitioningHandler?
    var statuBarStyle = UchicockStyle.statusBarStyle

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterScrollView: CustomScrollView!
    @IBOutlet weak var filterStackView: UIStackView!
    @IBOutlet weak var filterStackViewWidthConstraint: NSLayoutConstraint!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statuBarStyle
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
        "Dimming",
        "Arpeggio",
        "Traumerei",
        ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 17.5
        button.setTitleColor(UIColor.white, for: .normal)

        titleLabel.textColor = UIColor.white
        
        filterStackViewWidthConstraint.constant = CGFloat(106 * CIFilterNames.count)
        
        imageView.image = image
        smallCIImage = image.resizedCGImage(maxLongSide: 300)
        setupScrollView()
        setupGestureRecognizers()
        setupTransitions()
    }
    
    private func setupScrollView() {
        filterScrollView.indicatorStyle = .white
        imageScrollView.indicatorStyle = .white
        imageScrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        imageScrollView.alwaysBounceVertical = true
        imageScrollView.alwaysBounceHorizontal = true
    }
    
    private func setupGestureRecognizers() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer()
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.addTarget(self, action: #selector(imageViewDoubleTapped))
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func setupTransitions() {
        transitionHandler = PhotoFilterDismissalTransitioningHandler(fromImageView: self.imageView, toImageView: originalImageView)
        self.transitioningDelegate = transitionHandler
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addFilterButtons()
    }
    
    func addFilterButtons(){
        for i in 0..<CIFilterNames.count {
            let filterButton = UIButton(type: .custom)
            filterButton.layer.cornerRadius = 10
            filterButton.clipsToBounds = true
            filterButton.tag = i
            filterButton.addTarget(self, action: #selector(PhotoFilterViewController.filterButtonTapped(sender:)), for: .touchUpInside)
            
            if i == 0{
                filterButton.layer.borderColor = UIColor.white.cgColor
                filterButton.layer.borderWidth = 2.0
                if let smim = self.smallCIImage{
                    let filteredImage = self.filteredImage(filterNumber: i, originalImage: smim)
                    filterButton.setImage(filteredImage, for: .normal)
                    filterButton.imageView?.contentMode = .scaleAspectFill
                }
            }else{
                filterButton.layer.borderWidth = 0
                if let smim = self.smallCIImage{
                    DispatchQueue.global(qos: .userInteractive).async{
                        let filteredImage = self.filteredImage(filterNumber: i, originalImage: smim)
                        DispatchQueue.main.async{
                            filterButton.setImage(filteredImage, for: .normal)
                            filterButton.imageView?.contentMode = .scaleAspectFill
                        }
                    }
                }
            }
            filterStackView.addArrangedSubview(filterButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statuBarStyle = .lightContent
        self.setNeedsStatusBarAppearanceUpdate()
        filterScrollView.flashScrollIndicators()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statuBarStyle = UchicockStyle.statusBarStyle
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - IBAction
    @objc func filterButtonTapped(sender: UIButton){
        guard let ciim = CIImage(image: self.image) else{ return }
        DispatchQueue.main.async {
            self.imageView.image = self.filteredImage(filterNumber: sender.tag, originalImage: ciim)
        }

        for subview in filterScrollView.subviews where subview is UIStackView{
            for subsubview in subview.subviews where subsubview is UIButton{
                let b = subsubview as! UIButton
                b.layer.borderWidth = 0
            }
        }
        sender.layer.borderColor = UIColor.white.cgColor
        sender.layer.borderWidth = 2.0
    }
    
    @objc func imageViewDoubleTapped() {
        if imageScrollView.zoomScale > imageScrollView.minimumZoomScale {
            imageScrollView.setZoomScale(imageScrollView.minimumZoomScale, animated: true)
        }else{
            imageScrollView.setZoomScale(imageScrollView.maximumZoomScale, animated: true)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        originalImageView.isHidden = true

        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.imageScrollView.setZoomScale(self.imageScrollView.minimumZoomScale, animated: false)
        }, completion: { _ in
            self.performSegue(withIdentifier: "FilterFinished", sender: self)
        })

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
    private func filteredImage(filterNumber: Int, originalImage: CIImage) -> UIImage{
        let ciContext = CIContext(options: nil)
        var filteredImageData : CIImage? = nil
        
        switch CIFilterNames[filterNumber]{
        case "Original":
            filteredImageData = originalImage
        case "Dimming":
            filteredImageData = applyDimmingFilter(ciImage: originalImage)
        case "Traumerei":
            filteredImageData = applyTraumereiFilter(ciImage: originalImage)
        case "Arpeggio":
            filteredImageData = applyArpeggioFilter(ciImage: originalImage)
        case "Nashville":
            filteredImageData = applyNashvilleFilter(foregroundImage: originalImage)
        case "Clarendon":
            filteredImageData = applyClarendonFilter(foregroundImage: originalImage)
        case "1977":
            filteredImageData = apply1977Filter(ciImage: originalImage)
        case "Toaster":
            filteredImageData = applyToasterFilter(ciImage: originalImage)
        default:
            let filter = CIFilter(name: "\(CIFilterNames[filterNumber])")
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
    
    private func getColorImage( red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0, rect: CGRect) -> CIImage {
        let color = CIColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }

    // MARK: - Original Filters
    private func applyNashvilleFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(
            red: 0.97, green: 0.69, blue: 0.6, alpha: 0.56, rect: foregroundImage.extent)
        let backgroundImage2 = getColorImage(
            red: 0.0, green: 0.27, blue: 0.59, alpha: 0.4, rect: foregroundImage.extent)
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
    
    private func applyClarendonFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(red: 0.5, green: 0.73, blue: 0.89, alpha: 0.2, rect: foregroundImage.extent)
        return foregroundImage
            .applyingFilter("CIOverlayBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.35,
                "inputBrightness": 0.05,
                "inputContrast": 1.1,
            ])
    }
    
    private func apply1977Filter(ciImage: CIImage) -> CIImage? {
        let filterImage = getColorImage(
            red: 0.95, green: 0.42, blue: 0.74, alpha: 0.1, rect: ciImage.extent)
        let backgroundImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.1,
                "inputContrast": 1.05,
            ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.3,
            ])
        
        return filterImage
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
            ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.20),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.80),
                "inputPoint4": CIVector(x: 1, y: 1),
            ])
    }
    
    private func applyToasterFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 4.0, height / 4.0)
        let radius1 = min(width / 1.5, height / 1.5)
        
        let color0 = CIColor(red: 0.5, green: 0.31, blue: 0.06, alpha: 1.0)
        let color1 = CIColor(red: 0.31, green: 0.0, blue: 0.31, alpha: 1.0)
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
                "inputContrast": 1.1,
            ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": circle!,
            ])
    }
    
    private func applyArpeggioFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width, height) / 2.0 * 0.6
        let radius1 = sqrt(width * width + height * height) / 2.0 * 0.95
        let color0 = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let color1 = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        let circle1 = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1,
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        let filter = CIFilter(name: "CIPhotoEffectTransfer")!
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let newImage = filter.value(forKey: kCIOutputImageKey) as! CIImage

        return newImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.25,
                "inputBrightness": 0.05,
                "inputContrast": 1.1,
            ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.2,
            ])
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": circle1!,
            ])
    }
    
    private func applyDimmingFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width, height) / 2.0 * 0.5
        let radius1 = sqrt(width * width + height * height) / 2.0
        let color0 = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.05)
        let color1 = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let circle1 = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1,
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        let backgroundImage = getColorImage(
            red: 0.1, green: 0.25, blue: 0.52, alpha: 0.35, rect: ciImage.extent)

        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.05,
                "inputContrast": 1.2,
            ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.25,
            ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
            ])
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": circle1!,
            ])
    }
    
    private func applyTraumereiFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width, height) / 2.0 * 0.55
        let radius1 = sqrt(width * width + height * height) / 2.0

        let color0 = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let color1 = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let circle1 = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1,
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        let backgroundImage = getColorImage(
            red: 0.0, green: 0.31, blue: 0.63, alpha: 0.7, rect: ciImage.extent)

        let filter = CIFilter(name: "CILinearToSRGBToneCurve")!
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let newImage = filter.value(forKey: kCIOutputImageKey) as! CIImage

        return newImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.25,
                "inputBrightness": 0.05,
                "inputContrast": 1.15,
            ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
            ])
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": circle1!,
            ])
    }
    
}
