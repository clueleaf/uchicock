//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

struct SampleRecipeBasic{
    var name = ""
    var kanaName = ""
    var recoverable = true
    var recoverTarget = false
}

struct RecoverIngredient{
    var name = ""
    var amount = ""
    var mustflag = false
}

struct RecoverRecipe{
    var name = ""
    var method = 0
    var ingredientList = Array<RecoverIngredient>()
}
