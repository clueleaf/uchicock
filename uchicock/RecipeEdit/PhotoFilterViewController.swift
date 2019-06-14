//
//  PhotoFilterViewController.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/12/26.
//  Copyright © 2017年 Kou. All rights reserved.
//

import UIKit

class PhotoFilterViewController: UIViewController {

    var image : UIImage?
    var smallImage : UIImage?
    let queue = DispatchQueue(label: "queue")
    var buttonWidth:CGFloat = 100
    var buttonHeight: CGFloat = 100
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
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
        
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.tintColor = UIColor.white

        titleLabel.textColor = UIColor.white

        imageView.image = image
        if let im = image{
            smallImage = resizedImage(image: im)
        }
        
        buttonWidth = scrollView.frame.height - 20
        buttonHeight = scrollView.frame.height - 20

        self.setFilters()
    }
        
    func setFilters(){
        var xCoord: CGFloat = 10
        let yCoord: CGFloat = 10
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: self.buttonWidth, height: self.buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(PhotoFilterViewController.filterButtonTapped(sender:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 10
            filterButton.clipsToBounds = true
            
            if let smim = self.smallImage{
                if let ciim = CIImage(image: smim){
                    queue.async {
                        let filteredImage = self.filteredImage(filterNumber: i, originalImage: ciim)
                        DispatchQueue.main.async{
                            filterButton.setImage(filteredImage, for: .normal)
                            filterButton.imageView?.contentMode = .scaleAspectFill
                        }
                    }

                    xCoord +=  self.buttonWidth + gapBetweenButtons
                    if i == 0{
                        filterButton.layer.borderColor = UIColor.white.cgColor
                        filterButton.layer.borderWidth = 2.0
                    }else{
                        filterButton.layer.borderWidth = 0
                    }
                    self.scrollView.addSubview(filterButton)
                }
            }
        }
        self.scrollView.contentSize = CGSize(width: xCoord + 10, height: self.buttonHeight)
    }

    @objc func filterButtonTapped(sender: UIButton){
        let button = sender as UIButton
        guard let im = self.image else{ return }
        guard let ciim = CIImage(image: im) else{ return }
        imageView.image = filteredImage(filterNumber: button.tag, originalImage: ciim)
        
        for subview in scrollView.subviews{
            if subview is UIButton{
                let b = subview as! UIButton
                b.layer.borderWidth = 0
            }
        }
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
    }
    
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
        let maxLongSide : CGFloat = (scrollView.frame.height - 20) * 2
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
        self.performSegue(withIdentifier: "FilterFinished", sender: self)
    }

}
