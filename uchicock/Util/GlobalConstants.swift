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
    static let RecipeImagesDirectory = "recipeImages"
    static let RecipeThumbnailsDirectory = "recipeThumbnails"
    static let ImageFolderPath = GlobalConstants.DocumentDir.appendingPathComponent(GlobalConstants.RecipeImagesDirectory)
    static let ThumbnailFolderPath = GlobalConstants.DocumentDir.appendingPathComponent(GlobalConstants.RecipeThumbnailsDirectory)

    // MARK: - Database Version
    static let RealmSchemaVersion: UInt64 = 12
    
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
    static let FilterNonAlcoholKey = "filter-nonalcohol"
    static let FilterWeakKey = "filter-weak"
    static let FilterMediumKey = "filter-medium"
    static let FilterStrongKey = "filter-strong"
    static let FilterStrengthNoneKey = "filter-strengthnone"

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
    static let RecipeFilterNonAlcoholKey = "recipe-filter-nonalcohol"
    static let RecipeFilterWeakKey = "recipe-filter-weak"
    static let RecipeFilterMediumKey = "recipe-filter-medium"
    static let RecipeFilterStrongKey = "recipe-filter-strong"
    static let RecipeFilterStrengthNoneKey = "recipe-filter-strengthnone"

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
    static let ReverseLookupFilterNonAlcoholKey = "reverse-lookup-filter-nonalcohol"
    static let ReverseLookupFilterWeakKey = "reverse-lookup-filter-weak"
    static let ReverseLookupFilterMediumKey = "reverse-lookup-filter-medium"
    static let ReverseLookupFilterStrongKey = "reverse-lookup-filter-strong"
    static let ReverseLookupFilterStrengthNoneKey = "reverse-lookup-filter-strengthnone"
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
    static let AlbumFilterNonAlcoholKey = "album-filter-nonalcohol"
    static let AlbumFilterWeakKey = "album-filter-weak"
    static let AlbumFilterMediumKey = "album-filter-medium"
    static let AlbumFilterStrongKey = "album-filter-strong"
    static let AlbumFilterStrengthNoneKey = "album-filter-strengthnone"
    
    // MARK: - Alcohol Calc Keys
    static let AlcoholDecompositionWeightKey = "AlcoholDecompositionWeight"

    // MARK: - Introduction Descriptions
    static let IntroductionDescriptionThanks = "ダウンロードありがとうございます！\n「うちカク！」はあなたのおうちカクテルライフを強力にサポートするアプリです。\n\nこれから簡単に使い方を説明します。\nこの説明は後からでも確認できるので飛ばしていただいても構いません。"
    static let IntroductionAboutThisApp = "ダウンロードしていただき、本当にありがとうございます！\n\nこのアプリは収益目的で作られたものではなく、全機能を無料で利用できます。\n\nそれゆえ、レシピの画像が最初からついてなかったり、作り方の説明が不足していると感じるかもしれませんが、インターネット上などの情報で補完していただければと思います。\n\n全ての要望を実現することはできませんが、レシピを編集できる柔軟さと使いやすさにこだわって作りました。このアプリがみなさんのおうちカクテルライフをより楽しくできれば、これに勝る喜びはありません。\n\n製作者"
    static let IntroductionDescriptionRecipe = "レシピの検索や新規登録はこの画面から。\nサンプルレシピですら、編集して自前でアレンジ可能！\nカクテルを作ったらぜひ写真を登録してみよう！"
    static let IntroductionDescriptionIngredient = "ワンタップで材料の在庫を登録できます。\n在庫を登録すると、今の手持ちで作れるレシピがわかります。\nアルコールを含む材料は、わかりやすいように名前の横に瓶のマークが付いています。"
    static let IntroductionDescriptionReverseLookup = "3つまで材料を指定して、それらをすべて使うレシピを逆引きできます。\n「赤ワインとジンジャエールを使うカクテル何だっけ？」\n「テキーラベースのカクテルを絞り込み検索したい！」\nそんなときに活用しよう！"
    static let IntroductionDescriptionAlbum = "アプリに登録されているレシピの写真だけを取り出して表示します。\n表示順をシャッフルして、気まぐれにカクテルを選んでみては？"
    
    // MARK: - Image
    static let ThumbnailMaxLongSide: CGFloat = 512
    static let MiddleImageMaxLongSide: CGFloat = 1080
    static let LargeImageMaxLongSide: CGFloat = 2160
    
    // MARK: - Setting Keys
    static let ColorThemeKey = "Theme"
    static let SaveImageSizeKey = "ImageSize"
    static let AlreadyWrittenReviewKey = "AlreadyWrittenReview"
    static let Version73NewRecipeViewedKey = "Version73NewRecipeViewed"
}
