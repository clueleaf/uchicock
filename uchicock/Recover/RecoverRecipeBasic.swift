//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

struct SampleRecipeBasic{
    var name : String
    var kanaName : String{
        return name.katakana().lowercased()
    }
    var recoverable : Bool
    var recoverTarget : Bool
    var japaneseDictionaryOrder : String
}

struct RecoverIngredient{
    var name : String
    var amount : String
    var mustflag : Bool
}

struct RecoverRecipe{
    var name : String
    var method : Int
    var ingredientList = Array<RecoverIngredient>()
}
