//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

struct SampleRecipeBasic{
    var name : String
    var katakanaLowercasedNameForSearch : String
    var recoverable : Bool
    var recoverTarget : Bool
}

struct RecoverRecipe{
    var name : String
    var style: Int
    var method : Int
    var strength : Int
    var ingredientList = Array<RecipeIngredientBasic>()
}
