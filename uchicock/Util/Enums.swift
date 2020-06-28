//
//  Enums.swift
//  uchicock
//
//  Created by Kou Kinyo on 2020-06-21.
//  Copyright © 2020 Kou. All rights reserved.
//

enum RecipeSortType: String {
    case name = "名前順"
    
    case makeableName = "作れる順 > 名前順"
    case makeableMadenumName = "作れる順 > 作った回数順"
    case makeableFavoriteName = "作れる順 > お気に入り順"
    case makeableViewdName = "作れる順 > 最近見た順"

    case madenumName = "作った回数順 > 名前順"
    case madenumMakeableName = "作った回数順 > 作れる順"
    case madenumFavoriteName = "作った回数順 > お気に入り順"
    case madenumViewedName = "作った回数順 > 最近見た順"

    case favoriteName = "お気に入り順 > 名前順"
    case favoriteMakeableName = "お気に入り順 > 作れる順"
    case favoriteMadenumName = "お気に入り順 > 作った回数順"
    case favoriteViewedName = "お気に入り順 > 最近見た順"
    
    case viewedName = "最近見た順"
    
    static func from(primary: Int, secondary: Int) -> RecipeSortType {
          switch (primary, secondary) {
          case let (primary, _) where primary == 1: return .name
          case let (primary, secondary) where primary == 2 && secondary == 1: return .makeableName
          case let (primary, secondary) where primary == 2 && secondary == 3: return .makeableMadenumName
          case let (primary, secondary) where primary == 2 && secondary == 4: return .makeableFavoriteName
          case let (primary, secondary) where primary == 2 && secondary == 5: return .makeableViewdName
          case let (primary, _) where primary == 2: return .makeableName
          case let (primary, secondary) where primary == 3 && secondary == 1: return .madenumName
          case let (primary, secondary) where primary == 3 && secondary == 2: return .madenumMakeableName
          case let (primary, secondary) where primary == 3 && secondary == 4: return .madenumFavoriteName
          case let (primary, secondary) where primary == 3 && secondary == 5: return .madenumViewedName
          case let (primary, _) where primary == 3: return .madenumName
          case let (primary, secondary) where primary == 4 && secondary == 1: return .favoriteName
          case let (primary, secondary) where primary == 4 && secondary == 2: return .favoriteMakeableName
          case let (primary, secondary) where primary == 4 && secondary == 3: return .favoriteMadenumName
          case let (primary, secondary) where primary == 4 && secondary == 5: return .favoriteViewedName
          case let (primary, _) where primary == 4: return .favoriteName
          case let (primary, _) where primary == 5: return .viewedName
          default: return .name
        }
    }
}

enum RecipeStyleType : String{
    case long = "ロング"
    case short = "ショート"
    case hot = "ホット"
    case none = "未指定"
    
    static func fromInt(number: Int) -> RecipeStyleType {
             switch number {
             case 0: return .long
             case 1: return .short
             case 2: return .hot
             default: return .none
        }
    }
    
    static func isNotUndefined(number: Int) -> Bool{
        return [0,1,2].contains(number)
    }
}

enum RecipeMethodType : String{
    case build = "ビルド"
    case stir = "ステア"
    case shake = "シェイク"
    case blend = "ブレンド"
    case others = "その他"
    
    static func fromInt(number: Int) -> RecipeMethodType {
             switch number {
             case 0: return .build
             case 1: return .stir
             case 2: return .shake
             case 3: return .blend
             default: return .others
        }
    }
    
    static func isNotOthers(number: Int) -> Bool{
        return [0,1,2,3].contains(number)
    }
}

enum RecipeStrengthType : String{
    case nonAlcohol = "ノンアルコール"
    case weak = "弱い"
    case medium = "やや強い"
    case strong = "強い"
    case none = "未指定"
    
    static func fromInt(number: Int) -> RecipeStrengthType {
             switch number {
             case 0: return .nonAlcohol
             case 1: return .weak
             case 2: return .medium
             case 3: return .strong
             default: return .none
        }
    }
    
    static func isNotUndefined(number: Int) -> Bool{
        return [0,1,2,3].contains(number)
    }
}

enum IngredientCategoryType : String{
    case alcohol = "アルコール"
    case nonAlcohol = "ノンアルコール"
    case others = "その他"
    
