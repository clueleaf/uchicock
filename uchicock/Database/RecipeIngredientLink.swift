//
//  RecipeIngredient.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/06.
//  Copyright © 2016年 Kou. All rights reserved.
//

import RealmSwift

class RecipeIngredientLink: Object {
    dynamic var id = NSUUID().uuidString
    let recipes = LinkingObjects(fromType: Recipe.self, property: "recipeIngredients")
    var recipe: Recipe {
        return recipes.first!
    }
    let ingredients = LinkingObjects(fromType: Ingredient.self, property: "recipeIngredients")
    var ingredient: Ingredient {
        return ingredients.first!
    }
    dynamic var amount = ""
    dynamic var mustFlag = false
    
    override class func primaryKey() -> String {
        return "id"
    }

}

