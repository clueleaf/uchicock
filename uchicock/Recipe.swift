//
//  Recipe.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/02/24.
//  Copyright © 2016年 Kou. All rights reserved.
//

//import Foundation
import RealmSwift

class Recipe: Object {
    dynamic var recipeName = ""
    dynamic var favorites = 2
    dynamic var method = 0
    dynamic var procedure = ""
    dynamic var memo = ""
    //RecipeIngredientへの関係を追加
    
//    override class func primaryKey() -> String {
//        return "recipeName"
//    }
    
}