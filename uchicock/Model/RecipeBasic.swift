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
    var shortageNum : Int
    var favorites: Int
    var lastViewDate : Date?
    var madeNum : Int
    var method : Int
    var style : Int
    var strength : Int
    var imageFileName: String?
    var bookmarkDate : Date?
}