    static func fromInt(number: Int) -> IngredientCategoryType {
             switch number {
             case 0: return .alcohol
             case 1: return .nonAlcohol
             default: return .others
        }
    }
    
    static func isAlcohol(number: Int) -> Bool{
        return number == 0
    }
}

enum ThemeColorType : String, CaseIterable{
    case tequilaSunriseLight = "テキーラサンライズ - ライト"
    case tequilaSunriseDark = "テキーラサンライズ - ダーク"
    case seaBreezeLight = "シーブリーズ - ライト"
    case seaBreezeDark = "シーブリーズ - ダーク"
    case chinaBlueLight = "チャイナブルー - ライト"
    case chinaBlueDark = "チャイナブルー - ダーク"
    case grasshopperLight = "グラスホッパー - ライト"
    case irishCoffeeDark = "アイリッシュコーヒー - ダーク"
    case mojitoLight = "モヒート - ライト"
    case redEyeLight = "レッドアイ - ライト"
    case cubaLibreDark = "キューバリバー - ダーク"
    case silverWingLight = "シルバーウィング - ライト"
    case americanLemonadeDark = "アメリカンレモネード - ダーク"
    case blueLagoonLight = "ブルーラグーン - ライト"
    case blueLagoonDark = "ブルーラグーン - ダーク"
    case mimosaLight = "ミモザ - ライト"
    case mimosaDark = "ミモザ - ダーク"
    case pinkLadyLight = "ピンクレディ - ライト"
    case pinkLadyDark = "ピンクレディ - ダーク"
    case blackRussianDark = "ルシアンブラック - ダーク"
    case shoyoJulingLight = "照葉樹林 - ライト"
    case shoyoJulingDark = "照葉樹林 - ダーク"
    case unionJackLight = "ユニオンジャック - ライト"
    case unionJackDark = "ユニオンジャック - ダーク"
    case blueMoonLight = "ブルームーン - ライト"
    case bloodyMaryDark = "ブラッディメアリー - ダーク"
    
    static func fromString(_ no: String) -> ThemeColorType {
        switch no{
        case "0": return .tequilaSunriseLight
        case "1": return .tequilaSunriseDark
        case "2": return .seaBreezeLight
        case "3": return .seaBreezeDark
        case "4": return .chinaBlueLight
        case "5": return .chinaBlueDark
        case "6": return .grasshopperLight
        case "7": return .irishCoffeeDark
        case "8": return .mojitoLight
        case "9": return .redEyeLight
        case "10": return .cubaLibreDark
        case "11": return .silverWingLight
        case "12": return .americanLemonadeDark
        case "13": return .blueLagoonLight
        case "14": return .blueLagoonDark
        case "15": return .mimosaLight
        case "16": return .mimosaDark
        case "17": return .pinkLadyLight
        case "18": return .pinkLadyDark
        case "19": return .blackRussianDark
        case "20": return .shoyoJulingLight
        case "21": return .shoyoJulingDark
        case "22": return .unionJackLight
        case "23": return .unionJackDark
        case "24": return .blueMoonLight
        case "25": return .bloodyMaryDark
        default: return .mimosaDark
        }
    }
    
    static func toInt(from theme: ThemeColorType) -> Int {
        switch theme{
        case .tequilaSunriseLight: return 0
        case .tequilaSunriseDark: return 1
        case .seaBreezeLight: return 2
        case .seaBreezeDark: return 3
        case .chinaBlueLight: return 4
        case .chinaBlueDark: return 5
        case .grasshopperLight: return 6
        case .irishCoffeeDark: return 7
        case .mojitoLight: return 8
        case .redEyeLight: return 9
        case .cubaLibreDark: return 10
        case .silverWingLight: return 11
        case .americanLemonadeDark: return 12
        case .blueLagoonLight: return 13
        case .blueLagoonDark: return 14
        case .mimosaLight: return 15
        case .mimosaDark: return 16
        case .pinkLadyLight: return 17
        case .pinkLadyDark: return 18
        case .blackRussianDark: return 19
        case .shoyoJulingLight: return 20
        case .shoyoJulingDark: return 21
        case .unionJackLight: return 22
        case .unionJackDark: return 23
        case .blueMoonLight: return 24
        case .bloodyMaryDark: return 25
        }
    }
}

enum RecipeIngredientEditType {
    case add
    case edit
    case remove
    case cancel
}
