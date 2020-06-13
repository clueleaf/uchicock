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
    var point : Float
    var method : Int
    var style : Int
    var strength : Int
    var shortageNum : Int
    var isBookmarked : Bool
    var imageFileName: String?
    var ingredientList = Array<SimilarRecipeIngredient>()
}

struct SimilarRecipeIngredient{
    var name : String
    var mustFlag : Bool
}
