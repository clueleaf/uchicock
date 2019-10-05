//
//  GlobalConstants.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/10/02.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

struct GlobalConstants{
    // MARK: - File Manager
    static let DocumentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static let ImageFolderPath = GlobalConstants.DocumentDir.appendingPathComponent(GlobalConstants.RecipeImagesDirectory)

    // MARK: - Database Version
    static let RealmSchemaVersion: UInt64 = 8
    
    // MARK: - Launch Management Keys
    static let FirstLaunchKey = "firstLaunch"
    static let FirstRequestReviewKey = "FirstRequestReview"
    static let LaunchCountAfterReviewKey = "LaunchCountAfterReview"
    static let LaunchDateAfterReviewKey = "LaunchDateAfterReview"

    // MARK: - Database Correction Keys
    static let Version22CorrectedKey = "corrected_v2.2"
    static let Version23CorrectedKey = "corrected_v2.3"
    static let Version32CorrectedKey = "corrected_v3.2"
    static let Version41CorrectedKey = "corrected_v4.1"
    
    // MARK: - Recipe Search General Keys
    static let SortPrimaryKey = "sort-primary"
    static let SortSecondaryKey = "sort-secondary"
    static let FilterStar0Key = "filter-star0"
    static let FilterStar1Key = "filter-star1"
    static let FilterStar2Key = "filter-star2"
    static let FilterStar3Key = "filter-star3"
    static let FilterLongKey = "filter-long"
    static let FilterShortKey = "filter-short"
    static let FilterHotKey = "filter-hot"
    static let FilterStyleNoneKey = "filter-stylenone"
    static let FilterBuildKey = "filter-build"
    static let FilterStirKey = "filter-stir"
    static let FilterShakeKey = "filter-shake"
    static let FilterBlendKey = "filter-blend"
    static let FilterOthersKey = "filter-others"
    
    // MARK: - Recipe Search Keys
    static let RecipeSortPrimaryKey = "recipe-sort-primary"
    static let RecipeSortSecondaryKey = "recipe-sort-secondary"
    static let RecipeFilterStar0Key = "recipe-filter-star0"
    static let RecipeFilterStar1Key = "recipe-filter-star1"
    static let RecipeFilterStar2Key = "recipe-filter-star2"
    static let RecipeFilterStar3Key = "recipe-filter-star3"
    static let RecipeFilterLongKey = "recipe-filter-long"
    static let RecipeFilterShortKey = "recipe-filter-short"
    static let RecipeFilterHotKey = "recipe-filter-hot"
    static let RecipeFilterStyleNoneKey = "recipe-filter-stylenone"
    static let RecipeFilterBuildKey = "recipe-filter-build"
    static let RecipeFilterStirKey = "recipe-filter-stir"
    static let RecipeFilterShakeKey = "recipe-filter-shake"
    static let RecipeFilterBlendKey = "recipe-filter-blend"
    static let RecipeFilterOthersKey = "recipe-filter-others"
    
    // MARK: - Reverse Lookup Search Keys
    static let ReverseLookupSortPrimaryKey = "reverse-lookup-sort-primary"
    static let ReverseLookupSortSecondaryKey = "reverse-lookup-sort-secondary"
    static let ReverseLookupFilterStar0Key = "reverse-lookup-filter-star0"
    static let ReverseLookupFilterStar1Key = "reverse-lookup-filter-star1"
    static let ReverseLookupFilterStar2Key = "reverse-lookup-filter-star2"
    static let ReverseLookupFilterStar3Key = "reverse-lookup-filter-star3"
    static let ReverseLookupFilterLongKey = "reverse-lookup-filter-long"
    static let ReverseLookupFilterShortKey = "reverse-lookup-filter-short"
    static let ReverseLookupFilterHotKey = "reverse-lookup-filter-hot"
    static let ReverseLookupFilterStyleNoneKey = "reverse-lookup-filter-stylenone"
    static let ReverseLookupFilterBuildKey = "reverse-lookup-filter-build"
    static let ReverseLookupFilterStirKey = "reverse-lookup-filter-stir"
    static let ReverseLookupFilterShakeKey = "reverse-lookup-filter-shake"
    static let ReverseLookupFilterBlendKey = "reverse-lookup-filter-blend"
    static let ReverseLookupFilterOthersKey = "reverse-lookup-filter-others"
    static let ReverseLookupFirstIngredientKey = "ReverseLookupFirst"
    static let ReverseLookupSecondIngredientKey = "ReverseLookupSecond"
    static let ReverseLookupThirdIngredientKey = "ReverseLookupThird"
    
    // MARK: - Album Filter Keys
    static let AlbumFilterStar0Key = "album-filter-star0"
    static let AlbumFilterStar1Key = "album-filter-star1"
    static let AlbumFilterStar2Key = "album-filter-star2"
    static let AlbumFilterStar3Key = "album-filter-star3"
    static let AlbumFilterLongKey = "album-filter-long"
    static let AlbumFilterShortKey = "album-filter-short"
    static let AlbumFilterHotKey = "album-filter-hot"
    static let AlbumFilterStyleNoneKey = "album-filter-stylenone"
    static let AlbumFilterBuildKey = "album-filter-build"
    static let AlbumFilterStirKey = "album-filter-stir"
    static let AlbumFilterShakeKey = "album-filter-shake"
    static let AlbumFilterBlendKey = "album-filter-blend"
    static let AlbumFilterOthersKey = "album-filter-others"

    // MARK: - Introduction Descriptions
    static let IntroductionDescriptionThanks = "ダウンロードしていただき、ありがとうございます！\n使い方を簡単に説明します。\n\n※この説明は後からでも確認できます。"
    static let IntroductionDescriptionRecipe = "レシピの検索や新規登録はこの画面から。\nサンプルレシピですら、編集して自前でアレンジ可能！\nカクテルをつくったらぜひ写真を登録してみよう！"
    static let IntroductionDescriptionIngredient = "ワンタップで材料の在庫を登録できます。\n在庫を登録すると、今の手持ちで作れるレシピがわかります。"
    static let IntroductionDescriptionReverseLookup = "3つまで材料を指定して、それらをすべて使うレシピを逆引きできます。\n「あの材料とあの材料を使うカクテル何だっけ？」\nそんなときに活用しよう！"
    static let IntroductionDescriptionAlbum = "アプリに登録されているレシピの写真だけを取り出して表示します。\n表示順をシャッフルして、気まぐれにカクテルを選んでみては？"
    
    // MARK: - Directory
    static let RecipeImagesDirectory = "recipeImages"
    
    // MARK: - Image
    static let ImageMaxLongSide: CGFloat = 1024
}
