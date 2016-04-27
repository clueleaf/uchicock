//
//  uchicockTests.swift
//  uchicockTests
//
//  Created by Kou Kinyo on 2016/02/20.
//  Copyright © 2016年 Kou. All rights reserved.
//

import Quick
import Nimble
import ChameleonFramework
@testable import uchicock

class recipeListTests: QuickSpec {    
    override func spec() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        describe("RecipeListの初期化") {
            it("segmentedControlの背景色がFlatSand") {
                let recipeList = storyboard.instantiateViewControllerWithIdentifier("RecipeList") as! RecipeListViewController
                recipeList.loadView()
                recipeList.viewDidLoad()
                expect(recipeList.segmentedControlContainer.backgroundColor).to(equal(FlatSand()))
            }
            
        }
    }
}
