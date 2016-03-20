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
    let recipeIngredients = List<RecipeIngredientLink>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
}