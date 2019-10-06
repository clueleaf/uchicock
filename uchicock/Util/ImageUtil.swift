//
//  ImageUtil.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/09/13.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit
import RealmSwift

struct ImageUtil{
    static func saveToCache(imageFileName: String?){
        if let imageFileName = imageFileName, ImageCache.shared.object(forKey: imageFileName as NSString) == nil {
            let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(imageFileName + ".png")
            let loadedThumbnail: UIImage? = UIImage(contentsOfFile: thumbnailFilePath.path)
            if let loadedThumbnail = loadedThumbnail{
                ImageCache.shared.setObject(loadedThumbnail, forKey: imageFileName as NSString)
            }else{
                let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName + ".png")
                let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
                if let loadedImage = loadedImage{
                    ImageCache.shared.setObject(loadedImage, forKey: imageFileName as NSString)
                }
            }
        }
    }
    
    static func loadImageOf(recipeId: String, forList: Bool) -> UIImage? {
        let realm = try! Realm()
        let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeId)
        guard recipe != nil else{
            return nil
        }

        if let imageFileName = recipe!.imageFileName{
            let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName + ".png")
            let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(imageFileName + ".png")

            if forList{
                if let cachedData = ImageCache.shared.object(forKey: imageFileName as NSString) {
                    return cachedData
                }else{
                    let loadedThumbnail: UIImage? = UIImage(contentsOfFile: thumbnailFilePath.path)
                    if let loadedThumbnail = loadedThumbnail{
                        ImageCache.shared.setObject(loadedThumbnail, forKey: imageFileName as NSString)
                        return loadedThumbnail
                    }else{
                        let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
                        if let loadedImage = loadedImage{
                            ImageCache.shared.setObject(loadedImage, forKey: imageFileName as NSString)
                        }else{
                            try! realm.write{
                                recipe!.imageFileName = nil
                            }
                        }
                        return loadedImage
                    }
                }
            }else{
                let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
                if loadedImage == nil{
                    ImageCache.shared.removeObject(forKey: imageFileName as NSString)
                    try! realm.write{
                        recipe!.imageFileName = nil
                    }
                }
                return loadedImage
            }
        }else{
            return nil
        }
    }
    
    static func save(image: UIImage, toFileName imageFileName: String) -> Bool{
        let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName + ".png")
        let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(imageFileName + ".png")
        do {
            try FileManager.default.createDirectory(atPath: GlobalConstants.ImageFolderPath.path, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: GlobalConstants.ThumbnailFolderPath.path, withIntermediateDirectories: true, attributes: nil)
            // 万が一の不整合のためにキャッシュをクリアしておく
            ImageCache.shared.removeObject(forKey: imageFileName as NSString)
            try image.pngData()?.write(to: imageFilePath)
            try image.resizedUIImage(maxLongSide: GlobalConstants.ThumbnailMaxLongSide)?.pngData()?.write(to: thumbnailFilePath)
            return true
        }catch{
            return false
        }
    }
    
    static func remove(imageFileName: String?){
        if let imageFileName = imageFileName{
            ImageCache.shared.removeObject(forKey: imageFileName as NSString)
            let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName + ".png")
            try? FileManager.default.removeItem(at: imageFilePath)
            let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(imageFileName + ".png")
            try? FileManager.default.removeItem(at: thumbnailFilePath)
        }
    }
}

final class ImageCache: NSCache<NSString, UIImage> {
    static let shared = ImageCache()
    private override init() {
        super.init()
        self.countLimit = 365
    }
}
