//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

struct IngredientName{
    var name : String
    var kanaName : String {
        return name.katakana().lowercased()
    }
    var japaneseDictionaryOrder : String
}

