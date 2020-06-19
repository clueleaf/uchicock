//
//  SimilarRecipeBasice.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-05-20.
//  Copyright © 2020 Kou. All rights reserved.
//

struct SimilarRecipeBasic{
    var id : String
    var name : String
    var isBookmarked : Bool
    var canMake : Bool
    var style : Int
    var method : Int
    var strength : Int
    var imageFileName: String?
    var point : Float
    var ingredientList = Array<SimilarRecipeIngredient>()
}

struct SimilarRecipeIngredient{
    var name : String
    var weight : Float
}
