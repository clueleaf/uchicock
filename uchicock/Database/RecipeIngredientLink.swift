//
//  RecipeIngredient.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/06.
//  Copyright © 2016年 Kou. All rights reserved.
//

//import Foundation
import RealmSwift

class RecipeIngredientLink: Object {
    dynamic var id = NSUUID().UUIDString
    var recipe: Recipe {
        return linkingObjects(Recipe.self, forProperty: "recipeIngredients").first!
    }
    var ingredient: Ingredient {
        return linkingObjects(Ingredient.self, forProperty: "recipeIngredients").first!
    }
    dynamic var amount = ""
    dynamic var mustFlag = false
    
    override class func primaryKey() -> String {
        return "id"
    }

}