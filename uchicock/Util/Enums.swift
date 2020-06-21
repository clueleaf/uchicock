//
//  Enums.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-06-21.
//  Copyright © 2020 Kou. All rights reserved.
//

enum RecipeSortType {
    case name
    
    case makeableName
    case makeableMadenumName
    case makeableFavoriteName
    case makeableViewdName

    case madenumName
    case madenumMakeableName
    case madenumFavoriteName
    case madenumViewedName

    case favoriteName
    case favoriteMakeableName
    case favoriteMadenumName
    case favoriteViewedName
    
    case viewedName
}

enum RecipeIngredientEditType {
    case add
    case edit
    case remove
    case cancel
}
