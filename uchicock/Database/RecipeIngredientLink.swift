//
//  RecipeIngredient.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/06.
//  Copyright © 2016年 Kou. All rights reserved.
//

import RealmSwift

class RecipeIngredientLink: Object {
    @objc dynamic var id = NSUUID().uuidString
    let recipes = LinkingObjects(fromType: Recipe.self, property: "recipeIngredients")
    var recipe: Recipe {
        return recipes.first!
    }
    let ingredients = LinkingObjects(fromType: Ingredient.self, property: "recipeIngredients")
    var ingredient: Ingredient {
        return ingredients.first!
    }
    @objc dynamic var amount = ""
    @objc dynamic var mustFlag = false
    @objc dynamic var displayOrder : String? = nil

    override class func primaryKey() -> String {
        return "id"
    }

}

