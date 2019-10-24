//
//  Ingredient.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/03/06.
//  Copyright © 2016年 Kou. All rights reserved.
//

import RealmSwift

class Ingredient: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var ingredientName = ""
    @objc dynamic var katakanaLowercasedNameForSearch = ""
    @objc dynamic var stockFlag = false
    @objc dynamic var memo = ""
    @objc dynamic var category = 2
    @objc dynamic var contributionToRecipeAvailability = 0
    var recipeIngredients = List<RecipeIngredientLink>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    func calcContribution(){
        self.contributionToRecipeAvailability = 0
        if self.stockFlag == false{
            for ri in self.recipeIngredients{
                if ri.mustFlag && ri.recipe.shortageNum == 1{
                    self.contributionToRecipeAvailability += 1
                }
            }
        }
    }
}
