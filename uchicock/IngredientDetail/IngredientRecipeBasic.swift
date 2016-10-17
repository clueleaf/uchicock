//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

struct IngredientRecipeBasic{
    var recipeIngredientLinkId : String
    var recipeName : String
    var recipeKanaName : String {
        return recipeName.katakana().lowercased()
    }
    var shortageNum : Int
}

