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
        guard let imageFileName = imageFileName, ImageCache.shared.object(forKey: imageFileName as NSString) == nil else{ return }
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
    
    static func loadImageForList(recipeId: String, imageFileName: String?) -> UIImage? {
        if imageFileName == nil { return nil }
        if let cachedData = ImageCache.shared.object(forKey: imageFileName! as NSString) {
            return cachedData
        }

        let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(imageFileName! + ".png")
        let loadedThumbnail: UIImage? = UIImage(contentsOfFile: thumbnailFilePath.path)
        if let loadedThumbnail = loadedThumbnail{
            ImageCache.shared.setObject(loadedThumbnail, forKey: imageFileName! as NSString)
            return loadedThumbnail
        }

        let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName! + ".png")
        let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
        if let loadedImage = loadedImage{
            ImageCache.shared.setObject(loadedImage, forKey: imageFileName! as NSString)
        }else{
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeId)
            guard recipe != nil else{ return nil }
            try! realm.write{
                recipe!.imageFileName = nil
            }
        }
        return loadedImage
    }
    
    static func loadImageForDetail(recipeId: String, imageFileName: String?) -> UIImage? {
        if imageFileName == nil { return nil }
        let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName! + ".png")
        
        let loadedImage: UIImage? = UIImage(contentsOfFile: imageFilePath.path)
        if loadedImage == nil{
            ImageCache.shared.removeObject(forKey: imageFileName! as NSString)
            let realm = try! Realm()
            let recipe = realm.object(ofType: Recipe.self, forPrimaryKey: recipeId)
            guard recipe != nil else{ return nil }
            try! realm.write{
                recipe!.imageFileName = nil
            }
        }
        return loadedImage
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
        guard let imageFileName = imageFileName else { return }

        ImageCache.shared.removeObject(forKey: imageFileName as NSString)
        let imageFilePath = GlobalConstants.ImageFolderPath.appendingPathComponent(imageFileName + ".png")
        try? FileManager.default.removeItem(at: imageFilePath)
        let thumbnailFilePath = GlobalConstants.ThumbnailFolderPath.appendingPathComponent(imageFileName + ".png")
        try? FileManager.default.removeItem(at: thumbnailFilePath)
    }
}

final class ImageCache: NSCache<NSString, UIImage> {
    static let shared = ImageCache()
    private override init() {
        super.init()
        self.countLimit = 750
    }
}
