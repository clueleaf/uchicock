//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

struct RecipeBasic{
    var id : String
    var name : String
    var nameYomi : String
    var katakanaLowercasedNameForSearch : String
    var bookmarkDate : Date?
    var shortageNum : Int
    var shortageIngredientName: String?
    var lastViewDate : Date?
    var favorites: Int
    var style : Int
    var method : Int
    var strength : Int
    var madeNum : Int
    var imageFileName: String?
}
