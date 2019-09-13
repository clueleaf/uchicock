//
//  ImageUtil.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/09/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

struct ImageUtil{

    private static let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    static func load(imageFileName: String?, useCache: Bool) -> UIImage? {
        if let imageFileName = imageFileName{
            if useCache, let cachedData = ImageCache.shared.object(forKey: imageFileName as NSString) {
                return cachedData
            } else {
                let imageFolderPath = documentDir.appendingPathComponent("recipeImages")
                let imageFilePath = imageFolderPath.appendingPathComponent(imageFileName + ".png")
                let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
                if let loadedImage = loadedImage{
                    ImageCache.shared.setObject(loadedImage, forKey: imageFileName as NSString)
                }
                return loadedImage
            }
        }else{
            return nil
        }
    }
    
    static func save(image: UIImage, toFileName imageFileName: String) -> Bool{
        let imageFolderPath = documentDir.appendingPathComponent("recipeImages")
        let imageFilePath = imageFolderPath.appendingPathComponent(imageFileName + ".png")
        do {
            try FileManager.default.createDirectory(atPath: imageFolderPath.path, withIntermediateDirectories: true, attributes: nil)
            try image.pngData()?.write(to: imageFilePath)
            ImageCache.shared.setObject(image, forKey: imageFileName as NSString)
            return true
        }catch{
            return false
        }
    }
    
    static func remove(imageFileName: String?) -> Bool{
        if let imageFileName = imageFileName{
            let imageFolderPath = documentDir.appendingPathComponent("recipeImages")
            let imageFilePath = imageFolderPath.appendingPathComponent(imageFileName + ".png")
            ImageCache.shared.removeObject(forKey: imageFileName as NSString)
            do{
                try FileManager.default.removeItem(at: imageFilePath)
                return true
            }catch{
                return false
            }
        }else{
            return false
        }
    }
}

final class ImageCache: NSCache<NSString, UIImage> {
    static let shared = ImageCache()
    private override init() {
        super.init()
    }
}
