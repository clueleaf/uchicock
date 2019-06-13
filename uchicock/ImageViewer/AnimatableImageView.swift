//
//  AnimatableImageView.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

class AnimatableImageView: UIView {
    let imageView = UIImageView()
    
    override var contentMode: UIView.ContentMode {
        didSet { update() }
    }
    
    override var frame: CGRect {
        didSet { update() }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            update()
        }
    }
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(imageView)
        imageView.contentMode = .scaleToFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        guard let image = image else { return }
        
        switch contentMode {
        case .scaleToFill:
            imageView.bounds = ImageViewerUtil.rect(forSize: bounds.size)
            imageView.center = ImageViewerUtil.center(forSize: bounds.size)
        case .scaleAspectFit:
            imageView.bounds = ImageViewerUtil.aspectFitRect(forSize: image.size, insideRect: bounds)
            imageView.center = ImageViewerUtil.center(forSize: bounds.size)
        case .scaleAspectFill:
            imageView.bounds = ImageViewerUtil.aspectFillRect(forSize: image.size, insideRect: bounds)
            imageView.center = ImageViewerUtil.center(forSize: bounds.size)
        case .redraw:
            imageView.bounds = ImageViewerUtil.aspectFillRect(forSize: image.size, insideRect: bounds)
            imageView.center = ImageViewerUtil.center(forSize: bounds.size)
        case .center:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.center(forSize: bounds.size)
        case .top:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.centerTop(forSize: image.size, insideSize: bounds.size)
        case .bottom:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.centerBottom(forSize: image.size, insideSize: bounds.size)
        case .left:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.centerLeft(forSize: image.size, insideSize: bounds.size)
        case .right:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.centerRight(forSize: image.size, insideSize: bounds.size)
        case .topLeft:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.topLeft(forSize: image.size, insideSize: bounds.size)
        case .topRight:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.topRight(forSize: image.size, insideSize: bounds.size)
        case .bottomLeft:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.bottomLeft(forSize: image.size, insideSize: bounds.size)
        case .bottomRight:
            imageView.bounds = ImageViewerUtil.rect(forSize: image.size)
            imageView.center = ImageViewerUtil.bottomRight(forSize: image.size, insideSize: bounds.size)
        default:
            break
        }
    }
}
