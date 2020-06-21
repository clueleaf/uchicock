//
//  UIImageExtension.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/10/02.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

extension UIImage{
    func resizedUIImage(maxLongSide: CGFloat) -> UIImage? {
        if self.size.width <= maxLongSide && self.size.height <= maxLongSide {
            return self
        }
        
        let w = self.size.width / maxLongSide
        let h = self.size.height / maxLongSide
        let ratio = w > h ? w : h
        let rect = CGRect(x: 0, y: 0, width: self.size.width / ratio, height: self.size.height / ratio)
        
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizedCGImage(maxLongSide: CGFloat) -> CIImage? {
        if self.size.width <= maxLongSide && self.size.height <= maxLongSide {
            return CIImage(image: self)
        }
        
        let w = self.size.width / maxLongSide
        let h = self.size.height / maxLongSide
        let ratio = w > h ? w : h
        let matrix = CGAffineTransform(scaleX: 1/ratio, y: 1/ratio)

        return CIImage(image: self)?.transformed(by: matrix)
    }
}
