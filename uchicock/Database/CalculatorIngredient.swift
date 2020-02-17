//
//  CalculatorIngredient.swift
//  uchicock
//
//  Created by Kou Kinyo on 2/16/20.
//  Copyright © 2020 Kou. All rights reserved.
//

import RealmSwift

class CalculatorIngredient: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var degree = 0
    @objc dynamic var amount = 0
    @objc dynamic var valid = false
    
    override class func primaryKey() -> String {
        return "id"
    }

}

