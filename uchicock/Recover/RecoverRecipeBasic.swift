//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

class SampleRecipeBasic: NSObject {
    var name = ""
    var kanaName = ""
    var recoverable = true
    var recoverTarget = false
}

class RecoverIngredient: NSObject {
    var name = ""
    var amount = ""
    var mustflag = false
}

class RecoverRecipe: NSObject {
    var name = ""
    var method = 0
    var ingredientList = Array<RecoverIngredient>()
}
