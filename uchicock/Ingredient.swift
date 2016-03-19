//
//  Ingredient.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/06.
//  Copyright © 2016年 Kou. All rights reserved.
//

//import Foundation
import RealmSwift

class Ingredient: Object {
    dynamic var id = NSUUID().UUIDString
    dynamic var ingredientName = ""
    dynamic var stockFlag = false
    dynamic var memo = ""
    let recipeIngredients = List<RecipeIngredient>()
    
    override class func primaryKey() -> String {
        return "id"
    }
}