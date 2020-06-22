//
//  IngredientRecipeListBasic.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/11.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

struct IngredientBasic{
    var id : String
    var name : String
    var nameYomi : String
    var katakanaLowercasedNameForSearch : String
    var stockFlag : Bool
    var category : Int
    var contributionToRecipeAvailability : Int
    var usingRecipeNum : Int
    var reminderSetDate : Date?
}
