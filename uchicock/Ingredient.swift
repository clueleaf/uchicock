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
    dynamic var ingredientName = ""
    dynamic var stockFlac = false
    let recipeIngredients = List<RecipeIngredient>()
    
    override class func primaryKey() -> String {
        return "ingredientName"
    }
}