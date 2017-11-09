//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

struct RecipeBasic{
    var id : String
    var name : String
    var kanaName : String {
        return name.katakana().lowercased()
    }
    var shortageNum : Int
    var favorites: Int
    var japaneseDictionaryOrder : String
    var lastViewDate : Date?
}

