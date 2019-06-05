//
//  File.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/27.
//  Copyright © 2016年 Kou. All rights reserved.
//

extension String {
    func katakana() -> String {
        var str = ""
        for c in unicodeScalars {
            if c.value >= 0x3041 && c.value <= 0x3096 {
                if let u = UnicodeScalar(c.value+96){
                    str += "\(u)"
                }
            } else {
                str += "\(c)"
            }
        }
        return str
    }
    
    func hiragana() -> String {
        var str = ""
        for c in unicodeScalars {
            if c.value >= 0x30A1 && c.value <= 0x30F6 {
                if let u = UnicodeScalar(c.value-96){
                    str += "\(u)"
                }
            } else {
                str += "\(c)"
            }
        }
        return str
    }
    
    func categoryNumber() -> Int {
        switch self{
        case "ウォッカ": return 0
        case "テキーラ": return 0
        case "ジン": return 0
        case "ドライジン": return 0
        case "ドライ・ジン": return 0
        case "ブランデー": return 0
        case "チェリーブランデー": return 0
        case "チェリー・ブランデー": return 0
        case "ラム": return 0
        case "ホワイトラム": return 0
        case "ホワイト・ラム": return 0
        case "ダークラム": return 0
        case "ダーク・ラム": return 0
        case "ゴールドラム": return 0
        case "ゴールド・ラム": return 0
        case "ウィスキー": return 0
        case "ウイスキー": return 0
        case "バーボンウィスキー": return 0
        case "バーボン・ウィスキー": return 0
        case "バーボンウイスキー": return 0
        case "バーボン・ウイスキー": return 0
        case "アイリッシュウィスキー": return 0
        case "アイリッシュ・ウィスキー": return 0
        case "アイリッシュウイスキー": return 0
        case "アイリッシュ・ウイスキー": return 0
        case "スコッチウィスキー": return 0
        case "スコッチ・ウィスキー": return 0
        case "スコッチウイスキー": return 0
        case "スコッチ・ウイスキー": return 0
        case "カナディアンウィスキー": return 0
        case "カナディアン・ウィスキー": return 0
        case "カナディアンウイスキー": return 0
        case "カナディアン・ウイスキー": return 0
        case "アメリカンウィスキー": return 0
        case "アメリカン・ウィスキー": return 0
        case "アメリカンウイスキー": return 0
        case "アメリカン・ウイスキー": return 0
        case "テネシーウィスキー": return 0
        case "テネシー・ウィスキー": return 0
        case "テネシーウイスキー": return 0
        case "テネシー・ウイスキー": return 0
        case "ライウィスキー": return 0
        case "ライ・ウィスキー": return 0
        case "ライウイスキー": return 0
        case "ライ・ウイスキー": return 0
        case "ジャパニーズウィスキー": return 0
        case "ジャパニーズ・ウィスキー": return 0
        case "ジャパニーズウイスキー": return 0
        case "ジャパニーズ・ウイスキー": return 0
        case "アマレット": return 0
        case "オレンジキュラソー": return 0
        case "オレンジ・キュラソー": return 0
        case "ブルーキュラソー": return 0
        case "ブルー・キュラソー": return 0
        case "ホワイトキュラソー": return 0
        case "ホワイト・キュラソー": return 0
        case "コアントロー": return 0
        case "カルーア": return 0
        case "カンパリ": return 0
        case "クレームドカカオ": return 0
        case "クレーム・ド・カカオ": return 0
        case "クレームドカカオホワイト": return 0
        case "クレーム・ド・カカオ・ホワイト": return 0
        case "クレームドカシス": return 0
        case "クレーム・ド・カシス": return 0
        case "クレームドフランボワーズ": return 0
        case "クレーム・ド・フランボワーズ": return 0
        case "クレームドアプリコット": return 0
        case "クレーム・ド・アプリコット": return 0
        case "ディタ": return 0
        case "ドライベルモット": return 0
        case "ドライ・ベルモット": return 0
        case "スイートベルモット": return 0
        case "スイート・ベルモット": return 0
        case "ピーチツリー": return 0
        case "ベイリーズ": return 0
        case "マンゴヤン": return 0
        case "ミドリ": return 0
        case "ペパーミント": return 0
        case "ペパー・ミント": return 0
        case "ホワイトペパーミント": return 0
        case "ホワイト・ペパーミント": return 0
        case "ホワイト・ペパー・ミント": return 0
        case "マリブ": return 0
        case "ティフィン": return 0
        case "パッソア": return 0
        case "アンゴスチュラビターズ": return 0
        case "アンゴスチュラ・ビターズ": return 0
        case "ビール": return 0
        case "赤ワイン": return 0
        case "白ワイン": return 0
        case "ワイン": return 0
        case "シャンパン": return 0
        case "スパークリングワイン": return 0
        case "スパークリング・ワイン": return 0
        case "紹興酒": return 0
        case "日本酒": return 0
            
        case "アップルジュース": return 1
        case "アップル・ジュース": return 1
        case "オレンジジュース": return 1
        case "オレンジ・ジュース": return 1
        case "グレープジュース": return 1
        case "グレープ・ジュース": return 1
        case "グレープフルーツジュース": return 1
        case "グレープフルーツ・ジュース": return 1
        case "トマトジュース": return 1
        case "トマト・ジュース": return 1
        case "パイナップルジュース": return 1
        case "パイナップル・ジュース": return 1
        case "ライムジュース": return 1
        case "ライム・ジュース": return 1
        case "クランベリージュース": return 1
        case "クランベリー・ジュース": return 1
        case "レモンジュース": return 1
        case "レモン・ジュース": return 1
        case "コーラ": return 1
        case "コカコーラ": return 1
        case "ジンジャエール": return 1
        case "ソーダ": return 1
        case "トニックウォーター": return 1
        case "トニック・ウォーター": return 1
        case "ミネラルウォーター": return 1
        case "ミネラル・ウォーター": return 1
        case "ウーロン茶": return 1
        case "烏龍茶": return 1
        case "牛乳": return 1
        case "ミルク": return 1
        case "レモネード": return 1
        case "アイスコーヒー": return 1
        case "アイス・コーヒー": return 1
        case "ホットコーヒー": return 1
        case "ホット・コーヒー": return 1
        case "ピーチネクター": return 1
        case "ピーチ・ネクター": return 1

        default: return 2
        }
    }
}
