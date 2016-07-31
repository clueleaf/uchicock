//
//  Recipe.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/24.
//  Copyright © 2016年 Kou. All rights reserved.
//

//import Foundation
import RealmSwift

class Recipe: Object {
    dynamic var id = NSUUID().UUIDString
    dynamic var recipeName = ""
    dynamic var favorites = 1
    dynamic var method = 0
    dynamic var memo = ""
    dynamic var imageData: NSData? = nil
    dynamic var shortageNum = 0
    let recipeIngredients = List<RecipeIngredientLink>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    func updateShortageNum(){
        var num = 0
        for ri in self.recipeIngredients{
            if ri.mustFlag && ri.ingredient.stockFlag == false {
                num += 1
            }
        }
        self.shortageNum = num
    }
    
    func fixNilImage(){
        if imageData != nil{
            if UIImage(data: imageData!) == nil{
                self.imageData = nil
            }
        }
    }
}